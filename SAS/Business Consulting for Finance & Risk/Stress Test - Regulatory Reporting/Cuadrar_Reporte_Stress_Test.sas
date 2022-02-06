
/*
Se realiza el cuadre Stres Test vs la Contabilidad:
Todos los cuadres estarán en Euros y en Miles
*/

/*
&biblioteca..F06_Saldos_Segmento -> Credito - Segmento FINREP
&biblioteca..F06_Saldos_Producto_Parti -> Credito - Segmento Particulares por Producto

&biblioteca..F08_Saldos_Producto -> Depositos - Segmento y Producto
&biblioteca..F08_Saldos_Segmento -> Depositos - Segmento

&biblioteca..F08_Emisiones_Saldo -> Emisiones - Saldo

&biblioteca..F10_Derivados_Saldo -> Derivados - Nocional
&biblioteca..Valor_Razonable -> Valor Razonable - Ratio Derivados Activo/Pasivo


F16_Reporte_cre_dep -> Credito y Depositos - Margen Financiero por Sector
&biblioteca..Margen_Emisiones -> Emisiones - Margen Financiero
&biblioteca..Margen_Derivados -> Derivados - Margen Financiero
*/



/*********************SE CONTRAVALORA A EUROS Y EN MILES*********************/

/*F06*/
proc sql;
	create table &biblioteca..F06_Saldos_Segmento_Eur as
		select a.SEGMENTO_FINREP, 
				a.F06_Soles_Unidades/(b.Tipo_Cambio*1000) as F06_Euros_Miles
			from &biblioteca..F06_Saldos_Segmento a,
			(select Tipo_Cambio from &bibliotecaInputs..Tipo_De_Cambio where Divisa="EUR") b;
quit;

proc sql;
	create table &biblioteca..F06_Saldos_Producto_Parti_Eur as
		select a.SEGMENTO_FINREP, a.PROD_PRESTAMOS,
				a.F06_Soles_Unidades/(b.Tipo_Cambio*1000) as F06_Euros_Miles
			from &biblioteca..F06_Saldos_Producto_Parti a,
			(select Tipo_Cambio from &bibliotecaInputs..Tipo_De_Cambio where Divisa="EUR") b;
quit;

/*F08*/
proc sql;
	create table &biblioteca..F08_Saldos_Producto_Eur as
		select a.SEGMENTO_FINREP, a.PROD_DEPOSITOS,
				a.F08_Soles_Unidades/(b.Tipo_Cambio*1000) as F08_Euros_Miles
			from &biblioteca..F08_Saldos_Producto a,
			(select Tipo_Cambio from &bibliotecaInputs..Tipo_De_Cambio where Divisa="EUR") b;
quit;

proc sql;
	create table &biblioteca..F08_Saldos_Segmento_Eur as
		select a.SEGMENTO_FINREP,
				a.F08_Soles_Unidades/(b.Tipo_Cambio*1000) as F08_Euros_Miles
			from &biblioteca..F08_Saldos_Segmento a,
			(select Tipo_Cambio from &bibliotecaInputs..Tipo_De_Cambio where Divisa="EUR") b;
quit;

proc sql;
	create table &biblioteca..F08_Emisiones_Saldo_Eur as
		select a.F08_Soles_Unidades/(b.Tipo_Cambio*1000) as F08_Euros_Miles
			from &biblioteca..F08_Emisiones_Saldo a,
			(select Tipo_Cambio from &bibliotecaInputs..Tipo_De_Cambio where Divisa="EUR") b;
quit;

/*F10*/
proc sql;
	create table &biblioteca..F10_Derivados_Saldo_Eur as
		select a.F10_Soles_Unidades/(b.Tipo_Cambio*1000) as F10_Euros_Miles
			from &biblioteca..F10_Derivados_Saldo a,
			(select Tipo_Cambio from &bibliotecaInputs..Tipo_De_Cambio where Divisa="EUR") b;
quit;





