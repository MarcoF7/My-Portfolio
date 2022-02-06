

/***************************Importing INPUTS***************************/
/*Importing ELIGIBLELOANS*/
proc import datafile="/SAS_RiskModelDev/SAS_FSB/Pledged loans/Inputs/EligibleLoans0519.xlsx"
	dbms=xlsx replace
	out=ELIGIBLELOANS_p;
	sheet="EligibleLoans";
	getnames=yes;
run;

data PLEDGED.ELIGIBLELOANS
(rename=(
'ORIG BAL'n = ORIG_BAL
'CUR BAL'n = CUR_BAL));
set ELIGIBLELOANS_p;
/*In case the & wasn't imported well*/
IF MRGNCDE = "C&amp;A" THEN
	MRGNCDE = "C&A";
run;

/*Importing FHLB Exclusions*/
proc import datafile=
"/SAS_RiskModelDev/SAS_FSB/Pledged loans/Inputs/FHLB Loans 04-30-2019.xlsx"
	dbms=xlsx replace
	out=FHLBA_CRE_MF_LOANS_p;
	sheet="LOANS_ENC_UNC_0419";
	getnames=yes;
run;

data PLEDGED.FHLBA_CRE_MF_LOANS
(keep='Loan Number'n AFS_Short_Number
rename=('Loan Number'n = M_ACCT_REF_NUM));
set FHLBA_CRE_MF_LOANS_p;
format AFS_Short_Number $10.;
AFS_Short_Number = substr('Loan Number'n,1,10);
run;

/*Importing STATIC Loans Exclusions*/
proc import datafile=
"/SAS_RiskModelDev/SAS_FSB/Pledged loans/Inputs/STATIC - FHLBA COMMERCIAL POOL.xlsx"
	dbms=xlsx replace
	out=FHLBA_STAT_LIST;
	sheet="Sheet1";
	getnames=yes;
run;

data PLEDGED.FHLBA_STATIC
(keep='Loan Number'n 
rename=('Loan Number'n = ACCTNBR));
set FHLBA_STAT_LIST;
run;

/*Importing WATCHLIST*/
proc import datafile=
"/SAS_RiskModelDev/SAS_FSB/Pledged loans/Inputs/=BBVA Compass Criticized and Classified Report 0419.xlsx"
	dbms=xlsx replace
	out=PLEDGED.WATCHLIST;
	sheet="April 2019 BBVA CCR";
	getnames=yes;
run;

/*Importing ABBREVIATION_STATE*/
proc import datafile="/SAS_RiskModelDev/SAS_FSB/Pledged loans/Inputs/Abbreviation_State.xlsx"
	dbms=xlsx replace
	out=PLEDGED.ABBREVIATION_STATE;
	sheet="Sheet1";
	getnames=yes;
run;

/*Importing INELIGIBLE_COST_CENTERS*/
proc import datafile="/SAS_RiskModelDev/SAS_FSB/Pledged loans/Inputs/INELIGIBLE_COST_CENTERS.xlsx"
	dbms=xlsx replace
	out=PLEDGED.INELIGIBLE_COST_CENTERS;
	sheet="Sheet1";
	getnames=yes;
run;

/***************************Importing INPUTS***************************/





*---------------------------------------------------------------------------------------;
*							Pledged Loans - Population;
*							Author: Management Solutions;
*---------------------------------------------------------------------------------------;

/* This process defines the requested population. It includes several filters that have been defined 
by Treasury and it will be joined (inner join) with the different tables generated to keep the accounts
that need to be reported. */

/* A - 0 Add CompCall to EligibleLoans */

PROC SQL;
	CREATE TABLE PRE_ELIGIBLE_LOANS AS
	SELECT EL.PROCDT, EL.SYS,
		BW.COMP_CALL, 
		EL.ACCTNBR, EL.CUSTNAME, EL.ORIG_BAL, EL.CUR_BAL, EL.CPNRTE, EL.RISKCODE, 
		EL.MATURDTE, EL.REMAINTERM, EL.MRGNCDE, EL.MRGNPCT, EL.PSTDUEDAYS, EL.STATECD,
		BW.CIS_ACCT_ID
	FROM PLEDGED.ELIGIBLELOANS EL /* Table provided by Rick */
	INNER JOIN WHS.W_FDBR_BW (WHERE = (BATCH_ID = &batch_WHS.)) BW 
	ON EL.ACCTNBR = BW.ACCT_REF_NUM; 
	/* Se duplican algunas cuentas (hay dups por ACCT_REF_NBR en FDBR), 
	EJ: ('00000000220000000356', '00000000220000000612') */
QUIT;

/* A - 1 IDENTIFY ELIGIBLE CREDIT CARDS */

