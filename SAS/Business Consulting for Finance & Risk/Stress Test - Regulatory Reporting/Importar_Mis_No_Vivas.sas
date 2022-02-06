/*** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***/

/* PROGRAMA: Importar_Mis_No_Vivas.sas
/* OBJETIVO: Cargar los inventarios MIS de las operaciones no vivas
/* AUTOR:	 Management Solutions
/* PROCESO:  Se realiza la importación de las operativas no vivas a la fecha de datos pero
/*           que si aportaron al margen del año.
/* 			 CONJUNTOS DE DATOS GENERADOS:
/* 			 - ...
/* 			 - ...
/*
/* FECHA: 29/11/2017
/*
/* NOTAS: ...
/*
/* LOG DE CAMBIOS:
/* FECHA	AUTOR	Objetivo
/* ...
/*** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***/


/*Se carga la ruta en donde se guardara los inventarios MIS de las operaciones
no vivas*/
%let Nombre_Logico_Input = Lib_Inv_Mis_No_Vivas;

data _NULL_;
	set FICHEROS_INPUT;

	if Nombre_Logico_Fichero = "&Nombre_Logico_Input" then do;
		call symput('Ruta_MIS_no_viv', trim(Ruta));
	end;

run;


/*libreria destino de los Inventarios MIS no vivas:
Esta es la ruta donde se tendra los Inventarios MIS no vivas, 
En esta ruta se hara la pregunta si ya existe dicho archivo antes de crearlo
para ahorrar tiempo de procesamiento*/
LIBNAME NoViv_lb "&dir_ficheros_orig.&Ruta_MIS_no_viv";


* Se asigna el nombre lógico del fichero;
%let Nombre_Logico_Input = Inv_Mis_No_Vivas;

* Se busca la ruta física en la tabla "FICHEROS_INPUT";
data _NULL_;
	set FICHEROS_INPUT;

	if Nombre_Logico_Fichero = "&Nombre_Logico_Input" then do;
		call symput('Ruta_input_a_cargar', trim(Ruta));
	end;

run;

/*Tener en cuenta que el fileexist es case sensitive*/

%Macro Crear_MIS_Si_No_Existe;
	/*Si no existe los inventarios MIS no vivas (= 0), entonces se crea.
	Con esto evitamos volver a crear esta base cada vez que se ejecuta el motor,
	y asi se ahorra tiempo de procesamiento*/
	%if %sysfunc(fileexist("&dir_ficheros_orig.&Ruta_input_a_cargar")) = 0 %then 
		%do;



			/*Lista de Inventarios MIS de todo el periodo de ejecución*/
			PROC IMPORT OUT=&biblioteca..Lista_Mis_NoVivas
				DATAFILE="&dir_ficheros_orig.&fichero_listado_inputs."
				DBMS=xlsx replace;
				getnames=yes;
				sheet="Historia_InvMIS";
			RUN; 


			/*Se unifican todas las operaciones que no hayan llegado con vida a la fecha de
			reporte, pero cuya fecha este dentro del periodo de ejecucion del analisis 
			de Margen Financiero*/


		    /*imho good practice to declare macro variables of a macro locally*/
		    %local datasetCount iter inElemento;

		    /*get number of datasets*/
		    proc sql noprint;
		        select count(*)
		         into :datasetCount
		        from &biblioteca..Lista_Mis_NoVivas;
		    quit;

		    /*initiate loop*/
		    %let iter=1;
		    %do %while (&iter.<= &datasetCount.);
		        /*get libref and dataset name for dataset you will work on during this iteration*/
		        data _NULL_;
		            set &biblioteca..Lista_Mis_NoVivas (firstobs=&iter. obs=&iter.); *only read 1 record;
		            *write the libname and dataset name to the macro variables;
		            call symput("inElemento",strip(Elemento_orden_actualidad));
		            *NOTE: i am always mortified by the chance of trailing blanks torpedoing my code, hence the strip function;
		        run;

				%if &iter. = 1 %then /*La primera fila sera el mes de referencia (e.g diciembre 2016)*/
					%do;
						data Referencia;
						set "&dir_ficheros_orig.&inElemento.";
					%end;
				%else /*Ahora empiezo a agregar los contratos que no estaban en diciembre pero si antes*/
					%do;
						/*Todos los contratos que tengo*/
						/*A medida que iteramos, "Referencia" tiene mas contratos almacenados.
						Si una operacion estuvo viva de julio a noviembre, no queremos almacenar
						de todos estos meses, solo del ultimo (noviembre). Por ello, es necesario
						actualizar constantemente "ContratosRef"*/
						proc sql;
							create table ContratosRef as
								select distinct CONTRATO
									from Referencia;
						quit;

						/*Los contratos del mes anterior*/
						proc sql;
							create table ContratosMes as
								select distinct CONTRATO
									from "&dir_ficheros_orig.&inElemento.";	
						quit;
						/*Identifico los contratos que estaban en el mes anterior, pero no en el actual*/
						proc sql;
							create table ContratosNoVivos as
								select a.CONTRATO
									from ContratosMes a LEFT JOIN ContratosRef b
										ON a.CONTRATO = b.CONTRATO
											where(b.CONTRATO = "");
						quit;

						/*Cogemos la informacion completa de estos contratos no vivos*/
						proc sql;
							create table ContratosNoVivos_Compl as
								select *
									from "&dir_ficheros_orig.&inElemento."
										where(CONTRATO IN (select distinct CONTRATO from ContratosNoVivos));
						quit;

						/*Ahora anadimos estos contratos no vivos al tablon original de referencia
						para tener todas las operativas: vivas y no vivas*/
						data Referencia;
						set Referencia ContratosNoVivos_Compl;
						run;

						/*Operativas_No_Vivas tendra solo las operativas no vivas*/
						%if (&iter. = 2) %then
							%do;
								data Operativas_No_Vivas;
								set ContratosNoVivos_Compl;
								run;
							%end;
						%else
							%do;
								data Operativas_No_Vivas;
								set Operativas_No_Vivas ContratosNoVivos_Compl;
								run;
							%end;


					%end;



		        /*increment the iterator of the loop*/
		        %let iter=%eval(&iter.+1);
		    %end;

			/*
			Referencia -> Esta tabla tendra todas las operaciones: vivas y no vivas
			Operativas_No_Vivas -> Esta tabla tendra las operativas no vivas solamente
			*/


			/*Se guarda el resultado final: 
			operativas no vivas que aportaron al margen*/
			proc sql;
				create table NoViv_lb.inventarios_&fechaReporte._no_vivas as
					select *
						from Operativas_No_Vivas;
			quit;

		%end;
