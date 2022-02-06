

libname frg_r "/sasdata2/Finanzas/Datamart FIN/MIS CLIENTES";


/*El descuadre de margen a nivel epigrafe era causado porque hubo un cambio de tepirela
entre diciembre 31 y enero 18*/

/*Se toma solo los campos que se necesitan para Stress Test*/
proc sql;
/*no se esta tomando la secuencia, tenerlo en mente*/
	create table Repositorio_ST_Cuadre as
		select /*SLECMOV0_PERIODO as Periodo,*/
				SLECMOV0_NUMCLEN as Num_Client,
				SLECMOV0_CONTRATO as Contrato,
				SLECMOV0_CENTRO as CeConta, /*centro contable*/
				SLECMOV0_DIVISA as Divisa,
				SLECMOV0_CONCEPAN as Concepan, /*concepto analitico*/
				SLECMOV0_NUCTA as Cuenta,/*cuenta contable*/

				/*Informacion de todo 2017*/
				SLECMOV0_IMPORTM02, SLECMOV0_IMPORTM03, SLECMOV0_IMPORTM04, SLECMOV0_IMPORTM05,
				SLECMOV0_IMPORTM06, SLECMOV0_IMPORTM07, SLECMOV0_IMPORTM08, SLECMOV0_IMPORTM09,
				SLECMOV0_IMPORTM10, SLECMOV0_IMPORTM11, SLECMOV0_IMPORTM12, SLECMOV0_IMPORTM13

					from "&dir_hist_mov.&hist_mov_contr."
						where((SLECMOV0_INDANAL = "A") AND (SLECMOV0_TIPODIV = "0")
											/*1 es divisa origen; 0 es contravalorado a soles*/
								AND (Concepan IN ("001","002","008","009",/*margen financiero*/
												  "006","007", /*Comisiones se usan para el cuadre vs MIS clientes*/
												  "016","017","018")) /*saldo medio*/

/*											AND (SLECMOV0_NUCTA NE "451301054152") */
							/*Esta cuenta traia unos margenes
							que hacian al MF > SM para 2015 y 2016. En 2017 en cambio
							su importe figura 0*/
								)
								;
															
quit;


/*Trato los signos y le doy formato a la cuenta contable*/
data Repositorio_ST_Cuadre2(drop=Cuenta rename=(Cta_Contable = Cuenta));
set Repositorio_ST_Cuadre;

/*Para no repetir varias veces el mismo codigo de tratamiento de signo,
usamos un array e iteramos para todos los saldos*/

	array Importes {12} SLECMOV0_IMPORTM02 SLECMOV0_IMPORTM03 SLECMOV0_IMPORTM04 SLECMOV0_IMPORTM05
						SLECMOV0_IMPORTM06 SLECMOV0_IMPORTM07 SLECMOV0_IMPORTM08 SLECMOV0_IMPORTM09
						SLECMOV0_IMPORTM10 SLECMOV0_IMPORTM11 SLECMOV0_IMPORTM12 SLECMOV0_IMPORTM13;

/*Para saber si la operacion estuvo viva en un mes y ponderarla en el calculo anual*/
	array Flag {12} Flag01 Flag02 Flag03 Flag04
					Flag05 Flag06 Flag07 Flag08
					Flag09 Flag10 Flag11 Flag12;

	format Cta_Contable $15.;
	Cta_Contable=trim(cats(Cuenta,"0000000000000")); /*lo pasamos a formato 15 caracteres*/


	do i=1 to 12;

		if (substr(Cuenta,1,1) = "5" AND Concepan = "002") then 
			Importes(i) = Importes(i)*-1;
		else if (substr(Cuenta,1,1) = "4") then
			Importes(i) = Importes(i)*-1;
		else if (Concepan = "007") then
			Importes(i) = Importes(i)*-1;
		else if (Concepan = "009") then
			Importes(i) = Importes(i)*-1;
		else if (substr(Cuenta,1,1) = "1" AND Concepan = "017") then
			Importes(i) = Importes(i)*-1;
		else if (substr(Cuenta,1,1) = "2" AND Concepan = "018") then
			Importes(i) = Importes(i)*-1;	

		if (Importes(i) = 0) then
			Flag(i) = 0; /*Indica que la operacion no estuvo viva en ese mes*/
		else
			Flag(i) = 1; 

	end;	
run;

/*Ahora necesito sumar los margenes de todo el año para tener el acumulado
y para el saldo medio pondero por el numero de dias de cada mes*/