PROC SQL;
	CREATE TABLE PRE_ELIGIBLE_LOANS_CC AS
		SELECT COMP_CALL, ACCT_REF_NUM AS ACCTNBR, NAME_ADD_1 AS CUSTNAME, CPN_RATE AS CPNRTE,
			CURR_BAL AS CUR_BAL,
			MDY(MOD(INT(MAT_DATE/100),100),MOD(MAT_DATE,100),INT(MAT_DATE/10000)) 
			FORMAT = DATE9. AS MATURDTE,
			ORIG_BOOK AS ORIG_BAL, PDUE_DAYS AS PSTDUEDAYS,
			MDY(MOD(INT(PROC_DATE/100),100),MOD(PROC_DATE,100),INT(PROC_DATE/10000)) 
			FORMAT = DATE9. AS PROCDT,
			REM_TRM_PERIODS AS REMAINTERM,
			SUBSYS_ID AS SYS, 
			STATE AS STATECD, 'CRD' AS MRGNCDE,	0.59 AS MRGNPCT,
			CIS_ACCT_ID
		FROM WHS.W_FDBR_BW
		WHERE BATCH_ID = &batch_WHS. AND COMP_CALL NOT IN ('06B0','04A0','06D0')
		AND CURR_BAL > 100 AND MAT_DATE > PROC_DATE
		AND PDUE_DAYS < 61 AND SUBSYS_ID IN ('OEC', 'OEC2') AND BANK IN ('077','045')
		AND (CHG_OFF_DATE IS NULL OR CHG_OFF_DATE = 0) 
		AND (CLOSE_DATE IS NULL OR CLOSE_DATE = 0) AND CUST_TYPE NOT IN ('B') 
		AND (NON_ACCR_DATE IS NULL OR NON_ACCR_DATE = 0)
		AND (PROD_PPS NOT IN ('252500','253500','255300','258600','259800','259000','258600')) 
		AND TRAN_CLASS IN ('REG', 'CML') AND TRAN_STAT IN ('ACT', 'NEW');
QUIT;

/* A - 2 IDENTIFY ELIGIBLE DEALER FLOOR PLAN LOANS */

PROC SQL;
	CREATE TABLE PRE_ELIGIBLE_LOANS_DFP AS
	SELECT MDY(MOD(INT(PROC_DATE/100),100),MOD(PROC_DATE,100),INT(PROC_DATE/10000)) 
			FORMAT = DATE9. AS PROCDT,
		SUBSYS_ID AS SYS, COMP_CALL, ACCT_REF_NUM AS ACCTNBR,
		NAME_ADD_1 AS CUSTNAME, ORIG_BOOK AS ORIG_BAL, CURR_BAL AS CUR_BAL, CPN_RATE AS CPNRTE, 
		'07' AS RISKCODE,
		MDY(MOD(INT(MAT_DATE/100),100),MOD(MAT_DATE,100),INT(MAT_DATE/10000)) 
			FORMAT = DATE9. AS MATURDTE,
		REM_TRM_PERIODS AS REMAINTERM, 'C&A' AS MRGNCDE, 0.65 AS MRGNPCT, 
		PDUE_DAYS AS PSTDUEDAYS, STATE AS STATECD,
		CIS_ACCT_ID
	FROM WHS.W_FDBR_BW  
	WHERE BATCH_ID = &batch_WHS. AND SUBSYS_ID = 'DFP' AND COMP_CALL = '04A0' 
		AND CURR_BAL > 0 AND MAT_DATE > PROC_DATE
		AND (CHG_OFF_DATE IS NULL OR CHG_OFF_DATE = 0)  
		AND (CLOSE_DATE IS NULL OR CLOSE_DATE = 0)
		AND (NON_ACCR_DATE IS NULL OR NON_ACCR_DATE = 0)
		AND (TRAN_CLASS = 'REG' OR TRAN_CLASS = 'CML') AND (TRAN_STAT = 'ACT' OR TRAN_STAT = 'NEW');
QUIT;

/* A - 3 COMBINE ALL THE PREVIOUS TABLES IN A MASTER TABLE THAT CONTAINS ALL THE ELEGIBLE LOANS */

DATA ELIGIBLE_LOANS;
	FORMAT SYS $5.;
	SET PRE_ELIGIBLE_LOANS
		PRE_ELIGIBLE_LOANS_CC
		PRE_ELIGIBLE_LOANS_DFP;
RUN;

/* B - 1 MODIFY ELIGIBLE LOANS - ADDING NEXT PMT DATE */

PROC SQL;
	CREATE TABLE FRB_ELIGIBLE_LOANS_1 AS
	SELECT EL.PROCDT, EL.SYS, EL.COMP_CALL, EL.ACCTNBR, EL.CUSTNAME, EL.ORIG_BAL, EL.CUR_BAL, EL.CPNRTE, 
		EL.RISKCODE, EL.MATURDTE, EL.REMAINTERM, EL.MRGNCDE, EL.MRGNPCT, EL.PSTDUEDAYS, EL.STATECD, 
		BW.COLL_CODE, BW.NXT_IPYMT_DATE, BW.NXT_PPYMT_DATE, BW.BANK, BW.CIS_ACCT_ID 
	FROM ELIGIBLE_LOANS EL 
	INNER JOIN WHS.W_FDBR_BW (WHERE = (BATCH_ID = &batch_WHS.)) BW  
		ON EL.ACCTNBR = BW.ACCT_REF_NUM
	WHERE EL.CUR_BAL > 0 AND BW.BANK IN ('045','077');
QUIT;

/* B - 2 IDENTIFY COMPASS LOANS */

