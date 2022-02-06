
/*Analisis empieza en 2011 Enero y termina en Diciembre 2016*/
%let Fec_ini  = "01JAN11"d;
%let Fec_Admi = "31DEC16"d;
%let nper = 71;



	Data list; /*VECTORES DE RECORRIDO ANUALES*/
		do i = 0 to &nper.;
		j=i-1;
			Format Date yymmdd10.;
			Date = intnx("month", &Fec_Admi., -1*i, "ending");
			x = upcase(put(intnx("month", &Fec_Admi., -1*i, "ending") , eurdfde9.));

			anio=year(date);
			mes=month(date);
			fecha_fm = catx( "_",anio,mes);

			/*CUENTA CICLOS*/

			dias= catx("_", "DIAS_cliente",fecha_fm);/*la diferencia con consumo, consumo es:"DIAS_VENCIDOSFM02" */
			CICLOS=catx("_","CICLOS",FECHA_FM);
			ciclos_madurez=catx("_","ciclos_madurez",FECHA_FM);
			CONT_CICL=catx("_","CONT_CICL",FECHA_FM);
			CONT_INT_CICL=catx("_","CONT_INT_CICL",FECHA_FM);
			meses_madurez=catx("_","meses_madurez",FECHA_FM);
			saldo=catx("_","saldo_totalfm02",FECHA_FM);
			*INT_ctes=catx("_","ICTE_VENCIDOFM02",FECHA_FM);
			CALIF=catx("_","cal_def",FECHA_FM);
			CICLOS_CALIF=catx("_","CICLOS_CALIF",FECHA_FM);
			CONT_CALIF=catx("_","CONT_CALIF",FECHA_FM);
			Pm=catx( "_","pm",FECHA_FM);
			Pd_90=catx( "_","cosecha",&nper.-i,&nper.-i+1);
			mora_sub=catx( "_","mora_sub",FECHA_FM);
			TRIM=catx( "_","TRIM",FECHA_FM);

			output;
		end;

	Run;


	Proc sort Data = list; By descending i;quit;

	Proc sql noprint;
		Select dias into: dias separated by " " from list;
		Select TRIM into: TRIM separated by " " from list;
		SELECT CONT_CICL INTO: CONT_CICL SEPARATED BY " " FROM list;
		SELECT CONT_INT_CICL INTO: CONT_INT_CICL SEPARATED BY " " FROM list;
		SELECT meses_madurez INTO: meses_madurez SEPARATED BY " " FROM list;
		SELECT CICLOS INTO: CICLOS SEPARATED BY " " FROM list;
		SELECT ciclos_madurez INTO: ciclos_madurez SEPARATED BY " " FROM list;
		SELECT saldo INTO: saldo SEPARATED BY " " FROM list;
		*SELECT INT_ctes INTO: INT_ctes SEPARATED BY " " FROM list;
		SELECT CALIF INTO: CALIF SEPARATED BY " " FROM list;
		SELECT CONT_CALIF INTO: CONT_CALIF SEPARATED BY " " FROM list;
		*SELECT CONT_INT_CALIF INTO: CONT_INT_CALIF SEPARATED BY " " FROM list;
		SELECT CICLOS_CALIF INTO: CICLOS_CALIF SEPARATED BY " " FROM list;
		Select Pm into: Pm separated by " " from list;
		Select Pd_90 into: cosecha separated by " " from list;
		Select mora_sub into: mora_sub separated by " " from list;

	quit;

	%put &dias.;
	%put &fechasb.;
	%put &CONT_CICL.;
	%put &meses_madurez.;
	%put &CICLOS;
	%put &ciclos_madurez;
	%put &CONT_INT_CICL;
	%put &saldo.;
	*%put &INT_ctes;
	%put &CALIF;
    %put &CONT_CALIF;
	*%PUT &CONT_INT_CALIF;
	%PUT &CICLOS_CALIF;
	%put Pm;
	%put cosecha;	
	%put mora_sub;
	%put TRIM;


