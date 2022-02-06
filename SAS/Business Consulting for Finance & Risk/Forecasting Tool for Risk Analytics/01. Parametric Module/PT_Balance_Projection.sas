

/*******************************IMPORTING**********************************/

/*Macro to import a specific Sheet from the Forecasting Tool parametric excel.
Sheet: Sheet Name
First_Row: Row from which the data starts (not header)
Output_PT: Name of the output imported table

SAS does not allow to import with header from a row different than the first one in Excel.
So this macro does that in 2 steps, first importing the data and then importing the headers,
and finally merging them*/
%Macro Import_Bal_Proj(Sheet, First_Row, Output_PT);

/*Importing Balance Projection Parametric Table*/
proc import out=Output_PT_prev
	datafile="&Forec_Tool.&Forecast_PT."
	dbms=xlsx replace;
	sheet="&Sheet.";
	datarow=&First_Row.;
	getnames=no;
run;

/*Importing  Headers*/
proc import out=PT_Head_p
	datafile="&Forec_Tool.&Forecast_PT."
	dbms=xlsx replace;
	sheet="&Sheet.";
	datarow=%eval(&First_Row. - 1);
	getnames=no;
run;

/*We keep the header names*/
data PT_Head;
set PT_Head_p;
	if _N_ = 1;
run;

/*Previous steps to get &Names_Head. to do the transpose with the Var statement*/
/*Transpose To have header vertically*/
proc contents data=PT_Head out=PT_Head_Nm noprint;
run;

/*Putting header in the correct order*/
proc sql;
create table PT_Head_Ord  as
select NAME
from PT_Head_Nm
order by VARNUM;
quit;

/*Saving initial header values*/
proc sql noprint;
select NAME	into: Names_Head
separated by " "
from PT_Head_Ord;
quit;

/*We take the data from a Horizontal view to a Vertical view*/
proc transpose
data=PT_Head
out=PT_Head_tr;
Var &Names_Head.;
run;

/*Keeping informed columns*/
data PT_Head_clean(keep=_NAME_ COL1);
set PT_Head_tr;
	where COL1 ne "";
run;

/*Renaming for the header*/
proc sql noprint;
select cats(_NAME_, "=", COL1) into: Rename_Head
separated by " "
from PT_Head_clean;
quit;

/*Keep Names for the header*/
proc sql noprint;
select _NAME_ into: Keep_Header
separated by " "
from PT_Head_clean;
quit;

/*Renaming Header to wanted values*/
data &Output_PT.(keep=&Keep_Header. rename=(&Rename_Head.));
set Output_PT_prev;
run;

proc sql;
drop table Output_PT_prev, PT_Head_p, PT_Head, PT_Head_Nm, PT_Head_Ord, PT_Head_tr, PT_Head_clean;
quit;

%Mend;

/*Importing Balances from TM1*/
%Import_Bal_Proj(9. Balances - In TM1, 3, Forecasted_Bal_Base);

/*Importing LookUp table for Balances from TM1*/
%Import_Bal_Proj(9. Balances -In TM1 MAP, 3, FAMILY_CODE_GL_LKP);

/*Importing Rates for Unfunded for LOB not available in the Engine*/
%Import_Bal_Proj(9. Balances - In OBS Rates, 3, Simple_Rates);




/*******************************ENGINE ANALYSIS**********************************/

/*Engine Table with LOB*/
proc sql;
create table Engine_Complete as
select Eng.*, ifrs.lob_dept1 as lob_dept1
from &ENGINE. Eng
LEFT JOIN &master_alll. ifrs 
ON Eng.CMCO_COD_CCONTR = ifrs.CMCO_COD_CCONTR
WHERE Eng.CMCO_IMP_PROV_FINAL <= 100000000000000;
quit;

/*Analysis for Funded*/
/*Calculating Rates for separating Secured/Unsecured*/
proc sql;
create table Engine_Sec_Unsec as
select distinct lob_dept1, Family_Code, CMCO_COD_CCONTR,
round(CMCO_IMP_EAD_ACTUAL,0.01) as CMCO_IMP_EAD_ACTUAL
from Engine_Complete
where UPCASE(Family_Code) LIKE "%SECURED%"
order by 1,2,3;
quit;

