/*** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***/

/* PROGRAMA: Importar_Inventarios_Mis.sas
/* OBJETIVO: Carga de los inventarios MIS
/* AUTOR:	 Management Solutions
/* PROCESO:  Se realiza la importación de los inventarios MIS y su homologacion
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
/*%let Nombre_Logico_Input = Inventarios_Mis;*/

* Se busca la ruta física en la tabla "FICHEROS_INPUT";
/*data _NULL_;*/
/*	set FICHEROS_INPUT;*/
/**/
/*	if Nombre_Logico_Fichero = "&Nombre_Logico_Input" then*/
/*		do;*/
/*			call symput('Ruta_input_a_cargar', trim(Ruta));*/
/*		end;*/
/*run;*/

* Se importa la tabla de Credito Finrep a nivel contrato;

/*data &biblioteca..Inventarios_Mis_compl;*/
/*	set "&dir_ficheros_orig.&Ruta_input_a_cargar";*/
/*run;*/

/*10136128 filas*/
/*SE HACE TRATAMIENTO A LAS FECHAS DE LOS INVENTARIOS MIS*/
data &biblioteca..Inv_Mis_fecha;
	format Fecha_Vcto			DDMMYY10.;
	format Cta_Principal_texto $15.;
	set &bibliotecaInputs..Inv_MIS_Stress_Test;
	Cta_Principal_texto=trim(cats(cuenta,"0000000000000"));
	Anio_Vcto = input(substr(FEVENCIM, 1, 4), $4.);
	Mes_Vcto = input(substr(FEVENCIM, 5, 2), $2.);
	Dia_Vcto = input(substr(FEVENCIM, 7, 2), $2.);

	if input(Anio_Vcto,8.) > 1900 then
		do;
			Fecha_Vcto = input(compress(Dia_Vcto||"/"||Mes_Vcto||"/"||Anio_Vcto), DDMMYY10.);
		end;
	else
		do;
			Fecha_Vcto = .;
		end;
run;



/*********Se procede con la homologacion de los Inventarios MIS********/


/*Se direccionan los saldos al campo Saldo_Inventario*/
Data &biblioteca..Inventario_MIS_Saldo;
	set &bibliotecaInputs..Inv_MIS_Stress_Test;

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

	* Se eliminan las filas con Saldo a 0 al no tener utilidad;
	if Saldo_Inventario = 0 or Saldo_Inventario = . then
		delete;
run;

/*EN ESTA TABLA TENEMOS LOS REGISTROS QUE TIENEN FECHA CANCELAMIENTO DISTINTO DE 00010101
que deberia cruzar contra ST*/
data Inventarios_MIS_Saldo_FeCancel;
set &biblioteca..Inventario_MIS_Saldo;
	format Cta_Principal_texto $15.;
	Cta_Principal_texto=trim(cats(cuenta,"0000000000000"));

	where(FECANCEL ne "00010101");
run;



/*ADEMAS NECESITAMOS LA FECHA DE APERTURA PARA EL PROCESO CREDITO FINREP QUE NO LA TRAE*/
proc sql;
	create table Inventario_MIS_Saldo_2 as
		select CONTRATO, min(FEAPERTU) as FEAPERTU
			from &bibliotecaInputs..Inv_MIS_Stress_Test
				group by 1;
quit;

/*Se completa el campo Divisa PARA CUANDO EL VALOR VIENE NULO O DE TIPO VAC*/
Data &biblioteca..Inventario_MIS_Divisa;
	set &biblioteca..Inventario_MIS_Saldo;

	if Divisa="VAC" or Divisa="" then
		Divisa="PEN";
run;

/*/*CONTRAVALORAMOS EL SALDO A SOLES*/*/
/*Proc sql;*/
/*	create table &biblioteca..Inventario_MIS_Soles as*/
/*		select a.*,a.Saldo_Inventario*Tipo_Cambio*/
/*			as Saldo_Soles*/
/*				from &biblioteca..Inventario_MIS_Divisa a*/
/*					left join &bibliotecaInputs..Tipo_De_Cambio b*/
/*						on a.Divisa=b.Divisa;*/
/*quit;*/;

/*CONTRAVALORAMOS EL SALDO A EUROS*/
/*5642670*/
Proc sql;
	create table &biblioteca..Inventario_MIS_Euros as
		select a.*,Saldo_Inventario*Tipo_Cambio_Eur as Saldo_Euros
			from &biblioteca..Inventario_MIS_Divisa a
				LEFT JOIN
					Tipo_De_Cambio B
					ON A.DIVISA=B.DIVISA;
