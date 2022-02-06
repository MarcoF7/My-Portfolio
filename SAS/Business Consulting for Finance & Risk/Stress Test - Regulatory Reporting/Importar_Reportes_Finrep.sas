/*** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***/

/* PROGRAMA: Importar_Reportes_Finrep.sas
/* OBJETIVO: Se cargan los reportes FINREP de la contabilidad
/* AUTOR:	 Management Solutions
/* PROCESO:  Se realiza la importación de los reportes FINREP		 
/* 			 
/* 			 
/*
/* FECHA: 20/02/2018
/*
/* NOTAS: ...
/*
/* LOG DE CAMBIOS:
/* FECHA	AUTOR	Objetivo
/* ...
/*** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***/


* Se asigna el nombre lógico del reporte F06;
%let Nombre_Logico_Input = Reporte_F06;

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

	if Pestana = "F06" then
		do;
			Pestana_Fichero_F06 = Nombre_fisico_pestana;
			call symput('Pestana_Param_F06', Pestana_Fichero_F06);
		end;
run;

/*Se importa el F06 original*/
PROC IMPORT OUT=F06_Complete
			DATAFILE="&dir_ficheros_orig.&Ruta_input_a_cargar."
			DBMS=xls replace;
			range="&Pestana_Param_F06";
			getnames=no;
RUN;

/*Se renombran los campos de interes*/
data F06_Complete2(keep= E Q 
rename=(E = Descrip Q = Saldo_Bruto));
set F06_Complete;
run;

/*Se clasifica por segmento FINREP*/
proc sql;
	create table F06_Complete3 as
		select a.*, b.SEGMENTO_FINREP
			from F06_Complete2 a LEFT JOIN &biblioteca..H_Descrip_F06 b
				ON a.Descrip = b.Descrip_F06;
quit;

/*Se resume el saldo por segmento finrep y se pone en unidades*/
proc sql;
	create table &biblioteca..F06_Saldos_Segmento as
		select SEGMENTO_FINREP, sum(Saldo_Bruto)*1000 as F06_Soles_Unidades
			from F06_Complete3
				group by 1
					having SEGMENTO_FINREP ne "";
quit;


/*Se almacena en una macrovariable el saldo del segmento particulares de credito*/
DATA _NULL_;
SET &biblioteca..F06_Saldos_Segmento;
	IF (SEGMENTO_FINREP = "006") THEN
		DO;
			CALL SYMPUT('Saldo_Parti_F06', TRIM(F06_Soles_Unidades));
		END;
RUN;

/*Para el segmento particulares ("006") ademas se debera
dividir por tipo de producto*/
proc sql;
	create table F06_Complete3_pro as
		select a.*, b.SEGMENTO_FINREP, b.PROD_PRESTAMOS
			from F06_Complete2 a LEFT JOIN &biblioteca..H_Descrip_F06_Parti b
				ON a.Descrip = b.Descrip_F06;
quit;	

/*Se suma el saldo por tipo de producto para el segmento particulares ("006")
y se pone en unidades*/
proc sql;
	create table F06_Div_Prod_sinRest as
		select SEGMENTO_FINREP, PROD_PRESTAMOS, sum(Saldo_Bruto)*1000 as F06_Soles_Unidades
			from F06_Complete3_pro
				where(SEGMENTO_FINREP = "006")
					group by 1,2;
quit;

/*Se genera en un registro la suma del saldo del segmento particulares
sin el tipo de producto otros*/
proc sql;
	create table F06_Parti_Sin_Resto as
		select sum(F06_Soles_Unidades) as F06_Saldo_Sin_Resto
			from F06_Div_Prod_sinRest;
quit;


/*Se almacena en una macrovariable el saldo del segmento particulares de credito
sin el tipo de producto Resto*/
DATA _NULL_;
SET F06_Parti_Sin_Resto;
	IF (_N_=1) THEN
		DO;
			CALL SYMPUT('Parti_SResto_F06', TRIM(F06_Saldo_Sin_Resto));
		END;
RUN;

/*Se añade el saldo de Resto para el segmento particulares de credito*/
proc sql;
	insert into F06_Div_Prod_sinRest
		set SEGMENTO_FINREP = "006", /*Particulares*/
			PROD_PRESTAMOS = "03", /*Resto*/
			/*Saldo de tipo de producto resto:*/
			F06_Soles_Unidades = &Saldo_Parti_F06 - &Parti_SResto_F06;