PROC SQL;
	CREATE TABLE COMPASS_LOANS AS
	SELECT 'Compass Loans' AS REASON, PROCDT, SYS, ACCTNBR, CUSTNAME, ORIG_BAL, CUR_BAL, CPNRTE, 
		RISKCODE, MATURDTE, REMAINTERM, MRGNCDE, MRGNPCT, PSTDUEDAYS, STATECD, COLL_CODE, NXT_IPYMT_DATE, 
		NXT_PPYMT_DATE
	FROM FRB_ELIGIBLE_LOANS_1
	WHERE LOWER(CUSTNAME) LIKE "%compass%";
QUIT;

/* B - 2X REMOVE COMPASS LOANS */

PROC SQL;
	CREATE TABLE FRB_ELIGIBLE_LOANS_2 AS
	SELECT DISTINCT FEL.*
	FROM FRB_ELIGIBLE_LOANS_1 FEL
	LEFT JOIN COMPASS_LOANS CL
	ON FEL.ACCTNBR = CL.ACCTNBR
	WHERE CL.ACCTNBR IS NULL;
QUIT;

/* B - 3 IDENTIFY DUPLICATE LOANS */

PROC SQL;
	CREATE TABLE DUP_ACCT_NBR AS
	SELECT 'Duplicate Loan Records' AS REASON, ACCTNBR, PROCDT, SYS, CUSTNAME, ORIG_BAL, CUR_BAL,
		CPNRTE, RISKCODE, MATURDTE, REMAINTERM, MRGNCDE, MRGNPCT, PSTDUEDAYS, STATECD, COLL_CODE, 
		NXT_IPYMT_DATE, NXT_PPYMT_DATE 
	FROM FRB_ELIGIBLE_LOANS_2
	WHERE (ACCTNBR IN (SELECT ACCTNBR FROM ELIGIBLE_LOANS AS TMP 
						GROUP BY ACCTNBR HAVING COUNT(*) > 1))
	ORDER BY ACCTNBR;
QUIT;

/* B - 3X REMOVE DUPLICATE LOANS */

PROC SQL;
	CREATE TABLE FRB_ELIGIBLE_LOANS_3 AS
	SELECT DISTINCT FEL.*
	FROM FRB_ELIGIBLE_LOANS_2 FEL
	LEFT JOIN DUP_ACCT_NBR DAN
	ON FEL.ACCTNBR = DAN.ACCTNBR
	WHERE DAN.ACCTNBR IS NULL;
QUIT;

/* B - 4 IDENTIFY FOREIGN LOANS */

PROC SQL;
	CREATE TABLE FOREIGN_LOANS AS
	SELECT FEL.PROCDT, FEL.SYS, FEL.ACCTNBR, FEL.CUSTNAME, FEL.ORIG_BAL, FEL.CUR_BAL, FEL.CPNRTE,
		FEL.RISKCODE, FEL.MATURDTE, FEL.REMAINTERM, FEL.MRGNCDE, FEL.MRGNPCT, FEL.PSTDUEDAYS, FEL.STATECD,
		FEL.COLL_CODE, FEL.NXT_IPYMT_DATE, FEL.NXT_PPYMT_DATE 
	FROM FRB_ELIGIBLE_LOANS_3 FEL 
	LEFT JOIN PLEDGED.ABBREVIATION_STATE ABST 
	ON FEL.STATECD = ABST.ABBREVIATION
	WHERE ABST.ABBREVIATION IS NULL;
QUIT;

/* B - 4X REMOVE FOREIGN LOANS */

PROC SQL;
	CREATE TABLE FRB_ELIGIBLE_LOANS_4 AS
	SELECT DISTINCT FEL.*
	FROM FRB_ELIGIBLE_LOANS_3 FEL
	LEFT JOIN FOREIGN_LOANS FL
	ON FEL.ACCTNBR = FL.ACCTNBR
	WHERE FL.ACCTNBR IS NULL;
QUIT;

/* B - 5 IDENTIFY MATURITY DATES > 60 DAYS */

PROC SQL;
	CREATE TABLE MAT_DATE_BIG_60_DAYS AS
	SELECT 'Maturity Date > 60 Days' AS REASON, 
		PROCDT, INTCK('day', PROCDT, MATURDTE) AS DAYS_FROM_MAT, 
		SYS, ACCTNBR, CUSTNAME, ORIG_BAL, CUR_BAL, CPNRTE, RISKCODE, MATURDTE, REMAINTERM, 
		MRGNCDE, MRGNPCT, PSTDUEDAYS, STATECD, COLL_CODE, NXT_IPYMT_DATE, NXT_PPYMT_DATE 
	FROM FRB_ELIGIBLE_LOANS_4
	WHERE INTCK('day', PROCDT, MATURDTE) < 1; /* Por que ponemos 1 si son 60 dias?? */
QUIT;

/* B - 5X REMOVE MATURITY DATES > 60 DAYS */

PROC SQL;
	CREATE TABLE FRB_ELIGIBLE_LOANS_5 AS
	SELECT DISTINCT FEL.*
	FROM FRB_ELIGIBLE_LOANS_4 FEL
	LEFT JOIN MAT_DATE_BIG_60_DAYS MAT
	ON FEL.ACCTNBR = MAT.ACCTNBR
	WHERE MAT.ACCTNBR IS NULL;