quit;







/*Se homologa la Fecha de Vencimiento por Defecto*/
Proc sql;
	create table &biblioteca..Inventario_FeVencim as
		select a.*,case when (b.Dias_Vcto^=.)
			then 
				put((input("&FechaReporte.",YYMMDD8.)+b.Dias_Vcto),YYMMDDN.) 
				else b.Fecha_Vcto end as Fevencim_Aux
			from &biblioteca..Inventario_MIS_Euros a
				left join 
					&biblioteca..H_Fecha_Defecto b on
					substr(a.contrato,9,2)=b.Producto 
					and a.Fevencim=b.Fevencim;
quit;

/*Se unifica la fecha de Vencimiento con la fecha que hemos generado por defecto*/

/* 5566620 filas*/
Proc sql;
	create table &biblioteca..Inventario_Fecha_Vcto 
		(drop=Fevencim Fevencim_Aux  rename=(Fevencim_Fin=Fevencim))as
			select a.*,case when a.Fevencim_Aux^=""
				then a.Fevencim_Aux  else Fevencim end as Fevencim_Fin
					from &biblioteca..Inventario_FeVencim a;
/*						(select distinct Fevencim from H_Fecha_Defecto) b;*/
quit;



/* 5566620 filas */
/*Se seleccionan las variables importates en el proceo*/
Proc sql;
	create table &biblioteca..Inventarios_Mis_prev as
		select FecInfo,substr(contrato,9,2) as Producto,Aplicac,Contrato,
			Secuenci,TipoReg,Ceconta,Divisa,Feapertu,Fevencim,
		case when (Fevencim^="99991231" )then 
			(input(Fevencim,YYMMDD10.)-input(Feapertu,YYMMDD10.))/365
			else 999 end as Dias_Vencimiento,
			Feimpago,TipoIntd,TipoInta,TipoRef,Feproxre,ClasRef,
			TipoExce,TipoTae,Indiesta,Fecesta,Clasific,IndiRef,Ctaorig,
			SecOrig,CodCamp,Perrenov,TipoTasa,Diferen,Indiries,
			Cuenta,min(Feapertu) as FechApertuMin,
		case when (Feapertu=min(Feapertu) and IndiRef^="RV" 
			and substr(min(Feapertu),1,4)=substr("&fechaReporte",1,4)) then "S" else "" end
		as Indicador,Saldo_Euros as Saldo_Inventario
			from &biblioteca..Inventario_Fecha_Vcto
				group by contrato
	;
quit;



/*Seleccionamos los contratos marcados New Bussines en el paso anterior*/
Proc sql;
	create table &biblioteca..Contratos_New_Bussines as
		select distinct Contrato,Indicador as Indicador_New_Bussines from 
			&biblioteca..Inventarios_Mis_prev
		where Indicador="S";
quit;

/*Se completa a nivel contrato si el contrato es New Bussines*/
Proc sql;
	create table &biblioteca..Inventarios_Ind_Bussiness(drop=Indicador)as
		select a.*,mean(Dias_Vencimiento) as Vencimiento_Original,
			case when b.Indicador_New_Bussines^="S"
				then "N" else b.Indicador_New_Bussines end as Indicador_New_Bussines
					from &biblioteca..Inventarios_Mis_prev a
						left join &biblioteca..Contratos_New_Bussines b
							on a.contrato=b.Contrato
						group by a.Contrato;
quit;
/*Traemos el epigrafe utilizando la tabla Tepirela*/
Proc sql;
	create table &biblioteca..Inventario_Epigrafe as
		select a.*,b.'Epigrafe Local'n as Epigrafe_55
			from &biblioteca..Inventarios_Ind_Bussiness a
				left join
					(select distinct Cuenta,'Epigrafe Local'n
						from &biblioteca..Epigrafe_CContable
							where Estado="55") b
								on a.Cuenta=b.Cuenta;
quit;


/***************************************************************
****************************************************************/

/*Generamos la tabla de saldos Medios*/
/*12668397*/
Proc sql;
	create table &biblioteca..Saldo_Medio as
		select Contrato, Oficina, Epigrafe, Saldo_Medio_Euros as SM_Eur
			from &biblioteca..RepositorioEur_&FechaReporte
				where Indicador = "SM"; /*selecciono el Saldo Medio*/
quit;


/*Generamos la tabla de Ingresos/Gastos*/

