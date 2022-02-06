
/***************IMPORT OF PLEDGE LOANS POPULATION FROM TREASURY***************/
proc import datafile="/SAS_RiskModelDev/SAS_FSB/Pledged loans/Inputs/Treasury Population/pledge_loans_may2019.xlsx"
	dbms=xlsx replace
	out=PLEDGE_LOANS_Treasury_prev;
	sheet="Pledge";
	getnames=yes;
run;

/*We take out of the analysis the repeated SBA loans in Commercial, CRE and Construction*/
data PLEDGE_LOANS_Treasury;
set PLEDGE_LOANS_Treasury_prev;
	WHERE NOT ((CATEGORY = "710" AND SYS = "SBA") OR 
			   (CATEGORY = "780" AND SYS = "SBA") OR
			   (CATEGORY = "790" AND SYS = "SBA"));
run;
/***************IMPORT OF PLEDGE LOANS POPULATION FROM TREASURY***************/


/********************************COMPARING*********************************/
proc sql;
create table Comparison_Population as
select SAS.ACCTNBR as ACCTNBR_SAS,
		Treasry.ACCTNBR as ACCTNBR_Treasury
from ELIGIBLELOANS_CATEG SAS FULL JOIN PLEDGE_LOANS_Treasury Treasry
ON SAS.ACCTNBR = Treasry.ACCTNBR;
quit;

/*MIS has and Treasury doesnt*/
data Compar_acct_SAS(keep=ACCTNBR_SAS);
set Comparison_Population;
where ACCTNBR_SAS NE ACCTNBR_Treasury AND ACCTNBR_SAS NE "";
run;

/*Treasury has and MIS doesnt*/
data Compar_acct_Treasury(keep=ACCTNBR_Treasury);
set Comparison_Population;
where ACCTNBR_SAS NE ACCTNBR_Treasury AND ACCTNBR_Treasury NE "";
run;

/*Getting the details*/
proc sql;
create table Comp_acct_SAS_detail as
select *
from ELIGIBLELOANS_CATEG
where ACCTNBR IN (select ACCTNBR_SAS from Compar_acct_SAS);
quit;

/*Exporting*/
%exportXLSX(Comp_acct_SAS_detail,
/SAS_RiskModelDev/SAS_FSB/Pledged loans/Comparison_Population.xlsx,
SAS_MIS_Only);

/*Getting the details*/
proc sql;
create table Comp_acct_Treasury_detail as
select *
from PLEDGE_LOANS_Treasury
where ACCTNBR IN (select ACCTNBR_Treasury from Compar_acct_Treasury);
quit;

/*Exporting*/
%exportXLSX(Comp_acct_Treasury_detail,
/SAS_RiskModelDev/SAS_FSB/Pledged loans/Comparison_Population.xlsx,
Treasury_Only);
/********************************COMPARING*********************************/