QUIT;

/* B - 6 IDENTIFY CURRENT BALANCES < 0 */

PROC SQL;
	CREATE TABLE NEG_CURR_BAL AS
	SELECT 'Current Balance <0' AS REASON, 
		PROCDT, SYS, ACCTNBR, CUSTNAME, ORIG_BAL, CUR_BAL, CPNRTE, RISKCODE, MATURDTE, REMAINTERM,
		MRGNCDE, MRGNPCT, PSTDUEDAYS, STATECD, COLL_CODE, NXT_IPYMT_DATE, NXT_PPYMT_DATE 
	FROM FRB_ELIGIBLE_LOANS_5
	WHERE CUR_BAL < 0.01;
QUIT;

/* B - 6X REMOVE CURRENT BALANCES < 0 */

PROC SQL;
	CREATE TABLE FRB_ELIGIBLE_LOANS_6 AS
	SELECT DISTINCT FEL.*
	FROM FRB_ELIGIBLE_LOANS_5 FEL
	LEFT JOIN NEG_CURR_BAL NEG
	ON FEL.ACCTNBR = NEG.ACCTNBR
	WHERE NEG.ACCTNBR IS NULL;
QUIT;

/* B - 7 IDENTIFY MISSING RISK CODES IDENTIFIED
B - 7+ ADD MISSING RISK CODES WITH DEFAULT
B - 7X REMOVE MISSING RISK CODES
*/

/*
PROC SQL;
CREATE TABLE MISS_RISK_CODES AS
SELECT "Missing Risk Codes" AS REASON, ACCTNBR
FROM FRB_ELIGIBLE_LOANS_6
	WHERE (RISKCODE IN ("", "00")) AND 
			(MRGNCDE IN ("CRE", "C&A"));
QUIT;
*/

PROC SQL;
	CREATE TABLE FRB_ELIGIBLE_LOANS_7 AS
	SELECT PROCDT, SYS, COMP_CALL, FRB.ACCTNBR, CUSTNAME, ORIG_BAL, CUR_BAL, CPNRTE, 
		CASE
			WHEN MRGNCDE IN ('CRE','C&A') THEN
				CASE
					WHEN RISKCODE IS NULL OR RISKCODE = '00' THEN '07'
					ELSE RISKCODE
				END
			ELSE RISKCODE
		END AS RISKCODE,
		MATURDTE, REMAINTERM, MRGNCDE, MRGNPCT, PSTDUEDAYS, STATECD, COLL_CODE, NXT_IPYMT_DATE, 
		NXT_PPYMT_DATE, CIS_ACCT_ID 
	FROM FRB_ELIGIBLE_LOANS_6 FRB 
	/*
	LEFT JOIN MISS_RISK_CODES MISS
	ON FRB.ACCTNBR = MISS.ACCTNBR
	WHERE MISS.ACCTNBR IS NULL
	*/
;
QUIT;

/* B - 8 IDENTIFY COLLATERAL CODES ON CONSUMER LOANS 
B - 8X REMOVE COLLATERAL CODES REMOVED
B - 8+ ADD CONSUMER CODES
*/

PROC SQL;
	CREATE TABLE FRB_ELIGIBLE_LOANS_8 AS
	SELECT PROCDT, SYS, COMP_CALL, ACCTNBR, CUSTNAME, ORIG_BAL, CUR_BAL, CPNRTE, RISKCODE, 
		MATURDTE, REMAINTERM,
		CASE 
			WHEN MRGNCDE = 'CON' THEN
				CASE WHEN COLL_CODE = 'UNS' THEN 'UCL' ELSE 'SCL' END
			ELSE MRGNCDE
		END AS MRGNCDE,
		MRGNPCT, PSTDUEDAYS, STATECD, COLL_CODE, NXT_IPYMT_DATE, NXT_PPYMT_DATE, CIS_ACCT_ID 
	FROM FRB_ELIGIBLE_LOANS_7
	WHERE CALCULATED MRGNCDE IS NOT NULL;
QUIT;

/* B - 9 IDENTIFY PAID TO DATE - NPD > 30 DAYS COMM */

PROC SQL;
	CREATE TABLE PAID_TO_DATE_30DAYS_COMM AS
	SELECT 'Next Payment Date Past Due' AS REASON, PROCDT, SYS, ACCTNBR, CUSTNAME, ORIG_BAL, CUR_BAL,
		CPNRTE, RISKCODE, MATURDTE, REMAINTERM, MRGNCDE, MRGNPCT, PSTDUEDAYS, STATECD, COLL_CODE, 
		CASE WHEN NXT_IPYMT_DATE=99991231 THEN . ELSE MDY(MOD(INT(NXT_IPYMT_DATE/100),100),MOD(NXT_IPYMT_DATE,100),INT(NXT_IPYMT_DATE/10000)) END
		FORMAT = DATE9. AS NXT_IPYMT_DATE,
		CASE WHEN NXT_PPYMT_DATE=99991231 THEN . ELSE MDY(MOD(INT(NXT_PPYMT_DATE/100),100),MOD(NXT_PPYMT_DATE,100),INT(NXT_PPYMT_DATE/10000)) END
		FORMAT = DATE9. AS NXT_PPYMT_DATE,
		INTCK('day', PROCDT, CALCULATED NXT_PPYMT_DATE) AS DAYS_FROM_NPTD
	FROM FRB_ELIGIBLE_LOANS_8
	WHERE (MRGNCDE IN ('CRE','C&A') 
		AND ((INTCK('day', PROCDT, CALCULATED NXT_PPYMT_DATE)) < -30 
			OR (INTCK('day', PROCDT, CALCULATED NXT_PPYMT_DATE)) IS NULL));
