/*** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***/

/* PROGRAMA: Importar_Plan_Cuotas_Completo.sas
/* OBJETIVO: Carga del plan de cuotas
/* AUTOR:	 Management Solutions
/* PROCESO:  Se realiza la importación del plan de cuotas de todas las operaciones
/*			 de la fecha de datos. Las cuotas se encuentran agrupadas en trimestres y
/* 			 representan las amortizaciones.
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

%PUT job "Importar_Plan_Cuotas_Completo.sas" comenzó a %now;
/**/
* Se asigna el nombre lógico del fichero;
/*%let Nombre_Logico_Input = Plan_Cuotas;*/

/** Se busca la ruta física en la tabla "FICHEROS_INPUT";*/
/*data _NULL_;*/
/*	set FICHEROS_INPUT;*/
/**/
/*	if Nombre_Logico_Fichero = "&Nombre_Logico_Input." then do;*/
/*		call symput('Ruta_input_a_cargar', trim(Ruta));*/
/*	end;*/
/*run;*/
/**/
/**/
/*data &biblioteca..Plan_Cuotas;*/
/*	set "&dir_ficheros_orig.&Ruta_input_a_cargar";*/
/*run;*/


/*los saldos vienen en unidades y en la DIVISA que indican*/
/*Se pasa todo a EUROS y en unidades*/
proc sql;
	create table &biblioteca..Plan_Cuotas2_prev as
		select a.CONTRATO, 
	/*Holding esta pidiendo las cuotas anteriores al 2018 para hacer validaciones de DQ*/
				(a.Q2016_1 * b.Tipo_Cambio_Eur) as Q2016_1_Eur, (a.Q2016_2 * b.Tipo_Cambio_Eur) as Q2016_2_Eur, 
				(a.Q2016_3 * b.Tipo_Cambio_Eur) as Q2016_3_Eur, (a.Q2016_4 * b.Tipo_Cambio_Eur) as Q2016_4_Eur,
				(a.Q2017_1 * b.Tipo_Cambio_Eur) as Q2017_1_Eur, (a.Q2017_2 * b.Tipo_Cambio_Eur) as Q2017_2_Eur, 
				(a.Q2017_3 * b.Tipo_Cambio_Eur) as Q2017_3_Eur, (a.Q2017_4 * b.Tipo_Cambio_Eur) as Q2017_4_Eur, 

				(a.Q1 * b.Tipo_Cambio_Eur) as Q1_Eur,
				(a.Q2 * b.Tipo_Cambio_Eur) as Q2_Eur, (a.Q3 * b.Tipo_Cambio_Eur) as Q3_Eur,
				(a.Q4 * b.Tipo_Cambio_Eur) as Q4_Eur, (a.Q5 * b.Tipo_Cambio_Eur) as Q5_Eur,
				(a.Q6 * b.Tipo_Cambio_Eur) as Q6_Eur, (a.Q7 * b.Tipo_Cambio_Eur) as Q7_Eur,
				(a.Q8 * b.Tipo_Cambio_Eur) as Q8_Eur, (a.Q9 * b.Tipo_Cambio_Eur) as Q9_Eur,
				(a.Q10 * b.Tipo_Cambio_Eur) as Q10_Eur, (a.Q11 * b.Tipo_Cambio_Eur) as Q11_Eur,
				(a.Q12 * b.Tipo_Cambio_Eur) as Q12_Eur, (a.Q13 * b.Tipo_Cambio_Eur) as Q13_Eur
			from &bibliotecaInputs..PCUOK_Total_Stress_Test a left join Tipo_De_Cambio b 
				ON a.Divisa =  b.Divisa;
quit;

/*Se agrupa a nivel contrato y resume las cuotas*/
proc sql;
	create table &biblioteca..Plan_Cuotas2 as
		select CONTRATO, 
				sum(Q2016_1_Eur) as Q2016_1_Eur, sum(Q2016_2_Eur) as Q2016_2_Eur,
				sum(Q2016_3_Eur) as Q2016_3_Eur, sum(Q2016_4_Eur) as Q2016_4_Eur,
				sum(Q2017_1_Eur) as Q2017_1_Eur, sum(Q2017_2_Eur) as Q2017_2_Eur,
				sum(Q2017_3_Eur) as Q2017_3_Eur, sum(Q2017_4_Eur) as Q2017_4_Eur,
				sum(Q1_Eur) as Q1_Eur, sum(Q2_Eur) as Q2_Eur, sum(Q3_Eur) as Q3_Eur,
				sum(Q4_Eur) as Q4_Eur, sum(Q5_Eur) as Q5_Eur, sum(Q6_Eur) as Q6_Eur,
				sum(Q7_Eur) as Q7_Eur, sum(Q8_Eur) as Q8_Eur, sum(Q9_Eur) as Q9_Eur,
				sum(Q10_Eur) as Q10_Eur, sum(Q11_Eur) as Q11_Eur, sum(Q12_Eur) as Q12_Eur,
				sum(Q13_Eur) as Q13_Eur

			from &biblioteca..Plan_Cuotas2_prev
				group by 1;
quit;