/*** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***/

/* PROGRAMA: Importar_Inventarios6.sas
/* OBJETIVO: Cargar los inventarios6 de todos los meses del periodo de reporte
/*			 para poder enriquecer las operativas no vivas
/* AUTOR:	 Management Solutions
/* PROCESO:  Se realiza la importación de todos los inventarios 6 del periodo
/*           de reporte y se unifican en una sola tabla
/* 			 CONJUNTOS DE DATOS GENERADOS:
/* 			 - ...
/* 			 - ...
/*
/* FECHA: 16/03/2018
/*
/* NOTAS: ...
/*
/* LOG DE CAMBIOS:
/* FECHA	AUTOR	Objetivo
/* ...
/*** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***/


%let Nombre_Logico_Input = Lib_Inv6;

data _NULL_;
	set FICHEROS_INPUT;

	if Nombre_Logico_Fichero = "&Nombre_Logico_Input" then do;
		call symput('Ruta_Inv6', trim(Ruta));
	end;

run;


/*libreria destino de los Inventarios 6 no vivas:
Esta es la ruta donde se tendra los Inventarios 6 no vivas, 
En esta ruta se hara la pregunta si ya existe dicho archivo antes de crearlo
para ahorrar tiempo de procesamiento*/
LIBNAME Inv6_lb "&dir_ficheros_orig.&Ruta_Inv6";


* Se asigna el nombre lógico del fichero;
%let Nombre_Logico_Input = Inv6;

* Se busca la ruta física en la tabla "FICHEROS_INPUT";
data _NULL_;
	set FICHEROS_INPUT;

	if Nombre_Logico_Fichero = "&Nombre_Logico_Input" then do;
		call symput('Ruta_input_a_cargar', trim(Ruta));
	end;

run;


%Macro Crear_Inv6_Existe;

	%if %sysfunc(fileexist("&dir_ficheros_orig.&Ruta_input_a_cargar")) = 0 %then 
		%do;


			/*Lista de Inventarios MIS de todo el periodo de ejecución*/
			PROC IMPORT OUT=&biblioteca..Lista_Inv6
				DATAFILE="&dir_ficheros_orig.&fichero_listado_inputs."
				DBMS=xlsx replace;
				getnames=yes;
				sheet="Historia_Inv6";
			RUN; 


			/*Se unifican todos los inventarios 6 del periodo de reporte para enriquecer
			a las operaciones no vivas*/


		    /*imho good practice to declare macro variables of a macro locally*/
		    %local datasetCount iter inElemento;

		    /*get number of datasets*/
		    proc sql noprint;
		        select count(*)
		         into :datasetCount
		        from &biblioteca..Lista_Inv6;
		    quit;

		    /*initiate loop*/
		    %let iter=1;
		    %do %while (&iter.<= &datasetCount.);
		        /*get libref and dataset name for dataset you will work on during this iteration*/
		        data _NULL_;
		            set &biblioteca..Lista_Inv6 (firstobs=&iter. obs=&iter.); *only read 1 record;
		            *write the libname and dataset name to the macro variables;
		            call symput("inElemento",strip(Elemento_orden_actualidad));
		            *NOTE: i am always mortified by the chance of trailing blanks torpedoing my code, hence the strip function;
		        run;

				%if &iter. = 1 %then /*La primera fila sera el mes de referencia (e.g diciembre 2016)*/
					%do;
						data Referencia;
						set "&dir_ficheros_orig.&inElemento.";
					%end;
				%else /*Ahora empiezo a agregar los contratos que no estaban en diciembre pero si antes*/
					%do;
						/*Todos los contratos que tengo*/
						/*A medida que iteramos, "Referencia" tiene mas contratos almacenados.
						Si una operacion estuvo viva de julio a noviembre, no queremos almacenar
						de todos estos meses, solo del ultimo (noviembre). Por ello, es necesario
						actualizar constantemente "ContratosRef"*/
						proc sql;
							create table ContratosRef as
								select distinct CONTRATO
									from Referencia;
						quit;

						/*Los contratos del mes anterior*/
						proc sql;
							create table ContratosMes as
								select distinct CONTRATO
									from "&dir_ficheros_orig.&inElemento.";	
						quit;
						/*Identifico los contratos que estaban en el mes anterior, pero no en el actual*/
						proc sql;
							create table ContratosNoVivos as
								select a.CONTRATO
									from ContratosMes a LEFT JOIN ContratosRef b
										ON a.CONTRATO = b.CONTRATO
											where(b.CONTRATO = "");
						quit;

						/*Cogemos la informacion completa de estos contratos no vivos*/
						proc sql;
							create table ContratosNoVivos_Compl as
								select *
									from "&dir_ficheros_orig.&inElemento."
										where(CONTRATO IN (select distinct CONTRATO from ContratosNoVivos));
						quit;

						/*Ahora anadimos estos contratos no vivos al tablon original de referencia
						para tener todas las operativas: vivas y no vivas*/
						data Referencia;
						set Referencia ContratosNoVivos_Compl;
						run;

						/*Operativas_No_Vivas tendra solo las operativas no vivas*/
						%if (&iter. = 2) %then
							%do;
								data Operativas_No_Vivas;
								set ContratosNoVivos_Compl;
								run;
							%end;
						%else
							%do;
								data Operativas_No_Vivas;
								set Operativas_No_Vivas ContratosNoVivos_Compl;
								run;
							%end;


					%end;



		        /*increment the iterator of the loop*/
		        %let iter=%eval(&iter.+1);
		    %end;

			/*
			Referencia -> Esta tabla tendra todas las operaciones: vivas y no vivas
			Operativas_No_Vivas -> Esta tabla tendra las operativas no vivas solamente
			*/


			/*Se guarda el resultado final: 
			inventarios 6 a nivel contrato*/
			proc sql;
				create table Inv6_lb.inv6_&fechaReporte._no_vivas as
					select contrato,PYME
						from Operativas_No_Vivas;
			quit;

		%end;


%mend Crear_Inv6_Existe;


/*Solo genera inv6_201712_no_vivas si este no existe*/
%Crear_Inv6_Existe;


/*Se resume a nivel contrato la marca PYME
(algunos meses algunos contratos tienen 2 valores de marca PYME, 
por eso se uso un MAX)*/
proc sql;
	create table &biblioteca..Inv6_Union as
		select contrato, max(PYME) as PYME
			from Inv6_lb.inv6_&fechaReporte._no_vivas
				group by 1;
quit;


/*Se eliminan las tablas Intermedias*/

%borrarTabla(Referencia);
%borrarTabla(ContratosRef);
%borrarTabla(ContratosMes);
%borrarTabla(ContratosNoVivos);
%borrarTabla(ContratosNoVivos_Compl);
%borrarTabla(Operativas_No_Vivas);