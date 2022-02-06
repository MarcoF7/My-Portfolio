/*** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***/

/* PROGRAMA: Importar_Curva_Libre_Sol.sas
/* OBJETIVO: Carga de la curva libre de riesgos
/* AUTOR:	 Management Solutions
/* PROCESO:  Se realiza la importación de la curva libre de riesgo para
/*			 la divisa soles (Bonos Soberanos)
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


%PUT job "Importar_Curva_Libre_Sol.sas" comenzó a %now;

* Se asigna el nombre lógico del fichero;
%let Nombre_Logico_Input = Curva_Libre_Sol;

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

	if Pestana = "Curva Libre Soles" then
		do;
			Pestana_Fichero_Curv_S = Nombre_fisico_pestana;
			call symput('Pestana_Curv_S', compress(trim(Pestana_Fichero_Curv_S)));
		end;
run;


%put "&dir_ficheros_orig.&Ruta_input_a_cargar.";


PROC IMPORT OUT=&biblioteca..Curva_Libre_Sol_prev
	DATAFILE="&dir_ficheros_orig.&Ruta_input_a_cargar."
	DBMS=xlsx replace;
	sheet= "&Pestana_Curv_S";
	getnames=yes;
RUN;

/*Se retiran filas vacías*/
proc sql;
	create table &biblioteca..Curva_Libre_Sol as
		select *
			from &biblioteca..Curva_Libre_Sol_prev
				where(Soles ne .);
quit;

/*Guardo la menor fecha de apertura que ofrece la curva libre de riesgo*/
data _null_;
set &biblioteca..Curva_Libre_Sol;
	if _N_ = 1 then
		do;
			call symput('ApertSoles', trim(Soles));
		end;
run;

%put &ApertSoles;