data listas2; /*VECTORES DE RECORRIDO POR TRIMESTRE*/
do i=1 to 24;
j=i-1;
NUMER=catx( "_","Num",j,i); /*numerador*/
Denom=catx( "_","Den",j,i); /*denominador*/
cohorte=catx("_","cohorte",i);
output;
end;
run;

Proc sort Data = listas2; By  i;

Proc sql noprint;
	Select NUMER into: NUMER separated by " " from listas2
	Select Denom into: Denom separated by " " from listas2;
	select cohorte into: cohorte separated by " " from listas2; 
quit;

%put Denom;
%put NUMER;
%put cohorte;
 




%let fecha_in=2011;
%let period=3;/*periodicidad de la PD trimestral, mensual, anual*/
%let intraciclo=12;/*duración para unir ciclos  en meses*/
%let materialidad=139000;



/*lectura de la tabla de entrada*/
data consumo_dayana;
	Set "C:\Users\c341973\Desktop\dayana\base_empresas_final22junio.sas7bdat";
run;



data consumo_dayana_ordenado;
retain tp nit suc_obl_al numero_op prod_alt &dias. &saldo. &CALIF. ;
set consumo_dayana;
run;



data consumo_replica;
set consumo_dayana;
	array dias(*) 	&dias.; /*recorre las columnas de dias de incumplimiento*/
	array meses_madurez(*) 	&meses_madurez.; 
	array CICLOS (*)     &CICLOS.;
	array CONT_CICL (*)     &CONT_CICL.;
	array ciclos_madurez (*)     &ciclos_madurez.;
	array CONT_INT_CICL (*) &CONT_INT_CICL.;
	array saldo(*)  &saldo.;

	a = dim(dias);
	format saldo_totalfm02_2011_1 16.2;
	/********************************/
	/*Creación del vectores de recorrido*/
	/********************************/

	if DIAS_VENCIDOSFM02_2011_1 ne . or DIAS_VENCIDOSFM02_2011_1=0 then meses_madurez(1)=1; /*Arranca la madurez, es cuando viene diferente de vacio*/
	IF DIAS_VENCIDOSFM02_2011_1>90 /*deberia ser inclusivo, esta operacion se excluye en el filtro de la base*/ 
	then CICLOS(1)=1; /*Se inicia el primer ciclo de mora*/
    else if DIAS_cliente_2011_1>9e-9 then CICLOS(1)=0; /*Deberia ir sin la condición ? o ser <90 no arrastra ?*/


	ciclos_madurez(1)= 0;

	do i=1 TO a;
		j=i-1;

		/*INFORMA MADUREZ*/
		if i=1 and saldo(i) ne . then meses_madurez(i)=1;/*arranca la madurez de la operacion en el primer valor de i*/
		if i>1  then do;
			if meses_madurez(j)>0 and saldo(i) ne . then meses_madurez(i)=meses_madurez(j)+1;/* va aumentando la madurez del cliente a medida que tenga meses informados*/
			if (saldo(j)=.  and meses_madurez(j)=.) and saldo(i) ne . then meses_madurez(i)=1;/*toma el caso en el que la operacion inicia despues de enero2011
		(excluye el caso en el que la operacion haya salido de un ciclo y esté entrando a uno nuevo, donde sus dias i<>. j=. pero su madurez >0)*/
	if meses_madurez(j)>0 and saldo(i)=. then meses_madurez(i)=meses_madurez(j);
