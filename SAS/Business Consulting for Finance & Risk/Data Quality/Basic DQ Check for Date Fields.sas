/*Importo Tabla para validar el periodo de cura de 12 meses y eso*/


data TablaEntrada;
	infile "C:\Users\marco.antonio.farfa1\Documents\Management Solutions Marco\Proyectos\Proyecto Colombia\Proyecto BBVA\SAS\Validacion Periodo Cura\Input\InputsNelson\REESTRUCTURADOS_SALIDA_201612.txt" lrecl=4096 truncover;
	INPUT

		  @1 Sucursal $4.   /**/
            @5 Libre $3.   /**/
            @8 Cuenta $10.   /**/
            @18 Periodicidad $4.   /**/
            @22 FecGracia $8.   /**/
            @30 FecReestruct $8.   /**/
            @38 PeriodCura $8.   /**/
            @46 FecUltEntMora $8.    /*MORA es con mas de 30 dias*/
			@54 FecUltSalMora $8.    /**/
			@62 FecUltEntInvIrr $8. /* Entrada Inversion Irregular es de 1 a 30 dias*/
			@70 FecSalidDef $8.
 
	;
	OUTPUT TablaEntrada;

	if _ERROR_ then
		call symput('_EFIERR_',1);
run;


data Table1;
set TablaEntrada;
	format FecGracia2 DATE7.;
	format FecReestruct2 DATE7.;
	format FecUltEntMora2 DATE7.;
	format FecUltSalMora2 DATE7.;
	format FecUltEntInvIrr2 DATE7.;
	format FecSalidDef2 DATE7.;
	format Sucursal2 4.;
	format Cuenta2 10.;

	FecGracia2 = input(FecGracia,YYMMDD8.);
	FecReestruct2 = input(FecReestruct,YYMMDD8.);
	FecUltEntMora2 = input(FecUltEntMora,YYMMDD8.);
	FecUltSalMora2 = input(FecUltSalMora,YYMMDD8.);
	FecUltEntInvIrr2 = input(FecUltEntInvIrr,YYMMDD8.);
	FecSalidDef2 = input(FecSalidDef,YYMMDD8.);

	Sucursal2 = input(Sucursal, 4.);
	Cuenta2 = input(Cuenta, 10.);

run;



/*Primero verificamos que todas las filas tengan fecha de reestructuracion distinta de NULO
100%
*/

data FecReest;
set Table1;	
	if FecReestruct NE "00010101" then
		Val1 = 1;
	else
		Val1 = 0;
run;

proc sql;
create table FecReest2 as
	select (sum(Val1)/count(Val1))*100 as Porc_Val1
		from FecReest;
quit;



/*Validamos que si hay Fecha de Ultima Mora,  
FecUltSalMora2 debe ser mayor a FecReestruct2
100%
*/

proc sql;
	create table UltMora as
		select FecReestruct2, FecUltSalMora2
			from Table1
				where FecUltSalMora NE "00010101";
quit; 

data UltMora;
set UltMora;
	if FecUltSalMora2>FecReestruct2 then
		val = 1;
	else
		val = 0;
run;

proc sql;
	create table UltMora2 as
		select (sum(val)/count(val))*100 as Porc_Val
			from UltMora;
quit;



/*Ahora validamos que si hay fecha ultima salida mora y fecha ultima entrada mora informadas,
la de salida debe ser mayor a la de entrada*/

proc sql;
	create table UltEntSalMora as
		select Sucursal, Cuenta, FecReestruct2, FecUltEntMora2, FecUltSalMora2 
			from Table1
				where FecUltEntMora NE "00010101" AND FecUltSalMora NE "00010101";
quit; 

/*
data UltEntSalMora;
set UltEntSalMora;
	Mes1 = month(FecUltEntMora2);
	Mes2 = month(FecUltSalMora2);

	year1 = year(FecUltEntMora2);
	year2 = year(FecUltSalMora2);

	if not (Mes1 = Mes2 AND Mes1= 12 AND year1 = year2 AND Year1 = 2016);
run;
*/

data UltEntSalMora2;
set UltEntSalMora;
	if FecUltSalMora2>=FecUltEntMora2 then
		val = 1;
	else
		val = 0;
run;

proc sql;
	create table UltEntSalMora3 as
		select (sum(val)/count(val))*100 as Porc_Val
			from UltEntSalMora2;