%mend Crear_MIS_Si_No_Existe;


/*Solo genera inventarios_201712_no_vivas si este no existe*/
%Crear_MIS_Si_No_Existe;




Data &biblioteca..Inventarios_Mis_No_Vivas_Saldo 
(keep= Producto FECINFO CONTRATO SECUENCI CECONTA DIVISA FEAPERTU FEVENCIM FECANCEL 
TIPOREF CLASREF TIPOTAE CODCAMP PERCAPI PERINTE PERRENOV TIPOTASA 
Cta_Principal_texto Saldo_Inventario);
	set NoViv_lb.inventarios_&fechaReporte._no_vivas;

	* Se selecciona el Saldo a emplear en los inventarios;
	if tiporeg='01' then
		do;
			Saldo_Inventario=saldod;
		end;
	else if tiporeg='02' then
		do;
			Saldo_Inventario=saldoven;
		end;
	else if tiporeg='03' then
		do;
			Saldo_Inventario=salmora;
		end;
	else if tiporeg='05' then
		do;
			Saldo_Inventario=saldoa;
		end;
	else
		do;
			Saldo_Inventario=saldod;
		end;


	format Cta_Principal_texto $15.;
	Cta_Principal_texto=trim(cats(cuenta,"0000000000000"));
run;

/*Formato a la Divisa*/
Data &biblioteca..Inventarios_Mis_No_Vivas_Div;
	set &biblioteca..Inventarios_Mis_No_Vivas_Saldo;

	if Divisa="VAC" or Divisa="" then
		Divisa="PEN";
run;

Proc sql;
	create table &biblioteca..Inventarios_Mis_No_Vivas_Eur as
		select a.*,Saldo_Inventario*Tipo_Cambio_Eur as Saldo_Euros
			from &biblioteca..Inventarios_Mis_No_Vivas_Div a
				LEFT JOIN
					Tipo_De_Cambio B
					ON A.DIVISA=B.DIVISA;
quit;

/*Solo me deberia quedar con las cuentas contables que aporten al margen,
solo las que empiezan con 14 y con 2*/
/*Tampoco son parte del perimetro los productos 98 (avales), 70 (garantias) y 40 (seguros)*/
data &biblioteca..Inv_Mis_No_Vivas_0;
set &biblioteca..Inventarios_Mis_No_Vivas_Eur;
	where((substr(Cta_Principal_texto,1,2) = "14" OR substr(Cta_Principal_texto,1,1) = "2")
		AND (substr(Contrato,9,2) NOT IN ("98","70","40")));
run;

/*A nivel contrato, cuenta contable y centro contable ya puedo cruzar vs FRG para obtener 
el saldo medio*/
proc sql;
	create table &biblioteca..Inv_Mis_No_Vivas_1 as
		select CONTRATO, Cta_Principal_texto, CECONTA, FECINFO, DIVISA, CLASREF,
		CODCAMP, PERRENOV, TIPOTASA,
		min(FEAPERTU) as FEAPERTU, max(FEVENCIM) as FEVENCIM, min(FECANCEL) as FECANCEL, 
		(sum(TIPOREF)/count(*)) as TIPOREF, (sum(TIPOTAE)/count(*)) as TIPOTAE,
		sum(Saldo_Euros) as Saldo_Euros
			from &biblioteca..Inv_Mis_No_Vivas_0
				group by 1,2,3,4,5,6,7,8,9;
quit;

/*Obtengo el Epigrafe*/
Proc sql;
	create table &biblioteca..Inv_Mis_No_Vivas_2 as
		select a.*, b.'Epigrafe Local'n as Epigrafe_55
			from &biblioteca..Inv_Mis_No_Vivas_1 a
				left join
					(select distinct Cuenta,'Epigrafe Local'n
						from Epigrafe_CContable_Format_dis) b
								on a.Cta_Principal_texto=b.Cuenta;
quit;



/*Obtengo el saldo medio*/
/*Es necesario el prorrateo porque algunos registros se repiten a nivel de
contrato, centro contable y epigrafe*/
proc sql;
	create table &biblioteca..Inv_Mis_No_Vivas_3 as
		select a.*, (case when b.SM_Eur ne . then b.SM_Eur else 0 end) as Saldo_Medio
			from &biblioteca..Inv_Mis_No_Vivas_2 a LEFT JOIN &biblioteca..Saldo_Medio b
				ON a.Contrato = b.Contrato AND a.CECONTA = b.Oficina 
					AND a.Epigrafe_55 = b.Epigrafe
