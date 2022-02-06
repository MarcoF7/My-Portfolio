
/*Engine Table with LOB*/
proc sql;
create table Engine_Complete as
select Eng.*, ifrs.lob_dept1 as lob_dept1
from &ENGINE. Eng
LEFT JOIN &master_alll. ifrs 
ON Eng.CMCO_COD_CCONTR = ifrs.CMCO_COD_CCONTR
WHERE Eng.CMCO_IMP_PROV_FINAL <= 100000000000000;
quit;

/*Separating data into Defaults and Non Defaults to treat them separately*/
data Engine_Complete_p_S1 Engine_Complete_p_S3(drop=year);
set Engine_Complete;
	if DEFAULT_FLAG_FINAL = "0" then
		output Engine_Complete_p_S1;
	else if DEFAULT_FLAG_FINAL = "1" then
		output Engine_Complete_p_S3;
run;

/*Proyecting Default Contracts based on Residual Term*/
data Engine_Complete_p_S3_year;
set Engine_Complete_p_S3;
	do year=1 to CEIL(CMCO_PLZ_RESID);
		output;
	end;
run;

/*Unifying Defaults and Non Defaults*/
data Engine_Stg3_yearly;
set Engine_Complete_p_S1 Engine_Complete_p_S3_year;
run;

/*Creating the Projection Day_ID and the Projection YTM (years to maturity)*/
data Engine_Day_py;
set Engine_Stg3_yearly;
	DAY_ID_PY = CMCO_FEC_DATOS + 10000*year;
	YTM_PY = ceil(CMCO_PLZ_RESID) - year;
run;

/*Base table for Stock Portfolio Projection*/
proc sql;
create table Base_Stock_Portf as 
select CMCO_FEC_DATOS as DAY_ID,
	   lob_dept1,
	   Family_Code,
	   DEFAULT_FLAG_FINAL as Stage_Base,
	   Driver_PD,	
	   Driver_LGD, 
	   ceil(CMCO_PLZ_RESID) as PLZ_RESID,
	   Year,
	   DAY_ID_PY,
	   YTM_PY,
	   round(sum(CMCO_IMP_EAD_ACTUAL),0.01) as EAD_actual, /*Rounding to 2 decimals*/
	   round(sum(CMCO_IMP_PROV_FINAL),0.01) as Provision_Actual /*Rounding to 2 decimals*/
from Engine_Day_py
where year<=4 /*Up to 4 years of projection*/
AND year<ceil(CMCO_PLZ_RESID) /*We can't project in the last year*/
/*AND DEFAULT_FLAG_FINAL ne "1"*/ /*Performing accounts*/
/*AND upcase(Family_Code) = "COMMERCIAL - CRE"*/ /*Specific Portfolio Filter*/
Group by 1,2,3,4,5,6,7,8,9,10
order by 1,2,3,4,5,6,7,8,9,10
;
quit;

/*Macro to calculate the Provision*/
%Macro Provision(Base_Table, outTable);

/*Formatting the Stage*/
data Stock_Stage_Format(drop=Stage_Base rename=(Stage_Base_new=Stage_Base));
format DAY_ID;
format lob_dept1;
format Family_Code;
format Stage_Base_new;
set &Base_Table.;
	format Stage_Base_new $2.;
	if Stage_Base = "0" then
		Stage_Base_new = "S1";
	else if Stage_Base = "1" then
		Stage_Base_new = "S3";
run;

/*Cheking Risk Profile Activation Flag*/
%if "&Flag_Risk_profile." = "N" %then
%do;
	/*If flag is set to No, then we keep the future PD Driver remains the same as the PD Driver*/
	data Vertical_Stock_Rsk_Prfl;
	set Stock_Stage_Format;
		format Pctg_Future_PD_Driver percent10.2;
		Future_PD_Driver = Driver_PD;
		Pctg_Future_PD_Driver = 1;
	run;
%end;
%else
%do;
	/*Joining to Risk Profile*/
	proc sql;
		create table Vertical_Stock_Rsk_Prfl as
		select Stock.*, Prof.Future_PD_Driver, Prof.Percentage as Pctg_Future_PD_Driver
		from Stock_Stage_Format Stock
		LEFT JOIN Risk_Profile_PT Prof
		ON Stock.Family_Code = Prof.Family_Code AND
		Stock.Driver_PD = Prof.Current_PD_Driver
	;quit;
%end;