/************************CUADRE F06************************/

/*Se selecciona el perímetro de F06 en el tablon de Stress Test*/
proc sql;
	create table VerifST_F06 as
		select INSTRUMENTO, SEGMENTO_FINREP, 
			sum(SALDO_CONTABLE) as SALDO_ST
			from &BIBLIOTECAOUTPUTS..REQUERIMIENTO_AGREGADO_&FECHAREPORTE
				where(INSTRUMENTO = "02")
					group by 1,2;
quit;

/*Se enriquece con el reporte F06*/
proc sql;
	create table VerifST_F06_2 as
		select a.*, b.F06_Euros_Miles
			from VerifST_F06 a LEFT JOIN &biblioteca..F06_Saldos_Segmento_Eur b
				ON a.SEGMENTO_FINREP = b.SEGMENTO_FINREP;
quit;

/*Se calculan diferencias*/
data VerifST_F06_3;
set VerifST_F06_2;
	Diferencia = F06_Euros_Miles - SALDO_ST;
	Dif_Porc = ((F06_Euros_Miles - SALDO_ST)/SALDO_ST)*100;
run;

proc sql;
	create table VerifST_F06_4 as
		select b.INSTRUMENTO_NEW as INSTRUMENTO, 
				b.SEGMENTO_FINREP_NEW as SEGMENTO_FINREP,
				a.SALDO_ST, a.F06_Euros_Miles, a.Diferencia, a.Dif_Porc
			from VerifST_F06_3 a LEFT JOIN &biblioteca..H_Cuadre_Cre_Seg_Descrip b
				on a.INSTRUMENTO = b.INSTRUMENTO AND 
					a.SEGMENTO_FINREP = b.SEGMENTO_FINREP;
quit;


/*Se exporta el cuadre de credito a nivel segmento*/
%exportXLS(VerifST_F06_4, 
			&localProjectPath.&dirLog.&hora_generacion_pestana_ajust._Cuadre_Cred_F06.xlsx,
			Segmento);

/*test FORMATO ESPECIAL EXPORTACION*/

%exportFormattedXLS(VerifST_F06_4, 
			&localProjectPath.&dirLog.&hora_generacion_pestana_ajust._Cuadre_Cred_F06_v2.xls,
			Segmento);

/*end test FORMATO ESPECIAL EXPORTACION*/




/*Se hace un analisis a nivel producto para el segmento particulares de credito*/
proc sql;
	create table VerifST_F06_Parti as
		select INSTRUMENTO, SEGMENTO_FINREP, PROD_PRESTAMOS, 
			sum(SALDO_CONTABLE) as SALDO_ST
			from &BIBLIOTECAOUTPUTS..REQUERIMIENTO_AGREGADO_&FECHAREPORTE
				where(INSTRUMENTO = "02" AND SEGMENTO_FINREP = "006")
					group by 1,2,3;
quit;

/*Se enriquece con el reporte F06*/
proc sql;
	create table VerifST_F06_Parti_2 as 
		select a.*, b.F06_Euros_Miles
			from VerifST_F06_Parti a LEFT JOIN &biblioteca..F06_Saldos_Producto_Parti_Eur b
				ON a.PROD_PRESTAMOS = b.PROD_PRESTAMOS;
quit;

/*Se calculan diferencias*/
data VerifST_F06_Parti_3;
set VerifST_F06_Parti_2;
	Diferencia = F06_Euros_Miles - SALDO_ST;
	Dif_Porc = ((F06_Euros_Miles - SALDO_ST)/SALDO_ST)*100;
run;

/*Descripcion completa*/
proc sql;
	create table VerifST_F06_Parti_4 as
		select "Crédito" as INSTRUMENTO, 
				b.SEGMENTO_FINREP_NEW as SEGMENTO_FINREP,
				b.PROD_PRESTAMOS_NEW as PROD_PRESTAMOS,
				a.SALDO_ST, a.F06_Euros_Miles, a.Diferencia, a.Dif_Porc
			from VerifST_F06_Parti_3 a LEFT JOIN &biblioteca..H_Cuadre_Cre_Prod_Descrip b
				on a.SEGMENTO_FINREP = b.SEGMENTO_FINREP AND 
					a.PROD_PRESTAMOS = b.PROD_PRESTAMOS;