/*					group by a.Contrato, a.CECONTA, a.Epigrafe_55*/
;
quit;


/*Para cruzar y obtener el margen, debo hacerlo a nivel de contrato,
como no puedo prorratear por saldo porque casi ninguna lo informa
ENTONCES me quedo con el tablon a nivel contrato*/
proc sql;
	create table &biblioteca..Inv_Mis_No_Vivas_4 as 
		select CONTRATO, FECINFO, CODCAMP,
			max(Cta_Principal_texto) as Cta_Principal_texto, 
			max(DIVISA) as DIVISA, min(FEAPERTU) as FEAPERTU,
			max(FEVENCIM) as FEVENCIM, min(FECANCEL) as FECANCEL, 
			(sum(TIPOREF)/count(*)) as TIPOREF,
			max(CLASREF) as CLASREF, (sum(TIPOTAE)/count(*)) as TIPOTAE, 
			max(PERRENOV) as PERRENOV, max(TIPOTASA) as TIPOTASA, sum(Saldo_Euros) as Saldo_Euros,
			sum(Saldo_Medio) as Saldo_Medio
			from &biblioteca..Inv_Mis_No_Vivas_3
				group by 1,2,3;
quit;

/*Obtengo el Margen Financiero*/
/*Solo nos interesa las oepraciones que aportaron al Margen del anio*/
proc sql;
	create table &biblioteca..Inv_Mis_No_Vivas_5 as
		select a.*, (case when b.MF_Euros ne . then b.MF_Euros else 0 end) as Margen_F
			from &biblioteca..Inv_Mis_No_Vivas_4 a LEFT JOIN &biblioteca..Ingresos_Gastos_Sin_Ofi b
				ON a.Contrato = b.Contrato;
quit;


/*Determino el Instrumento y el Tipo de Producto*/
data &biblioteca..Inv_Mis_No_Vivas_6;
set &biblioteca..Inv_Mis_No_Vivas_5;
	format Instrumento $2.;
	format Prod_Prestamos $2.;
	format Prod_Depositos $3.;

	Prod = substr(CONTRATO,9,2);
	Dig5_6 = substr(Cta_Principal_texto,5,2);

	/*Prestamos*/
	if (substr(Cta_Principal_texto,1,2) = "14") then
		do;
			Instrumento = "02";

			if (Dig5_6 = "03") then
				Prod_Prestamos = "02"; /*Consumo*/
			else if (Dig5_6 = "04") then
				Prod_Prestamos = "01"; /*Hipotecarios*/
			else
				Prod_Prestamos = "03"; /*resto prestamos*/
		end;
	else if (substr(Cta_Principal_texto,1,1) = "2") then
		do;
			Instrumento = "05";
			if (Prod IN ("01", "02")) then /*Vista*/
				Prod_Depositos = "020";
			else /*"03","07","08","14"*/
				Prod_Depositos = "010";
		end;

	Saldo_Euros = 0; /*Saldo de las operativas no vivas que aportaron al margen es 0*/

	/*El margen puede ser positivo o negativo, solo en la parte final del reporte poner
	el valor absoluto para fines de formato de entrega*/
	where(Margen_F ne 0); /*Solo nos quedamos con las operativas que aportaron al margen*/
run;

/*Obtengo la neocon segun la relacion contable del Plan 00
(Vigente desde despues de Octubre 2017)*/
proc sql;
	create table &biblioteca..Inv_Mis_No_Vivas_6_neo as
		select a.*, b.nCtaGestionBBV as cuenta_neocon
			from &biblioteca..Inv_Mis_No_Vivas_6 a LEFT JOIN Relacion_Cta_local_Neo2 b
				ON a.Cta_Principal_texto = b.CtaCont;
quit;


/*Ahora se debe homologar el Segmento FINREP, para ello se debe distinguir nuevamente
el mes de la fecha de datos, a partir de octubre se tiene una nueva parametria*/

/*************************************************************************************************/
/*************************************************************************************************/
/*************************************************************************************************/
/*************************************************************************************************/
/*************************************************************************************************/

/*PRIMERO HOMOLOGAMOS ANTES DE OCTUBRE*/
/*Empezamos por Credito*/

/*Algunos clientes fueron refundidos y las operaciones no vivas podrian estar no actualizados
Entonces algunos clientes podrian no cruzar y quedarse sin CORASU
Actualizamos el codigo de los clientes refundidos
*/
proc sql;
	create table &biblioteca..Inv_Mis_No_Vivas_7
	(drop = CODCAMP rename=(Cliente_Refundido = CODCAMP)) as 
		select a.*, 
			(case when b.Cliente_Final ne "" then b.Cliente_Final else a.CODCAMP end) as Cliente_Refundido
			from &biblioteca..Inv_Mis_No_Vivas_6_neo a LEFT JOIN &bibliotecaInputs..Clientes_Refund_Final b
				ON a.CODCAMP = b.Cliente_old;
quit;


/*Para las homologaciones se necesitan el CIIU y el CORASU*/
proc sql;
	create table &biblioteca..Inv_Mis_No_Vivas_8 as
		select a.*, b.CORASU, b.CIIU
			from &biblioteca..Inv_Mis_No_Vivas_7 a LEFT JOIN &bibliotecaInputs..Info_Clientes b
				ON a.CODCAMP = b.CODCLIEN;
quit;



/*************************************************************************************************/
/*************************************************************************************************/
/*************************************************************************************************/
/*************************************************************************************************/
/*************************************************************************************************/


