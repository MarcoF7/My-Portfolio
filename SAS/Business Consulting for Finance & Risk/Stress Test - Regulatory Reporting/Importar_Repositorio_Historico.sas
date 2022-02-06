/*** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***/

/* PROGRAMA: Importar_Repositorio_Historico.sas
/* OBJETIVO: Carga del Repositorio Historico de Movimientos
/* AUTOR:	 Management Solutions
/* PROCESO:  Se realiza la importación del Repositorio Historico (FRG) 
/*			 
/*
/* 			 CONJUNTOS DE DATOS GENERADOS:
/* 			 - ...
/* 			 - ...
/*
/* FECHA: 06/12/2017
/*
/* NOTAS: ...
/*
/* LOG DE CAMBIOS:
/* FECHA	AUTOR	Objetivo
/* ...
/*** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***/

%PUT job "Importar_Repositorio_Historico.sas" comenzó a %now;


/*Se carga la ruta en donde se guardara el mini FRG, despues del tratamiento del FRG original*/
%let Nombre_Logico_Input = Lib_Mini_FRG;

data _NULL_;
	set FICHEROS_INPUT;

	if Nombre_Logico_Fichero = "&Nombre_Logico_Input" then do;
		call symput('Ruta_mini_FRG', trim(Ruta));
	end;

run;


/*libreria destino del FRG:
Esta es la ruta donde se tendra la base FRG reducida, 
En esta ruta se hara la pregunta si ya existe la base reducida antes de crearla
para ahorrar tiempo de procesamiento*/
LIBNAME FRG_des "&dir_ficheros_orig.&Ruta_mini_FRG";

* Se asigna el nombre lógico del fichero;
%let Nombre_Logico_Input = Mini_FRG;

* Se busca la ruta física en la tabla "FICHEROS_INPUT";
data _NULL_;
	set FICHEROS_INPUT;

	if Nombre_Logico_Fichero = "&Nombre_Logico_Input" then do;
		call symput('Ruta_input_a_cargar', trim(Ruta));
	end;

run;

/*----------------------------------------------*/
/*------LEYENDA Historico de Movimientos-------*/
/*--------------------------------------------*/
/*COD_CONABCP=SUB PRODUCTO FRG */
/*COD_CONCMAC= PRODUCTO FRG*/
/*COD_CTAGES= CUENTA CONTABLE */
/*COD_IDCONTRA= CODIGO DE CONTRATO ENMASCARDO*/
/*COD_OFICNTBL= OFICINA*/
/*COD_PERSCTPN= CLIENTE*/
/*COD_SERVCRDR= CONCEPAN*/
/*FEC_CIERRE= FECHA DE CIERRE*/
/*IMP_RESANCTR= RESULTADO ACUMUALDO*/
/*IMP_RESINCTR= RESULTADO INTERANUAL*/
/*IMP_RESMECTR= RESULTADO ESTANCO*/
/*IMP_SALMACTR= SALDO MEDIO ACUMUALDO*/
/*IMP_SALMECTR=SALDO MEDIO MES*/
/*IMP_SALMICTR=SALDO MEDIO INTERANUAL*/
/*IMP_SALPUCTR=SALDO PUNTUAL*/
/*COD_MASCCNTR= CODIGO DE CONTRATO ALTAMIRA(LOCAL)*/

/*
Concepanes:
19,99 -> Saldo Puntual
16,17,18,99 -> Saldo Medio
1,2,6,7,8,9 -> Resultados

IMP_SALPUCTR -> Saldo Puntual (Concepanes 19,99)
IMP_SALMECTR, IMP_SALMACTR -> Saldo Medio (Concepanes 16,17,18,99)
IMP_RESMECTR, IMP_RESANCTR -> Margen Financiero (Concepanes 1,2,6,7,8,9)

El Saldo Medio ACUMULADO lo calcula para todos los meses hasta la fecha de cierre
de la tabla esté o no vivo el contrato a la fecha de cierre, 
ENTONCES es suficiente con tomar el último FRG y coger las columas de 
Saldo Medio Acumulado

Igual para Margen Financiero, si el contrato muere antes de la fecha de la tabla,
pero meses anteriores tuvo margen, entonces este margen acumulado se arrastra 
en los demás meses del año

RESUMEN: Suficiente con tomar las columnas de Saldo Medio Acumulado y
Margen Financiero Acumulado
*/



/*Tener en cuenta que el fileexist es case sensitive*/