proc sql;
create table Engine_Sec_Unsec_Summary as
select lob_dept1, Family_Code, 
sum(CMCO_IMP_EAD_ACTUAL) as CMCO_IMP_EAD_ACTUAL
from Engine_Sec_Unsec
group by 1,2;
quit;

/*Preparing the Secured/Unsecured Analysis*/
data Sec_Unsec_Summary_Tranwrd;
set Engine_Sec_Unsec_Summary;
	if find(Family_Code, "Unsecured") > 0 then
		Family_Code_Tranwrd = Tranwrd(Family_Code, "Unsecured", "");
	else if find(Family_Code, "Secured") > 0 then
		Family_Code_Tranwrd = Tranwrd(Family_Code, "Secured", "");
run;

/*Calculating the Secure/Unsecured Rates*/
proc sql;
create table Engine_Sec_Unsec_Rates as
select lob_dept1, Family_Code_Tranwrd, Family_Code, CMCO_IMP_EAD_ACTUAL,
CMCO_IMP_EAD_ACTUAL/sum(CMCO_IMP_EAD_ACTUAL) as Rate
from Sec_Unsec_Summary_Tranwrd
group by 1,2;
quit;


/*Analysis for Unfunded*/
proc sql;
create table Engine_Balances_Unfun as
select distinct lob_dept1, Family_Code, 
CMCO_COD_CCONTR, CMCO_POR_CCF, OFF_BALANCE, LOCS, LOCS_ORIG
from Engine_Complete;
quit;

/*Summarizing by LOB and Family Code*/
proc sql;
create table Engine_Bal_Unfun_Sum as
select lob_dept1, Family_Code, 
sum(OFF_BALANCE) as OFF_BALANCE,
sum(LOCS_ORIG) as LOCS_ORIG,
sum(OFF_BALANCE+LOCS_ORIG) as OFF_BALANCE_LOCS_ORIG
from Engine_Balances_Unfun
group by 1,2;
quit;

/*Calculating Weighted CCF by Family Code*/
proc sql;
create table Engine_CCF_Weighted as
select Family_Code, 
sum(CMCO_POR_CCF*OFF_BALANCE)/sum(OFF_BALANCE) as CCF_WGHTD_OFF_BAL,
sum(LOCS)/sum(LOCS_ORIG) as CCF_WGHTD_LOCS
from Engine_Balances_Unfun
group by 1;
quit;


/*******************************SPLITTING FUNDED/UNFUNDED**********************************/

/*Dividing Obs in a different Data Set*/
data Forecast_Bal_Base_Obs Forecast_Bal_Base_Non_Obs;
set Forecasted_Bal_Base;
	if find(PRODUCT, "OBS") > 0 then 
		Output Forecast_Bal_Base_Obs; /*Unfunded*/
	else
		Output Forecast_Bal_Base_Non_Obs; /*Funded*/
run;


/*******************************FUNDED**********************************/

/*Duplicated values because of Secured/Unsecured division in the Family Code.
INNER JOIN to filter Out the totals and only keep whatever it is in the Lkp*/
proc sql;
create table Non_Obs_join_lkp as
select Base.*, lkp.lob_dept1_curr, lkp.Family_Code
from Forecast_Bal_Base_Non_Obs Base
INNER JOIN FAMILY_CODE_GL_LKP lkp
ON Base.PRODUCT = lkp.Balance_ID;
quit;

/*We need to distribute the Secured/Unsecured amounts based on 
the rates calculated from the Engine*/
proc sql;
create table Non_Obs_Sec_Unsec as
select LOB_CODE, LOB_NAME, PRODUCT_2, GL_TYPE, PRODUCT,
YEAR, Month, Batch_ID, Balance, lob_dept1_curr, Family_Code, 
count(*) as count
from Non_Obs_join_lkp
group by 1,2,3,4,5,6,7,8,9,10;
quit;

/*Distributing the Balance for Secured and Unsecured*/
proc sql;
create table Funded_Final_Rates (drop=Balance Count) as
select Base.*, 
case when Rate.lob_dept1 ne "" and Rate.Family_Code ne "" and Base.count = 2 then
		  Base.Balance*Rate.Rate else Base.Balance end as Balance_Funded
from Non_Obs_Sec_Unsec Base
LEFT JOIN Engine_Sec_Unsec_Rates Rate
ON Base.lob_dept1_curr = Rate.lob_dept1 AND
Base.Family_Code = Rate.Family_Code;
quit;