quit;



/*Ahora validamos que si hay Fecha de Ultima Mora y Fecha de Gracia,  
FecUltSalMora2 debe ser mayor a FecGracia2 (aunque no necesariamente deberia ser asi)
100%
*/

proc sql;
	create table Gracia_UltMora as
		select FecReestruct2, FecGracia2, FecUltSalMora2
			from Table1
				where FecGracia NE "00010101" AND FecUltSalMora NE "00010101";
quit; 

data Gracia_UltMora;
set Gracia_UltMora;
	if FecUltSalMora2>FecGracia2 then
		val = 1;
	else
		val = 0;
run;

proc sql;
	create table Gracia_UltMora2 as
		select (sum(val)/count(val))*100 as Porc_Val
			from Gracia_UltMora;
quit;


/*Ahora verificamos que si hay Fecha de Gracia,
Esta siempre debe ser mayor a la fecha de reestructuracion
97.46%
*/

proc sql;
	create table Gracia as
		select FecReestruct2, FecGracia2
			from Table1
				where FecGracia NE "00010101";
quit;

data Gracia;
set Gracia;
	if FecGracia2>FecReestruct2 then
		val = 1;
	else
		val = 0;
run;

proc sql;
	create table Gracia2 as
		select (sum(val)/count(val))*100 as Porc_Val
			from Gracia;
quit;



/*
Ahora validamos que la fecha de salida default siempre sea el ultimo dia del mes siguiente
a la fecha de calculo (podria ser FecReestruct, FecGracia o FecUltSalMora)

100% DQ
*/

proc sql;
create table ValFecSalDef as
	select FecReestruct, FecGracia, FecUltSalMora, FecSalidDef, FecReestruct2 , FecGracia2, FecUltSalMora2, FecSalidDef2, PeriodCura
		from Table1
			where FecSalidDef NE "00010101";
quit;

data ValFecSalDef;
set ValFecSalDef;
	format FechaCalculo DATE7.;

	if FecUltSalMora NE "00010101" then
		FechaCalculo = FecUltSalMora2;

	else if FecGracia NE "00010101" then
		do;
			if FecGracia2>FecReestruct2 then
				FechaCalculo = FecGracia2;
			else 
				FechaCalculo = FecReestruct2;
		end;
	else
		FechaCalculo = FecReestruct2;
run;

/*
Nota:   como la base se actulizo a enero 2011,
entonces los reestructurados antes del 2011 tienen fecha salid default enero 2011 por default
excepto los casos en que tienen fecha ultima mora y/o fecha gracia informada:  */


data ValFecSalDef2;
set ValFecSalDef;
	if not (year(FechaCalculo) < 2011);	
run;


data ValFecSalDef2;
set ValFecSalDef2;

	datediff = intck('MONTH',FechaCalculo,FecSalidDef2);

	if datediff = 1 then
		Valid = 1;
	else
		Valid = 0;
run;


proc sql;
	create table ValFecSalDef3 as
		select (sum(Valid)/count(Valid))*100 as Porc_Valid
			from ValFecSalDef2;
quit;



/*
Ahora validamos que del grupo que tiene fecha salida default valida, 
TENGA UN periodo de cura valido (que la cuenta este OK)
100%
*/

proc sql;
create table ValFecSalDefff as
	select FecReestruct, FecGracia, FecUltSalMora, FecSalidDef, FecReestruct2 , FecGracia2, FecUltSalMora2, FecSalidDef2, PeriodCura
		from Table1
			where FecSalidDef NE "00010101";
quit;

data ValPerioGarant;
set ValFecSalDefff;
	format FechaFin DATE7.;
	format PeriodCura2 8.;

	FechaFin = INPUT("20161231",yymmdd8.);
	datediff = intck('MONTH',FecSalidDef2,FechaFin) + 1;

	PeriodCura2 = INPUT(PeriodCura,8.);

	if datediff = PeriodCura2 then
		Valid = 1;
	else
		Valid = 0; 
run;

proc sql;
	create table ValPerioGarant2 as
		select (sum(Valid)/count(Valid))*100 as Porc_Valid
			from ValPerioGarant;
quit;



/*

Adicinalmente validemos que la fecha salida ultima mora que me dan coincida con lo de la 
sgt base que me indica lo dias de pago de cada mes


Bloque 2 (Fecha Ultima Mora) de la verificacion de 1 mes entre fecCalculo y FecSalDef

*/

