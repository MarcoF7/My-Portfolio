/*** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***/

/* PROGRAMA: Importar_Tipo_De_Cambio.sas
/* OBJETIVO: Carga el fichero con la informacion del tipo de cambio de la fecha de datos
/* AUTOR:	 Management Solutions
/* PROCESO:  Se importa el fichero de tipo de cambio.

/*
/* 			 
/* FECHA: 11/09/2015
/*
/* ...
/*** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***/

* Se importa la tabla de tipos de cambio por Divisa;
/*%let Nombre_Logico_Input = Tipo_De_Cambio;*/

* Se busca la ruta física en la tabla "FICHEROS_INPUT";
/*data _null_;*/
/*	set FICHEROS_INPUT;*/
/**/
/*	if Nombre_Logico_Fichero = "&Nombre_Logico_Input." then*/
/*		do;*/
/*			call symput('Ruta_input_a_cargar', trim(Ruta));*/
/*		end;*/
/*run;*/

/*%borrarTabla(&biblioteca..Tipo_De_Cambio_Prev);*/
/*%put "&dir_ficheros_orig.&Ruta_input_a_cargar.";*/
/**/
/*%put &dir_ficheros_orig.&Ruta_input_a_cargar.;*/


/*data &biblioteca..Tipo_De_Cambio_Prev;*/
/*	infile "&dir_ficheros_orig.&Ruta_input_a_cargar." lrecl=4096;*/
/*	INPUT*/
/**/
/*		@1 Fecha $8.*/
/**/
/*		@11 Divisa $3.*/
/**/
/*		@16 Tipo_Cambio 14.8;*/
/*run;*/

* Se crea la fecha del ultimo dia de mes para poder filtrar;
/*data &biblioteca..Tipo_De_Cambio_Format_prev;*/
/*	set &biblioteca..Tipo_De_Cambio_Prev;*/
/*	Fecha_Inicio_Reporte = "&fechaReporte" || "01";*/
/*	Fecha_Formateada = input(Fecha_Inicio_Reporte, yymmdd8.);*/
/*	Fecha_Ultimo_Dia_Mes = intnx('month',Fecha_Formateada,1)-1;*/
/*	Fecha_Ultimo_Dia_Mes_text = put (Fecha_Ultimo_Dia_Mes, ddmmyyn8.);*/
/*	Fecha_Ultimo_Dia_Mes_Final = substr(Fecha_Ultimo_Dia_Mes_text, 5, 4) || substr(Fecha_Ultimo_Dia_Mes_text, 3, 2) || substr(Fecha_Ultimo_Dia_Mes_text, 1, 2);*/
/*	drop Fecha_Inicio_Reporte Fecha_Formateada Fecha_Ultimo_Dia_Mes Fecha_Ultimo_Dia_Mes_text;*/
/*run;*/

* Se recoge el tipo de cambio del ultimo dia del mes;
/*proc sql;*/
/*	create table &biblioteca..Tipo_De_Cambio (drop=Fecha*/
/*		Fecha_Ultimo_Dia_Mes_Final) as */
/*	select    distinct **/
/*		from &biblioteca..Tipo_De_Cambio_Format_prev*/
/*			where Fecha = Fecha_Ultimo_Dia_Mes_Final;*/
/*quit;*/


* Se añade una columna con el tipo de cambio preparado para transformar Euros;
proc sql;
	create table Tipo_De_Cambio as select
		a.*, a.Tipo_Cambio/b.Tipo_Cambio as Tipo_Cambio_Eur
	from &bibliotecaInputs..Tipo_De_Cambio a, (select * from &bibliotecaInputs..Tipo_De_Cambio where Divisa="EUR") b;
quit;


/*Tipo de cambio euros con la fecha de cierre del reporte con el formato para calcular el tipo
de cambio ponderado*/
proc sql;
	create table &biblioteca..Tipo_Cambio_Fec_Rep as 
	select *
		from &bibliotecainputs..Tipo_De_Cambio_Prev
			where (substr(fecha,1,6)="&FechaReporte." AND Divisa = "EUR");
