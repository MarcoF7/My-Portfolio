/*** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***/

/* PROGRAMA: Importar_H_Stress_Test.sas
/* OBJETIVO: Cargar el fichero con todas las Homologaciones para Stress Test
/* AUTOR:	 Management Solutions
/* PROCESO:  Se cargan todas las pestañas de este fichero de homologaciones.
			 Cada pestaña tiene una homologación a usarse en los distintos procesos del proyecto.

/*
/* 			 
/* FECHA: 06/12/2017
/*
/* ...
/*** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***/



/*Macro para cargar una hoja de un fichero excel xlsx*/
%macro cargarHojaExcel(hoja);

	PROC IMPORT OUT=&biblioteca..&hoja
	DATAFILE="&dir_ficheros_orig.&Ruta_input_a_cargar."
	DBMS=xlsx replace;
	getnames=yes;
	sheet="&hoja";
	RUN; 

%mend cargarHojaExcel;



* Se asigna el nombre lógico del fichero;
%let Nombre_Logico_Input = H_Stress_Test;

* Se busca la ruta física en la tabla "FICHEROS_INPUT";
data _NULL_;
	set FICHEROS_INPUT;

	if Nombre_Logico_Fichero = "&Nombre_Logico_Input" then
		do;
			call symput('Ruta_input_a_cargar', trim(Ruta));
		end;
run;

/*Se importan todas las pestaña del Input H_Stress_Test*/
data _NULL_;
set &Nombre_Logico_Input._Pestanas;
	format llamada 				$1000.;

	llamada = "cargarHojaExcel("||Nombre_fisico_pestana||");";
	call execute ("%" || llamada);
	
run;