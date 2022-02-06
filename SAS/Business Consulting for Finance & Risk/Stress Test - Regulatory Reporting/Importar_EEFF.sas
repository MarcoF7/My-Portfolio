/*** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***/

/* PROGRAMA: Importar_EEFF.sas
/* OBJETIVO: Carga del fichero de contabilidad a nivel neocon de BBVA Continental
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


%PUT job "Importar_EEFF.sas" comenzó a %now;

* Se asigna el nombre lógico del fichero;
/*%let Nombre_Logico_Input = EEFF;*/

* Se busca la ruta física en la tabla "FICHEROS_INPUT";
/*data _NULL_;*/
/*	set FICHEROS_INPUT;*/
/**/
/*	if Nombre_Logico_Fichero = "&Nombre_Logico_Input" then do;*/
/*		call symput('Ruta_input_a_cargar', trim(Ruta));*/
/*	end;*/
/**/
/*run;*/


/*data _NULL_;*/
/*	set &Nombre_Logico_Input._Pestanas;*/
/**/
/*	if Pestana = "&Nombre_Logico_Input" then*/
/*		do;*/
/*			Pestana_Fichero_EEFF = Nombre_fisico_pestana;*/
/*			call symput('Pestana_EEFF', compress(trim(Pestana_Fichero_EEFF)));*/
/*		end;*/
/*run;*/

/*%put "&dir_ficheros_orig.&Ruta_input_a_cargar.";*/


* Se cargan los EEFF;

/*PROC IMPORT OUT=&biblioteca..EEFF*/
/*	DATAFILE="&dir_ficheros_orig.&Ruta_input_a_cargar."*/
/*	DBMS=xlsx replace;*/
/*	RANGE="&Pestana_EEFF.$A5:N1000";*/
/*	getnames=yes;*/
/*RUN;*/





/*Se tiene directamente del Aprovisionamiento Unico:
&bibliotecaInputs..EEFF (EEFF tal cual)
&bibliotecaInputs..EEFF_Final
*/