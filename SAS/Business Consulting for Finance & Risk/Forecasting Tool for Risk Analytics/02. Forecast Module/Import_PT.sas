
/******IMPORTING ALL PARAMETRIC TABLES - FORECASTING TOOL*******/


/*Macro to Import a Parametric Table based on the Excel sheet name, 
the first row of data and the original PT table*/
%Macro Importing_PT(Sheet, First_Row, Orig_Data, Output_PT);

/*Importing Parametric Table*/
proc import datafile= "&Forec_Tool.&Forecast_PT."
	dbms=xlsx replace
	out=PT_prev;
	sheet="&Sheet.";
	datarow=&First_Row.;
	getnames=no;
run;

/*Dropping empty column A*/
data PT_prev_fields(drop=A);
set PT_prev;
run;

/*Saving new by default field names*/
proc contents data=PT_prev_fields out=PT_prev_Header noprint;
run;
proc sort data=PT_prev_Header out=PT_prev_Header_Ord(keep=NAME);
by varnum;
run;

/*Saving original field names*/
proc contents data=&Orig_Data. out=Orig_PT_Head noprint;
run;
proc sort data=Orig_PT_Head out=Orig_PT_Head_Ord(keep=NAME rename=(NAME=NAME_ORIG));
by varnum;
run;

/*Putting old and new field names in one data set AND 
only keeping the fields from the original parametric table*/
data PT_Field_Names;
set PT_prev_Header_Ord;
set Orig_PT_Head_Ord;
run;

/*Preparing Final Keeping Fields*/
proc sql noprint;
select NAME into: PT_Orig_Fields
separated by " "
from PT_Field_Names;
quit;

/*Preparing Rename statement*/
proc sql noprint;
select CATS(NAME,"=",NAME_ORIG) into: PT_ReNames
separated by " "
from PT_Field_Names;
quit;

/*Preparing Missing Values Checking*/
proc sql noprint;
select cats("missing(",NAME,")") into: PT_Missing
separated by " AND "
from PT_Field_Names;
quit;

/*Renaming fields to the original SAS names*/
data &Output_PT.(keep=&PT_Orig_Fields. rename=(&PT_ReNames.));
set PT_prev_fields;
where not (&PT_Missing.);
run;


proc sql;
drop table PT_prev, PT_prev_fields, PT_prev_Header, PT_prev_Header_Ord, 
			Orig_PT_Head, Orig_PT_Head_Ord, PT_Field_Names;
quit;

%Mend;



/***1. Importing Explicit Transfer Rates***/
%Importing_PT(1. Explicit Transfer Rates, 3, output.Explicit_TR, Explicit_TR_PT);


/***2. Importing EAD Evolution***/
%Importing_PT(2. EAD Evolution, 3, output.EAD_Evolution, EAD_Evolution_PT);


/***3.1 Importing Lifetime EL - Non Default***/
%Importing_PT(3.1 Lifetime EL - Non Default, 3, output.Expected_Loss_s1, EL_Non_Default_PT);

/*When curing (S3 to S1) there are some PD Drivers that were not defined in the 
EL Stage1 table so for those cases we take the average EL disregarding the PD Driver*/
proc sql;
create table Expected_Loss_s1_No_Driver as
select lob_dept1, Family_Code, PLZ_RESID, year, 
sum(Expected_Loss*sum_EAD)/sum(sum_EAD) as Expected_Loss
from EL_Non_Default_PT
group by 1,2,3,4
order by 1,2,3,4;		
quit;

/*Same idea when curing but applied for LOB*/
proc sql;
create table Expected_Loss_s1_No_LOB as
select Family_Code, PLZ_RESID, year, 
sum(Expected_Loss*sum_EAD)/sum(sum_EAD) as Expected_Loss
from EL_Non_Default_PT
group by 1,2,3
order by 1,2,3;		
quit;


/***3.2 Importing Lifetime EL - Default***/
%Importing_PT(3.2 Lifetime EL - Default, 3, output.Expected_Loss_s3, EL_Default_PT);


/***4. Importing Change in Risk Profile***/
%Importing_PT(4. Change in Risk Profile, 6, output.migration_perc_all, Risk_Profile_PT);

/*Importing FLAG Change in Risk Profile*/
proc import datafile= "&Forec_Tool.&Forecast_PT."
	dbms=xlsx replace
	out=Flag_Risk_profile;
	range="4. Change in Risk Profile$B2:B3";
	getnames=yes;
run;

/*Storing the activation flag in a macro variable for later use*/
data _null_;
set Flag_Risk_profile;
	call symput('Flag_Risk_profile',SUBSTR(UPCASE('Activation FLAG (Y/N)'n),1,1));
run;

%put Flag_Risk_profile = &Flag_Risk_profile.;


/***5. Importing Cure Rates and Implicit Tran***/
%Importing_PT(5. Cure Rates and Implicit Tran, 3, output.Cure_Rates, Cure_Rate_PT);


/***6. Importing Charge Offs***/
%Importing_PT(6. Charge Offs, 3, output.Charge_Off, Charge_Off_PT);


/***7. Importing Expected Life for Growth***/
%Importing_PT(7. Expected Life for Growth, 3, output.Expected_Life_Growth, Exp_Life_Growth_PT);


/***8. Importing Risk Profile for Growth***/
%Importing_PT(8. Risk Profile for Growth, 3, output.Risk_Profile_Growth, Rsk_Prof_Growth_PT);


/***9.1 Importing Forecasted Balances***/
%Importing_PT(9. Balances - Out Final EAD, 3, output.Balances_Final_EAD, Balance_Projec_PT);