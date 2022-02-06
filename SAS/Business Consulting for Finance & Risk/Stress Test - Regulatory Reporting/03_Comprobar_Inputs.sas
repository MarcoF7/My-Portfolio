/*** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***/
/* PROGRAMA: 03_Nombres_Ficheros_Origenes.sas
/* OBJETIVO: Carga los nombres de los ficheros de entrada
/* AUTOR:	 Management Solutions
/* PROCESO:  En primer lugar se realiza la lectura del fichero que contiene las
/*			 rutas de los inputs y se comprueba si los mismos existen en la ruta
/*			 especificada.
/*			 Después, se comprueba si los inputs que son ficheros Excel contienen
/*			 las pestañas necesarias.
/*
/* 			 DATASETS GENERADOS:
/* 			 - Listado de inputs necesarios para el instrumento (Ficheros_Input)
/*			 - Listado de errores por inputs no encontrados (Errores_Ruta_Origenes)
/*			 - Listado de errores por pestañas no encontradas (Errores_Pestana_Fichero)
/*
/* FECHA: 06/12/2017
/*
/* NOTAS: No aplica
/*
/* LOG DE CAMBIOS:
/* FECHA	AUTOR	Objetivo
/* ...
/*** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***/

%PUT job "03_Comprobar_Inputs.sas" comenzó a %now ; 

* Se comprueba la existencia del fichero paramétrico que contiene la relación;
* entre el instrumento y los inputs necesarios para el mismo;
%comprobarExistenciaFichero(rutaInput=&fichero_listado_inputs., errores=Errores_Ruta_Origenes);

%put &dir_ficheros_orig.&fichero_listado_inputs.;


PROC IMPORT OUT=Ficheros_Input_prev
	DATAFILE="&dir_ficheros_orig.&fichero_listado_inputs."
	DBMS=xlsx replace;
	getnames=yes;
	sheet="Ficheros_Origen";
RUN; 
* eligiendo las que aplican al instrumento a generar;
proc sql;
	create table Ficheros_Input as 
		select Nombre_Logico_Fichero, Ruta
			from Ficheros_Input_prev where &instrumento = "S";
quit;


* Se comprueba si existen todos los ficheros necesarios para procesar el instrumento;
data _NULL_;
	format llamada 				$1000.;
	set Ficheros_Input;
	
	* Se comprueba si cada input existe en la ruta especificada;
	* En caso contrario, se volcará en una tabla de errores (Errores_Ruta_Origenes);
	llamada = "comprobarExistenciaFichero(rutaInput="||Ruta||", errores=Errores_Ruta_Origenes);";
	call execute ("%" || llamada); 
run;

* Se comprueba si todos los ficheros necesarios para el procesar el instrumento, si son ficheros Excel, 
* contienen las pestañas adecuadas;
data _NULL_;
     set Ficheros_Input;

     extension = compress(substr(Ruta, length(Ruta) - 2, 3));

     if upcase(extension) = "XLS" or upcase(extension) = "LSX" then do;
          llamada = "comprobarPestanasFichero(rutaInput="||Ruta||", nombre_logico="||Nombre_Logico_Fichero||", errores=Errores_Pestana_Fichero);";
          call execute ("%" || llamada);
     end;
run;

%PUT job "03_Comprobar_Inputs.sas" finalizó a %now ; 