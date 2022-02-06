/*** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***/

/* PROGRAMA: Importar_Tabla_Credito_Finrep.sas
/* OBJETIVO: Carga de la tabla de credito FINREP
/* AUTOR:	 Management Solutions
/* PROCESO:  Se realiza la importación de la tabla finrep de credito
/*
/* 			 CONJUNTOS DE DATOS GENERADOS:
/* 			 - ...
/* 			 - ...
/*
/* FECHA: 01/03/2016
/*
/* NOTAS: ...
/*
/* LOG DE CAMBIOS:
/* FECHA	AUTOR	Objetivo
/* ...
/*** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***/

* Se asigna el nombre lógico del fichero;
%let Nombre_Logico_Input = Base_Credito_Finrep;

* Se busca la ruta física en la tabla "FICHEROS_INPUT";
data _NULL_;
	set FICHEROS_INPUT;

	if Nombre_Logico_Fichero = "&Nombre_Logico_Input" then
		do;
			call symput('Ruta_input_a_cargar', trim(Ruta));
		end;
run;

* Se importa la tabla de Credito Finrep a nivel contrato;

data &biblioteca..Credito_Finrep ;
	set "&dir_ficheros_orig.&Ruta_input_a_cargar";
run;