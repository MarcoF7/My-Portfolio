/*** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***/

/* PROGRAMA: Importar_Contratos_Morosos.sas
/* OBJETIVO: Carga de los contratos morosos
/* AUTOR:	 Management Solutions
/* PROCESO:  Se realiza la importación de todos los contratos que entraron en
/*			 mora en el año de datos
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

%PUT job "Importar_Contratos_Morosos.sas" comenzó a %now;
/**/
* Se asigna el nombre lógico del fichero;
%let Nombre_Logico_Input = Contratos_Morosos;

/** Se busca la ruta física en la tabla "FICHEROS_INPUT";*/
data _NULL_;
	set FICHEROS_INPUT;

	if Nombre_Logico_Fichero = "&Nombre_Logico_Input." then do;
		call symput('Ruta_input_a_cargar', trim(Ruta));
	end;
run;

/*
Se utilizo el criterio de 90 dias a vencido para mora
En esta tabla tenemos todas las operaciones que entraron en mora durante 
el año de evaluacion
*/
data &biblioteca..Contratos_Morosos;
	set "&dir_ficheros_orig.&Ruta_input_a_cargar";
run;


/*Analizando la data*/

/*Marcamos con Default los que a la fecha de reporte aun estaban en mora*/
data morosos1; /*43678 filas*/
set &biblioteca..Contratos_Morosos;
	format FINI date10.;
	format FFIN date10.;

	FINI = input(FINISUBC,yymmdd8.); /*entro mora, todos entraron*/
	FFIN = input(FFINSUBC,yymmdd8.); /*salio*/

	format FechDat2 date10.;
	FechDat = cat("&fechaReporte","31"); /*completamos la fecha de datos*/
	FechDat2 = input(FechDat,yymmdd8.); /*formato fecha*/

	/*Marcamos los de nuestro interes, los que han estado en mora al momento de la 
	fecha de datos*/
	/*Sabemos que todos estos contratos entraron en mora el año de datos*/
	if ((year(FFIN) > year(FechDat2)) OR ((year(FFIN) = year(FechDat2)) AND (month(FFIN) = month(FechDat2)))) then
		Default = 1;
	
run;

/*14348 filas
ademas no se repite por contrato
*/
proc sql;
	create table morosos2 as
		select contrato, FINI
			from morosos1
				where Default = 1;
quit;