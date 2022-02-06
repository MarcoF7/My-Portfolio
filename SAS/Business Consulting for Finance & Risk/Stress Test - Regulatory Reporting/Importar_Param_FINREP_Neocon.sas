

/* PROGRAMA: Importar_Param_FINREP_Neocon.sas
/* OBJETIVO: Carga de la parametria FINREP Nivel Neocon
/* AUTOR:	 Management Solutions
/* PROCESO:  Se realiza la importación de la parametria nivel neocon
/*			 necesaria para homologar el segmento FINREP y el tipo de producto
/*		     FINREP para Crédito y Depósitos
/* 			 CONJUNTOS DE DATOS GENERADOS:
/* 			 - ...
/* 			 - ...
/*
/* FECHA: 25/04/2018
/*
/* NOTAS: ...
/*
/* LOG DE CAMBIOS:
/* FECHA	AUTOR	Objetivo
/* ...
/*** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***/



%let Nombre_Logico_Input = Param_FINREP_Plan00;

* Se busca la ruta física en la tabla "FICHEROS_INPUT";
data _NULL_;
	set FICHEROS_INPUT;

	if Nombre_Logico_Fichero = "&Nombre_Logico_Input" then
		do;
			call symput('Ruta_input_a_cargar', trim(Ruta));
		end;
run;

/*Se importa detalles de las pestañas*/
data _NULL_;
	set &Nombre_Logico_Input._Pestanas;

	if Pestana = "Credito" then
		do;
			Pestana_Fichero_Cre = Nombre_fisico_pestana;
			call symput('Pestana_Param_Cre', compress(trim(Pestana_Fichero_Cre)));
		end;
	else if Pestana = "Depositos" then
		do;
			Pestana_Fichero_Dep = Nombre_fisico_pestana;
			call symput('Pestana_Param_Dep', compress(trim(Pestana_Fichero_Dep)));
		end;
run;


/*Credito*/
PROC IMPORT OUT=&biblioteca..Parametria_FINREP_Cr
	DATAFILE="&dir_ficheros_orig.&Ruta_input_a_cargar."
	DBMS=xlsx replace;
	sheet= "&Pestana_Param_Cre";
	getnames=yes;
RUN;


/*Depositos*/
PROC IMPORT OUT=&biblioteca..Parametria_FINREP_Dep
	DATAFILE="&dir_ficheros_orig.&Ruta_input_a_cargar."
	DBMS=xlsx replace;
	sheet= "&Pestana_Param_Dep";
	getnames=yes;
RUN;