/*********LA HOMOLOGACON DEL SECTOR NO ESTA TAN PRECISA, MEJOR REPLICARE LA DE LIQUIDEZ CRED********/

/*El sector lo puedo sacar de lo que importe Clientes_Sector*/
proc sql;
	create table &biblioteca..Inv_Mis_No_Vivas_9 as
		select a.*, (case when b.sector ne "" then b.sector else "Particulares" end) as sector_0
			from &biblioteca..Inv_Mis_No_Vivas_8 a LEFT JOIN &bibliotecaInputs..Clientes_Sector_Final b
				ON a.CODCAMP = b.CODCLIEN;
quit;


/*Se homologa para el Plan 00*/
/*proc sql;*/
/*	create table CClientela_SectorContrapNEOCON as */
/*		select	a.*,*/
/*				b.Sector_Contraparte as Sector_Contraparte_NEOCON,*/
/*				"Particulares" as Sector_Contraparte_Defecto*/
/*		from &biblioteca..Inv_Mis_No_Vivas_9 a LEFT JOIN Homo_CredLiq_a b*/
/*		on a.cuenta_neocon = b.Cta_NEOCON;*/
/*quit;*/
/**/
/**/
/*proc sql;*/
/*	create table CClientela_SectorContrapCORASU as*/
/*		select a.*, Sector_Pyme as Sector_Contraparte_Finre,*/
/*			b.Sector as Sector_Contraparte_Area_CORASU */
/*		from */
/*			CClientela_SectorContrapNEOCON a*/
/*		left join */
/*			&bibliotecaInputs..Clientes_Sector_Final b*/
/*			on compress(upcase(a.CODCAMP)) = compress(upcase(b.CODCLIEN));*/
/*quit;*/
/**/
/**/
/*data CClientela_SectorContraparte;*/
/*	format Sector_Contraparte $100.;*/
/*	set CClientela_SectorContrapCORASU;*/
/**/
/*	if Sector_Contraparte_Area_CORASU^="" then*/
/*		do;*/
/*			Sector_Contraparte=Sector_Contraparte_Area_CORASU;*/
/*		end;*/
/*	else*/
/*		do;*/
/*			if Sector_Contraparte_Area_CORASU="" and  index(Sector_Contraparte_NEOCON, '+')=0 then*/
/*				do;*/
/*					Sector_Contraparte=Sector_Contraparte_NEOCON;*/
/*				end;*/
/*			else*/
/*				do;*/
/*					Sector_Contraparte=Sector_Contraparte_Defecto;*/
/*				end;*/
/*		end;*/
/*run;*/
/**/
/**/
/**/
/*proc sql;*/
/*	create table CClientela_SectorCont_Miv*/
/*(drop= Sector_Contraparte rename=(Sector_Contraparte2 =Sector_Contraparte)) as */
/*		select */
/*			a.*,*/
/*			case when b.sector ne "" then b.sector else a.Sector_Contraparte end as Sector_Contraparte2,*/
/*			b.sector as Sector_Homologado_Vi_Finrep*/
/*		from*/
/*			CClientela_SectorContraparte a*/
/*		left join */
/*			Homo_CredLiq_b b*/
/*			on a.Cta_Principal_texto like b.Cta_Contable*/
/*order by b.sector;*/
/*quit;*/
/**/
/*proc sql;*/
/*	create table CClientela_SectorCont_Miv_mu*/
/*	(drop= Sector_Contraparte_NEOCON Sector_Contraparte_Defecto Sector_Contraparte_Finre*/
/*			Sector_Contraparte_Area_CORASU Sector_Homologado_Vi_Finrep Sector_Homologado_Multilaterales*/
/*			Sector_Contraparte)as */
/*select a.*,*/
/*			case when b.sector ne "" then b.sector else a.Sector_Contraparte end as Sector_Contraparte_dps,*/
/*			b.sector as Sector_Homologado_Multilaterales*/
/*from CClientela_SectorCont_Miv a*/
/*left join Homo_CredLiq_c b*/
/*	on a.Cta_Principal_texto like b.Cta_Contable*/
/*order by b.sector;*/
/*quit;*/



/***********Ahora se homologa para antes del Plan 00************/