/*Validating Balances*/
/*Summary:
We are taking out: LOB_NAME = "TOTAL_BANK" and "CUSTOMER_SOLUTIONS", and
PRODUCT_2 = "LMH010 - TOTAL LOANS" and "LMH386 - ADVANCE CLEARING"
The rest is matching 100%*/
proc sql;
create table Validating_Funded as
select a.LOB_CODE, a.LOB_NAME, a.PRODUCT_2, a.GL_TYPE, a.PRODUCT,
a.YEAR, a.Month, a.Batch_ID, round(a.Balance,0.01) as Orig_Balance,
round(b.Balance,0.01) as Balance
from Forecast_Bal_Base_Non_Obs a
LEFT JOIN (select LOB_CODE, LOB_NAME, PRODUCT_2,
GL_TYPE, PRODUCT, YEAR, Month, Batch_ID, 
sum(Balance_Funded) as Balance
from Funded_Final_Rates 
group by 1,2,3,4,5,6,7,8) b
ON a.LOB_CODE = b.LOB_CODE AND a.LOB_NAME = b.LOB_NAME AND a.PRODUCT_2 = b.PRODUCT_2 AND 
a.GL_TYPE = b.GL_TYPE AND a.PRODUCT = b.PRODUCT AND a.YEAR = b.YEAR AND 
a.Month = b.Month AND a.Batch_ID = b.Batch_ID ;
quit;
/*End Validating Balances*/


/*******************************UNFUNDED**********************************/

/*Rolling Up Lkp Table for LOB*/
proc sql;
create table LOB_LKP_Obs as
select distinct lob_dept_detail, lob_dept1_curr
from FAMILY_CODE_GL_LKP;
quit;

/*Pulling Line of Business*/
proc sql;
create table Obs_join_lkp_lob as
select Base.*, lkp.lob_dept1_curr
from Forecast_Bal_Base_Obs Base
LEFT JOIN LOB_LKP_Obs lkp
ON upcase(Base.LOB_NAME) = upcase(lkp.lob_dept_detail);
quit;

/*Rolling Up*/
proc sql;
create table Obs_Roll_Up_lob as
select PRODUCT_2, GL_TYPE, YEAR, Month, Batch_ID, lob_dept1_curr,
sum(Balance) as Balance
from Obs_join_lkp_lob
group by 1,2,3,4,5,6;
quit;

/*Family Code Lkp Table for Unfunded*/
proc sql;
create table FAMILY_CODE_LKP_Obs as
select distinct lob_dept1_curr, Family_Code
from FAMILY_CODE_GL_LKP;
quit;

/*Pulling Family Code
INNER JOIN to filter Out the Totals*/
proc sql;
create table Obs_join_lkp_family as
select Base.*, lkp.Family_Code
from Obs_Roll_Up_lob Base
INNER JOIN FAMILY_CODE_LKP_Obs lkp
ON upcase(Base.lob_dept1_curr) = upcase(lkp.lob_dept1_curr);
quit;

/*Calculating the Cecl Engine Rates ONLY for 
the LOB and Family Codes present in the LookUp Table*/
proc sql;
create table Eng_Bal_Unfun_Sum_Inner as
select Eng.*
from Engine_Bal_Unfun_Sum Eng
INNER JOIN (select distinct lob_dept1_curr, Family_Code
from Obs_join_lkp_family) Obs
ON Eng.lob_dept1 = Obs.lob_dept1_curr AND
Eng.Family_Code = Obs.Family_Code;
quit;

/*Calculating the Rates for Unfunded based on the Current Data from the Engine*/
proc sql;
create table Unfunded_Rates as
select lob_dept1, Family_Code, 
OFF_BALANCE/sum(OFF_BALANCE_LOCS_ORIG) as Off_Balance_Rate,
LOCS_ORIG/sum(OFF_BALANCE_LOCS_ORIG) as LOCS_Rate
from Eng_Bal_Unfun_Sum_Inner
group by 1;
quit;

/*Adding Rates for the LOB Simple*/
data Total_Rates;
format lob_dept1 $60.;
format Family_Code $80.;
set Unfunded_Rates Simple_Rates;
run;