data TablaCruzada;
set "C:\Users\marco.antonio.farfa1\Documents\Management Solutions Marco\Proyectos\Proyecto Colombia\Proyecto BBVA\SAS\Validacion Periodo Cura\Input\tablacruzada.sas7bdat";
run;



proc sql;
create table SegValFecCal2a as
	select  NUMERO_OP, SUC_OBL_AL, 
			DIAS_ENE_00,DIAS_FEB_00,DIAS_MAR_00,DIAS_ABR_00,DIAS_MAY_00,DIAS_JUN_00,DIAS_JUL_00,DIAS_AGO_00,DIAS_SEP_00,DIAS_OCT_00,DIAS_NOV_00,DIAS_DIC_00,
			DIAS_ENE_01,DIAS_FEB_01,DIAS_MAR_01,DIAS_ABR_01,DIAS_MAY_01,DIAS_JUN_01,DIAS_JUL_01,DIAS_AGO_01,DIAS_SEP_01,DIAS_OCT_01,DIAS_NOV_01,DIAS_DIC_01,
			DIAS_ENE_02,DIAS_FEB_02,DIAS_MAR_02,DIAS_ABR_02,DIAS_MAY_02,DIAS_JUN_02,DIAS_JUL_02,DIAS_AGO_02,DIAS_SEP_02,DIAS_OCT_02,DIAS_NOV_02,DIAS_DIC_02,
			DIAS_ENE_03,DIAS_FEB_03,DIAS_MAR_03,DIAS_ABR_03,DIAS_MAY_03,DIAS_JUN_03,DIAS_JUL_03,DIAS_AGO_03,DIAS_SEP_03,DIAS_OCT_03,DIAS_NOV_03,DIAS_DIC_03,
			DIAS_ENE_04,DIAS_FEB_04,DIAS_MAR_04,DIAS_ABR_04,DIAS_MAY_04,DIAS_JUN_04,DIAS_JUL_04,DIAS_AGO_04,DIAS_SEP_04,DIAS_OCT_04,DIAS_NOV_04,DIAS_DIC_04,
			DIAS_ENE_05,DIAS_FEB_05,DIAS_MAR_05,DIAS_ABR_05,DIAS_MAY_05,DIAS_JUN_05,DIAS_JUL_05,DIAS_AGO_05,DIAS_SEP_05,DIAS_OCT_05,DIAS_NOV_05,DIAS_DIC_05,
			DIAS_ENE_06,DIAS_FEB_06,DIAS_MAR_06,DIAS_ABR_06,DIAS_MAY_06,DIAS_JUN_06,DIAS_JUL_06,DIAS_AGO_06,DIAS_SEP_06,DIAS_OCT_06,DIAS_NOV_06,DIAS_DIC_06,
			DIAS_ENE_07,DIAS_FEB_07,DIAS_MAR_07,DIAS_ABR_07,DIAS_MAY_07,DIAS_JUN_07,DIAS_JUL_07,DIAS_AGO_07,DIAS_SEP_07,DIAS_OCT_07,DIAS_NOV_07,DIAS_DIC_07,
			DIAS_ENE_08,DIAS_FEB_08,DIAS_MAR_08,DIAS_ABR_08,DIAS_MAY_08,DIAS_JUN_08,DIAS_JUL_08,DIAS_AGO_08,DIAS_SEP_08,DIAS_OCT_08,DIAS_NOV_08,DIAS_DIC_08,
			DIAS_ENE_09,DIAS_FEB_09,DIAS_MAR_09,DIAS_ABR_09,DIAS_MAY_09,DIAS_JUN_09,DIAS_JUL_09,DIAS_AGO_09,DIAS_SEP_09,DIAS_OCT_09,DIAS_NOV_09,DIAS_DIC_09,
			DIAS_ENE_10,DIAS_FEB_10,DIAS_MAR_10,DIAS_ABR_10,DIAS_MAY_10,DIAS_JUN_10,DIAS_JUL_10,DIAS_AGO_10,DIAS_SEP_10,DIAS_OCT_10,DIAS_NOV_10,DIAS_DIC_10,
			DIAS_ENE_11,DIAS_FEB_11,DIAS_MAR_11,DIAS_ABR_11,DIAS_MAY_11,DIAS_JUN_11,DIAS_JUL_11,DIAS_AGO_11,DIAS_SEP_11,DIAS_OCT_11,DIAS_NOV_11,DIAS_DIC_11,
			DIAS_ENE_12,DIAS_FEB_12,DIAS_MAR_12,DIAS_ABR_12,DIAS_MAY_12,DIAS_JUN_12,DIAS_JUL_12,DIAS_AGO_12,DIAS_SEP_12,DIAS_OCT_12,DIAS_NOV_12,DIAS_DIC_12,
			DIAS_ENE_13,DIAS_FEB_13,DIAS_MAR_13,DIAS_ABR_13,DIAS_MAY_13,DIAS_JUN_13,DIAS_JUL_13,DIAS_AGO_13,DIAS_SEP_13,DIAS_OCT_13,DIAS_NOV_13,DIAS_DIC_13,
			DIAS_ENE_14,DIAS_FEB_14,DIAS_MAR_14,DIAS_ABR_14,DIAS_MAY_14,DIAS_JUN_14,DIAS_JUL_14,DIAS_AGO_14,DIAS_SEP_14,DIAS_OCT_14,DIAS_NOV_14,DIAS_DIC_14,
			DIAS_ENE_15,DIAS_FEB_15,DIAS_MAR_15,DIAS_ABR_15,DIAS_MAY_15,DIAS_JUN_15,DIAS_JUL_15,DIAS_AGO_15,DIAS_SEP_15,DIAS_OCT_15,DIAS_NOV_15,DIAS_DIC_15,
			DIAS_ENE_16,DIAS_FEB_16,DIAS_MAR_16,DIAS_ABR_16,DIAS_MAY_16,DIAS_JUN_16,DIAS_JUL_16,DIAS_AGO_16,DIAS_SEP_16,DIAS_OCT_16,DIAS_NOV_16,DIAS_DIC_16
			
		from TablaCruzada;