/*proc sql;*/
/*	create table CClientela_SectorContrapNEOCON2 as */
/*		select	a.*,*/
/*				b.Sector_Contraparte as Sector_Contraparte_NEOCON,*/
/*				"Particulares" as Sector_Contraparte_Defecto*/
/*		from CClientela_SectorCont_Miv_mu a LEFT JOIN Homo_CredLiq_ant_a b*/
/*		on a.cuenta_neocon = b.Cta_NEOCON;*/
/*quit;*/
/**/
/**/
/*proc sql;*/
/*	create table CClientela_SectorContrapCORASU2 as*/
/*		select a.*, Sector_Pyme as Sector_Contraparte_Finre,*/
/*			b.Sector as Sector_Contraparte_Area_CORASU */
/*		from */
/*			CClientela_SectorContrapNEOCON2 a*/
/*		left join */
/*			&bibliotecaInputs..Clientes_Sector_Final b*/
/*			on compress(upcase(a.CODCAMP)) = compress(upcase(b.CODCLIEN));*/
/*quit;*/
/**/
/*data CClientela_SectorContraparte2;*/
/*	format Sector_Contraparte $100.;*/
/*	set CClientela_SectorContrapCORASU2;*/
/**/
/*	if Sector_Contraparte_Area_CORASU^="" then*/
/*		do;*/
/*			Sector_Contraparte=Sector_Contraparte_Area_CORASU;*/
/*		end;*/
/*	else*/
/*		do;*/
/*			if Sector_Contraparte_Area_CORASU="" and  index(Sector_Contraparte_NEOCON, '+')=0 then*/
/*				do;*/
/*					Sector_Contraparte=Sector_Contraparte_NEOCON;*/
/*				end;*/
/*			else*/
/*				do;*/
/*					Sector_Contraparte=Sector_Contraparte_Defecto;*/
/*				end;*/
/*		end;*/
/*run;*/
/**/
/**/
/**/
/*proc sql;*/
/*	create table CClientela_SectorCont_Miv2*/
/*(drop= Sector_Contraparte rename=(Sector_Contraparte2 =Sector_Contraparte))as */
/*		select */
/*			a.*,*/
/*			case when b.sector ne "" then b.sector else a.Sector_Contraparte end as Sector_Contraparte2,*/
/*			b.sector as Sector_Homologado_Vi_Finrep*/
/*		from*/
/*			CClientela_SectorContraparte2 a*/
/*		left join */
/*			Homo_CredLiq_ant_b b*/
/*			on a.Cta_Principal_texto like b.Cta_Contable*/
/*order by b.sector;*/
/*quit;*/
/**/
/**/
/*proc sql;*/
/*	create table CClientela_SectorCont_Miv_mu2*/
/*	(drop= Sector_Contraparte_NEOCON Sector_Contraparte_Defecto Sector_Contraparte_Finre*/
/*			Sector_Contraparte_Area_CORASU Sector_Homologado_Vi_Finrep Sector_Homologado_Multilaterales*/
/*			Sector_Contraparte)as */
/*select a.*,*/
/*			case when b.sector ne "" then b.sector else a.Sector_Contraparte end as Sector_Contraparte_ant,*/
/*			b.sector as Sector_Homologado_Multilaterales*/
/*from CClientela_SectorCont_Miv2 a*/
/*left join Homo_CredLiq_ant_c b*/
/*	on a.Cta_Principal_texto like b.Cta_Contable*/
/*order by b.sector;*/
/*quit;*/


/**********END REPLICA HOMOLOGACION CREDITO LIQUIDEZ*******************/




/**********REPLICA HOMOLOGACION CREDITO FINREP PLAN 00*******************/

proc sql;
	create table &biblioteca..RCD_Sect_Prd_SC as
		select 	a.*,
			b.Situacion_contable as 'Situacion contable'n, 
			b.Nombre_del_importe as Importe, 
			b.Sector as Sector_Plan00,
			b.Producto as Producto_Plan00
		from &biblioteca..Inv_Mis_No_Vivas_9 a 
			LEFT JOIN (select * from &biblioteca..Parametria_FINREP_Cr where Nombre_del_importe="Saldo contable (bruto)") b	
			on a.cuenta_neocon = b.cuenta 

		order by 'Situacion contable'n
	;
quit;





Data RCD_Sector_prev RCD_Sector_Pend;
	set &biblioteca..RCD_Sect_Prd_SC;

	if index(compress(Sector_Plan00,""),"+")>0 then
		output RCD_Sector_Pend;
	else output RCD_Sector_prev;
run;

PROC SQL;
	CREATE TABLE RCD_Sector_Cora_Ciiu AS
		select 	a.*, 
			b.Sector as Sector_Corasu_CIIU 
		from RCD_Sector_Pend a LEFT JOIN H_Sector_CIIU_cr_dps b
			on a.CORASU = b.CORASU 
			and (
			compress(trim(substr(a.CIIU,8,2))) = compress(trim(b.CIIU)) 
			or 
			(
			b.CIIU = "NA" and not (substr(a.CIIU,8,2) IN ("65", "66", "67") 
			and 
			a.CORASU IN ("F01", "F02", "M02", "M20")
				)
				)
				)
				and (compress(trim(a.Cta_Principal_texto)) like compress(trim(b.Cta_Contable)) or b.Cta_Contable = "NA");
quit;

PROC SQL;
	CREATE TABLE RCD_Sector_Parti
		as
			select 	a.*,
				b.Sector  as Sector_Particulares 
from
				RCD_Sector_Cora_Ciiu a 
			LEFT JOIN  H_Finalidad_cr_dps b
				on compress(trim(a.Cta_Principal_texto)) like compress(trim(b.Cta_Contable))
				or a.Corasu=b.Corasu;
quit;


data Sector_Final_cr_fin;
	set RCD_Sector_Parti;

	if Sector_Particulares   ne "" and substr(Cta_Principal_texto,1,2) ne "15" then
		Sector_Final=Sector_Particulares;
	;
	if substr(Cta_Principal_texto,1,2)="15" and Prod_Prestamos = "02" then
		Sector_Final="Particulares";

	if substr(Cta_Principal_texto,1,2)="15" and Prod_Prestamos = "02" then
		Sector_Final="Autonomos";

	if 'Situacion contable'n="Fallido" and Prod_Prestamos = "02" then
		Sector_Final="Particulares";

	if 'Situacion contable'n="Fallido" and Prod_Prestamos = "02" then
		Sector_Final="Autonomos";

	if 'Situacion contable'n ne "Fallido" and substr(Cta_Principal_texto,1,2) ne "15" and Sector_Particulares="" then
		Sector_Final="Autonomos";
run;

data Sector_Compl_prev_cr_fin;
	set RCD_Sector_prev Sector_Final_cr_fin(drop=Sector_Corasu_CIIU Sector_Particulares);
run;