%Macro Crear_Si_No_Existe;
	/*Si no existe la minibase (= 0), entonces se crea
	Con esto evitamos volver a crear la mini base FRG cada vez que se ejecuta el motor,
	puesto que la base es muy pesada y toma tiempo procesar*/
	%if %sysfunc(fileexist("&dir_ficheros_orig.&Ruta_input_a_cargar")) = 0 %then 
		%do;


			/*Se toman los campos de interés del Historico de Movimientos y 
			se enriquece el Contrato con la tabla Traducción Contrato*/
			proc sql;
				create table Hist_Movim_Acum as
					select b.COD_MASCCNTR as Contrato,
							a.COD_OFICNTBL as Oficina, 
							a.COD_CTAGES as Cta_Cont, 
							/*a.FEC_CIERRE, */
							a.COD_SERVCRDR as Concepan, 
							/*a.IMP_SALPUCTR as Saldo_Puntual,*/
							/*a.IMP_SALMECTR as Saldo_Medio,*/
							a.IMP_SALMACTR as Saldo_Medio_Acum, 
							/*a.IMP_RESMECTR as Margen,*/
							a.IMP_RESANCTR as Margen_Acum
						from "&dir_hist_mov.&hist_mov_acum." a LEFT JOIN "&dir_hist_mov.&hist_mov_contr." b
							ON a.COD_IDCONTRA = b.COD_IDCONTRA
								where(a.COD_SERVCRDR IN 
										(1,2,6,7,8,9,16,17,18,19,99)
									);
			quit;

			/*Se necesita agrupar los Concepanes correspondientes a Saldo Medio y
			a Margen Financiero*/
			data Hist_Movim_Acum2;
			set Hist_Movim_Acum;
				format Indicador $2.;
				if (Concepan IN (16,17,18,99)) then
					Indicador = "SM";
				else if (Concepan IN (1,2,6,7,8,9)) then
					Indicador = "MF";
			run;

			proc sql;
				create table Hist_Movim_Acum3 as
					select Contrato, Oficina, Cta_Cont, Indicador,
						sum(Saldo_Medio_Acum) as Saldo_Medio_Acum,
						sum(Margen_Acum) as Margen_Acum
						from Hist_Movim_Acum2
							group by 1,2,3,4;
			quit;

			/*Se pasa la cuenta contable a formato 15 Caracteres y
			se retira del análisis los contratos que no aportan ni Margen ni Saldo Medio a la vez*/
			data Hist_Movim_Acum4(drop=Cta_Cont rename=(Cta_Contable = Cuenta));
			set Hist_Movim_Acum3;
				format Cta_Contable $15.;
				Cta_Contable=trim(cats(Cta_Cont,"0000000000000")); /*lo pasamos a formato 15 caracteres*/
				where not (Saldo_Medio_Acum = 0 AND Margen_Acum = 0);
			run;

			/*Se enriquece con el Epigrafe*/
			proc sql;
				create table Hist_Movim_Acum5 as
					select a.*, b.'EPIGRAFE LOCAL'n as Epigrafe
						from Hist_Movim_Acum4 a LEFT JOIN Epigrafe_CContable_Format_dis b
							ON a.Cuenta = b.Cuenta;
			quit;


			/*Se resume en una sola Tabla el Saldo Medio y Margen Financiero a nivel
			Contrato, Oficina, Indicador (Saldo Medio o Margen Financiero) y Epigrafe*/	
			proc sql;
				create table FRG_des.minifrg_&fechaReporte as
					select Contrato, Oficina, Indicador, Epigrafe,
							sum(Saldo_Medio_Acum) as Saldo_Medio_Acum,
							sum(Margen_Acum) as Margen_Acum
							from Hist_Movim_Acum5
								group by 1,2,3,4;
			quit;

		%end;
%mend Crear_Si_No_Existe;


/*Solo genera minifrg_fechareporte si esta no existe*/
%Crear_Si_No_Existe;


/*Paso el Saldo Medio y Margen Financiero a Euros y en unidades*/
/*21468399*/
Proc sql;
	create table &biblioteca..RepositorioEur_&FechaReporte as
		select a.Contrato, a.Oficina, a.Epigrafe, a.Indicador,
				a.Saldo_Medio_Acum/b.Tipo_Cambio as Saldo_Medio_Euros,
				a.Margen_Acum/b.Tipo_Cambio as Margen_Euros
			from FRG_des.minifrg_&fechaReporte a,
				(select Tipo_Cambio from &bibliotecaInputs..Tipo_De_Cambio where Divisa="EUR") b;
quit;


/*Borramos todas las tablas intermedias que ya no se usan para liberar espacio en la memoria*/
%borrarTabla(Hist_Movim_Acum);
%borrarTabla(Hist_Movim_Acum2);
%borrarTabla(Hist_Movim_Acum3);
%borrarTabla(Hist_Movim_Acum4);
%borrarTabla(Hist_Movim_Acum5);