quit;



/*******************************Esta es la TABLA MAS COMPLETA: *****************************************/
proc sql;
create table SegValFecCal2b as
	select a.FecReestruct, a.FecUltSalMora, a.FecSalidDef, a.FecGracia, a.FecUltEntMora, 
			a.FecReestruct2, a.FecUltSalMora2, a.FecSalidDef2, a.FecGracia2, a.FecUltEntMora2
			  ,b.*
		from Table1 a LEFT JOIN SegValFecCal2a b
			ON a.Cuenta2 = b.NUMERO_OP AND a.Sucursal2 = b.SUC_OBL_AL;
quit;



proc sql;
create table SegValFecCal2 as
	select *
		from SegValFecCal2b
			where FecSalidDef NE "00010101" AND FecUltSalMora NE "00010101";
quit;



/*Test*/


/*We UPPERCASE all column names
because there are some which are in lowercase*/

%MACRO UpcaseCharVar(lib, ds);	/* lib: library's name 
ds: dataset's name */
proc sql noprint;
select count(distinct name)
into :NbrCharVar
from dictionary.columns
where libname = upcase("&lib")
and memname = upcase("&ds")
and type = 'char';
quit;

%let NbrCharVar = &NbrCharVar;	/* Removes Leading and Trailing Blanks */

proc sql noprint;
select name
into :CharVar1-:CharVar&NbrCharVar
from dictionary.columns
where libname = upcase("&lib")
and memname = upcase("&ds")
and type = 'char';
quit;

%IF &NbrCharVar > 0 %THEN
%DO i=1 %TO &NbrCharVar;
proc sql;
update &lib..&ds
set &&CharVar&i = upcase(&&CharVar&i);
quit;
%END;
%MEND;

%UpcaseCharVar(Work, SegValFecCal2);






