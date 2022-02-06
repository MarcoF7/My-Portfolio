/*** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***/

/* PROGRAMA: Importar_Credito_Param_Finrep.sas
/* OBJETIVO: Carga de la parametria de credito FINREP
/* AUTOR:	 Management Solutions
/* PROCESO:  Se realiza la importación de la parametria de credito
/*			 necesaria para homologar el segmento finrep de las operativas no vivas
/*
/* 			 CONJUNTOS DE DATOS GENERADOS:
/* 			 - ...
/* 			 - ...
/*
/* FECHA: 12/02/2017
/*
/* NOTAS: ...
/*
/* LOG DE CAMBIOS:
/* FECHA	AUTOR	Objetivo
/* ...
/*** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***/


/*****************Inputs Credito FINREP Despues Plan 00***************************/

%let Nombre_Logico_Input = H_Credito_Finrep;

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

	if Pestana = "H_Sector_CIIU_Autonomos" then
		do;
			Pestana_Fichero_a = Nombre_fisico_pestana;
			call symput('Pestana_Param_Auto', compress(trim(Pestana_Fichero_a)));
		end;
	else if Pestana = "H_Finalidad" then
		do;
			Pestana_Fichero_b = Nombre_fisico_pestana;
			call symput('Pestana_Param_Fina', compress(trim(Pestana_Fichero_b)));
		end;
run;


/*sector corasu*/
PROC IMPORT OUT=H_Sector_CIIU_cr_dps
	DATAFILE="&dir_ficheros_orig.&Ruta_input_a_cargar."
	DBMS=xlsx replace;
	sheet= "&Pestana_Param_Auto";
	getnames=yes;
RUN;

/*finalidad*/
PROC IMPORT OUT=H_Finalidad_cr_dps
	DATAFILE="&dir_ficheros_orig.&Ruta_input_a_cargar."
	DBMS=xlsx replace;
	sheet= "&Pestana_Param_Fina";
	getnames=yes;
RUN;


/*****************End Inputs FINREP Credito Despues Plan 00***************************/