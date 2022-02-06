/*** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***/

/* PROGRAMA: Importar_Curva_Libre_Dol.sas
/* OBJETIVO: Carga de la curva libre de riesgos
/* AUTOR:	 Management Solutions
/* PROCESO:  Se realiza la importación de la curva libre de riesgo para
/*			 la divisa dolares (Treasuries)
/* 			 
/* 			 
/* 			 
/*
/* FECHA: 06/12/2017
/*
/* NOTAS: ...
/*
/* LOG DE CAMBIOS:
/* FECHA	AUTOR	Objetivo
/* ...
/*** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***/


%PUT job "Importar_Curva_Libre_Dol.sas" comenzó a %now;

* Se asigna el nombre lógico del fichero;
%let Nombre_Logico_Input = Curva_Libre_Dol;

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

	if Pestana = "Curva Libre Dolares" then
		do;
			Pestana_Fichero_Curv_D = Nombre_fisico_pestana;
			call symput('Pestana_Curv_D', compress(trim(Pestana_Fichero_Curv_D)));
		end;
run;


%put "&dir_ficheros_orig.&Ruta_input_a_cargar.";


%put &Pestana_Curv_D;

PROC IMPORT OUT=&biblioteca..Curva_Libre_Dol_prev
	DATAFILE="&dir_ficheros_orig.&Ruta_input_a_cargar."
	DBMS=xlsx replace;
	sheet= "&Pestana_Curv_D";
	getnames=yes;
RUN;


/*Se retiran filas vacías*/
proc sql;
	create table &biblioteca..Curva_Libre_Dol as
		select *
			from &biblioteca..Curva_Libre_Dol_prev
				where(USD ne .);
quit;


/*Guardo la menor fecha de apertura que ofrece la curva libre de riesgo*/
data _null_;
set &biblioteca..Curva_Libre_Dol;
	if _N_ = 1 then
		do;
			call symput('ApertDolares', trim(USD));
		end;
run;