data SegValFecCal3;
set SegValFecCal2;
	array arreglo1[203] $ DIAS_DIC_16 DIAS_NOV_16 DIAS_OCT_16 DIAS_SEP_16 DIAS_AGO_16 DIAS_JUL_16 DIAS_JUN_16 DIAS_MAY_16
						DIAS_ABR_16 DIAS_MAR_16 DIAS_FEB_16 DIAS_ENE_16 DIAS_DIC_15 DIAS_NOV_15 DIAS_OCT_15 DIAS_SEP_15
						DIAS_AGO_15 DIAS_JUL_15 DIAS_JUN_15 DIAS_MAY_15 DIAS_ABR_15 DIAS_MAR_15 DIAS_FEB_15 DIAS_ENE_15
						DIAS_DIC_14 DIAS_NOV_14 DIAS_OCT_14 DIAS_SEP_14 DIAS_AGO_14 DIAS_JUL_14 DIAS_JUN_14 DIAS_MAY_14
						DIAS_ABR_14 DIAS_MAR_14 DIAS_FEB_14 DIAS_ENE_14 DIAS_DIC_13 DIAS_NOV_13 DIAS_OCT_13 DIAS_SEP_13
						DIAS_AGO_13 DIAS_JUL_13 DIAS_JUN_13 DIAS_MAY_13 DIAS_ABR_13 DIAS_MAR_13 DIAS_FEB_13 DIAS_ENE_13
						DIAS_DIC_12 DIAS_NOV_12 DIAS_OCT_12 DIAS_SEP_12 DIAS_AGO_12 DIAS_JUL_12 DIAS_JUN_12 DIAS_MAY_12 
						DIAS_ABR_12 DIAS_MAR_12 DIAS_FEB_12 DIAS_ENE_12 DIAS_DIC_11 DIAS_NOV_11 DIAS_OCT_11 DIAS_SEP_11
						DIAS_AGO_11 DIAS_JUL_11 DIAS_JUN_11 DIAS_MAY_11 DIAS_ABR_11 DIAS_MAR_11 DIAS_FEB_11 DIAS_ENE_11
						DIAS_DIC_10 DIAS_NOV_10 DIAS_OCT_10 DIAS_SEP_10 DIAS_AGO_10 DIAS_JUL_10 DIAS_JUN_10 DIAS_MAY_10
						DIAS_ABR_10 DIAS_MAR_10 DIAS_FEB_10 DIAS_ENE_10 DIAS_DIC_09 DIAS_NOV_09 DIAS_OCT_09 DIAS_SEP_09
						DIAS_AGO_09 DIAS_JUL_09 DIAS_JUN_09 DIAS_MAY_09 DIAS_ABR_09 DIAS_MAR_09 DIAS_FEB_09 DIAS_ENE_09
						DIAS_DIC_08 DIAS_NOV_08 DIAS_OCT_08 DIAS_SEP_08 DIAS_AGO_08 DIAS_JUL_08 DIAS_JUN_08DIAS_MAY_08
						DIAS_ABR_08 DIAS_MAR_08 DIAS_FEB_08 DIAS_ENE_08 DIAS_DIC_07 DIAS_NOV_07 DIAS_OCT_07 DIAS_SEP_07
						DIAS_AGO_07 DIAS_JUL_07 DIAS_JUN_07 DIAS_MAY_07 DIAS_ABR_07 DIAS_MAR_07 DIAS_FEB_07 DIAS_ENE_07
						DIAS_DIC_06 DIAS_NOV_06 DIAS_OCT_06 DIAS_SEP_06 DIAS_AGO_06 DIAS_JUL_06 DIAS_JUN_06 DIAS_MAY_06
						DIAS_ABR_06 DIAS_MAR_06 DIAS_FEB_06 DIAS_ENE_06 DIAS_DIC_05 DIAS_NOV_05 DIAS_OCT_05 DIAS_SEP_05 
						DIAS_AGO_05 DIAS_JUL_05 DIAS_JUN_05 DIAS_MAY_05 DIAS_ABR_05 DIAS_MAR_05 DIAS_FEB_05 DIAS_ENE_05
						DIAS_DIC_04 DIAS_NOV_04 DIAS_OCT_04 DIAS_SEP_04 DIAS_AGO_04 DIAS_JUL_04 DIAS_JUN_04 DIAS_MAY_04
						DIAS_ABR_04 DIAS_MAR_04 DIAS_FEB_04 DIAS_ENE_04 DIAS_DIC_03 DIAS_NOV_03 DIAS_OCT_03 DIAS_SEP_03
						DIAS_AGO_03 DIAS_JUL_03 DIAS_JUN_03 DIAS_MAY_03 DIAS_ABR_03 DIAS_MAR_03 DIAS_FEB_03 DIAS_ENE_03
						DIAS_DIC_02 DIAS_NOV_02 DIAS_OCT_02 DIAS_SEP_02 DIAS_AGO_02 DIAS_JUL_02 DIAS_JUN_02 DIAS_MAY_02
						DIAS_ABR_02 DIAS_MAR_02 DIAS_FEB_02 DIAS_ENE_02 DIAS_DIC_01 DIAS_NOV_01 DIAS_OCT_01 DIAS_SEP_01
						DIAS_AGO_01 DIAS_JUL_01 DIAS_JUN_01 DIAS_MAY_01 DIAS_ABR_01 DIAS_MAR_01 DIAS_FEB_01 DIAS_ENE_01 
						DIAS_DIC_00 DIAS_NOV_00 DIAS_OCT_00 DIAS_SEP_00 DIAS_AGO_00 DIAS_JUL_00 DIAS_JUN_00 DIAS_MAY_00
						DIAS_ABR_00 DIAS_MAR_00 DIAS_FEB_00 DIAS_ENE_00;

	do i=1 to 200;
		if (arreglo1[i+1]>30) AND (arreglo1[i]<=30) then /*Lo cambie para estar iguales con el del piso3: mora>=30*/
			do;
				NumDiasSalioMora = arreglo1[i];
				leave;
			end;
	end;

	/*FechUltMoraVerdad indica el mes que estuvo por ultima vez en mora,
	si a este valor le sumamos 1 mes ENTONCES deberiamos tener la fec salida default*/
	
	format FechFin DATE7.;
	format FechUltMoraVerdad DATE7.;

	FechFin = INPUT("20161231",yymmdd8.);
	j=i*-1;
	
	FechUltMoraVerdad = intnx('month',FechFin,j);

	datediff = intck('MONTH',FechUltMoraVerdad,FecSalidDef2);

	if datediff = 1 then
		Valid = 1;
	else
		Valid = 0;