QUIT;

/* B - 9 IDENTIFY PAID TO DATE - NPD > 60 DAYS CON */

PROC SQL;
	CREATE TABLE PAID_TO_DATE_60DAYS_COMM AS
	SELECT 'Payment Next Payment Date Past Due' AS REASON, PROCDT, SYS, ACCTNBR, CUSTNAME, ORIG_BAL, 
		CUR_BAL, CPNRTE, RISKCODE, MATURDTE, REMAINTERM, MRGNCDE, MRGNPCT, PSTDUEDAYS, STATECD,
		COLL_CODE,
		CASE WHEN NXT_IPYMT_DATE=99991231 THEN . ELSE MDY(MOD(INT(NXT_IPYMT_DATE/100),100),MOD(NXT_IPYMT_DATE,100),INT(NXT_IPYMT_DATE/10000)) END
		FORMAT = DATE9. AS NXT_IPYMT_DATE,
		CASE WHEN NXT_PPYMT_DATE=99991231 THEN . ELSE MDY(MOD(INT(NXT_PPYMT_DATE/100),100),MOD(NXT_PPYMT_DATE,100),INT(NXT_PPYMT_DATE/10000)) END
		FORMAT = DATE9. AS NXT_PPYMT_DATE,
		INTCK('day', PROCDT, CALCULATED NXT_PPYMT_DATE) AS DAYS_FROM_NPTD 
	FROM FRB_ELIGIBLE_LOANS_8
	WHERE (MRGNCDE IN ('UCL', 'SCL', 'CRD') 
		AND ((INTCK('day', PROCDT, CALCULATED NXT_PPYMT_DATE)) < -60
			OR (INTCK('day', PROCDT, CALCULATED NXT_PPYMT_DATE)) IS NULL));
QUIT;

/* B - 9X REMOVE PAID TO DATE - NPD >30 DAYS COMM */

PROC SQL;
	CREATE TABLE PRE_FRB_ELIGIBLE_LOANS_9 AS
	SELECT DISTINCT FEL.*
	FROM FRB_ELIGIBLE_LOANS_8 FEL
	LEFT JOIN PAID_TO_DATE_30DAYS_COMM P30
	ON FEL.ACCTNBR = P30.ACCTNBR
	WHERE P30.ACCTNBR IS NULL;
QUIT;

/* B - 9X REMOVE PAID TO DATE - NPD >60 DAYS CON */

PROC SQL;
	CREATE TABLE FRB_ELIGIBLE_LOANS_9 AS
	SELECT DISTINCT FEL.*
	FROM PRE_FRB_ELIGIBLE_LOANS_9 FEL
	LEFT JOIN PAID_TO_DATE_60DAYS_COMM P60
	ON FEL.ACCTNBR = P60.ACCTNBR
	WHERE P60.ACCTNBR IS NULL;
QUIT;

/* C - 1 IDENTIFY SHORT NUMBER FOR CLS LOANS */

PROC SQL;
	CREATE TABLE AFS_SHORT_ACCT_NBR AS
	SELECT BW.ACCT_REF_NUM, SUBSTR(BW.ACCT_REF_NUM,1,10) AS SHORT_NUMBER, BW.SUBSYS_ID, BW.CURR_BAL 
	FROM FRB_ELIGIBLE_LOANS_9 FEL
	INNER JOIN WHS.W_FDBR_BW (WHERE = (BATCH_ID = &batch_WHS.)) BW
		ON FEL.ACCTNBR = BW.ACCT_REF_NUM
	WHERE BW.SUBSYS_ID = 'CLS';
QUIT;

/* C - 2 IDENTIFY FHLB LOANS */

PROC SQL;
	CREATE TABLE FHLB_CRE_MF_LOANS_REMOVE AS
	SELECT 'FHLBA Loans' AS REASON, 
		FHLB.AFS_SHORT_NUMBER, AFS.ACCT_REF_NUM,
		AFS.CURR_BAL, AFS.SUBSYS_ID 
	FROM PLEDGED.FHLBA_CRE_MF_LOANS FHLB /* Table provided by Robert Williams. Do we need to 
		update it monthly? */
	INNER JOIN AFS_SHORT_ACCT_NBR AFS
	ON FHLB.AFS_SHORT_NUMBER = AFS.SHORT_NUMBER;
QUIT;

/* C - 3X REMOVE FHLBA LOANS FROM FRB POOL */