quit;



/******************CALCULO DEL TIPO DE CAMBIO EUR-PEN MEDIO ANUAL****************/


%Macro Tipo_Cambio_Promedio;


	/*Lista de Inventarios MIS de todo el periodo de ejecución*/
	PROC IMPORT OUT=&biblioteca..Lista_Tipo_Cambio
		DATAFILE="&dir_ficheros_orig.&fichero_listado_inputs."
		DBMS=xlsx replace;
		getnames=yes;
		sheet="Historia_TipCamb";
	RUN; 

	/*Se unifican todos los Tipo de Cambio dentro del periodo de ejecucion*/


    /*imho good practice to declare macro variables of a macro locally*/
    %local datasetCount iter inElemento inPeriodo;

    /*get number of datasets*/
    proc sql noprint;
        select count(*)
         into :datasetCount
        from &biblioteca..Lista_Tipo_Cambio;
    quit;

    /*initiate loop*/
    %let iter=1;
    %do %while (&iter.<= &datasetCount.);
        /*get libref and dataset name for dataset you will work on during this iteration*/
        data _NULL_;
            set &biblioteca..Lista_Tipo_Cambio (firstobs=&iter. obs=&iter.); *only read 1 record;
            *write the libname and dataset name to the macro variables;
            call symput("inElemento",strip(Elemento_orden_actualidad));
            *NOTE: i am always mortified by the chance of trailing blanks torpedoing my code, hence the strip function;
			call symput("inPeriodo",strip(Periodo));
        run;



		/*Se carga el Tipo de Cambio*/
		data &biblioteca..Tipo_Cambio_Period_prev;
			infile "&dir_ficheros_orig.&inElemento." lrecl=4096;
			INPUT

				@1 Fecha $8.

				@11 Divisa $3.

				@16 Tipo_Cambio 14.8;
		run;

		/*Se seleccionan los campos de interes*/
		proc sql;
			create table &biblioteca..Tipo_Cambio_Period as 
			select *
				from &biblioteca..Tipo_Cambio_Period_prev
					where (substr(fecha,1,6)="&inPeriodo." AND Divisa = "EUR");
		quit;



		/*La primera iteracion toma como base el Tipo de Cambio del ultimo mes
		del periodo del reporte*/
		%if (&iter. = 1) %then
			%do;
				data &biblioteca..Tipo_Cambio_Unific;
				set &biblioteca..Tipo_Cambio_Fec_Rep &biblioteca..Tipo_Cambio_Period;
				run;
			%end;
		/*Las siguientes iteraciones toman de 1 en 1 los meses anteriores
		dentro del periodo de reporte*/
		%else
			%do;
				data &biblioteca..Tipo_Cambio_Unific;
				set &biblioteca..Tipo_Cambio_Unific &biblioteca..Tipo_Cambio_Period;
				run;
			%end;


        /*increment the iterator of the loop*/
        %let iter=%eval(&iter.+1);
    %end;

%mend Tipo_Cambio_Promedio;


/* 
&biblioteca..Tipo_Cambio_Unific -> Tipos de Cambio de todos los meses dentro del 
periodo de reporte unificados 
*/

%Tipo_Cambio_Promedio;

/*Ahora que se tiene el tipo de cambio de todos los dias de todos los meses del periodo de ejecucion,
se calcula el promedio para poder contravalorar el Margen Financiero acumulado*/
proc sql;
	create table &biblioteca..Tipo_Cambio_Prom1 as
		select avg(Tipo_Cambio) as Tipo_Cambio_Prom
			from &biblioteca..Tipo_Cambio_Unific;
quit;

/*Se guarda el Tipo de Cambio Promedio*/
data _null_;
set &biblioteca..Tipo_Cambio_Prom1;

	call symput('Tipo_Cambio_Prom', Tipo_Cambio_Prom);

run;