/*5642501*/
Proc sql;
	create table &biblioteca..Ingresos_Gastos as
		select Contrato, Oficina, sum(Margen_Euros) as MF_Euros
			from &biblioteca..RepositorioEur_&FechaReporte
				where(Indicador = "MF") /*selecciono el margen financiero*/
					group by 1,2; /*La tabla me venia agrupada por Contrato, CeConta y Epigrafe. Ahora reagrupo*/
quit;

/*5209494*/
Proc sql;
	create table &biblioteca..Ingresos_Gastos_Sin_Ofi as
		select Contrato, sum(MF_Euros) as MF_Euros
			from &biblioteca..Ingresos_Gastos
				group by 1;
quit;


/***************************************************************
****************************************************************/

/*Homologamos el saldo Medio */
Proc sql;
	create table &biblioteca..Inventario_Saldo_Medio as
		select a.*,

			(b.SM_Eur*Saldo_Inventario)/sum(Saldo_Inventario) as Saldo_Medio /*Prorrateamos*/
	
			from &biblioteca..Inventario_Epigrafe a
				left join 
					&biblioteca..Saldo_Medio b
					on a.Contrato=b.Contrato and a.Ceconta=b.Oficina
					and a.Epigrafe_55=b.Epigrafe
					group by a.Contrato,a.Ceconta,a.Epigrafe_55
				order by a.Contrato;
quit;

/*5642670*/
proc sql;
	create table Inventario_Saldo_Medio2
				(drop = Saldo_Medio Saldo_Inventario 
				rename = (Saldo_Medio_New = Saldo_Medio Saldo_Inventario_New = Saldo_Inventario)) as
		select a.*,
				case when a.Saldo_Medio ne . then a.Saldo_Medio else 0 end as Saldo_Medio_New,
				case when a.Saldo_Inventario ne . then a.Saldo_Inventario else 0 end as Saldo_Inventario_New
					from &biblioteca..Inventario_Saldo_Medio a;
quit;

/*Ya no necesito el centro contable para cruzar y obtener el Margen
Entonces lo elimino en la sgt agrupacion*/
/*5446324*/
proc sql;
	create table Inventario_Ingresos_Gastos_prev as
		select Contrato,/*Ceconta,*/Divisa,
			sum(TipoRef*Saldo_Inventario)/sum(Saldo_Inventario) as TipoRef,
			Clasref,
			sum(TipoTae*Saldo_Inventario)/sum(Saldo_Inventario) as TipoTae,
			IndiRef,CodCamp,
			Perrenov,TipoTasa,Diferen,Cuenta,Indicador_New_Bussines,Epigrafe_55,
			sum(Vencimiento_Original*Saldo_Inventario)/sum(Saldo_Inventario) as Vencimiento_Original,
			FEVENCIM, 
			sum(Saldo_Medio) as Saldo_Medio, sum(Saldo_Inventario) as Saldo_Inventario
				from Inventario_Saldo_Medio2
					group by Contrato, Divisa, Clasref, IndiRef,CodCamp,Perrenov,TipoTasa,Diferen,
							Cuenta,Indicador_New_Bussines,Epigrafe_55,FEVENCIM;
quit;


/*Homologamos el campo Ingresos/Gastos */
/*5446324*/
Proc sql;
	create table &biblioteca..Inventario_Ingresos_Gastos as
		select a.Contrato,Divisa,TipoRef,
			Clasref,TipoTae,IndiRef,CodCamp,
			Perrenov,TipoTasa,Diferen,Cuenta,Indicador_New_Bussines,Epigrafe_55,
			Vencimiento_Original,
			FEVENCIM,
			Saldo_Medio,
			Saldo_Inventario,
		case when 
			((b.MF_Euros*a.Saldo_inventario)/sum(a.Saldo_inventario)) = . /*Prorrateamos*/
		then 0 else 
			((b.MF_Euros*a.Saldo_inventario)/sum(a.Saldo_inventario)) end 
		as Ingresos_Gastos
			from Inventario_Ingresos_Gastos_prev a
				left join 
					&biblioteca..Ingresos_Gastos_Sin_Ofi b
					on a.Contrato=b.Contrato
				group by a.Contrato;
quit;


/*Tomamos las variables importates que serviran para los diferentes perimetros*/
Proc sql ;
	create table &biblioteca..Inventario_Completo  as 
		select Contrato,Divisa,TipoRef,Clasref,TipoTae,IndiRef,
			Perrenov,TipoTasa,Diferen,Cuenta,Indicador_New_Bussines,Epigrafe_55,
			Vencimiento_Original,
			FEVENCIM,
			sum(Saldo_Medio) as Saldo_Medio, /*Como prorratee, ya puedo sumar y el saldo total se mantiene*/
			sum(Ingresos_Gastos) as Ingresos_Gastos,
			sum(Saldo_Inventario) as Saldo_Inventario
		from &biblioteca..Inventario_Ingresos_Gastos
			group by 1,2,3,4,5,6,7,8,9,10
				,11,12,13,14;
