
/*** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***/

/* PROGRAMA: Importar_Depositos_Param_Finrep.sas
/* OBJETIVO: Carga de la parametria de depositos FINREP
/* AUTOR:	 Management Solutions
/* PROCESO:  Se realiza la importación de la parametria de depositos
/*			 necesaria para homologar el segmento finrep y el tipo de producto
/*
/* 			 CONJUNTOS DE DATOS GENERADOS:
/* 			 - ...
/* 			 - ...
/*
/* FECHA: 06/12/2017
/*
/* NOTAS: ...
/*
/* LOG DE CAMBIOS:
/* FECHA	AUTOR	Objetivo
/* ...
/*** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***/

/*Se quiere un nuevo desglose por producto depositos tomando la parametria de FINREP
en vez de la que ya me viene en los tablones de Liquidez. 
La idea es llegar al F08 (FINREP Depositos)*/


%let Nombre_Logico_Input = H_Depositos_Finrep;

* Se busca la ruta física en la tabla "FICHEROS_INPUT";
data _NULL_;
	set FICHEROS_INPUT;

	if Nombre_Logico_Fichero = "&Nombre_Logico_Input" then do;
		call symput('Ruta_input_a_cargar', trim(Ruta));
	end;

run;

/*Se importa detalles de las pestañas*/
data _NULL_;
	set &Nombre_Logico_Input._Pestanas;

	if Pestana = "H_Sector_CORASU" then
		do;
			Pestana_Fichero_a = Nombre_fisico_pestana;
			call symput('Pestana_Param_a', compress(trim(Pestana_Fichero_a)));
		end;
	else if Pestana = "H_Sec_Prod_Imp_Car" then
		do;
			Pestana_Fichero_b = Nombre_fisico_pestana;
			call symput('Pestana_Param_b', compress(trim(Pestana_Fichero_b)));
		end;
	else if Pestana = "H_Sector_SaldosDiarios" then
		do;
			Pestana_Fichero_c = Nombre_fisico_pestana;
			call symput('Pestana_Param_c', compress(trim(Pestana_Fichero_c)));
		end;
run;


/**************Se cargan las pestañas de H_Depositos necesarias para la homologacion***************/

PROC IMPORT OUT=&biblioteca..H_Dep_Corasu
	DATAFILE="&dir_ficheros_orig.&Ruta_input_a_cargar."
	DBMS=xlsx replace;
	sheet= "&Pestana_Param_a";
	getnames=yes;
RUN;

PROC IMPORT OUT=&biblioteca..H_Dep_Prod
	DATAFILE="&dir_ficheros_orig.&Ruta_input_a_cargar."
	DBMS=xlsx replace;
	sheet= "&Pestana_Param_b";
	getnames=yes;
RUN;

/*PROC IMPORT OUT=&biblioteca..H_Dep_Brokers*/
/*	DATAFILE="&dir_ficheros_orig.&Ruta_input_a_cargar."*/
/*	DBMS=xlsx replace;*/
/*	sheet= "H_Brokers";*/
/*	getnames=yes;*/
/*RUN;*/

PROC IMPORT OUT=&biblioteca..H_Sector_SaldosDiarios
	DATAFILE="&dir_ficheros_orig.&Ruta_input_a_cargar."
	DBMS=xlsx replace;
	sheet= "&Pestana_Param_c";
	getnames=yes;
RUN;






/************************segmentacion_pyme*******************************************/

%let Nombre_Logico_Input = segmentacion_pyme;


* Se busca la ruta física en la tabla "FICHEROS_INPUT";
data _NULL_;
	set FICHEROS_INPUT;

	if Nombre_Logico_Fichero = "&Nombre_Logico_Input" then
		do;
			call symput('Ruta_input_a_cargar', trim(Ruta));
		end;
run;

* Se importa la tabla de Credito Finrep a nivel contrato;

data segmentacion_pyme_final;
	set "&dir_ficheros_orig.&Ruta_input_a_cargar";
run;

proc sql;
	create table base_pymes_cliente as
		select	distinct "Pymes" as Tipologia, 
			numclien as codcen
		from segmentacion_pyme_final;
quit;





/************************Saldos Diarios*******************************************/

%let Nombre_Logico_Input = Saldos_Diarios;


* Se busca la ruta física en la tabla "FICHEROS_INPUT";
data _NULL_;
	set FICHEROS_INPUT;

	if Nombre_Logico_Fichero = "&Nombre_Logico_Input" then do;
		call symput('Ruta_input_a_cargar', trim(Ruta));
	end;

run;

/*Se importa detalles de la pestaña*/
data _NULL_;
	set &Nombre_Logico_Input._Pestanas;

	if Pestana = "Saldos Diarios" then
		do;
			Pestana_Fichero_SD = Nombre_fisico_pestana;
			call symput('Pestana_Param_SD', compress(trim(Pestana_Fichero_SD)));
		end;
run;


PROC IMPORT OUT=&biblioteca..Saldos_prev
	DATAFILE="&dir_ficheros_orig.&Ruta_input_a_cargar."
	DBMS=xlsx replace;
	sheet= "&Pestana_Param_SD";
	getnames=yes;
RUN;

proc sql;
	create table Saldos_Diarios as
		select distinct	CTA as Cta_Contable,
			'DESCR CTA'n as Descripcion,
			'S ACTUAL'n as Saldo_Diario_Actual
		from &biblioteca..Saldos_prev
			where (CTA like "21%" or CTA like "23%") and 'INDIC U'n="I";
quit;


data Saldos_Diarios_Norm (drop=Cta_Contable);
	format Cta_Contable15char $15.;
	set saldos_diarios;

	if length(Cta_Contable)<15 then
		do;
			Cta_Contable15char=trim(cats(Cta_Contable,"000000000000000"));
		end;
run;