quit;

/*Se exporta el cuadre de credito a nivel producto para el segmento particulares*/
%exportXLS(VerifST_F06_Parti_4, 
			&localProjectPath.&dirLog.&hora_generacion_pestana_ajust._Cuadre_Cred_F06.xlsx,
			Producto);



/************************CUADRE F08************************/

/*Se selecciona el perímetro de F08 en el tablon de Stress Test
a nivel segmento y producto para Depositos*/
proc sql;
	create table VerifST_F08 as
		select INSTRUMENTO, SEGMENTO_FINREP, PROD_DEPOSITOS,
			sum(SALDO_CONTABLE) as SALDO_ST
			from &BIBLIOTECAOUTPUTS..REQUERIMIENTO_AGREGADO_&FECHAREPORTE
				where(INSTRUMENTO = "05")
					group by 1,2,3;
quit;

/*Se enriquece con el reporte F08*/
proc sql;
	create table VerifST_F08_2 as
		select a.*, b.F08_Euros_Miles
			from VerifST_F08 a LEFT JOIN &biblioteca..F08_Saldos_Producto_Eur b
				ON a.SEGMENTO_FINREP = b.SEGMENTO_FINREP AND
					a.PROD_DEPOSITOS = b.PROD_DEPOSITOS;
quit;

/*Se calculan diferencias*/
data VerifST_F08_3;
set VerifST_F08_2;
	Diferencia = F08_Euros_Miles - SALDO_ST;
	Dif_Porc = ((F08_Euros_Miles - SALDO_ST)/SALDO_ST)*100;
run;

/*Descripcion completa*/
proc sql;
	create table VerifST_F08_4 as
		select b.INSTRUMENTO_NEW as INSTRUMENTO,
				b.SEGMENTO_FINREP_NEW as SEGMENTO_FINREP,
				b.PROD_DEPOSITOS_NEW as PROD_DEPOSITOS,
				a.SALDO_ST, a.F08_Euros_Miles, a.Diferencia, a.Dif_Porc
			from VerifST_F08_3 a LEFT JOIN &biblioteca..H_Cuadre_Dep_Prod_Descrip b
				ON a.INSTRUMENTO = b.INSTRUMENTO AND
					a.SEGMENTO_FINREP = b.SEGMENTO_FINREP AND
					a.PROD_DEPOSITOS = b.PROD_DEPOSITOS;
quit;


/*Se exporta el cuadre de depositos a nivel segmento y producto*/
%exportXLS(VerifST_F08_4, 
			&localProjectPath.&dirLog.&hora_generacion_pestana_ajust._Cuadre_Dep_Emi_F08.xlsx,
			Dep_Segmento_Producto);


/*Se selecciona el perímetro de F08 en el tablon de Stress Test
a nivel segmento finrep para Depositos*/
proc sql;
	create table VerifST_F08_Seg as
		select INSTRUMENTO, SEGMENTO_FINREP,
			sum(SALDO_CONTABLE) as SALDO_ST
			from &BIBLIOTECAOUTPUTS..REQUERIMIENTO_AGREGADO_&FECHAREPORTE
				where(INSTRUMENTO = "05")
					group by 1,2;
quit;

/*Se enriquece con el reporte F08*/
proc sql;
	create table VerifST_F08_Seg_2 as
		select a.*, b.F08_Euros_Miles
			from VerifST_F08_Seg a LEFT JOIN &biblioteca..F08_Saldos_Segmento_Eur b
				ON a.SEGMENTO_FINREP = b.SEGMENTO_FINREP;
quit;

