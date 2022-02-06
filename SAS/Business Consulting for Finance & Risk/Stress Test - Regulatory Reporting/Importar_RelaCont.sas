/*** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***/

/* PROGRAMA: Importar_RelaCont.sas
/* OBJETIVO: Carga del fichero de relacion cuenta contable - cuenta neocon
/* AUTOR:	 Management Solutions
/* PROCESO:  Se realiza la importación de la relacion contable de la fecha de datos
/*
/* 			 CONJUNTOS DE DATOS GENERADOS:
/* 			 - ...
/* 			 - ...
/*
/* FECHA: 24/01/2018
/*
/* NOTAS: ...
/*
/* LOG DE CAMBIOS:
/* FECHA	AUTOR	Objetivo
/* ...
/*** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***/

* Se asigna el nombre lógico del fichero;
/*%let Nombre_Logico_Input = Relacion_Ctas_NEOCON;*/

* Se busca la ruta física en la tabla "FICHEROS_INPUT";
/*data _NULL_;*/
/*	set FICHEROS_INPUT;*/
/**/
/*	if Nombre_Logico_Fichero = "&Nombre_Logico_Input" then*/
/*		do;*/
/*			call symput('Ruta_input_a_cargar', trim(Ruta));*/
/*		end;*/
/*run;*/


/*usar directamente lo importado por el APROVISIONAMIENTO UNICO:

&bibliotecaInputs..Relacion_Cta_local_Neo
*/


proc sql;
	create table Relacion_Cta_local_Neo2 as
		select distinct nCtaGestionBBV, CtaCont
			from &bibliotecaInputs..Relacion_Cta_local_Neo;
quit;