Data Sector_Completo_cr_fin;
format Sector_Final $100.;
	set Sector_Compl_prev_cr_fin;

	if Sector_Final="" then
		Sector_Final=Sector_Plan00;
run;

data Sector_Completo_cr_fin2;
set Sector_Completo_cr_fin;
	/*Las neocones que no estan en la nueva parametria credito no son
	parte del perimetro*/
	where not(Instrumento = "02" AND Sector_Final = ""); 	
run;




/**********END REPLICA HOMOLOGACION CREDITO FINREP PLAN 00*******************/




/*Para credito se usara la Homologacion que acabamos de hacer,
A partir de octubre se debe tomar segun el Plan 00*/
/*Para depositos se usara el sector que se obtiene de clientes_sector*/
data &biblioteca..Inv_Mis_No_Vivas_10sec;
/*set CClientela_SectorCont_Miv_mu2;*/
set Sector_Completo_cr_fin2;

	if (instrumento = "02") then
		do;
			Sector_Final_No_Viv = Sector_Final;
/*			if (FECINFO <= "201612") then*/
/*				Sector_Final_No_Viv = Sector_Contraparte_ant;*/
/*			else*/
/*				Sector_Final_No_Viv = Sector_Contraparte_dps;*/

		end;
	else
		do;
			Sector_Final_No_Viv = sector_0;
		end;
run;

/*688893*/
proc sql;
	create table &biblioteca..Inv_Mis_No_Vivas_10 (drop= Prod Dig5_6) as 
		select a.*, b.C0001, b.Segmento_Finrep
			from &biblioteca..Inv_Mis_No_Vivas_10sec a LEFT JOIN &biblioteca..Sector_No_Vivas b 
				ON a.Instrumento = b.Instrumento AND a.Sector_Final_No_Viv = b.sector;
quit;

/*Se enriquece con la marca PYME*/
proc sql;
	create table &biblioteca..Inv_Mis_No_Vivas_10_0 as
		select a.*, b.PYME as marca_PYME
			from &biblioteca..Inv_Mis_No_Vivas_10 a LEFT JOIN 
				&biblioteca..Inv6_Union b
					ON a.CONTRATO = b.contrato;
quit;

/*La marca PYME determina si una sociedad financiera es PYME,
Aplica para la segmentacion de credito*/
data &biblioteca..Inv_Mis_No_Vivas_10_1;
set &biblioteca..Inv_Mis_No_Vivas_10_0;
	if (Instrumento = "02" AND Sector_Final_No_Viv = "Sociedades no financieras") then
		do;
			if (marca_PYME = 1) then /*PYMES*/
				Segmento_Finrep = "004";
			else if (marca_PYME = 0) then /*No PYMES*/
				Segmento_Finrep = "005";
		end;
run;	


data &biblioteca..Inv_Mis_No_Vivas_11
(drop=FEAPERTU FEVENCIM FECANCEL 
rename=(FEAPERTU2 = FEAPERTU FEVENCIM2 = FEVENCIM FECANCEL2 = FECANCEL Saldo_Euros = C0016 CONTRATO = C0000 DIVISA = C0022));
set &biblioteca..Inv_Mis_No_Vivas_10_1;
	format C0005 $1.;
	format C0973 $1.;
	format C0038 date10.;
	format C1010 $2.;

	

	if (FECANCEL = "00010101") then
		FECANCEL = "";
	if (FEVENCIM = "00010101") then
		FEVENCIM = "";
	if (FEAPERTU = "00010101") then
		FEAPERTU = "";


	format FEAPERTU2 date10.;
	format FEVENCIM2 date10.;
	format FECANCEL2 date10.;

	FEAPERTU2 = input(FEAPERTU,yymmdd8.);
	FEVENCIM2 = input(FEVENCIM,yymmdd8.);
	FECANCEL2 = input(FECANCEL,yymmdd8.);

	C0019="&fechaReporte";
	C0020="&sociedad_informante";
	C0021 = "Tercero";
	Marca_Intergrupo = "TER";
	C0024 = "N";
	C0029 = TIPOTAE - TIPOREF;
	C0038 = .; /*fecha de revision*/
	C1010 = "";
	C1014 = "";
	IndOperViva = "F"; 
	AnioDatos = substr(C0019,1,4);

	if(AnioDatos = year(FECANCEL2)) then
		IndMatBus = "S";
	else	
		IndMatBus = "N";
	
	if (AnioDatos = year(FEAPERTU2)) then
		IndNewBus = "S";
	else	
		IndNewBus = "N";


	if (C0001 = "SNF") then /*tamanio empresa*/
		do;
			if (Sector_Final_No_Viv IN ("PYMEs Mayoristas","PYMEs Minoristas")) then
				C0005 = "P";
			else if (Sector_Final_No_Viv = "Corporaciones") then
				C0005 = "G";
		end;

	if (Instrumento = "02") then /*Garantia Hipotecaria*/
		C0973 = "N";

	if (TIPOTASA = "F") then
		C0023 = "F";
	else 
		C0023 = "V";

	if (C0023 = "V" AND Clasref = "") then /*Si no tiene clasref y estaba marcado como variable, lo hago fijo*/
		C0023 = "F";

run;


proc sql;
	create table &biblioteca..Inv_Mis_No_Vivas_12 as 
		select 
			a.*,
			b.Tipo_Tramo as C0025

		from
			&biblioteca..Inv_Mis_No_Vivas_11 a
		left join
			&biblioteca..H_TRAMOS_TIPO b
			on
			a.TIPOTAE>b.Cota_Inferior 
			and 
			a.TIPOTAE<=b.cota_superior;
quit;