/*Se calculan diferencias*/
data VerifST_F08_Seg_3;
set VerifST_F08_Seg_2;
	Diferencia = F08_Euros_Miles - SALDO_ST;
	Dif_Porc = ((F08_Euros_Miles - SALDO_ST)/SALDO_ST)*100;
run;

/*Descripcion completa*/
proc sql;
	create table VerifST_F08_Seg_4 as
		select b.INSTRUMENTO_NEW as INSTRUMENTO,
				b.SEGMENTO_FINREP_NEW as SEGMENTO_FINREP,
				a.SALDO_ST, a.F08_Euros_Miles, a.Diferencia, a.Dif_Porc
			from VerifST_F08_Seg_3 a LEFT JOIN &biblioteca..H_Cuadre_Dep_Seg_Descrip b
				ON a.INSTRUMENTO = b.INSTRUMENTO AND
					a.SEGMENTO_FINREP = b.SEGMENTO_FINREP;
quit;

/*Se exporta el cuadre de depositos a nivel segmento*/
%exportXLS(VerifST_F08_Seg_4, 
			&localProjectPath.&dirLog.&hora_generacion_pestana_ajust._Cuadre_Dep_Emi_F08.xlsx,
			Dep_Segmento);


/*Se selecciona el perímetro de F08 en el tablon de Stress Test
para Emisiones*/
proc sql;
	create table VerifST_Emisiones as
		select "Emisiones" as INSTRUMENT,
			sum(SALDO_CONTABLE) as SALDO_ST
			from &BIBLIOTECAOUTPUTS..REQUERIMIENTO_AGREGADO_&FECHAREPORTE
				where(INSTRUMENTO = "06")
					group by 1;
quit;

/*Se enriquece con el reporte F08*/
proc sql;
	create table VerifST_Emisiones_2 as
		select a.*, b.F08_Euros_Miles
			from VerifST_Emisiones a, &biblioteca..F08_Emisiones_Saldo_Eur b;
quit;

/*Se calculan diferencias*/
data VerifST_Emisiones_3;
set VerifST_Emisiones_2;
	Diferencia = F08_Euros_Miles - SALDO_ST;
	Dif_Porc = ((F08_Euros_Miles - SALDO_ST)/SALDO_ST)*100;
run;

/*Se exporta el cuadre de depositos a nivel segmento*/
%exportXLS(VerifST_Emisiones_3, 
			&localProjectPath.&dirLog.&hora_generacion_pestana_ajust._Cuadre_Dep_Emi_F08.xlsx,
			Emisiones);



/************************CUADRE F10************************/

/*Se selecciona el perímetro de F10 en el tablon de Stress Test
para Derivados*/
proc sql;
	create table VerifST_Derivados as
		select INSTRUMENTO,
			sum(SALDO_CONTABLE) as SALDO_ST
			from &BIBLIOTECAOUTPUTS..REQUERIMIENTO_AGREGADO_&FECHAREPORTE
				where(INSTRUMENTO IN ("04","08"))
					group by 1;
quit;

/*Se enriquece con el reporte F10*/
proc sql;
	create table VerifST_Derivados_2 as
		select a.*, b.F10_Euros_Miles
			from VerifST_Derivados a, &biblioteca..F10_Derivados_Saldo_Eur b;
quit;

data VerifST_Derivados_3;
set VerifST_Derivados_2;
	if (INSTRUMENTO = "04") then 
		/*Se toma el nocional correspondiente a la pata de activo*/
		F10_Euros_Miles = F10_Euros_Miles * &PORC_DER_ACT;
	else if (INSTRUMENTO = "08") then
		/*Se toma el nocional correspondiente a la pata de pasivo*/
		F10_Euros_Miles = F10_Euros_Miles * &PORC_DER_PAS;
run;

/*Se calculan diferencias*/
data VerifST_Derivados_4;
set VerifST_Derivados_3;
	Diferencia = F10_Euros_Miles - SALDO_ST;
	Dif_Porc = ((F10_Euros_Miles - SALDO_ST)/SALDO_ST)*100;
