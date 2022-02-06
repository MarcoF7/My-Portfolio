/*** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***/

/* PROGRAMA: Importar_Clientes_Sector.sas
/* OBJETIVO: Carga de Clientes_Sector
/* AUTOR:	 Management Solutions
/* PROCESO:  Se realiza la importaci�n de la tabla con la relacion cliente - sector
/*			 
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


%PUT job "Importar_Clientes_Sector.sas" comenz� a %now;
/**/
* Se asigna el nombre l�gico del fichero;

/*%let Nombre_Logico_Input = Clientes_Sector;*/
/**/
/*%put &Nombre_Logico_Input;*/

/** Se busca la ruta f�sica en la tabla "FICHEROS_INPUT";*/
/*data _NULL_;*/
/*	set FICHEROS_INPUT;*/
/**/
/*	if Nombre_Logico_Fichero = "&Nombre_Logico_Input." then do;*/
/*		call symput('Ruta_input_a_cargar', trim(Ruta));*/
/*	end;*/
/*run;*/
/**/
/*%put &Ruta_input_a_cargar;*/
/**/
/**/
/*data &biblioteca..Clientes_Sector;*/
/*	set "&dir_ficheros_orig.&Ruta_input_a_cargar";*/
/*run;*/



/*
Se usa directamente del aprovisionamiento unico,
del proceso "Procesar_Sectorizacion_Cliente.sas", la tabla:

&bibliotecaInputs..Clientes_Sector_Final
*/