/*Homologamos el Indice de referencia*/
Proc sql;
	Create table &biblioteca..Inv_Mis_No_Vivas_13 as 
		select a.*,case when C0023="V" then 
			b.Valor else "" end as C0027,
			case when C0023='V' then coalesce(b.Periodo_Renovacion_Dias,0) else . end as PlazoRef
		from
			&biblioteca..Inv_Mis_No_Vivas_12 a
		left join &biblioteca..H_Curva_finrep b on
			a.Clasref=b.Curva and a.perrenov=b.perrenov and a.C0022=b.Divisa;
quit;





/*Homologamos el spread*/
proc sql;
	create table &biblioteca..Inv_Mis_No_Vivas_14 as 
		select 
			a.*,
		case when (C0023="V" and (a.TIPOTAE-a.TIPOREF)^=.)
			then 
				b.Tipo_Tramo else "" end as C0052
			from
				&biblioteca..Inv_Mis_No_Vivas_13 a
			left join
				&biblioteca..H_Tramos_Tipo b
				on
				((a.TIPOTAE-a.TIPOREF))>b.Cota_Inferior 
				and 
				((a.TIPOTAE-a.TIPOREF))<=b.cota_superior;
quit;


/*Homologamos el periodo de revision*/
Proc sql;
	create table &biblioteca..Inv_Mis_No_Vivas_15 as
		select a.*,b.Valor as  C0030
			from &biblioteca..Inv_Mis_No_Vivas_14 a
				left join &biblioteca..H_Revision b
					on a.Perrenov=b.Perrenov;
quit;

/*Tabla de operativas no vivas stress test*/
proc sql;
	create table No_Vivas_STRESS_2017_CONTR as  /*686938 filas*/
		select C0000 format = $18.,
				C0001, 
				C0005,
				C0016 as C0016, 
			    C0019,
				C0020,
				C0021, 
				C0022, 
				C0023, 
				C0024, 
				C0025,
				tipotae as C0026, 
				C0027, 
				TIPOREF as C0028, 
				C0029,
				C0030, 
				C0038, 
				FEAPERTU as C0039, 
				FECANCEL as C0040,
				abs(Saldo_Medio) as C0041, 
				FEVENCIM as C0050, 
				C0052, 
				Margen_F as C0067, 
				. as C0068,
				"PE" as C0900, 
				"PEN" as C0901, 
				"" as C0973, 
				C1010, 
				C1014,
				cuenta_neocon,
				Cta_Principal_texto as cta_contable,
				PlazoRef,


				Instrumento, Segmento_FINREP, Prod_Prestamos, Prod_Depositos, "" as Prod_EmiRF, 
				IndNewBus, IndOperViva, IndMatBus, . as dias, Marca_Intergrupo
			from 

				&biblioteca..Inv_Mis_No_Vivas_15;
quit;


/*******************CODIGO EJECUCION 2015********************/

/*
Para 201512,
el segmento 001 de credito se pasaba por un poco del margen total del F16,
lo nivelamos pasando un poco al segmento 003 de OPERATIVAS NO VIVAS*/
/*data &biblioteca..Inv_Mis_No_Vivas_8aju;*/
/*set &biblioteca..Inv_Mis_No_Vivas_8sec;*/
/*	if(&FechaReporte = 201512) then*/
/*		do;*/
/*			if (Instrumento = "02" AND Sector_Final_No_Viv="Administraciones Publicas - Resto"*/
/*				AND contrato IN ("001108501150851163","001108501150873833")) then*/
/*					do;*/
/*						Sector_Final_No_Viv = "Otras instituciones financieras";*/
/*					end;*/
/*					*/
/*		end;*/
/*run;*/

/*******************END CODIGO EJECUCION 2015*******************/



/*********************TEST CRUCE MARGEN FINANCIERO**********************/

/*ANALIZO CRUCE FRG VS NO VIVAS*/
/*11138804
con el where ne 0 -> 8848796*/
/*proc sql;*/
/*	create table FRG_Contratos as*/
/*		select distinct Contrato*/
/*			from &biblioteca..RepositorioEur_&FechaReporte*/
/*				where(Importe_Euros ne 0);*/
/*quit;*/
/**/
/**/
/*proc sql;*/
/*	create table NoVivas_Contratos as*/
/*		select distinct Contrato*/
/*			from &biblioteca..Inv_Mis_No_Vivas_0;*/
/*quit;*/

/*Todos los contratos de las NoVivas deberian estar en el FGR*/
/*1845150 total
Cruzan: 941808
*/
/*proc sql;*/
/*	create table verif as*/
/*		select a.*, b.Contrato as Contrato_FRG*/
/*			from NoVivas_Contratos a LEFT JOIN FRG_Contratos b*/
/*				ON a.Contrato = b.Contrato*/
/**/
/*					;*/
/*quit;*/
/**/
/*proc sql;*/
/*	create table tes_No_Cruzan_MF as*/
/*		select **/
/*			from  &biblioteca..Inv_Mis_No_Vivas_5*/
/*				where (CONTRATO IN (select distinct CONTRATO from verif));*/
/*quit;*/
/**/
/*data tes_No_Cruzan_MF2;*/
/*set tes_No_Cruzan_MF;*/
/*	Prod = substr(CONTRATO,9,2);*/
/*run;*/
/**/
/*proc freq data=tes_No_Cruzan_MF2;*/
/*	tables Prod;*/
/*run;*/
/*todo bien , esos productos pueden no tener MARGEN!*/