run;

/*Descripcion completa*/
proc sql;
	create table VerifST_Derivados_5 as
		select b.INSTRUMENTO_NEW as INSTRUMENTO,
				a.SALDO_ST, a.F10_Euros_Miles, a.Diferencia, a.Dif_Porc
			from VerifST_Derivados_4 a LEFT JOIN &biblioteca..H_Cuadre_Derivad_Descrip b
				ON a.INSTRUMENTO = b.INSTRUMENTO;
quit;

/*Se exporta el cuadre de depositos a nivel segmento*/
%exportXLS(VerifST_Derivados_5, 
			&localProjectPath.&dirLog.&hora_generacion_pestana_ajust._Cuadre_Deriv_F10.xlsx,
			Nocional_Activ_Pasiv);



/*Se selecciona todo el Nocional de Derivados de Stress Test*/
proc sql;
	create table VerifST_Deriv_Tot as
		select "Derivados" as INSTRUMENT,
			sum(SALDO_CONTABLE) as SALDO_ST
			from &BIBLIOTECAOUTPUTS..REQUERIMIENTO_AGREGADO_&FECHAREPORTE
				where(INSTRUMENTO IN ("04","08"));
quit;

/*Se enriquece con el reporte F10*/
proc sql;
	create table VerifST_Deriv_Tot_2 as
		select a.*, b.F10_Euros_Miles
			from VerifST_Deriv_Tot a, &biblioteca..F10_Derivados_Saldo_Eur b;
quit;

/*Se calculan diferencias*/
data VerifST_Deriv_Tot_3;
set VerifST_Deriv_Tot_2;
	Diferencia = F10_Euros_Miles - SALDO_ST;
	Dif_Porc = ((F10_Euros_Miles - SALDO_ST)/SALDO_ST)*100;
run;

/*Se exporta el cuadre de depositos a nivel segmento*/
%exportXLS(VerifST_Deriv_Tot_3, 
			&localProjectPath.&dirLog.&hora_generacion_pestana_ajust._Cuadre_Deriv_F10.xlsx,
			Derivados_Total);



/************************CUADRE F16************************/

/*Se selecciona Margen de Credito y Deposito en el tablon de Stress Test*/
proc sql;
	create table VerifST_F16_Cre_Dep as
		select INSTRUMENTO, SEGMENTO_FINREP, 
			sum(ING_GAST) as ING_GAST
			from &BIBLIOTECAOUTPUTS..REQUERIMIENTO_AGREGADO_&FECHAREPORTE
				where(INSTRUMENTO IN ("02","05"))
					group by 1,2;
quit;

/*Se segmenta igual al F16*/
proc sql;
	create table VerifST_F16_Cre_Dep2 as
		select a.*, b.INSTRUMENTO_new format = $9., 
				b.SEGMENTO_FINREP_new format = $8.
			from VerifST_F16_Cre_Dep a LEFT JOIN &biblioteca..H_Cuadre_F16 b
				ON a.INSTRUMENTO = b.INSTRUMENTO AND 
					a.SEGMENTO_FINREP = b.SEGMENTO_FINREP;
quit;

/*Se vuelve a agrupar para estar alineados vs el F16*/
proc sql;
	create table VerifST_F16_Cre_Dep3 as
		select INSTRUMENTO_new as INSTRUMENTO, 
				SEGMENTO_FINREP_new as SEGMENTO_FINREP, 
				sum(ING_GAST) as Margen_ST
			from VerifST_F16_Cre_Dep2
				group by 1,2;
quit;

/*Se enriquece con el F16*/
proc sql;
	create table VerifST_F16_Cre_Dep4 as
		select a.*, (b.Margen_Eur/1000) as Margen_Euros_F16
			from VerifST_F16_Cre_Dep3 a LEFT JOIN F16_Reporte_Eur b
				ON a.INSTRUMENTO=b.Instrumento AND a.SEGMENTO_FINREP=b.Sector;
