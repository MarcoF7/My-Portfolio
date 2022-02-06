/*Exclusions to the Universe*/
/*First Exclusion: Exclude CLS from Secured Consumer*/
data PLEDGE_LOANS_Exclu_Sec;
set PLEDGE_LOANS_RECAT;
	where not(SYS = 'CLS' AND CATEGORY = '741');
run;

/*Second Exclusion: Exclusion of Mexican Cities*/
PROC SQL;
CREATE TABLE PLEDGE_LOANS AS 
select pledge.*
from PLEDGE_LOANS_Exclu_Sec pledge
LEFT JOIN (select ACCT_REF_NUM, CITY from WHS.W_FDBR_BW where BATCH_ID = &batch_WHS) FDBR
on pledge.ACCTNBR = FDBR.ACCT_REF_NUM
WHERE NOT (FDBR.CITY LIKE '%MEX%' AND FDBR.CITY <> 'MEXIA' AND FDBR.CITY <> 'MEXICO BEACH' AND FDBR.CITY <> 'NEW MEXICO');
QUIT;


/************Exclusions Log************/

data Exclusion_Secured_Not_CLS
(keep=ACCTNBR Reason);
set PLEDGE_LOANS_RECAT;
	format Reason $100.;
	Reason = "Secured Consumer and Subsystem CLS";
	where (SYS = 'CLS' AND CATEGORY = '741');
run;

/*Exporting*/
%exportXLSX(Exclusion_Secured_Not_CLS,
/SAS_RiskModelDev/SAS_FSB/Pledged loans/Exclusions_Log.xlsx,
Secured_CLS);

PROC SQL;
CREATE TABLE Exclusion_Mex_Cities AS 
select pledge.ACCTNBR, "Mexican Cities" as Reason
from PLEDGE_LOANS_Exclu_Sec pledge
LEFT JOIN (select ACCT_REF_NUM, CITY from WHS.W_FDBR_BW where BATCH_ID = &batch_WHS) FDBR
on pledge.ACCTNBR = FDBR.ACCT_REF_NUM
WHERE (FDBR.CITY LIKE '%MEX%' AND FDBR.CITY <> 'MEXIA' AND FDBR.CITY <> 'MEXICO BEACH' AND FDBR.CITY <> 'NEW MEXICO');
QUIT;

/*Exporting*/
%exportXLSX(Exclusion_Mex_Cities,
/SAS_RiskModelDev/SAS_FSB/Pledged loans/Exclusions_Log.xlsx,
Mexican Cities);