quit;

/*Esta tabla se usa para enriquecer depositos liquidez y credito liquidez*/
/*Se procesa la tabla de inventarios*/
data &biblioteca..Inventarios_Mis_cfecha;
	format Fecha_Vcto			DDMMYY10.;
	format Cta_Principal_texto $15.;
	set &biblioteca..Inventario_Completo;
	Cta_Principal_texto=trim(cats(cuenta,"0000000000000"));
	Anio_Vcto = input(substr(FEVENCIM, 1, 4), $4.);
	Mes_Vcto = input(substr(FEVENCIM, 5, 2), $2.);
	Dia_Vcto = input(substr(FEVENCIM, 7, 2), $2.);

	if input(Anio_Vcto,8.) > 1900 then
		do;
			Fecha_Vcto = input(compress(Dia_Vcto||"/"||Mes_Vcto||"/"||Anio_Vcto), DDMMYY10.);
		end;
	else
		do;
			Fecha_Vcto = .;
		end;
run;

/*Necesito un tablon a nivel contrato para poder cruzar vs credito FINREP */
/*4702789*/
Proc sql;
	create table &biblioteca..Inventario_Contratos_Saldos as
		select Contrato,
			/*Epigrafe_55,*/Fevencim,Vencimiento_Original,
			Indicador_New_Bussines,Perrenov,TipoTasa,
			IndiRef,ClasRef,tiporef,
			TipoTae,
			sum(Saldo_Inventario) as Saldo_Inventario,
			sum(Saldo_Medio) as Saldo_Medio,
			sum(Ingresos_Gastos) as Ingresos_Gastos
		from &biblioteca..Inventario_Completo
			group by 1,2,3,4,5,6,7,8,9,10/*,11*/;
quit;


/*Esta tabla se usará para enriquecer crédito FINREP*/
/*Para que no se dupliquen los registros al cruzar solo por contrato, debo agrupar:*/
proc sql;
	create table &biblioteca..Inventario_Contratos_Saldos2 as
		select Contrato, max(Fevencim) as Fevencim, 
			   sum(Vencimiento_Original*Saldo_Inventario)/sum(Saldo_Inventario) as Vencimiento_Original,
			   max(Indicador_New_Bussines) as Indicador_New_Bussines, max(Perrenov) as Perrenov,
			   max(TipoTasa) as TipoTasa, max(IndiRef) as IndiRef, max(ClasRef) as ClasRef,
			   sum(tiporef*Saldo_Inventario)/sum(Saldo_Inventario) as tiporef,
			   sum(TipoTae*Saldo_Inventario)/sum(Saldo_Inventario) as TipoTae,
			   sum(Saldo_Inventario) as Saldo_Inventario,
			   sum(Saldo_Medio) as Saldo_Medio,
			   sum(Ingresos_Gastos) as Ingresos_Gastos

			   from &biblioteca..Inventario_Contratos_Saldos
			   		group by 1;
quit;



/*Borramos todas las tablas intermedias que ya no se usan para liberar espacio en la memoria*/
%borrarTabla(&biblioteca..Inv_Mis_fecha);
%borrarTabla(&biblioteca..Inventario_MIS_Saldo);
%borrarTabla(&biblioteca..Inventario_MIS_Divisa);
%borrarTabla(&biblioteca..Inventario_MIS_Euros);
%borrarTabla(&biblioteca..Inventario_FeVencim);
%borrarTabla(&biblioteca..Inventario_Fecha_Vcto);
%borrarTabla(&biblioteca..Inventarios_Mis_prev);
%borrarTabla(&biblioteca..Contratos_New_Bussines);
%borrarTabla(&biblioteca..Inventarios_Ind_Bussiness);
%borrarTabla(&biblioteca..Inventario_Epigrafe);
%borrarTabla(&biblioteca..Inventario_Saldo_Medio);
%borrarTabla(Inventario_Saldo_Medio2);
%borrarTabla(Inventario_Ingresos_Gastos_prev);
%borrarTabla(&biblioteca..Inventario_Ingresos_Gastos);
%borrarTabla(&biblioteca..Inventario_Completo);
%borrarTabla(&biblioteca..Inventario_Contratos_Saldos);