PROC SQL;
	CREATE TABLE FRB_ELIGIBLE_LOANS_10 AS
	SELECT DISTINCT FEL.*
	FROM FRB_ELIGIBLE_LOANS_9 FEL
	LEFT JOIN FHLB_CRE_MF_LOANS_REMOVE FHLB
	ON FEL.ACCTNBR = FHLB.ACCT_REF_NUM
	WHERE FHLB.ACCT_REF_NUM IS NULL;
QUIT;

/* D - 1 IDENTIFY BANK 092 LOANS */

PROC SQL;
	CREATE TABLE CMC_LOANS_BANK_092 AS
	SELECT ACCT_REF_NUM, BANK
	FROM WHS.W_FDBR_BW BW
	WHERE BATCH_ID = &batch_WHS. AND BANK IN ('092', '92');
QUIT;

/* D - 2X REMOVE BANK 092 LOANS */

PROC SQL;
	CREATE TABLE FRB_ELIGIBLE_LOANS_11 AS
	SELECT DISTINCT FEL.*
	FROM FRB_ELIGIBLE_LOANS_10 FEL
	LEFT JOIN CMC_LOANS_BANK_092 CMC
	ON FEL.ACCTNBR = CMC.ACCT_REF_NUM
	WHERE CMC.ACCT_REF_NUM IS NULL;
QUIT;

/* E - 1 IDENTIFY INELIGIBLE COST CENTERS */

/* Ver si hacer un create table (pisa la anterior) o hacer un insert into cuando tengamos
los datos y podamos hacer testing!!! */

/* Este paso sirve para algo?? */

PROC SQL; 
	CREATE TABLE CMC_LOANS_BANK_092 AS
	SELECT BW.BANK, FEL.PROCDT, FEL.SYS, FEL.ACCTNBR, FEL.CUSTNAME, FEL.ORIG_BAL, FEL.CUR_BAL, 
		FEL.CPNRTE, FEL.RISKCODE, FEL.MATURDTE, FEL.REMAINTERM, FEL.MRGNCDE, FEL.MRGNPCT, 
		FEL.PSTDUEDAYS, FEL.STATECD, FEL.COLL_CODE, FEL.NXT_IPYMT_DATE, FEL.NXT_PPYMT_DATE 
	FROM FRB_ELIGIBLE_LOANS_11 FEL
	INNER JOIN WHS.W_FDBR_BW (WHERE = (BATCH_ID = &batch_WHS.)) BW 
		ON FEL.ACCTNBR = BW.ACCT_REF_NUM;
QUIT;

/* E - 1X REMOVE INELIGIBLE COST CENTERS */

PROC SQL;
	CREATE TABLE FRB_ELIGIBLE_LOANS AS
	SELECT DISTINCT FEL.*
	FROM FRB_ELIGIBLE_LOANS_11 FEL
	LEFT JOIN PLEDGED.INELIGIBLE_COST_CENTERS ICC
	ON FEL.ACCTNBR = ICC.ACCTNBR
	WHERE ICC.ACCTNBR IS NULL;
QUIT;

/* F - 1 FINAL ELIGIBLE LOAN LISTING */

PROC SQL;
	CREATE TABLE ELIGIBLELOANS_FINAL AS
	SELECT FEL.PROCDT, FEL.SYS, FEL.COMP_CALL, FEL.ACCTNBR, FEL.CUSTNAME, FEL.ORIG_BAL, 
			FEL.CUR_BAL, FEL.CPNRTE, FEL.RISKCODE, FEL.MATURDTE, FEL.REMAINTERM, FEL.MRGNCDE,
			FEL.MRGNPCT, FEL.PSTDUEDAYS, FEL.STATECD, FEL.NXT_PPYMT_DATE, 
			CASE WHEN REPR_CODE = 'FM' THEN 'Fixed' ELSE 'Floating' END AS INTEREST_RATE_TYPE,
			FEL.CIS_ACCT_ID 
	FROM FRB_ELIGIBLE_LOANS FEL
	INNER JOIN WHS.W_FDBR_BW (WHERE = (BATCH_ID = &batch_WHS.)) BW 
		ON FEL.ACCTNBR = BW.ACCT_REF_NUM;
QUIT;

/* G - 1 SBA LOANS - A BEGINNING BALANCE */