quit;

/*Se tiene al segmento particulares de credito dividio por producto con el saldo
en unidades*/
data &biblioteca..F06_Saldos_Producto_Parti;
set F06_Div_Prod_sinRest;
run;






* Se asigna el nombre lógico del reporte F08;
%let Nombre_Logico_Input = Reporte_F08;

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

	if Pestana = "F08" then
		do;
			Pestana_Fichero_F08 = Nombre_fisico_pestana;
			call symput('Pestana_Param_F08', Pestana_Fichero_F08);
		end;
run;

/*Cargo el reporte F08 con los saldos a nivel segmento FINREP para Depositos*/
PROC IMPORT OUT=F08_Complete
	DATAFILE="&dir_ficheros_orig.&Ruta_input_a_cargar."
	DBMS=xls replace;
	range="&Pestana_Param_F08";
	getnames=no;
RUN;

/*Se renombran los campos de interes*/
data F08_Complete2(keep= E N 
rename=(E = Descrip N = Saldo_Contable));
set F08_Complete;
run;

/*Se clasifica por segmento FINREP y por producto depositos*/
proc sql;
	create table F08_Complete3_prod as
		select a.*, b.SEGMENTO_FINREP, b.PROD_DEPOSITOS
			from F08_Complete2 a LEFT JOIN &biblioteca..H_Descrip_F08_Dep b
				ON a.Descrip = b.Descrip_F08;
quit;

/*Se resume el saldo por segmento finrep y tipo de producto depositos
y se pone en unidades*/
proc sql;
	create table &biblioteca..F08_Saldos_Producto as
		select SEGMENTO_FINREP,PROD_DEPOSITOS, 
				sum(Saldo_Contable)*1000 as F08_Soles_Unidades
			from F08_Complete3_prod
				group by 1,2
					having SEGMENTO_FINREP ne "";
quit;

/*Se resume el saldo por segmento finrep y se pone en unidades*/
proc sql;
	create table &biblioteca..F08_Saldos_Segmento as
		select SEGMENTO_FINREP, sum(F08_Soles_Unidades) as F08_Soles_Unidades
			from &biblioteca..F08_Saldos_Producto
				group by 1;
quit;

/*Se selecciona el saldo correspondiente a Emisiones
y se pasa a unidades*/
proc sql;
	create table &biblioteca..F08_Emisiones_Saldo as
		select a.Saldo_Contable*1000 as F08_Soles_Unidades
			from F08_Complete2 a LEFT JOIN &biblioteca..H_Descrip_F08_Emi b 
				ON a.Descrip = b.Descrip_F08
					where(b.Descrip_F08 ne "");
quit;







* Se asigna el nombre lógico del reporte F10;
%let Nombre_Logico_Input = Reporte_F10;

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

	if Pestana = "F10" then
		do;
			Pestana_Fichero_F10 = Nombre_fisico_pestana;
			call symput('Pestana_Param_F10', Pestana_Fichero_F10);
		end;
run;

/*Se carga el reporte F10 de Derivados*/
PROC IMPORT OUT=F10_Complete
	DATAFILE="&dir_ficheros_orig.&Ruta_input_a_cargar."
	DBMS=xls replace;
	range="&Pestana_Param_F10";
	getnames=no;
RUN;

/*Se renombran los campos de interes*/
data F10_Complete2(keep= E T 
rename=(E = Descrip T = Nocional));
set F10_Complete;
run;

/*Se selecciona el nocional correspondiente a Derivados
y se pasa a unidades*/
proc sql;
	create table &biblioteca..F10_Derivados_Saldo as
		select a.Nocional*1000 as F10_Soles_Unidades
			from F10_Complete2 a LEFT JOIN &biblioteca..H_Descrip_F10 b
				ON a.Descrip = b.Descrip_F10
					where(b.Descrip_F10 ne "");
quit;

/*Ademas se necesita dividir el Nocional entre derivado de activo y derivado de pasivo
Para ello se usa el Valor Razonable del reporte F10*/

