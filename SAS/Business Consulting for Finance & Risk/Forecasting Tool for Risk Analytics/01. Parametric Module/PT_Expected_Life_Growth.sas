
/*Engine Table with LOB*/
proc sql;
create table Engine_Complete as
select Eng.*, ifrs.lob_dept1 as lob_dept1
from &ENGINE. Eng
LEFT JOIN &master_alll. ifrs 
ON Eng.CMCO_COD_CCONTR = ifrs.CMCO_COD_CCONTR
WHERE Eng.CMCO_IMP_PROV_FINAL <= 100000000000000;
quit;

/*Pulling Variables Needed for Parametric Table*/
proc sql;
create table Expected_Life_Growth_Vars as
	select distinct CMCO_COD_CCONTR, lob_dept1, Family_Code, CMCO_IMP_EAD_ACTUAL, CMCO_FEC_APERTURA as OPEN_DT, CMCO_FEC_VENCIM as MATY_DT
	from Engine_Complete
	where CMCO_FEC_VENCIM ne '00010101' and CMCO_IMP_EAD_ACTUAL ne 0
;quit;

/*Adjusting date variable formatting, adding vintage variable,
calculating the time difference between the open date and the maturity date*/
data Expected_Life_Growth_Vars_2;
set Expected_Life_Growth_Vars;

OPEN_DT1= put(input(cats(Open_DT),8.),z8.);
format open_date ddmmyy.;
open_date= mdy((substr(OPEN_DT1,5,2)),(substr(OPEN_DT1,7,2)),(substr(OPEN_DT1,1,4)));

MATY_DT1= put(input(cats(Maty_DT),8.),z8.);
format maturity_date ddmmyy.;
maturity_date= mdy((substr(MATY_DT1,5,2)),(substr(MATY_DT1,7,2)),(substr(MATY_DT1,1,4)));

Vintage = input(substr(OPEN_DT1,1,4), 4.);

date_diff = intck('year', open_date, maturity_date) ;
date_diff_2 = yrdif(open_date, maturity_date);

run;


/*Calculates Expected Life for all vintages weighting by EAD*/
proc sql;
	create table Exp_Life_Growth_Vintage as
	select lob_dept1 , Family_Code, Vintage, ceil(sum(date_diff_2*CMCO_IMP_EAD_ACTUAL) / sum(CMCO_IMP_EAD_ACTUAL)) as Expected_Life
	From Expected_Life_Growth_Vars_2
	group by lob_dept1, family_Code, Vintage;
quit;

/*Stores the newest vintage*/
proc sql;
create table Exp_Life_Max_Vintage as
select lob_dept1, Family_Code, max(Vintage) as max_Vintage
from Exp_Life_Growth_Vintage
group by 1,2;
quit;

/*Keeps the newest vintage*/
proc sql;
create table Exp_Life_Growth_Newest as
select Growth.*
from Exp_Life_Growth_Vintage Growth
INNER JOIN Exp_Life_Max_Vintage Vintage
ON Growth.lob_dept1 = Vintage.lob_dept1 AND
Growth.Family_Code = Vintage.Family_Code AND
Growth.Vintage = Vintage.max_Vintage;
quit;

/*Creates Final Expected life for Growth Parametric Table*/
data Output.Expected_Life_Growth; 
format lob_dept1;
format Family_Code;
format vintage;
format Expected_Life;
set Exp_Life_Growth_Newest(drop=vintage);
	do vintage = 1 to 4;
		output;
	end;
run;