PROC SQL;
	CREATE TABLE SBA_A_BEGIN_BALANCE_1 AS
	SELECT ACCT_REF_NUM, NAME_ADD_1, BANK, 
		CHG_OFF_DATE, CHG_OFF_MTD, CIS_ACCT_ID, CLOSE_DATE,	COLL_CODE, COMP_CALL, CPN_RATE,
		CURR_BAL, CUST_ADD_ID, CUST_TYPE, MAT_DATE,
		NON_ACCR_DATE, NXT_IPYMT_DATE, NXT_PPYMT_DATE, 
		ORIG_BOOK, 
		MDY(MOD(INT(ORIG_DATE/100),100),MOD(ORIG_DATE,100),INT(ORIG_DATE/10000)) FORMAT = DATE9.
		AS ORIG_DATE,
		ORIG_OFFCR, PDUE_DAYS, PROC_DATE, PROD_PPS, 
		REM_TRM_PERIODS, REPR_CODE,
		SUBSYS_ID, TRAN_CLASS,
		TRAN_STAT, OPT_DATA7, OPT_DATA8, OPT_NBR1, 
		STATE,
		ROUND((MAT_DATE - PROC_DATE)/30) AS REMAINING_TERM, 
		CASE WHEN REPR_CODE = 'FM' THEN 'Fixed' ELSE 'Floating' END AS INTEREST_RATE_TYPE,
		0.95 AS MRGNPCT, '07' AS RISKCODE 
	FROM WHS.W_FDBR_BW 
	WHERE BATCH_ID = &batch_WHS. AND (BANK IN ('045', '077') 
		AND (CHG_OFF_DATE IS NULL OR CHG_OFF_DATE = 0)
		AND (CLOSE_DATE IS NULL OR CLOSE_DATE = 0)
		AND COLL_CODE NOT IN ('RE1','RE2','RE3','REZ','GLA')
		AND COMP_CALL NOT IN ('01C1','01C2','01C2A','01C2B','1C2A','1C2B')
		AND CURR_BAL > 0 AND PDUE_DAYS < 31 
		AND CALCULATED ORIG_DATE > '30JUN1999'D 
		AND SUBSYS_ID IN ('SBA','SBLOC2') AND TRAN_CLASS IN ('REG','CML') 
		AND TRAN_STAT IN ('ACT','NEW') AND OPT_DATA7 IS NULL 
		AND UPPER(OPT_DATA8) LIKE '7A%' AND (PROC_DATE - MAT_DATE) < 1);
QUIT;

/* G - 1X SBA LOANS - A BEGINNING BALANCE LESS WATCHLIST LOANS */

PROC SQL;
	CREATE TABLE SBA_A_BEGIN_BALANCE AS
	SELECT DISTINCT SBA.*
	FROM SBA_A_BEGIN_BALANCE_1 SBA
	LEFT JOIN PLEDGED.WATCHLIST WL
	ON SBA.ACCT_REF_NUM = WL.ACCT_REF_NUM
	WHERE WL.ACCT_REF_NUM IS NULL;
QUIT;

/* G - 2 SBA LOANS - B BEGINNING BALANCE � GUARANTEED */

PROC SQL;
	CREATE TABLE SBA_A_BEGIN_BAL_GUAR AS 
	SELECT ACCT_REF_NUM,
		SUBSTR(ACCT_REF_NUM,1,18)!!SUBSTR(ACCT_REF_NUM,LENGTH(ACCT_REF_NUM)- 1, 1)!!'N' AS ACCOUNT_NUMBER, 
		NAME_ADD_1, BANK,
		CHG_OFF_DATE, CHG_OFF_MTD, CIS_ACCT_ID, CLOSE_DATE, 
		COLL_CODE, COMP_CALL, CPN_RATE, CURR_BAL, 
		ROUND(CURR_BAL*(OPT_NBR1/100),2) AS CUR_BAL,
		CUST_ADD_ID, CUST_TYPE, MAT_DATE, 
		NON_ACCR_DATE, NXT_IPYMT_DATE, NXT_PPYMT_DATE, ORIG_BOOK, 
		ROUND(ORIG_BOOK*(OPT_NBR1/100),2) AS ORIG_BAL, ORIG_DATE, ORIG_OFFCR, 
		PDUE_DAYS, PROC_DATE, PROD_PPS, 
		REM_TRM_PERIODS, REPR_CODE, 
		SUBSYS_ID, TRAN_CLASS, TRAN_STAT, OPT_DATA7, OPT_DATA8, OPT_NBR1,  
		STATE, REMAINING_TERM, MRGNPCT, 'GGA' AS MRGNCDE, RISKCODE, INTEREST_RATE_TYPE 
	FROM SBA_A_BEGIN_BALANCE;
QUIT;

/* G - 3 SBA LOANS - B BEGINNING BALANCE � NONGUARANTEED */
/*
PROC SQL;
	CREATE TABLE SBA_A_BEGIN_BAL_UNGUAR AS 
	SELECT ACCT_REF_NUM,
		SUBSTR(ACCT_REF_NUM,1,18)!!SUBSTR(ACCT_REF_NUM,LENGTH(ACCT_REF_NUM)- 1, 1)!!'N' AS ACCOUNT_NUMBER, NAME_ADD_1, BANK, 
		CHG_OFF_DATE, CHG_OFF_MTD, CIS_ACCT_ID, CLOSE_DATE, COLL_CODE, COMP_CALL, 
		CPN_RATE, CURR_BAL,	ROUND(CURR_BAL*(1-OPT_NBR1/100),2) AS CUR_BAL, 
		CUST_ADD_ID, CUST_TYPE, MAT_DATE, NON_ACCR_DATE, NXT_IPYMT_DATE, NXT_PPYMT_DATE, 
		ORIG_BOOK, 
		ROUND(ORIG_BOOK*(1-OPT_NBR1/100),2) AS ORIG_BAL, 
		ORIG_DATE, ORIG_OFFCR, PDUE_DAYS, PROC_DATE, PROD_PPS, 
		REM_TRM_PERIODS, REPR_CODE, 
		SUBSYS_ID, TRAN_CLASS,
		TRAN_STAT, OPT_DATA7, OPT_DATA8, OPT_NBR1,
		STATE, REMAINING_TERM, 
		INTEREST_RATE_TYPE, MRGNPCT, 'NGA' AS MRGNCDE, RISKCODE 
	FROM SBA_A_BEGIN_BALANCE;
QUIT;
*/