end;

		
		/*ciclos de madurez
		if (meses_madurez(1) = .) then do;
			if i>1 and meses_madurez(i)>0 and meses_madurez(j)=. then ciclos_madurez(i)=ciclos_madurez(j)+1;
			else 
				if i>1 then ciclos_madurez(i)=ciclos_madurez(j);
				else if i=0 then ciclos_madurez(i)=0;
		end;

		else if (meses_madurez(1) > 0 AND i=1) then do; ciclos_madurez(i)= 1; end;
		else if (meses_madurez(1) > 0 AND i>1) then do;
				if i>1 and meses_madurez(i)>0 and meses_madurez(j)=. then ciclos_madurez(i)=ciclos_madurez(j)+1;
				else ciclos_madurez(i)=ciclos_madurez(j);
		end;*/


		/*INFORMA LOS CICLOS DE MORA*/
		if i>=1 and  meses_madurez(i)=1 then ciclos(i)=0; /*no hay que tener en cuenta que los dias sean menores de 90 o no deberia ser solo  = */
		if i>1 then do;
			if ciclos(j)>=0 and dias(i)<=90 then ciclos(i)=ciclos(j);/* donde salga de un ciclo de mora se conserva el #*/
			if dias(j)<=90 and dias(i)>90 and ciclos(j)=0 then ciclos(i)=1;/*arranca los ciclos de mora despues de enero 2011*/
			if dias(j)>90 and dias(i)>90 then ciclos(i)=ciclos(j);/* conserva la cantidad de ciclos mientras se está en uno*/
			if dias(j)<=90 and dias(i)>90 and ciclos(j)>0 then ciclos(i)=ciclos(j)+1; /*aumenta la cantidad de ciclos cuando se entra a uno nuevo*/
		end;


		
		/*INFORMA MESES DE LOS CICLOS */
		if i>1 then do;
			if ciclos(j)< ciclos(i) and ciclos(j)>=0 and  CONT_CICL(j)=. then CONT_CICL(i)=1;/*se inicia cada vez que se entra a un ciclo de mora*/
			if dias(i)>90 and CONT_CICL(j)>0 then CONT_CICL(i)=CONT_CICL(j)+1;/*aumenta los meses del ciclo*/
		end;


		

		/*INFORMA LOS INTRACICLOS DE MORA*/
		if j>0 and dias(j)>90 and dias(i)=< 90 and dias(i) ne . then do;/*inicia los vectores cuando se entra a el primer ciclo*/
                      CONT_INT_CICL(i)=1;
               end;
               if j>0 and dias(j)<=90 and dias(i)<=90  then/*Cuenta la cantidad de meses en cada ciclo*/
                       CONT_INT_CICL(i)=CONT_INT_CICL(j)+1;

	end;




	max_meses_madurez=max(of meses_madurez:);
	max_ciclo=max(of CONT_CICL:);
	MAX_CONT_INT_CICL=max(of CONT_INT_CICL:);
	trim_salida=int((max_meses_madurez-1)/&period.)+1;
run;




/*
DEFINO LOS VECTORES para calcular la probabilidad de default (PD),

La PD sera igual al numerador(N)/denominador(D)
*/
data listas3;
	do i=1 to 20;
		do j=1 to 5;
			Bloque_N = catx("_","BloqueN",i,j);
			Suma_Bloque_N = compress("SumBloqueN_"||i||"_"||j);
			SumaTotalN=catx(" ","SUM(",Bloque_N,") AS",Suma_Bloque_N,",");

			Bloque_D = catx("_","BloqueD",i,j);
			Suma_Bloque_D = compress("SumBloqueD_"||i||"_"||j);
			SumaTotalD=catx(" ","SUM(",Bloque_D,") AS",Suma_Bloque_D,",");

			output;
		end;
	end;
run;

proc sql noprint;
	select Bloque_N into: Bloque_N separated by " " from listas3;
	SELECT Suma_Bloque_N    INTO :Suma_Bloque_N separated by " "    FROM listas3;
	SELECT SumaTotalN    INTO :SumaTotalN separated by " "    FROM listas3;

	select Bloque_D into: Bloque_D separated by " " from listas3;
	SELECT Suma_Bloque_D    INTO :Suma_Bloque_D separated by " "    FROM listas3;
	SELECT SumaTotalD    INTO :SumaTotalD separated by " "    FROM listas3;
quit;