/*Escogemos las columnas de acuerdo a la fecha de datos del reporte*/
data Repositorio_ST_Cuadre3;
set Repositorio_ST_Cuadre2;
	if (Concepan IN ("001","002","008","009","006","007")) then /*Margen acumulado*/
		do;
			Indicador = "MF";

			Importe_dic = SLECMOV0_IMPORTM02+ SLECMOV0_IMPORTM03+ SLECMOV0_IMPORTM04+ SLECMOV0_IMPORTM05+
						  SLECMOV0_IMPORTM06+ SLECMOV0_IMPORTM07+ SLECMOV0_IMPORTM08+ SLECMOV0_IMPORTM09+
						  SLECMOV0_IMPORTM10+ SLECMOV0_IMPORTM11+ SLECMOV0_IMPORTM12+ SLECMOV0_IMPORTM13;

		end;
	else /*Saldo medio acumulado*/
		do;
			Indicador = "SM";

		/*Si no tenemos ningun importe en ningun mes del anio (todos 0) entonces 
				directamente el promedio debera ser 0*/
			if (sum(31*Flag01,30*Flag02,31*Flag03,30*Flag04,
					31*Flag05,31*Flag06,30*Flag07,31*Flag08,
					30*Flag09,31*Flag10,28*Flag11,31*Flag12) = 0) then
				Importe_dic = 0;
			else /*Si por lo menos 1 mes es distinto de 0, entonces se calcula el promedio
					tomando en cuenta solo los meses vivos*/
				Importe_dic = (sum(SLECMOV0_IMPORTM02*31, SLECMOV0_IMPORTM03*30, SLECMOV0_IMPORTM04*31, 
								   SLECMOV0_IMPORTM05*30, SLECMOV0_IMPORTM06*31, SLECMOV0_IMPORTM07*31,
								   SLECMOV0_IMPORTM08*30, SLECMOV0_IMPORTM09*31, SLECMOV0_IMPORTM10*30,
								   SLECMOV0_IMPORTM11*31, SLECMOV0_IMPORTM12*28, SLECMOV0_IMPORTM13*31)
								/
							   sum(31*Flag01,30*Flag02,31*Flag03,30*Flag04,
								   31*Flag05,31*Flag06,30*Flag07,31*Flag08,
								   30*Flag09,31*Flag10,28*Flag11,31*Flag12));
		end;

run;


/*Se trae el Epigrafe*/
proc sql;
	create table Repositorio_ST_Cuadre3_Epig as
		select a.*, b.'Epigrafe Local'n as Epigrafe
			from Repositorio_ST_Cuadre3 a LEFT JOIN Epigrafe_CContable_Format_dis b
				ON a.Cuenta = b.Cuenta;
quit;


/*Resumen a nivel Epigrafe del Margen Financiero*/
proc sql;
	create table Repositorio_Cuadre_MIS_Clie as
		select Epigrafe, sum(Importe_dic) as Margen_Acum, sum(SLECMOV0_IMPORTM02) as Margen_Dic
			from Repositorio_ST_Cuadre3_Epig
				where(Indicador = "MF") /*Seleccionamos info de Margen*/
					group by 1;
quit;




/*Se carga el reporte de MIS Clientes de Margen Financiero a nivel Epigrafe*/

%let Nombre_Logico_Input = Cuadre_Rep_Historico_MIS_Cli;

* Se busca la ruta física en la tabla "FICHEROS_INPUT";
data _NULL_;
	set FICHEROS_INPUT;

	if Nombre_Logico_Fichero = "&Nombre_Logico_Input" then do;
		call symput('Ruta_input_a_cargar', trim(Ruta));
	end;

run;

/*Se Importa el fichero de MIS Clientes para cuadrar el Margen Financiero a nivel epigrafe*/
proc import datafile= "&dir_ficheros_orig.&Ruta_input_a_cargar."
	dbms= xlsx replace
	out=Cuadre_MIS_Clie;
	sheet="Resultados";
	getnames=no;
	datarow=4;
run;

/*Se da formato*/
data Cuadre_MIS_Clie2(keep=A D rename=(A=Epigrafe D=Importe));
set Cuadre_MIS_Clie;
run;

/*Se realiza el Cuadre de Margen Financiero del Historico de Movimientos vs MIS Clientes*/
proc sql;
	create table Cuadre_Histor1 as
		select a.*, b.Margen_Acum as Margen_Acum_FRG, b.Margen_Dic as Margen_Dic_FRG
			from Cuadre_MIS_Clie2 a LEFT JOIN Repositorio_Cuadre_MIS_Clie b
				ON a.Epigrafe = b.Epigrafe;
quit;

/*Tambien se calcula la diferencia en Porcentaje*/
data Cuadre_Histor2(keep=Epigrafe Importe Margen_Dic_FRG Diferencia Diferencia_Porc);
set Cuadre_Histor1;
	Diferencia = Importe - Margen_Dic_FRG;

	if (Margen_Dic_FRG IN (0,.)) then
		Diferencia_Porc = .;
		
	else 
		Diferencia_Porc = ((Importe - Margen_Dic_FRG)/Margen_Dic_FRG)*100;
run;


/*Se exporta a excel el cuadre de FRG vs MIS Clientes*/

/*Exportacion sin formato*/
%exportXLS(Cuadre_Histor2, 
			&localProjectPath.&dirLog.&hora_generacion_pestana_ajust._CuadreFRG.xlsx,
			FRG_vs_MIS_Clie);


/*Exportacion en formato especial excel*/
/*%exportFormattedXLS(Cuadre_Histor2,*/
/*					&localProjectPath.&dirLog.&hora_generacion_pestana_ajust._CuadreFRG.xls,*/
/*					FRG_vs_MIS_Clie);*/


%borrarTabla(Repositorio_ST_Cuadre);
%borrarTabla(Repositorio_ST_Cuadre2);
%borrarTabla(Repositorio_ST_Cuadre3);
%borrarTabla(Repositorio_ST_Cuadre3_Epig);