/* G - 4 SBA LOANS - C APPENDING GUARANTEED PORTION */

PROC SQL;
	CREATE TABLE ELIGIBLELOANS_GUAR AS
	SELECT MDY(MOD(INT(PROC_DATE/100),100),MOD(PROC_DATE,100),INT(PROC_DATE/10000)) 
			FORMAT = DATE9. AS PROCDT,
		SUBSYS_ID AS SYS, COMP_CALL, ACCOUNT_NUMBER AS ACCTNBR,
		NAME_ADD_1 AS CUSTNAME, ORIG_BAL, CUR_BAL, CPN_RATE AS CPNRTE, RISKCODE,
		MDY(MOD(INT(MAT_DATE/100),100),MOD(MAT_DATE,100),INT(MAT_DATE/10000)) 
			FORMAT = DATE9. AS MATURDTE, 
		REMAINING_TERM AS REMAINTERM, MRGNCDE, MRGNPCT, PDUE_DAYS AS PSTDUEDAYS, 
		STATE AS STATECD, INTEREST_RATE_TYPE, NXT_PPYMT_DATE, CIS_ACCT_ID
	FROM SBA_A_BEGIN_BAL_GUAR;
QUIT;

/* G - 5 SBA LOANS - C APPENDING NONGUARANTEED PORTION */
/*
PROC SQL;
	CREATE TABLE ELIGIBLELOANS_NONGUAR AS
	SELECT MDY(MOD(INT(PROC_DATE/100),100),MOD(PROC_DATE,100),INT(PROC_DATE/10000)) 
			FORMAT = DATE9. AS PROCDT,
		SUBSYS_ID AS SYS, COMP_CALL, ACCOUNT_NUMBER AS ACCTNBR,
		NAME_ADD_1 AS CUSTNAME, ORIG_BAL, CUR_BAL, CPN_RATE AS CPNRTE, RISKCODE,
		MDY(MOD(INT(MAT_DATE/100),100),MOD(MAT_DATE,100),INT(MAT_DATE/10000)) 
			FORMAT = DATE9. AS MATURDTE,
		REMAINING_TERM AS REMAINTERM, MRGNCDE, MRGNPCT, PDUE_DAYS AS PSTDUEDAYS,
		STATE AS STATECD, INTEREST_RATE_TYPE,NXT_PPYMT_DATE
	FROM SBA_A_BEGIN_BAL_UNGUAR;
QUIT;
*/

/* G - 6 COMBINE SBA LOANS (GUARANTEED AND NONGUARANTEED)*/

DATA ELIGIBLELOANS_CONSOLID;
SET ELIGIBLELOANS_FINAL
	ELIGIBLELOANS_GUAR
	/*Non Guaranteed will be informed in Commercial, CRE and Construction*/
	/*ELIGIBLELOANS_NONGUAR*/
;
RUN;


/*Additional Exclusion: Static FHLB Loans*/
PROC SQL;
CREATE TABLE ELIGIBLELOANS_STATIC AS
SELECT ELIG.*
FROM ELIGIBLELOANS_CONSOLID ELIG
LEFT JOIN PLEDGED.FHLBA_STATIC STAT
ON ELIG.ACCTNBR = STAT.ACCTNBR
WHERE STAT.ACCTNBR = "";
QUIT;


/*LOGIC TO DETERMINE THE CATEGORY*/
DATA ELIGIBLELOANS_CATEG
(rename=(COMP_CALL = M_COMP_CALL));
SET ELIGIBLELOANS_STATIC;
	FORMAT CATEGORY $3.;

	IF SYS NE "SBA" AND COMP_CALL = "0300" THEN
		CATEGORY = "705";
	ELSE IF SYS NE "SBA" AND (COMP_CALL IN ("04A0","0800","0900","09B1","09B2")) THEN
		CATEGORY = "710";
	ELSE IF SYS NE "SBA" AND COMP_CALL IN ("01B0", "01D0", "01E1", "01E2") THEN
		CATEGORY = "780";
	ELSE IF SYS NE "SBA" AND COMP_CALL IN ("01A1", "01A2") THEN
		CATEGORY = "790";
	ELSE IF SYS NE "SBA" AND COMP_CALL = "06A0" THEN
		CATEGORY = "842";
	ELSE IF SYS NE "SBA" AND MRGNCDE = "SCL" AND COMP_CALL IN ("06B0", "06C0", "06D0") THEN
		CATEGORY = "741";
	ELSE IF SYS NE "SBA" AND MRGNCDE = "UCL" AND COMP_CALL IN ("06B0", "06C0", "06D0") THEN
		CATEGORY = "740";
	ELSE IF SYS = "SBA" THEN
		CATEGORY = "720";
RUN;