%put &Bloque_N.;
%put &Suma_Bloque_N.;
%put &SumaTotalN.;
%put &Bloque_D.;
%put &Suma_Bloque_D.;
%put &SumaTotalD.;


data consumo_replica1;
retain &dias. &saldo. &CICLOS. &CALIF. &Bloque_N. &Bloque_D.;
set consumo_replica;
run;



/*COHORTES

Defino las cohortes trimestrales,

Cada operacion entrara en las cohortes si tiene una buena calificacion y no esta en mora en dicho periodo
*/

data calculo_cohorte;
set consumo_replica1;

array cohorte(*) &cohorte.;
array saldo (*) &saldo.;
array CALIF (*) &CALIF.;
array CONT_INT_CICL (*) &CONT_INT_CICL.;
array meses_madurez (*) &meses_madurez.;
array dias(*) &dias.;
array ciclos(*) &ciclos.;



a=dim(cohorte);

do i=1 to a;
	j=3*i;
	if i=1 then do;
		if meses_madurez(j) >=1 and ( CALIF(j)<5 and dias(j)<=90) then cohorte(i)=1;

	end;

	if i>1 then do;
		if meses_madurez(j) >=1 and ( CALIF(j)<5 and dias(j)<=90)	then do; 
			if ciclos(j)>0 then do; /*PIENSO QUE HAY UN ERROR (j) deberia ser?*/
				if CONT_INT_CICL(j)>12 then cohorte(i)=1;  /*Si entro en mora y pasaron 12 meses*/
			end;
			else
				cohorte(i)=1; /*Si no entro en mora nunca*/
		end;
	end;

end;
run;




/*Calculo el numerador*/
data MarcoCod;
set calculo_cohorte;

	array dias(*) 	&dias.; /*recorre las columnas de dias de incumplimiento*/
	array saldo(*)  &saldo.;
	array CICLOS (*)     &CICLOS.;
	array CALIF (*)     &CALIF.;
	array Bloque_N (*)     &Bloque_N.;
	array cohorte(*) &cohorte.;


do i=1 to 20;
	flagj=0;

	if (cohorte(i)=1) then
		do;
			do j=1 to 5;
				
				x = (3*i) + 12*(j-1);/*mes inicial del año j de observación*/
				y = x + 11;/*mes final del año j de observación*/

				do k=x to y;
					if(k>72) then 
						continue;
					else
					do;
						if(dias(k) > 90 OR CALIF(k) >= 5) then
							do;
								num = 5*(i-1) + j;/*calcula la posicion en el vector bloque_n a partir de su i y j*/
								Bloque_N(num) = 1;   /*pone el actual a 1*/
								flagj=1;
								leave;
							end;				
					end;
				end;

				if(flagj=1) then
					leave;
			end;
		end;

end;

run;


/*Calculo el denominador*/
data MarcoCod2;
set MarcoCod;

	array dias(*) 	&dias.; /*recorre las columnas de dias de incumplimiento*/
	array Bloque_N (*)     &Bloque_N.;
	array Bloque_D (*)     &Bloque_D.;

do i=1 to 20;
	do j=1 to 5;

		x = (3*i) + 12*(j-1);
		y = x + 11;

		num = 5*(i-1) + j;
		
		if(num>1) then
			do;
				if(Bloque_D(num-1) =1 AND Bloque_N(num-1) = 1) then /*cuando fue malo el ciclo anterior*/
					do;
						Bloque_D(num) = 1;
					end;
			end;

		if(Bloque_N(num) = 1) then /*Cuando es malo*/
			Bloque_D(num) = 1;
		else
			do;
				if(meses_madurez_2016_12 <= (12*j + 2)) then  /*chekar bie sto!*/
					Bloque_D(num) = meses_madurez_2016_12/(12*j + 2);
				else
					Bloque_D(num) = 1;
			end;
			
	end;
end;

run;



proc sql ;
create table MarcoCod3 as 
	select  &SumaTotalN. &SumaTotalD. *
		from MarcoCod2
			group by nit; 
quit;