/*Primero se toma el valor razonable total (activo + pasivo)*/
proc sql;
	create table F10_Complete_Valor_Raz as 
		select a.Nocional as Valor_Raz
			from F10_Complete2 a LEFT JOIN &biblioteca..H_Descrip_F10_Valor_Raz b
				ON a.Descrip = b.Descrip_F10
					where(b.Descrip_F10 ne "");
quit;

/*Se guarda en una macrovariable*/
DATA _NULL_;
SET F10_Complete_Valor_Raz;
	IF (_N_=1) THEN
		DO;
			CALL SYMPUT('Valor_Raz_Tot', TRIM(Valor_Raz));
		END;
RUN;

/*Ahora se calcula el ratio de valor razonable de activo y de pasivo*/
proc sql;
	create table F10_Complete_ValRaz_Act_Pas as 
		select a.Descrip as Concepto, a.Nocional as Valor_Raz
			from F10_Complete2 a LEFT JOIN &biblioteca..H_Descrip_F10_Act_Pasiv b	
				ON a.Descrip = b.Descrip_F10
					where(b.Descrip_F10 ne "");
quit;

/*Se calcula el Ratio tanto para derivados de activo como de pasivos
Para poder dividir el Nocional*/
data &biblioteca..Valor_Razonable;
set F10_Complete_ValRaz_Act_Pas;
	Ratio = (Valor_Raz/&Valor_Raz_Tot);
run;





* Se asigna el nombre lógico del Reporte F16;
%let Nombre_Logico_Input = Reporte_F16;

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

	if Pestana = "F16" then
		do;
			Pestana_Fichero_F16 = Nombre_fisico_pestana;
			call symput('Pestana_Param_F16', Pestana_Fichero_F16);
		end;
run;

/*Se importa el reporte de F16 de Margen Financiero*/
PROC IMPORT OUT=F16_Complete
			DATAFILE="&dir_ficheros_orig.&Ruta_input_a_cargar."
			DBMS=xls replace;
			range="&Pestana_Param_F16";
			getnames=no;
RUN;

/*Se renombran los campos de interes*/
data F16_Complete2(keep= E H I 
rename=(E = Descrip H = Margen_Acti I = Margen_Pasi));
set F16_Complete;
run;

/*Se consolida en una sola columna el margen de activo y de pasivo*/
data F16_Complete3(drop=Margen_Acti Margen_Pasi);
set F16_Complete2;
	Margen = abs(coalesce(Margen_Acti,Margen_Pasi));
run;

/*Se divide el margen en Instrumento - Segmento*/

proc sql;
	create table F16_Complete4 as
		select a.*, b.Instrumento format = $9., b.Sector format = $8.
			from F16_Complete3 a LEFT JOIN &biblioteca..H_Descrip_F16 b
				ON a.Descrip = b.Descrip_F16;
quit;

/*Se resume el Margen por Instrumento y Sector y se pone en unidades
Para Credito y Deposito*/
proc sql;
	create table F16_Reporte_cre_dep as
		select Instrumento,Sector, 
				sum(Margen)*1000 as Margen_Soles
			from F16_Complete4
				group by 1,2
					having Instrumento ne "";
quit;

/*Se pasan los importes a Euros y en unidades
Para credito y depositos*/
Proc sql;
	create table F16_Reporte_Eur as
		select Instrumento, Sector,
				Margen_Soles/&Tipo_Cambio_Prom as Margen_Eur
			from F16_Reporte_cre_dep;
quit;



/*Se separa el Margen Financiero de Emisiones en una tabla aparte
y se pone en unidades*/
proc sql;
	create table &biblioteca..Margen_Emisiones as
		select a.Margen*1000 as Margen_Soles
			from F16_Complete3 a LEFT JOIN &biblioteca..H_Descrip_F16_Emi b
				ON a.Descrip = b.Descrip_F16
					where(b.Descrip_F16 ne "");
quit;


/*Se separa el Margen Financiero de Derivados en una tabla aparte
y se pone en unidades*/
proc sql;
	create table &biblioteca..Margen_Derivados as
		select a.Margen*1000 as Margen_Soles
			from F16_Complete3 a LEFT JOIN &biblioteca..H_Descrip_F16_Deriv b
				ON a.Descrip = b.Descrip_F16
					where(b.Descrip_F16 ne "");
quit;