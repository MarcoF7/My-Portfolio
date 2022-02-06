
/*Engine Table with LOB*/
proc sql;
create table Engine_Complete as
select Eng.*, ifrs.lob_dept1 as lob_dept1
from &ENGINE. Eng
LEFT JOIN &master_alll. ifrs 
ON Eng.CMCO_COD_CCONTR = ifrs.CMCO_COD_CCONTR
WHERE Eng.CMCO_IMP_PROV_FINAL <= 100000000000000;
quit;

/*Creating Risk Profile for Growth Parametric Table*/

/*Determines number of months on books
Removes default contracts*/

data Engine_Complete_date;
set Engine_Complete;

Current_DT1= put(input(cats(CMCO_FEC_DATOS),8.),z8.);
format current_date ddmmyy.;
current_date= mdy((substr(Current_DT1,5,2)),(substr(Current_DT1,7,2)),(substr(Current_DT1,1,4)));

Open_DT1= put(input(cats(CMCO_FEC_APERTURA),8.),z8.);
format open_date ddmmyy.;
open_date= mdy((substr(Open_DT1,5,2)),(substr(Open_DT1,7,2)),(substr(Open_DT1,1,4)));

format date_diff 5.;
date_diff = intck('month', open_date, current_date) ;

where default_flag_final = '0';

run;

/*Limits data to contracts opened in the previous 6 months*/
data Engine_Complete_date;
set Engine_Complete_date;
where date_diff <=6;
run;


/*Select distint to ensure there are no duplicates, order by to select oldest batch ID in next step*/
proc sql;
create table engine_order as
select distinct *
from Engine_Complete_date
order by lob_dept1, Family_Code, CMCO_COD_CCONTR, open_date
;quit;

/*Keeps oldest date for each account*/
proc sort data=engine_order nodupkey out=Fst_Batch;
by CMCO_COD_CCONTR;
run; 

/*Summing total commitment for each Line of Business and Family Code*/
proc sql;
create table Risk_Prof_Growth_1 as
select lob_dept1, Family_Code, Driver_PD, Driver_LGD, CMCO_IMP_EAD_ACTUAL, sum(CMCO_IMP_EAD_ACTUAL) as Total_Commit_Fam
from Fst_Batch
group by lob_dept1, Family_Code
;quit;

/*Summing total commitment for each PD Driver and LGD Driver Combination*/
proc sql;
	create table Risk_Profile_Growth_2 as
	select lob_dept1, Family_Code, Driver_PD, Driver_LGD, CMCO_IMP_EAD_ACTUAL, sum(CMCO_IMP_EAD_ACTUAL) as Total_Commit_PD, Total_Commit_Fam
	from Risk_Prof_Growth_1  
	group by 1,2,3,4
	order by 1,2,3,4
;quit;


/*Calculating percentage of total commitment each PD Driver and LGD Driver combination contributes to the growth*/
proc sql;
	create table output.Risk_Profile_Growth as
	select distinct lob_dept1 as Line_Of_Business, Family_Code as Family_Code, Driver_PD, Driver_LGD, Total_Commit_PD/Total_Commit_Fam as Distribution_Factor
	from Risk_Profile_Growth_2
	group by 1,2
	order by 1,2 
;quit;


