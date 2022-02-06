/*** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***/

/* PROGRAMA: Importar_Derivados_Param.sas
/* OBJETIVO: Carga de la parametria de derivados
/* AUTOR:	 Management Solutions
/* PROCESO:  Se realiza la importación de la parametria de derivados:
/*			 Tipo de Derivados, contabilidad y cuentas de margen financiero.
/*
/* 			 CONJUNTOS DE DATOS GENERADOS:
/* 			 - ...
/* 			 - ...
/*
/* FECHA: 23/02/2017
/*
/* NOTAS: ...
/*
/* LOG DE CAMBIOS:
/* FECHA	AUTOR	Objetivo
/* ...
/*** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***/



/***********************Tipo de Derivado*****************/


%let Nombre_Logico_Input = Derivados_Tipo;

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

	if Pestana = "Tipo Derivados" then
		do;
			Pestana_Fichero_TipDer = Nombre_fisico_pestana;
			call symput('Pestana_Tip_Der', compress(trim(Pestana_Fichero_TipDer)));
		end;
run;

/*Tipo derivados*/
PROC IMPORT OUT=&biblioteca..Tipo_Derivados_prev
	DATAFILE="&dir_ficheros_orig.&Ruta_input_a_cargar."
	DBMS=xlsx replace;
	sheet= "&Pestana_Tip_Der";
	getnames=no;
RUN;

/*Se selecciona los registros de interes
(Solo los que tienen en la columna S: "Float to Fixed" o "Fixed to Float")*/
proc sql;
	create table &biblioteca..Tipo_Derivados_prev2 as
		select P as Num_Operacion, S as Descripcion
			from &biblioteca..Tipo_Derivados_prev
				where(Descripcion NOT IN ("","Tipo"));
quit;

/*Se homologa el Tipo de Derivado*/
proc sql;
	create table &biblioteca..Tipo_Derivados as
		select a.*, b.Codigo as TIPO_DERIVADO
			from &biblioteca..Tipo_Derivados_prev2 a LEFT JOIN &biblioteca..H_Tipo_Derivados b
				ON UPCASE(COMPRESS(a.Descripcion)) = UPCASE(COMPRESS(b.Tipo_Derivado));
quit;






/***********************Margen Financiero*****************/

%let Nombre_Logico_Input = Derivados_Ctas_Margen;

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

	if Pestana = "Margen Derivados" then
		do;
			Pestana_Fichero_MargDer = Nombre_fisico_pestana;
			call symput('Pestana_Marg_Der', compress(trim(Pestana_Fichero_MargDer)));
		end;
run;

PROC IMPORT OUT=&biblioteca..Ctas_Margen_Derivados_prev
	DATAFILE="&dir_ficheros_orig.&Ruta_input_a_cargar."
	DBMS=xlsx replace;
	sheet= "&Pestana_Marg_Der";
	getnames=yes;
RUN;

/*Se trae el margen financiero del B29*/
proc sql;
	create table &biblioteca..Ctas_Margen_Derivados as
		select a.*, case when b.Saldo_Actual_Uni ne . then b.Saldo_Actual_Uni
					else 0 end as Margen_Acumulado_B29
			from &biblioteca..Ctas_Margen_Derivados_prev a 
				LEFT JOIN &biblioteca..B29_Margen_Saldo_Agrup b	
				ON a.Cuenta = b.Ctacontable;
quit;




/******************Derivados Relacion Cuenta Contable - Contrato*****************/

%let Nombre_Logico_Input = Derivados_CtaCont_Neo;

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

	if Pestana = "Cuenta Cont Neocon Derivados" then
		do;
			Pestana_Fichero_CtaDer = Nombre_fisico_pestana;
			call symput('Pestana_Cta_Der', compress(trim(Pestana_Fichero_CtaDer)));
		end;
run;

/*Cuenta Contable-contrato*/
PROC IMPORT OUT=&biblioteca..Ctas_Contab_Derivados_prev
	DATAFILE="&dir_ficheros_orig.&Ruta_input_a_cargar."
	DBMS=xlsx replace;
	sheet= "&Pestana_Cta_Der";
	getnames=yes;
RUN;


/*Se renombran variables*/
data &biblioteca..Ctas_Contab_Derivados
(keep=Neocon_ajust 'Cuenta local'n Producto contrato
rename=(Neocon_ajust = Neocon 'Cuenta local'n = Cuenta_local));
set &biblioteca..Ctas_Contab_Derivados_prev;
run;