/*Joining to Explicit TR
to pull the Transition Rate (Stage 1 to Stage 3)*/
proc sql;
	create table Vertical_Stock_TR as
	select Stock.*, 
	case when Stock.Stage_Base = "S1" then TR.Transition_Rate end as Transition_Rate
	from Vertical_Stock_Rsk_Prfl Stock
	LEFT JOIN Explicit_TR_PT TR
	ON Stock.Family_Code = TR.Family_Code AND Stock.lob_dept1 = TR.lob_dept1 
	AND Stock.Driver_PD = TR.Driver_PD AND Stock.Year = TR.Year
	order by Stock.lob_dept1, Stock.Family_Code, Stock.PLZ_RESID, Stock.Year, 
	Stock.Driver_LGD, Stock.Driver_PD, Stock.Future_PD_Driver
;quit;

/*Adding Stage Information*/
data Vertical_Stock_TR_Stages;
set Vertical_Stock_TR;
format Calc_Stage $2.;
	do i=1 to 2;
		if i=1 then
			Calc_Stage = "S3"; /*Stage 3*/
		else if i=2 then
			Calc_Stage = "S1"; /*Stage 1*/
		output;
	end;
run;

/*Defining the transition rate when remaining in Stage 1*/
data Vertical_Stock_TR_Rate(drop=i);
set Vertical_Stock_TR_Stages;
	if Stage_Base="S1" AND Calc_Stage="S1" then
		Transition_Rate = 1- Transition_Rate;
run;

/*Calculating EAD Post Transitions*/
data Vertical_Stock_EAD_Post;
set Vertical_Stock_TR_Rate;
	if Stage_Base = "S1" then
		EAD_Post_Tran = EAD_actual*Pctg_Future_PD_Driver*Transition_Rate;
	else if Stage_Base = "S3" AND Calc_Stage = "S3" then
		EAD_Post_Tran = EAD_actual;
	else if Stage_Base = "S3" AND Calc_Stage = "S1" then
		EAD_Post_Tran = 0;
run;

/*Joining to Cure Rates*/

/*Keeping Stage 3 records to perform Cure Rate calculations*/
data Stg3_Cure_Rate;
set Vertical_Stock_EAD_Post;
where Calc_Stage = "S3";
run;

/*Calculating Cured Amount for Stage 3*/
proc sql;
create table Stg3_Cured_Amnt as
select Stock.*, Cure.Cure_Rate, Stock.EAD_Post_Tran*Cure.Cure_Rate as Cured_Amount
from Stg3_Cure_Rate Stock
LEFT JOIN Cure_Rate_PT Cure
ON Stock.Family_Code = Cure.Family_Code;
quit;

/*Calculating the EAD Post Cure*/
proc sql;
create table Vertical_Cure_Rate as
select Stock.*, Cure.Cure_Rate,
case when Stock.Calc_Stage = "S1" then Stock.EAD_Post_Tran + Cure.Cured_Amount 
	 when Stock.Calc_Stage = "S3" then Stock.EAD_Post_Tran - Cure.Cured_Amount 
	 end as EAD_Post_Cure
from Vertical_Stock_EAD_Post Stock
LEFT JOIN Stg3_Cured_Amnt Cure
ON Stock.lob_dept1 = Cure.lob_dept1 AND Stock.Family_Code = Cure.Family_Code AND 
Stock.Stage_Base = Cure.Stage_Base AND Stock.PLZ_RESID = Cure.PLZ_RESID AND 
Stock.Year = Cure.Year AND Stock.Driver_LGD = Cure.Driver_LGD AND 
Stock.Driver_PD = Cure.Driver_PD AND Stock.Future_PD_Driver = Cure.Future_PD_Driver
;
quit;

/*Joining to EAD Decay (Cancelations and Prepayments)*/
proc sql;
	create table Vertical_EAD_Decay as
	select Stock.*, EAD.EAD_Decay AS Decay_Rate
	from Vertical_Cure_Rate Stock
	LEFT JOIN EAD_Evolution_PT EAD 
	ON Stock.Family_Code = EAD.Family_Code AND 
	Stock.Year = EAD.Year
;quit;

/*Joining to ChargeOffs*/
proc sql;
	create table Vertical_Chrg_Off as
	select Stock.*, Off.Charge_Off_Rate
	from Vertical_EAD_Decay Stock
	LEFT JOIN Charge_Off_PT Off
	ON Stock.Family_Code = Off.Family_Code AND 
	Stock.Year = Off.Year_of_Projection
	order by Stock.lob_dept1, Stock.Family_Code, Stock.Stage_Base, Stock.PLZ_RESID, 
	Stock.Year, Stock.Driver_LGD, Stock.Driver_PD, Stock.Future_PD_Driver, Stock.Calc_Stage