/*We distribute the duplicated balance based on rates.
INNER JOIN to only keep the ones with the rate calculated*/
proc sql;
create table Unfunded_Final_Rates(drop=Balance) as
select Base.*,
Base.Balance*Rate.Off_Balance_Rate as Balance_OffBal,
Base.Balance*Rate.LOCS_Rate as Balance_LOCS
from Obs_join_lkp_family Base
INNER JOIN Total_Rates Rate
ON base.lob_dept1_curr = Rate.lob_dept1 AND
base.Family_Code = Rate.Family_Code
order by base.lob_dept1_curr, base.Family_Code;
quit;


/*Validating Distribution Logic*/
/*Summary:
LOB: CUSTOMER_SOLUTIONS and TOTAL_BANK weren't in the LookUp so
they appear here as Blanks (it can be validared with the table previous to
the lob roll up).
THE REST MATCH 100%
*/
proc sql;
create table Validating_Unfunded as
select a.PRODUCT_2, a.GL_TYPE, a.YEAR, a.Month, a.Batch_ID, 
a.lob_dept1_curr, round(a.Balance,0.01) as Orig_Balance,
round(b.New_Balance,0.01) as New_Balance
from Obs_Roll_Up_lob a
LEFT JOIN 
(select PRODUCT_2, GL_TYPE, YEAR, Month, Batch_ID, lob_dept1_curr, 
sum(Balance_OffBal+ Balance_LOCS) as New_Balance 
from Unfunded_Final_Rates 
group by 1,2,3,4,5,6) b
ON a.PRODUCT_2 = b.PRODUCT_2 AND a.GL_TYPE = b.GL_TYPE AND 
a.YEAR = b.YEAR AND a.Month = b.Month AND a.Batch_ID = b.Batch_ID 
AND a.lob_dept1_curr=b.lob_dept1_curr
;
quit;
/*End Validating Distribution Logic*/


/***************************MERGING FUNDED/UNFUNDED*****************************/

/*Grouping and Merging Funded and Unfunded*/
proc sql;
create table Funded_Final_Group as
select Batch_ID, lob_dept1_curr, Family_Code,
sum(Balance_Funded) as Balance_Funded
from Funded_Final_Rates
group by 1,2,3;
quit;

proc sql;
create table Unfunded_Final_Group as
select Batch_ID, lob_dept1_curr, Family_Code,
sum(Balance_OffBal) as Balance_OffBal,
sum(Balance_LOCS) as Balance_LOCS
from Unfunded_Final_Rates
group by 1,2,3;
quit;

/*Joining Funded and Unfunded*/
proc sql;
create table Full_Union_Fund_Unfund as
select 
Fun.Batch_ID as Batch_ID_Fun,
Fun.lob_dept1_curr as lob_dept1_curr_Fun,
Fun.Family_Code as Family_Code_Fun,
Fun.Balance_Funded,
Unfun.Batch_ID as Batch_ID_Unf,
Unfun.lob_dept1_curr as lob_dept1_curr_Unf,
Unfun.Family_Code as Family_Code_Unf,
Unfun.Balance_OffBal, Unfun.Balance_LOCS
from Funded_Final_Group Fun
FULL JOIN Unfunded_Final_Group Unfun
ON Fun.Batch_ID = Unfun.Batch_ID AND
Fun.lob_dept1_curr = Unfun.lob_dept1_curr AND
Fun.Family_Code = Unfun.Family_Code;
quit;

/*Generating Outputs with possible errors for inspection*/
data Union_Fund_Unfund (drop=Batch_ID_Unf lob_dept1_curr_Unf Family_Code_Unf
rename=(Batch_ID_Fun = Batch_ID lob_dept1_curr_Fun = lob_dept1_curr
Family_Code_Fun = Family_Code))
Missing_Unfunded Missing_Funded;
set Full_Union_Fund_Unfund;
	/*Possible Error Tables*/
	if Batch_ID_Unf = . then
		output Missing_Unfunded;
	else if Batch_ID_Fun = . then
		output Missing_Funded;

	/*We can't have Unfunded informed and Funded not informed at the same time*/
	if Batch_ID_Fun ne . then
		output Union_Fund_Unfund;
run;

/*Calculating EAD based on funded, unfunded and CCF*/
proc sql;
create table Union_Fund_Unfund_ccf as
select base.*, 
ccf.CCF_WGHTD_OFF_BAL, ccf.CCF_WGHTD_LOCS,
coalesce(base.Balance_Funded,0) + coalesce(base.Balance_OffBal*ccf.CCF_WGHTD_OFF_BAL,0) + 
coalesce(base.Balance_LOCS*ccf.CCF_WGHTD_LOCS,0) as Calculated_EAD 
from Union_Fund_Unfund base
LEFT JOIN Engine_CCF_Weighted ccf
ON base.Family_Code = ccf.Family_Code;
quit;