run;

/*
DQ 94.3%
*/


proc sql;
	create table SegValFecCal4 as
		select (sum(Valid)/count(Valid))*100 as Porc_Valid
			from SegValFecCal3;
quit;


/* tabla de fec ultima salida mora malos: */
PROC SQL;
create table marcox as
	select *
		from SegValFecCal3
			where Valid = 0;
QUIT;




proc export data=SegValFecCal3
outfile="C:\Users\marco.antonio.farfa1\Desktop\exportado.xls";
run;


libname miLib "C:\Users\marco.antonio.farfa1\Documents\Management Solutions Marco\";

data miLib.SalidaUltMora;
set SegValFecCal3;
run;





/*Lo ultimo que faltaba era verificar que si la fecha salida default es NULA
entonces significa que la cuenta tiene mora a diciembre 2016,
que DIAS_DIC_16 es mayor a 30

Data Quality: 
*/


proc sql;
	create table FecSalDefNul as
		select FecReestruct, FecGracia, FecUltEntMora, FecUltSalMora, FecSalidDef,
				FecReestruct2, FecGracia2, FecUltEntMora2, FecUltSalMora2, FecSalidDef2, DIAS_DIC_16
			from SegValFecCal2b
				where FecSalidDef = "00010101";
quit;



data FecSalDefNul;
set FecSalDefNul;
	format FechaCalculo DATE7.;

	if FecUltSalMora NE "00010101" then
		FechaCalculo = FecUltSalMora2;

	else if FecGracia NE "00010101" then
		do;
			if FecGracia2>FecReestruct2 then
				FechaCalculo = FecGracia2;
			else 
				FechaCalculo = FecReestruct2;
		end;
	else
		FechaCalculo = FecReestruct2;
run;


/*debemos filtrar los casos en que fecha calculo sea diciembre 2016
xq ahi termina el analisis*/

data FecSalDefNul2;
set FecSalDefNul;
	if not (year(FechaCalculo) = 2016 AND month(FechaCalculo) = 12);
run;	

/*De los que restan, la fecha salida default no esta informada xq el periodo gracia es
mayor a diciembre 2016 ENTONCES la fecha de calculo es mayor a diciembre 2016

100% DQ
*/

data FecSalDefNul3;
set FecSalDefNul2;
	if year(FechaCalculo) > 2016 then
		Valid = 1;
	else
		Valid = 0;
run;

proc sql;
	create table FecSalDefNul4 as
		select (sum(Valid)/count(Valid)) * 100 as Porc_Val
			from FecSalDefNul3;
quit;