/*Ahora analizo cruze FRG VS VIVAS*/
/*proc sql;*/
/*	create table Vivas_Contratos as*/
/*		select distinct C0000*/
/*			from SALIDA_FINAL_2017_CONTR_1_CUA1;*/
/*quit;*/

/*
total: 5639351
no cruzan: 64695
*/
/*proc sql;*/
/*	create table verif_vivas as*/
/*		select a.*, b.Contrato as Contrato_FRG*/
/*			from Vivas_Contratos a LEFT JOIN FRG_Contratos b*/
/*				ON a.C0000 = b.Contrato*/
/*					where(b.Contrato = "")*/
/*					;*/
/*quit;*/
/**/
/*data verif_vivas2;*/
/*set verif_vivas;*/
/*	Prod = substr(C0000,9,2);*/
/*run;*/
/**/
/*proc freq data=verif_vivas2;*/
/*	tables Prod;*/
/*run;*/


/*Ahora verificamos que todos los contratos del FRG han sido usados para Margen de
Operativas vivas + no vivas*/
/*941808*/
/*proc sql;*/
/*	create table FRG_usa_NoVivas as*/
/*		select a.*, b.Contrato as Contrato_NoViva*/
/*			from FRG_Contratos a LEFT JOIN NoVivas_Contratos b*/
/*				ON a.Contrato = b.Contrato*/
/*					where(b.Contrato ne "")*/
/*					;*/
/*quit;*/

/*3277659*/
/*contratos del FRG que no se usan en ST*/
/*proc sql;*/
/*	create table FRG_usa_Vivas_NoVivas as*/
/*		select a.*, b.C0000 as Contrato_Viva*/
/*			from FRG_Contratos a LEFT JOIN Vivas_Contratos b*/
/*				ON a.Contrato = b.C0000*/
/*					where(b.C0000 = "")*/
/*					;*/
/*quit;*/
/*data FRG_usa_Vivas_NoVivas2;*/
/*set FRG_usa_Vivas_NoVivas;*/
/*	Prod = substr(Contrato,9,2);*/
/*run;*/
/**/
/*proc freq data=FRG_usa_Vivas_NoVivas2;*/
/*	tables Prod;*/
/*run;*/





/*Veamos los contratos del FRG que no son referenciados en ST*/
/*Contratos del FRG que no estan en ST*/
/*proc sql;*/
/*	create table FRG_no_usados as*/
/*		select **/
/*			from &biblioteca..RepositorioEur_&FechaReporte*/
/*				where(Contrato NOT IN (select distinct Contrato from FRG_usa_Vivas_NoVivas));*/
/*quit;*/



/**********************END TEST CRUZE MARGEN FINANCIERO**********************/




/*Borramos todas las tablas intermedias que ya no se usan para liberar espacio en la memoria*/
%borrarTabla(Referencia);
%borrarTabla(ContratosRef);
%borrarTabla(ContratosMes);
%borrarTabla(ContratosNoVivos);
%borrarTabla(ContratosNoVivos_Compl);
%borrarTabla(Operativas_No_Vivas);
%borrarTabla(&biblioteca..Inventarios_Mis_No_Vivas);
%borrarTabla(&biblioteca..Inventarios_Mis_No_Vivas_Saldo);
%borrarTabla(&biblioteca..Inventarios_Mis_No_Vivas_Div);
%borrarTabla(&biblioteca..Inventarios_Mis_No_Vivas_Eur);
%borrarTabla(&biblioteca..Inv_Mis_No_Vivas_0);
%borrarTabla(&biblioteca..Inv_Mis_No_Vivas_1);
%borrarTabla(&biblioteca..Inv_Mis_No_Vivas_2);
%borrarTabla(&biblioteca..Inv_Mis_No_Vivas_3);
%borrarTabla(&biblioteca..Inv_Mis_No_Vivas_4);
%borrarTabla(&biblioteca..Inv_Mis_No_Vivas_5);
%borrarTabla(&biblioteca..Inv_Mis_No_Vivas_6);
%borrarTabla(&biblioteca..Inv_Mis_No_Vivas_6_neo);
%borrarTabla(&biblioteca..Inv_Mis_No_Vivas_7);
%borrarTabla(&biblioteca..Inv_Mis_No_Vivas_8);
%borrarTabla(&biblioteca..Inv_Mis_No_Vivas_9);
%borrarTabla(&biblioteca..RCD_Sect_Prd_SC);
%borrarTabla(RCD_Sector_prev);
%borrarTabla(RCD_Sector_Pend);
%borrarTabla(RCD_Sector_Cora_Ciiu);
%borrarTabla(RCD_Sector_Parti);
%borrarTabla(Sector_Final_cr_fin);
%borrarTabla(Sector_Compl_prev_cr_fin);
%borrarTabla(Sector_Completo_cr_fin);
%borrarTabla(Sector_Completo_cr_fin2);
%borrarTabla(&biblioteca..Inv_Mis_No_Vivas_10sec);
%borrarTabla(&biblioteca..Inv_Mis_No_Vivas_10);
%borrarTabla(&biblioteca..Inv_Mis_No_Vivas_10_0);
%borrarTabla(&biblioteca..Inv_Mis_No_Vivas_10_1);
%borrarTabla(&biblioteca..Inv_Mis_No_Vivas_11);
%borrarTabla(&biblioteca..Inv_Mis_No_Vivas_12);
%borrarTabla(&biblioteca..Inv_Mis_No_Vivas_13);
%borrarTabla(&biblioteca..Inv_Mis_No_Vivas_14);
%borrarTabla(&biblioteca..Inv_Mis_No_Vivas_15);