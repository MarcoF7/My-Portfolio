/*** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***/

/* PROGRAMA: Importar_Dl521.sas
/* OBJETIVO: Carga del fichero DL521
/* AUTOR:	 Management Solutions
/* PROCESO:  Se realiza la importación del DL521
/*
/* 			 CONJUNTOS DE DATOS GENERADOS:
/* 			 - ...
/* 			 - ...
/*
/* FECHA: 01/12/2015
/*
/* NOTAS: ...
/*
/* LOG DE CAMBIOS:
/* FECHA	AUTOR	Objetivo
/* ...
/*** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***/

%PUT job "Importar_Dl521.sas" comenzó a %now;

* Se asigna el nombre lógico del fichero;
/*%let Nombre_Logico_Input = Dl521;*/

* Se busca la ruta física en la tabla "FICHEROS_INPUT";
/*data _NULL_;*/
/*	set FICHEROS_INPUT;*/
/**/
/*	if Nombre_Logico_Fichero = "&Nombre_Logico_Input" then do;*/
/*		call symput('Ruta_input_a_cargar', trim(Ruta));*/
/*	end;*/
/**/
/*run;*/
/**/
/*%let _EFIERR_ = 0;*/

/********************************
* Se importa la pestaña del DL521
********************************/
********************************/;


/*Diferencia excel de csv*/
/*%Macro Importar_DL521;*/
/**/
/*	%if (&FechaReporte = 201512) %then*/
/*		%do;*/
/*			proc import datafile="&dir_ficheros_orig.&Ruta_input_a_cargar."*/
/*				dbms=xlsx replace*/
/*				out=&biblioteca..Rep_DL521_Importado;*/
/*				sheet="DL521 31122015_ajustado_cuadre";*/
/*				getnames=yes;*/
/*			run;*/
/*		%end;*/
/*	%else %if (&FechaReporte = 201612) %then*/
/*		%do;*/
/*			proc import file="&dir_ficheros_orig.&Ruta_input_a_cargar."*/
/*			     out=&biblioteca..Rep_DL521_Importado_prev replace; delimiter=','; getnames=yes; guessingrows=32767;*/
/*			run;*/
/**/
/*			data &biblioteca..Rep_DL521_Importado(drop='Deal Star'n rename=(Deal_Star_New = 'Deal Star'n));*/
/*			set &biblioteca..Rep_DL521_Importado_prev;*/
/*				Deal_Star_New = put('Deal Star'n, 10.);*/
/*			run;				*/
/*		%end;*/
/**/
/*%Mend;*/


/*El formato del fichero es distinto de 2015 que de 2016, para ello usamos la Macro*/
/*%Importar_DL521;*/




/*Data &biblioteca..Dl521;*/
/*set &biblioteca..Rep_DL521_Importado*/
/*(rename=( */
/*		'Tipo Sub Producto'n='Tipo_Sub_Producto'n*/
/*		'Oficina'n='Oficina'n*/
/*		'Portafolio'n='Portafolio'n*/
/*		'Clase'n='Clase'n*/
/*		'Cod Contraparte'n='Cod_Contraparte'n*/
/*		'Contraparte'n='Contraparte'n*/
/*		'Deal Spectrum'n='Deal_Spectrum'n*/
/*		'Deal Star'n='Deal_Star'n*/
/*		'Fecha Contratación'n='Fecha_Contratación'n*/
/*		'Fecha Valor'n='Fecha_Valor'n*/
/*		'Fecha Vencimiento'n='Fecha_Vencimiento'n*/
/*		'Tipo de Tasa'n='Tipo_de_Tasa'n*/
/*		'Tasa'n='Tasa'n*/
/*		'Divisa'n='Divisa'n*/
/*		'Principal'n='Principal'n*/
/*		'Tipo Operación'n='Tipo_Operación'n*/
/*		'Interes al Final'n='Interes_al_Final'n*/
/*		'Interes a la Fecha'n='Interes_a_la_Fecha'n*/
/*		'Interes Restante'n='Interes_Restante'n*/
/*		'Base'n='Base'n*/
/*		'Principal Amortizado'n='Principal_Amortizado'n*/
/*		'CTA_PRINCIPAL'n='CTA_PRINCIPAL'n*/
/*		'[PRIMA_AMORT'n='_PRIMA_AMORT'n*/
/*		'CTA_PRIMA'n='CTA_PRIMA'n*/
/*		'CTA_INTERES'n='CTA_INTERES'n))*/
/*;*/
/*run;*/

/*data Rep_DL521;*/
/*	set &biblioteca..Dl521;*/
/**/
/*	Cta_Principal_texto = compress(put(Cta_Principal, 15.));*/
/*	drop Cta_Principal;*/
/*	Cta_Principal_texto=trim(cats(Cta_Principal_texto,"0000000000000"));*/
/*	rename Cta_Principal_texto = Cta_Principal;*/
/**/
/*	Oficina_texto = compress(put(Oficina, 4.));*/
/*	drop Oficina;*/
/*	if Oficina_texto ^= "" and length(Oficina_texto) = 3 then do;*/
/*		Oficina_texto = compress(cats("0", Oficina_texto));*/
/*	end;*/
/*	rename Oficina_texto = Oficina;*/
/**/
/*	if length (Cod_Contraparte) > 1 and length (Cod_Contraparte) < 8 and compress(Cod_Contraparte, "0123456789", "") = "" then*/
/*	do;*/
/*		do while (length(Cod_Contraparte) < 8);*/
/*			Cod_Contraparte = compress(cats("0",Cod_Contraparte));*/
/*		end;*/
/*	end;*/
/*run;*/


proc sql;
     create table Dl521_contr as
          select a.*, a.principal_amortizado * b.Tipo_Cambio/1000 as Saldo_Contravalorado
                from &bibliotecaInputs..Rep_DL521 a
                     left join &bibliotecaInputs..Tipo_De_Cambio b
                          on compress(upcase(a.Divisa)) = compress(upcase(b.Divisa));
quit;


data Dl521_contr2(drop=Deal_Star rename=(Deal_Star_New = Deal_Star));
set Dl521_contr;
	Deal_Star_New = put(Deal_Star, 10.);
run;


/*Esta tabla final será usada en los procesos que la necesitan: 
05_procesar_depositos y 07_procesar_Credito_liquidez*/
data dl521_venc_pro(drop= interes_Anual Numero_Dias_Prorrateo);
	set Dl521_contr2;

	FORMAT FECHCOMPDAT2 DATE10.;

	FECHCOMPDAT = CAT("&FECHAREPORTE","31"); /*COMPLETAMOS LA FECHA DE DATOS*/
	FECHCOMPDAT2 = INPUT(FECHCOMPDAT,YYMMDD8.); /*FORMATO FECHA*/
	Anio = input(substr("&FECHAREPORTE",1,4),4.); /*Año de datos en formato numerico*/


	* Se prepara el campo para los intereses;
/*	Interes_Anual = (Tasa/100) * Saldo_Contravalorado*3.706802;*/

	Interes_Anual = 0;

	if year('Fecha_Contratación'n) < Anio then
		do;
			Numero_Dias_Prorrateo = 365;
		end;
	else
		do;
			Numero_Dias_Prorrateo = FECHCOMPDAT2 - 'Fecha_Contratación'n;
		end;

	Ingresos_Gastos = Interes_Anual * (Numero_Dias_Prorrateo/365);

	/*Se homologa el campo new_Business*/
	if year('Fecha_Contratación'n)=Anio then
		Indicador_New_Bussines='S';
	else Indicador_New_Bussines='N';
	dias=Fecha_Vencimiento-'Fecha_Contratación'n;
run;