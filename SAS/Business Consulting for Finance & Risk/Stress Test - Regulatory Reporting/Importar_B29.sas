/*** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***/

/* PROGRAMA: Importar_B29.sas
/* OBJETIVO: Carga del fichero de contabilidad local de BBVA Continental
/* AUTOR:	 Management Solutions
/* PROCESO:  Se realiza la importación de la contabilidad local
/*
/* 			 CONJUNTOS DE DATOS GENERADOS:
/* 			 - ...
/* 			 - ...
/*
/* FECHA: 01/12/2015
/*
/* NOTAS: ...
/*
/* LOG DE CAMBIOS:
/* FECHA	AUTOR	Objetivo
/* ...
/*** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***/

* Se asigna el nombre lógico del fichero;
/*%let Nombre_Logico_Input = B29;*/

* Se busca la ruta física en la tabla "FICHEROS_INPUT";
/*data _NULL_;*/
/*	set FICHEROS_INPUT;*/
/**/
/*	if Nombre_Logico_Fichero = "&Nombre_Logico_Input" then*/
/*		do;*/
/*			call symput('Ruta_input_a_cargar', trim(Ruta));*/
/*		end;*/
/*run;*/

* Se carga la parametrización;

* Se introduce en una macrovariable el nombre de la pestaña para poder acceder con la sentencia libname;
* La estructura de acceso a una pestaña de un Excel abierto con la sentencia libname es: 'Nombre_Pestana$'n;
/*data _NULL_;*/
/*	set &Nombre_Logico_Input._Pestanas;*/
/**/
/*	if Pestana = "B29" then*/
/*		do;*/
/*			Pestana_Fichero_B29 = Nombre_fisico_pestana;*/
/*			call symput('Pestana_B29', compress(trim(Pestana_Fichero_B29)));*/
/*		end;*/
/*run;*/

*Ingresamos el libname B29 a una tabla SAS;

/*PROC IMPORT OUT=&biblioteca..B29*/
/*	DATAFILE="&dir_ficheros_orig.&Ruta_input_a_cargar."*/
/*	DBMS=xls replace;*/
/*	sheet= "&Pestana_B29";*/
/*	getnames=yes;*/
/*RUN;*/




*Se excluyen las divisas "REU","RTT","XXX";
proc sql;
	create table &biblioteca..B29_Divisa as
		select a.*
			from &bibliotecaInputs..B29_Prev a 
				/*left join H_Sec_Sit_Imp b on a.CtaGestionBBV=b.Cta_Neocon*/
			where moneda not in ("REU","RTT","XXX") and ctacontable ^= "";
quit;

/*SE OBTIENE EL SALDO ACTUAL DE ACUERDO AL MES DEL PRESENTE REPORTE ESTO PARA TODAS LA DIVISAS POSIBLES*/
data &biblioteca..B29_Todas_Divisas;
	set &bibliotecaInputs..B29_Prev;
	array saldos {*} _numeric_;
	Fecha_Hoy_Texto = "&FechaReporte";
	Posicion_Saldo=input(substr(Fecha_Hoy_Texto,5,2),2.);
	Saldo_Actual = saldos(Posicion_Saldo);;
run;


/*SE HACE UN DISTINCT PARA OBTENER UNA SOLA COMBINACION DE CUENTA CONTABLE Y OCUENTA NEOCON*/
proc sql;
	create table &biblioteca..B29_Todas_Divisas_NEOCON as
		select distinct CtaGestionBBV,Ctacontable
			from &biblioteca..B29_Todas_Divisas;
quit;

*Se toma el saldo correspondiente al mes y se ingresa en Saldo actual;
data &biblioteca..B29_Saldo;
	set &biblioteca..B29_Divisa;
	array saldos {*} _numeric_;


	* Se cambia el signo dado que en el B29 los saldos de activo aparecen en negativo y los de pasivo en positivo;

	 Mes =input(substrn(&fechaReporte,5,2),2.);


	
	* Se cambia el signo dado que en el B29 los saldos de activo aparecen en negativo y los de pasivo en positivo;
	 if substr(ctacontable,1,1)="2" then
		do;
			Saldo_Actual_Uni = (saldos(Mes));
			Saldo_Actual = round(saldos(Mes)/1000, 1);
		end;
	else 
		do;
			Saldo_Actual_Uni = -(saldos(Mes));
			Saldo_Actual = -round(saldos(Mes)/1000, 1);
		end;
	
	Patron_Cuenta = substr(Ctacontable, 1, 2) || "0" || substr(Ctacontable, 4, 1) || "." || substr(Ctacontable, 5, 2);
run;

*Sumarizamos saldo por cuenta Neocon y cuenta contable;
proc sql;
	create table &biblioteca..B29_Saldo_Agrup as
		select
			Patron_Cuenta,CtaGestionBBV,Ctacontable,strip(trim(DesGestion)) as DesGestion,
			sum(Saldo_Actual) as Saldo_B29, sum(saldo_actual_uni) as Saldo_Actual_Uni
		from &biblioteca..B29_Saldo
			group by 1,2,3,4;
quit;

*Agrupamos por cuenta Neocon y cuenta contable;
Proc sql;
	create table &biblioteca..B29_Neocon as
		select distinct CtaGestionBBV,Ctacontable 
			from &biblioteca..B29_Saldo;
quit;








/***************************************************************************
Ademas se debe tener un B29 para las cuentas de margen,
Es usado para obtener el margen de derivados a nivel cuenta resultados.
Para el caso de cuentas de resultados, se maneja a nivel de divisas PEN y RTT
****************************************************************************/
proc sql;
	create table &biblioteca..B29_Margen_Divisa as
		select a.*
			from &bibliotecaInputs..B29_Prev a 
			where moneda in ("PEN","RTT") and ctacontable ^= "";
quit;


data &biblioteca..B29_Margen_Saldo;
	set &biblioteca..B29_Margen_Divisa;
	array saldos {*} _numeric_;


	* Se cambia el signo dado que en el B29 los saldos de activo aparecen en negativo y los de pasivo en positivo;

	 Mes =input(substrn(&fechaReporte,5,2),2.);


	
	* Se cambia el signo dado que en el B29 los saldos de activo aparecen en negativo y los de pasivo en positivo;
	 if substr(ctacontable,1,1)="2" then
		do;
			Saldo_Actual_Uni = (saldos(Mes));
			Saldo_Actual = round(saldos(Mes)/1000, 1);
		end;
	else 
		do;
			Saldo_Actual_Uni = -(saldos(Mes));
			Saldo_Actual = -round(saldos(Mes)/1000, 1);
		end;
	
	Patron_Cuenta = substr(Ctacontable, 1, 2) || "0" || substr(Ctacontable, 4, 1) || "." || substr(Ctacontable, 5, 2);
run;


*Sumarizamos saldo por cuenta Neocon y cuenta contable;
proc sql;
	create table &biblioteca..B29_Margen_Saldo_Agrup as
		select
			CtaGestionBBV,Ctacontable,
			sum(saldo_actual_uni) as Saldo_Actual_Uni
		from &biblioteca..B29_Margen_Saldo
			group by 1,2;
quit;