
/*Leemos la tabla DESARROLLO*/

DATA DESARROLLO;
SET "C:\Users\marco.antonio.farfa1\Documents\Management Solutions Marco\Proyectos\Proyecto Colombia\Proyecto BBVA\SAS\Regresion Lineal\Data\desarrollo_comp.sas7bdat";
RUN;

DATA DESARROLLO;
SET DESARROLLO;
IF modelo_ant="ACT_NOM" THEN MODELO=1;
	ELSE IF modelo_ant="ACT_NO_NOM" THEN MODELO=2;
	ELSE IF modelo_ant="PASIVO" THEN MODELO=3;
RUN;

/*Ordeno por modelo: */

PROC SORT DATA=DESARROLLO; BY MODELO; RUN;



/*
Codigo para obtener rapidamente el modelo Regresion Lineal: 

PROC REG DATA=DESARROLLO outest=est tableout alpha=0.1;
MODEL prob_mora_nuev=prob_mora_ant;
by modelo_ant;
run;
proc print data=est;
run;
*/


/*
Codigo para dividir aleatoriamente en 2 tablas:
(la llave esta en la variable selected)

data all;
do id=1 to 10;
  output;
end;
run;
proc surveyselect data=all samprate=0.80 seed=49201 out=Sample outall 
   method=srs noprint;
run;
proc sql;
create table marco1 as
	select id
		from Sample
			where selected = 0;

create table marco2 as
	select id
		from Sample
			where selected = 1;
quit;

*/





/**********************************************MACRO RUNREG*************************************************/

/*
Esta macro recibe la tabla a realizar la regresion lineal (DSName) y el numero de iteraciones (NumVars)
y genera las tablas:
TablaFinal&i -> Tabla en la cual se puede comparar la Prob_mora_nuev con la prob_mora_nueva estimada de cada iteracion
TablaConsolidada -> La union de todas las tablas TablaF4&i, aca se puede comparar el RMSE con el RMSE2

*/

%macro RunReg(DSName, NumVars);

%do i = 1 %to &NumVars;

/*proc surveyselect -> para coger una cantidad 'n'de filas aleatorias*/



/*Por ahora solo cogo 100 como mi total para hacer un analisis mas rapido*/
/*   proc surveyselect data=&DSName*/
/*   method=srs n=100 out=SampleSRS;*/
/*   quit;*/



/*El 80% tendra selected = 1; el otro 20% tendra selected = 0*/
   proc surveyselect data=&DSName samprate=0.80 out=Sample outall 
   method=srs noprint;
   run;


   /*Tendra el 80% de filas
   y sobre el se calculara el modelo*/
	proc sql;
	create table SamploMayor as  
		select *
			from Sample
				where selected = 1;


	/*Tendra el otro 20% de filas
	y sobre el se aplicara el modelo*/
	create table SampleMenor as  
		select *
			from Sample
				where selected = 0;
	quit;
   	

/*proc reg -> para calcular los parametros del modelo de Regresion Lineal*/

	/*Importante, si alpha = 0.05 entonces se llaman L95, U95
		si no escribo el alpha, es 0.05 por default*/
   proc reg data=SamploMayor noprint
            outest=PE&i tableout alpha=0.05; 
   model prob_mora_nuev = prob_mora_ant;
   by modelo_ant;
   quit;
   

   /*Les cambio los nombres a algunas columnas para Estetica*/
   data PE&i;
   set PE&i;
      rename modelo_ant = Modelo
			 prob_mora_ant = Coef_prob_mora_ant; 
   run;


/*
   Ahora debo de agregar 6 nuevos parametros a los 2 que ya tenia(Intercept y Coef_prob_mora_ant)

   Primero los pongo en una columna aparte:
   */
   proc sql;
   create table PEE&i as
		select Modelo, _TYPE_, _RMSE_, Intercept, Coef_prob_mora_ant, 
				(case when _TYPE_ = "PVALUE" then Intercept end) as P1,
			    (case when _TYPE_ = "PVALUE" then Coef_prob_mora_ant end) as P2,
				(case when _TYPE_ = "L95B" then Intercept end) as L95B1,
				(case when _TYPE_ = "L95B" then Coef_prob_mora_ant end) as L95B2,
				(case when _TYPE_ = "U95B" then Intercept end) as U95B1,
				(case when _TYPE_ = "U95B" then Coef_prob_mora_ant end) as U95B2
			from PE&i;
   quit;

   /*Sin embargo, quiero tenerlas todas en una misma fila 
     Ademas, solo quiero 3 filas en total (1 por cada modelo): */

   proc sql;
   create table Table&i as
   		select *
			from PE&i
				where _TYPE_ = "PARMS"; /*Aqui estan los valores hallados de intercept y coef_prob_mora_ant*/
   quit;