quit;

/*Se calculan diferencias*/
data VerifST_F16_Cre_Dep5;
set VerifST_F16_Cre_Dep4;
	Diferencia = Margen_Euros_F16 - Margen_ST;
	Dif_Porc = ((Margen_Euros_F16 - Margen_ST)/Margen_ST)*100;
run;

/*Descripcion completa*/
proc sql;
	create table VerifST_F16_Cre_Dep6 as
		select a.INSTRUMENTO,
				b.SEGMENTO_FINREP_NEW as SEGMENTO_FINREP,
				a.Margen_ST, a.Margen_Euros_F16, a.Diferencia, a.Dif_Porc
			from VerifST_F16_Cre_Dep5 a LEFT JOIN &biblioteca..H_Cuadre_Margen_Descrip b
				ON a.INSTRUMENTO = b.INSTRUMENTO AND
					a.SEGMENTO_FINREP = b.SEGMENTO_FINREP;
quit;

/*Se exporta el cuadre del margen de credito y depositos vs F16*/
%exportXLS(VerifST_F16_Cre_Dep6, 
			&localProjectPath.&dirLog.&hora_generacion_pestana_ajust._Cuadre_Margen_F16.xlsx,
			Margen_Cre_Dep);



/*Se selecciona de Stress Test el Margen de Emisiones*/
proc sql;
	create table VerifST_F16_Emisiones as
		select "Emisiones" as INSTRUMENT,
			sum(ING_GAST) as Margen_ST
			from &BIBLIOTECAOUTPUTS..REQUERIMIENTO_AGREGADO_&FECHAREPORTE
				where(INSTRUMENTO = "06")
					group by 1;
quit;

/*Se enriquece con el reporte F16*/
proc sql;
	create table VerifST_F16_Emisiones_2 as
		select a.*, b.Margen_Soles/(&Tipo_Cambio_Prom*1000) as Margen_F16_Euros
			from VerifST_F16_Emisiones a, &biblioteca..Margen_Emisiones b;
quit;

/*Se calculan diferencias*/
data VerifST_F16_Emisiones_3;
set VerifST_F16_Emisiones_2;
	Diferencia = Margen_F16_Euros - Margen_ST;
	Dif_Porc = ((Margen_F16_Euros - Margen_ST)/Margen_ST)*100;
run;

/*Se exporta el cuadre del margen de emisiones*/
%exportXLS(VerifST_F16_Emisiones_3, 
			&localProjectPath.&dirLog.&hora_generacion_pestana_ajust._Cuadre_Margen_F16.xlsx,
			Margen_Emisiones);




/*Se selecciona de Stress Test el Margen de Derivados*/
proc sql;
	create table VerifST_F16_Derivados as
		select "Derivados" as INSTRUMENT,
			sum(ING_GAST) as Margen_ST
			from &BIBLIOTECAOUTPUTS..REQUERIMIENTO_AGREGADO_&FECHAREPORTE
				where(INSTRUMENTO IN("04","08"));
quit;

/*Se enriquece con el reporte F16*/
proc sql;
	create table VerifST_F16_Derivados_2 as
		select a.*, b.Margen_Soles/(&Tipo_Cambio_Prom*1000) as Margen_F16_Euros
			from VerifST_F16_Derivados a, &biblioteca..Margen_Derivados b;
quit;

/*Se calculan diferencias*/
data VerifST_F16_Derivados_3;
set VerifST_F16_Derivados_2;
	Diferencia = Margen_F16_Euros - Margen_ST;
	Dif_Porc = ((Margen_F16_Euros - Margen_ST)/Margen_ST)*100;
run;

/*Se exporta el cuadre del margen de derivados*/
%exportXLS(VerifST_F16_Derivados_3, 
			&localProjectPath.&dirLog.&hora_generacion_pestana_ajust._Cuadre_Margen_F16.xlsx,
			Margen_Derivados);