/*Calculating the Projected Dates based on the current Engine Day ID*/
data Engine_DAY_ID_PY
(keep=CMCO_FEC_DATOS CMCO_COD_CCONTR lob_dept1 Family_Code CMCO_IMP_EAD_ACTUAL DAY_ID_PY year);
set Engine_Complete;
	DAY_ID_PY = CMCO_FEC_DATOS + 10000*year;
	where year<=4; /*Up to 4 years of projection*/
run;

/*Saving all the yearly projected Batch IDs*/
proc sql noprint;
select distinct DAY_ID_PY into: Yearly_Batch
separated by ","
from Engine_DAY_ID_PY;
quit;

/*Filtering only the projected yearly Batch IDs*/
data Union_Fund_Unfund_Yearly;
set Union_Fund_Unfund_ccf;
	where Batch_ID IN (&Yearly_Batch.);
run;

/*Keeping the EAD Growth to export it to the Parametric Table*/
data Balances_Final_EAD_p(keep=Batch_ID lob_dept1_curr Family_Code Calculated_EAD
rename=(Calculated_EAD = EAD lob_dept1_curr = lob_dept1));
set Union_Fund_Unfund_Yearly;
run;

/*Ordering for the Transpose
Order by lob_dept1 Family_Code for the by statement in the transpose
Order by Batch_ID to have te correct order of the transposed Batch IDs*/
proc sort data=Balances_Final_EAD_p out=Balances_Final_EAD_sort;
by lob_dept1 Family_Code Batch_ID;
run;

/*Transpose to match Parametric Table format*/
proc transpose
data=Balances_Final_EAD_sort
out=Balances_Final_EAD_transp(drop=_NAME_)
prefix=EAD_;
by lob_dept1 Family_Code;
id Batch_ID;
run;

/*Removing duplicate values*/
proc sql;
create table Engine_year0_Distinct as
select distinct CMCO_COD_CCONTR, lob_dept1, Family_Code,
CMCO_IMP_EAD_ACTUAL
from Engine_DAY_ID_PY;
quit;

/*Aggregating Year 0 Data*/
proc sql;
create table Engine_year0_sum as
select lob_dept1, Family_Code,
sum(CMCO_IMP_EAD_ACTUAL) as EAD
from Engine_year0_Distinct
group by 1,2;
quit;

/*Joining Stock Year 0 EAD and projected EADs*/
proc sql;
create table Balances_Final_EAD_join as
select yr0.lob_dept1 as lob_dept1_yr0, yr0.Family_Code as Family_Code_yr0, 
yr0.EAD as EAD_&DAY., gt0.*
from Engine_year0_sum yr0
FULL JOIN Balances_Final_EAD_transp gt0
ON yr0.lob_dept1 = gt0.lob_dept1 AND yr0.Family_Code = gt0.Family_Code;
quit;

/*Keeping all informed LOB and Family Codes*/
proc sql;
create table Balances_EAD_Coalesc as
select Bal.*, 
coalesce(lob_dept1_yr0, lob_dept1) as lob_dept1_Final,
coalesce(Family_Code_yr0, Family_Code) as Family_Code_Final
from Balances_Final_EAD_join Bal;
quit;

/*Saving column names*/
proc contents data=Balances_EAD_Coalesc out=Balances_EAD_columns noprint;
run;

/*Ordering numeric fields*/
proc sql;
create table Balances_EAD_colum_num as
select NAME
from Balances_EAD_columns
where TYPE = 1
order by NAME;
quit;

/*Saving numeric column names in the correct order*/
proc sql;
select NAME into: Num_Fields_EAD
separated by " "
from Balances_EAD_colum_num;
quit;

/*Output Parametric Table for Final EAD*/
data Output.Balances_Final_EAD
(keep=lob_dept1_Final Family_Code_Final &Num_Fields_EAD.
rename=(lob_dept1_Final = lob_dept1 Family_Code_Final = Family_Code));
format lob_dept1_Final Family_Code_Final &Num_Fields_EAD.;
set Balances_EAD_Coalesc;
run;