/*
   Para poder jalar las 6 variables que corresponden a PVALUE, L95B y U95B debo hacer 3 distintos LEFT JOINs porque
   cada caso tiene un distinto KEY(el valor de _TYPE_ cambia)
*/

   /*Obteniendo los PVALUES*/
   data Table&i;
   set Table&i;
   		_TYPE_ = "PVALUE"; /*Cambiamos para poder jalar los PValues con el left join*/
   run;

   proc sql;
    create table TablaF&i as
		select a.*, b.P1 as P1, b.P2 as P2 /*Cogo los PVALUES*/
			from Table&i a LEFT JOIN PEE&i b
				on a.Modelo = b.Modelo and a._TYPE_ = b._TYPE_;
   quit;


/*Obteniendo los L95Bs*/
   data TablaF&i;
   set TablaF&i;
   		_TYPE_ = "L95B"; /*Cambiamos para poder jalar los L95Bs con el left join*/
   run;

   proc sql;
    create table TablaF2&i as
		select a.*, b.L95B1 as L95B1, b.L95B2 as L95B2
			from TablaF&i a LEFT JOIN PEE&i b
				on a.Modelo = b.Modelo and a._TYPE_ = b._TYPE_;
   quit;


/*Obteniendo los U95Bs*/
   data TablaF2&i;
   set TablaF2&i;
   		_TYPE_ = "U95B"; /*Cambiamos para poder jalar los U95Bs con el left join*/
   run;


   /* TablaF3&i ya tiene todos los parametros del modelo de Regresion Lineal por Modelo*/
   proc sql;
    create table TablaF3&i as
		select a.Modelo, a._RMSE_, a.Intercept, a.Coef_prob_mora_ant, a.P1, a.P2, a.L95B1, a.L95B2, b.U95B1 as U95B1, b.U95B2 as U95B2
			from TablaF2&i a LEFT JOIN PEE&i b
				on a.Modelo = b.Modelo and a._TYPE_ = b._TYPE_;
   quit;



	/*Ahora que ya tengo los 2 parametros importantes del modelo, procedo a aplicarlos a 
      SampleMenor (el 20% restante de data)
   	  jalo los 2 parametros de acuerdo al Modelo*/

   proc sql;
   		create table TablaFinal&i as
			select a.*, b.Intercept, b.Coef_prob_mora_ant
				from SampleMenor a LEFT JOIN TablaF3&i b
					on a.modelo_ant = b.Modelo;	
   quit;

/*Hago calculos intermedios: */
   data TablaFinal&i;
   set TablaFinal&i;
		prob_Estimada = Intercept + Coef_prob_mora_ant*prob_mora_ant;
		DifCuadrado = (prob_Estimada - prob_mora_nuev)*(prob_Estimada - prob_mora_nuev);
   run;


/* 
   Aplico los parametros hallados en el 80% de data al 20% de data restante
   y hallo el error cuadratico medio nuevo y lo comparo con el error cuadratico medio del modelo
   para ver que tan preciso es el Modelo
*/
   proc sql;
   	create table TablaFinalFinal&i as
		select modelo_ant, sum(DifCuadrado)/count(modelo_ant) as RMSE2, count(modelo_ant) as CuentaModelo
			from TablaFinal&i
				group by 1;
   quit;


   /*
	_RMSE_  : Error cuadratico medio del 80% de data segun el modelo
	_RMSE2_ : Error cuadratico medio aplicado al 20% de data restante segun los parametros hallados con el modelo
   */
   proc sql;
		create table TablaF4&i as
			select a.*, b.RMSE2 as _RMSE2_
				from TablaF3&i a LEFT JOIN TablaFinalFinal&i b
					ON a.Modelo = b.modelo_ant;
   quit;
   

	/*Finalmente, CONSOLIDO las tablas de salida TablaF4&i en una sola tabla
      que se llamara TablaConsolidada*/

   %if &i = 1 %then
    %do;
		data TablaConsolidada;
		set TablaF4&i;
   		run;
	%end;

   %else
    %do;
		data TablaConsolidada;
		set TablaConsolidada TablaF4&i;
		run;
    %end;

/*Borramos las tablas usadas en pasos intermedios para liberar memoria*/

	proc delete data = PE&i;
	proc delete data = PEE&i;
	proc delete data = Table&i;
	proc delete data = TablaF&i;
	proc delete data = TablaF2&i;
	proc delete data = TablaF3&i;
	proc delete data = TablaFinalFinal&i;
	proc delete data = TablaF4&i;

%end;

%mend;

%RunReg(DESARROLLO, 100);





/* Codigo adicional para ver la media y la desviacion de la prob_mora_nuev original y
de la prob mora nueva estimada: prob_Estimada: 

proc means data=TablaFinal1; var prob_mora_nuev prob_Estimada;by Modelo_ant;
run;

*/