;quit;

/*Calculating the EAD Final (After Cancelations&Prepayments and ChargeOffs*/
data Vertical_EAD_Final; 
set Vertical_Chrg_Off;
	Calc_EAD_Final = EAD_Post_Cure*Decay_Rate*(1-Charge_Off_Rate);
run;

/**Joining to Lifetime Expected Loss**/
/*Expected Loss for Stage 1*/
proc sql;
	create table Vertical_EL_S1 as
	select Stock.*, coalesce(EL.Expected_Loss, ELND.Expected_Loss, ELNL.Expected_Loss) as EL_S1
	from Vertical_EAD_Final Stock
	LEFT JOIN EL_Non_Default_PT EL
	ON 
	Stock.lob_dept1			= EL.lob_dept1 		AND 
	Stock.Family_Code		= EL.Family_Code 	AND 
	Stock.Future_PD_Driver 	= EL.Driver_PD 		AND 
	Stock.Year				= EL.year 			AND 
	Stock.PLZ_RESID		    = EL.PLZ_RESID 		
	LEFT JOIN Expected_Loss_s1_No_Driver ELND
	ON
	Stock.lob_dept1			= ELND.lob_dept1 		AND 
	Stock.Family_Code		= ELND.Family_Code 		AND 
	Stock.Year				= ELND.year 			AND 
	Stock.PLZ_RESID		    = ELND.PLZ_RESID 		
	LEFT JOIN Expected_Loss_s1_No_LOB ELNL
	ON
	Stock.Family_Code		= ELNL.Family_Code 		AND 
	Stock.Year				= ELNL.year 			AND 
	Stock.PLZ_RESID		    = ELNL.PLZ_RESID 		
;quit;

/*Expected Loss for Stage 3*/
proc sql;
	create table Vertical_EL_S3 as
	select Stock.*, EL.Expected_Loss as EL_S3
	from Vertical_EL_S1 Stock
	LEFT JOIN EL_Default_PT EL
	ON Stock.Family_Code = EL.Family_Code AND
	   Stock.Driver_LGD = EL.Driver_LGD AND
	   Stock.year = EL.year;
quit;

/*Calculating the Provision*/
proc sql;
create table Provision_gt_yr_0 (drop=EL_S1 EL_S3) as
select *, case when Calc_Stage = "S1" then EL_S1 
			when Calc_Stage = "S3" then EL_S3 end as Calc_EL_rate,
			case when Calc_Stage = "S1" then Calc_EAD_Final*EL_S1 
			when Calc_Stage = "S3" then Calc_EAD_Final*EL_S3 end as Calc_Provision
from Vertical_EL_S3
order by lob_dept1, Family_Code, Stage_Base, PLZ_RESID, 
Year, Driver_LGD, Driver_PD, Future_PD_Driver, Calc_Stage;
quit;

/*Saving field's names of the output table in the correct order*/
proc contents data=Provision_gt_yr_0 out=prov_columns noprint;
run;
proc sort data=prov_columns out=prov_columns_ord(keep=NAME);
by varnum;
run;
proc sql noprint;
select NAME into: Columns_Nm
separated by " "
from prov_columns_ord;
quit;

/*Calculating year 0 information*/
proc sql;
create table Provision_eq_yr_0 as
select distinct DAY_ID, lob_dept1, Family_Code, Stage_Base, 
Driver_PD, Driver_LGD, PLZ_RESID, 0 as Year, DAY_ID as DAY_ID_PY,
PLZ_RESID as YTM_PY, Stage_Base as Calc_Stage,
EAD_actual, Provision_Actual, EAD_actual as Calc_EAD_Final, 
Provision_Actual as Calc_Provision
from Provision_gt_yr_0;
quit;

/*Adding Year 0 to the Provision output table*/
data &outTable.;
format &Columns_Nm.; /*Keeping original order of the fields*/
set Provision_eq_yr_0 Provision_gt_yr_0;
run;

/*Ordering*/
proc sort data=&outTable.;
by lob_dept1 Family_Code Stage_Base PLZ_RESID 
Year Driver_LGD Driver_PD Future_PD_Driver Calc_Stage;
run;

%Mend Provision;


/*Stock Portfolio Provision Projection*/
%Provision(Base_Stock_Portf, output.Stock_Portf_Provision);