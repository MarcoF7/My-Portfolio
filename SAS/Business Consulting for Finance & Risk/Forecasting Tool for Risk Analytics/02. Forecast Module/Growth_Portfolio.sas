
/************Calculating Growth Amounts****************/

/*We transpose back to have the initial structure*/
proc transpose
data=Balance_Projec_PT
out=Balances_EAD_Trans_Back
name=Batch_ID;
by lob_dept1 Family_Code;
run;

/*Formatting*/
data Balances_EAD_Corrected(keep=lob_dept1 Family_Code Batch_ID_Format COL1
rename=(Batch_ID_Format = Batch_ID COL1 = EAD));
set Balances_EAD_Trans_Back;
	format Batch_ID_Format 8.;
	Batch_ID_Format = INPUT(substr(Batch_ID,5,8),$8.);
run;

/*Summarizing Stock Projection*/
proc sql;
create table Stock_EAD_Project as
select lob_dept1, Family_Code, DAY_ID_PY,
sum(Calc_EAD_Final) as EAD_Stock
from output.Stock_Portf_Provision
group by 1,2,3;
quit;

/*Calculating the Growth with the updated values based on the PT Balance Projection*/
proc sql;
create table Growth_EAD_Calcul as
select Tot.Batch_ID, Tot.lob_dept1, Tot.Family_Code, 
Tot.EAD as EAD_Growth, Stock.EAD_Stock,
coalesce(Tot.EAD,0) - coalesce(Stock.EAD_Stock,0) as Growth_Calc
from Balances_EAD_Corrected Tot
FULL JOIN Stock_EAD_Project Stock
ON Tot.Batch_ID = Stock.DAY_ID_PY AND Tot.lob_dept1 = Stock.lob_dept1 AND
Tot.Family_Code = Stock.Family_Code;
quit;


/***************************GROWTH PORTFOLIO*****************************/

/*Calculating the Years of Projection based on the Growth Year.
Defining all growth portfolio initially as Stage 1*/
data Growth_EAD_Year;
set Growth_EAD_Calcul;
	format Batch_ID_Date yymmdd10.;
	format _year z4.0;
	format _month z2.0;
	format _day z2.0;
	format _date_base yymmdd10.;

	Batch_ID_Date = input(put(Batch_ID, 8.), yymmdd10.);
	_year = input(substr(left(&DAY),1,4),4.);
	_month = input(substr(left(&DAY),5,2),2.);
	_day = input(substr(left(&DAY),7,2),2.);
	_date_base = mdy(_month, _day, _year);

	Growth_Year = year(Batch_ID_Date) - year(_date_base);
	Years_Projection = 4-Growth_Year;

	Stage_Base = 0;
run;

/*Pulling Years to Maturity.
We filter projected Batch IDs*/
proc sql;
create table Growth_Base_YTM as
select Growth.Batch_ID, Growth.lob_dept1, Growth.Family_Code,
growth.Years_Projection, Growth.Growth_Calc, Growth.Stage_Base,
Expec.Expected_Life as PLZ_RESID
from Growth_EAD_Year Growth
LEFT JOIN Exp_Life_Growth_PT Expec
ON Growth.lob_dept1 = Expec.lob_dept1 AND Growth.Family_Code = Expec.Family_Code AND
Growth.Growth_Year = Expec.Vintage
where Growth.Years_Projection > 0 AND Growth.Years_Projection < 4;
quit;

/*Generating the Year of Projection*/
data Growth_EAD_Year_of_proj(drop=Years_Projection);
set Growth_Base_YTM;
	do Year = 1 to Years_Projection;
		output;
	end;
run;

/*Creating the Projection Day_ID and the Projection YTM (years to maturity)*/
data Growth_Base_Day_Py;
set Growth_EAD_Year_of_proj;
	DAY_ID_PY = Batch_ID + 10000*year;
	YTM_PY = PLZ_RESID - year;
run;

/*Distributing in PD Driver and LGD Driver
Ordering final Growth Base Table to calculate the Provision of the Growth*/
proc sql;
create table Growth_Base_Rsk_prof as
select Growth.Batch_ID as DAY_ID, Growth.lob_dept1, Growth.Family_Code,
Growth.Stage_Base, Rsk.Driver_PD, Rsk.Driver_LGD,
Growth.PLZ_RESID, Growth.Year, Growth.DAY_ID_PY, Growth.YTM_PY,
Growth.Growth_Calc*Rsk.Distribution_Factor as EAD_actual, /*Growth_Distributed*/
0 as Provision_Actual
from Growth_Base_Day_Py Growth
LEFT JOIN Rsk_Prof_Growth_PT Rsk
ON Growth.lob_dept1 = Rsk.Line_Of_Business AND
Growth.Family_Code = Rsk.Family_Code
order by 1,2,3,4,5,6,7,8;
quit;


data Growth_Base_Final;
set Growth_Base_Rsk_prof;
	where DAY_ID = 20200531;
run;


%Provision(Growth_Base_Final, Growth_Portf_Provision);







data test;
set Growth_Base_Rsk_prof;
	where lob_dept1 = "COMMERCIAL BANKING AND WMG CONSOLIDATION" AND
			Family_Code = "Commercial - CRE";
run;








/*Freq Test*/
proc freq data=Forecast_Bal_Base_Obs noprint;
tables LOB_NAME/out=test_freq_Obs missing;
run;

proc freq data=FAMILY_CODE_GL_LKP noprint;
tables lob_dept_detail/out=test_freq_Lkp;
run;
/*End Freq Test*/


/*Checking Duplicates*/
proc sql;
create table test as 
select Balance_ID, count(*) as cc
from FAMILY_CODE_GL_LKP
group by 1
having cc>1
;
quit;

proc sql;
create table test_compl as
select a.*
from FAMILY_CODE_GL_LKP a
INNER JOIN test b
ON a.Balance_ID = b.Balance_ID
order by a.Balance_ID
;
quit;
/*End Checking Duplicates*/