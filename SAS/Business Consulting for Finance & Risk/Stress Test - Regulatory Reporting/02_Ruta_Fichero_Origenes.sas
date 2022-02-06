/*** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***  ***/

/* PROGRAMA: 02_Ruta_Fichero_Origenes.sas
/* OBJETIVO: Carga del fichero que contiene la ruta del directorio
/*			 donde se ubican los ficheros origen del proceso
/* AUTOR:	 Management Solutions
/* PROCESO:  Importación del fichero con la ruta del directorio
/*			 donde se ubican los ficheros origen del proceso y 
/*			 almacenamiento de la misma en una macrovariable
/*
/* 			 MACROVARIABLES GENERADAS:
/* 			 - fichero_listado_inputs: contiene el nombre del fichero
/*								   	   que tiene todos los nombres y rutas	
/*								       de los inputs a usar en Stress Test	
/*								   
/* 			 - dir_ficheros_orig:  contiene el directorio raíz donde se
/*								   encuentran los inputs necesarios para
/*								   procesar el instrumento
/* FECHA: 06/12/2017
/*
/* NOTAS: No aplica
/*
/* LOG DE CAMBIOS:
/* FECHA	AUTOR	Objetivo
/* ...
/*** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***/
%PUT job "02_Ruta_Ficheros_Origenes.sas" comenzó a %now;

* Se importa el TXT con la ruta donde se ubican los ficheros origen;
PROC IMPORT OUT = RutaOrigenes
	DATAFILE = "&libRutaOrig"
	DBMS = dlm replace;
	delimiter = ",";
RUN;

* Se almacena el contenido en las macrovariables;
data _NULL_;
	set RutaOrigenes;

	* En la primera fila se encuentra la ruta del fichero con el listado de inputs;
	if _N_ = 1 then
		do;
			call symput('fichero_listado_inputs', trim(Ruta));
		end;

	/*	* En la segunda fila se encuentra el directorio raíz donde están los inputs;*/
	if _N_ = 2 then
		do;
			call symput('dir_ficheros_orig', trim(Ruta));
		end;

	/* En la tercera fila se encuentra el nombre en SAS de la tabla
		Traducción Contrato del Histórico de Movimientos*/
		if _N_ = 3 then
			do;
				call symput('hist_mov_contr', trim(Ruta));
			end;

	/* En la cuarta fila se encuentra el nombre en SAS del
		Histórico de Movimientos con fecha de cierre del reporte Stress Test*/
		if _N_ = 4 then
			do;
				call symput('hist_mov_acum', trim(Ruta));
			end;

	/* En la quinta fila se encuentra la ruta de los Históricos de Movimientos
			y de la Traducción Contrato*/
		if _N_ = 5 then
			do;
				call symput('dir_hist_mov', trim(Ruta));
			end;

	/* En la sexta fila se encuentra la ruta de los inputs del Aprovisionamiento Unico*/
		if _N_ = 6 then
			do;
				call symput('dirInputsOrig', trim(Ruta));
			end;
run;

%PUT job "02_Ruta_Ficheros_Origenes.sas" finalizó a %now;