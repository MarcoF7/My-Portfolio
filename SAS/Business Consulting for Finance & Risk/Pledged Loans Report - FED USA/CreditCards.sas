proc sql;
create table CreditCards as (
select 
	ACCT_REF_NUM as ObligationNumber, 
	NAME_ADD_1 as ObligorName,
	BALANCE, 
	TS2_CURR_BAL AS BALANCE_WITHOUT_FC,
	CASE WHEN CURR_BAL > 0 AND CURR_BAL <= 100 THEN 0 ELSE CURR_BAL END as BALANCE_FDBR,
	CREDIT_BUREAU_SCORE,
	CASE WHEN CREDIT_BUREAU_SCORE >= 760 THEN '1' 
		 WHEN CREDIT_BUREAU_SCORE >= 660 AND CREDIT_BUREAU_SCORE < 760 THEN '2'
		 WHEN CREDIT_BUREAU_SCORE >= 620 AND CREDIT_BUREAU_SCORE < 660 THEN '3'
		 WHEN CREDIT_BUREAU_SCORE < 620 THEN '4'
	END AS CREDIT_BUREAU_SCORE_CURRENT,	
	WCTMCA.TS2_PUR_APR AS APR,
	COMP_CALL AS CALL_REPORT_CODE,
	pledge.SYS as Subsystem,
	pledge.CATEGORY,
	pledge.M_COMP_CALL,
	OriginalBalance,
	CPN_RATE as InterestRate,
	RISKCODE,
	MAT_DATE as MaturityDate,
	REMAINTERM, 
	MRGNCDE, 
	MRGNPCT,
	PDUE_DAYS,
	STATE as ObligorState,
	NXT_PPYMT_DATE as M_NXT_PPYMT_DATE,
	FXFLFlag

from (
	SELECT 
	FDBR.ACCT_REF_NUM, 
	FDBR.NAME_ADD_1,
	TRAN.TRN5_ACCT_NUM, 
	TRAN.TS2_ACCT_ID, 
	WCSF.TS2_CURR_BAL,
	WCSF.TS2_CURR_BAL + FINANCE_CHARGE AS BALANCE, 
	/*cycle_ending_balance, 
	month_ending_balance,
	reference_number,*/ 
	TSYS.R_CB_SCORE, 
	CASE WHEN TSYS.R_CB_SCORE >= 300 AND TSYS.R_CB_SCORE <= 850 THEN TSYS.R_CB_SCORE ELSE input(FDBR.CR_SCORE_3,5.) END AS CREDIT_BUREAU_SCORE,
	
	/*rep.refreshed_credit_score,*/ 
	CR_SCORE_1, CR_SCORE_2, CR_SCORE_3, CR_SCORE_4, CR_SCORE_5,
	/*cycle_ending_retail_apr,*/
	FDBR.COMP_CALL,
	CASE 
		WHEN MDA1.LOAN_LINE_IND = "LINE" THEN FDBR.ORIG_LINE
		WHEN MDA1.LOAN_LINE_IND = "LOAN" THEN FDBR.ORIG_BOOK
	END as OriginalBalance,
	FDBR.CPN_RATE,
	pledge.RISKCODE,
	FDBR.MAT_DATE,
	pledge.REMAINTERM, 
	pledge.MRGNCDE, 
	pledge.MRGNPCT,
	FDBR.PDUE_DAYS,
	FDBR.STATE,
	FDBR.NXT_PPYMT_DATE,
	FDBR.CURR_BAL,
	CASE
		WHEN FDBR.REPR_CODE = 'FM' THEN 'FX'
		ELSE 'FL'
	END as FXFLFlag

	FROM (
		SELECT ACCTNBR, LENGTH(ACCTNBR), SUBSTR(ACCTNBR,5,LENGTH(ACCTNBR)), SYS,
		CATEGORY, M_COMP_CALL, RISKCODE, REMAINTERM, MRGNCDE, MRGNPCT
		FROM PLEDGE_LOANS WHERE CATEGORY = '842'
	) PLEDGE
	LEFT JOIN (
	  SELECT ACCT_REF_NUM, NAME_ADD_1, CIS_ACCT_ID, CPN_RATE, MAT_DATE, PDUE_DAYS, STATE, NXT_PPYMT_DATE, ORIG_LINE, ORIG_BOOK, REPR_CODE,
	  BATCH_ID, CR_SCORE_1, CR_SCORE_2, CR_SCORE_3, CR_SCORE_4, CR_SCORE_5, COMP_CALL, CURR_BAL 
	  FROM WHS.W_FDBR_BW WHERE BATCH_ID = &batch_WHS
	) FDBR
	ON PLEDGE.ACCTNBR = FDBR.ACCT_REF_NUM

	LEFT JOIN (
	  SELECT distinct TS2_ACCT_ID, TRN5_ACCT_NUM FROM WHS.W_CACC_TS2_TRAN_BASE WHERE BATCH_ID = &batch_WHS
	) TRAN
	ON SUBSTR(FDBR.ACCT_REF_NUM,5,LENGTH(FDBR.ACCT_REF_NUM)) = TRAN.TRN5_ACCT_NUM
	
	LEFT JOIN (
	  SELECT TS2_ACCT_ID, TS2_CURR_BAL, SADA_NET_PURCH_FC_AMT + SADA_NET_CASH_FC_AMT AS FINANCE_CHARGE FROM WHS.W_CACC_SADA_FACT WHERE BATCH_ID = &batch_WHS
	) WCSF
	ON WCSF.TS2_ACCT_ID = TRAN.TS2_ACCT_ID

	LEFT JOIN (
		SELECT R_ACCOUNT_NUMBER, R_CB_SCORE FROM WHS.W_TSYS_FLAT WHERE BATCH_ID = &batch_WHS
	) TSYS
	ON TSYS.R_ACCOUNT_NUMBER = SUBSTR(FDBR.ACCT_REF_NUM,5,LENGTH(FDBR.ACCT_REF_NUM))
	/*left join (
		select cards.reference_number, cards.cycle_ending_balance, month_ending_balance, ts2_acct_id, refreshed_credit_score, cycle_ending_retail_apr from (
				SELECT * FROM WKFSPRO.t_fsc_usfedrr_sr016_vf20180331 where lot_id = 1463
		) cards
		join (
			select * from WKFSPRO.t_bc_etl_mrt_ts2_link where 
			'30Sep2018:0:0:0'dt BETWEEN start_validity_date AND end_validity_date
		) etl
		on input(cards.reference_number, 9.) = etl.account_key
	) rep
	on rep.ts2_acct_id = WCSF.TS2_ACCT_ID
	) loan*/
LEFT JOIN (
	SELECT TS2_ACCT_ID, TS2_PUR_APR FROM WHS.W_CACC_TS2_MTHLY_CIF_ACCT WHERE BATCH_ID = &batch_WHS
) WCTMCA
ON WCTMCA.TS2_ACCT_ID = TRAN.TS2_ACCT_ID
LEFT JOIN (select MRA_LOAN_ID, LOAN_LINE_IND, ACCOUNT_KEY, CIS_ACCT_ID 
from MRT.D_ACCOUNTS) MDA1
on MDA1.CIS_ACCT_ID = FDBR.CIS_ACCT_ID
))
;
quit;

/*Keeping columns required by FED*/
data CreditCards_Addit(
keep=ObligationNumber BALANCE APR CREDIT_BUREAU_SCORE);
set CreditCards;
run;

/*Exporting*/
%exportXLSX(CreditCards_Addit,
/SAS_RiskModelDev/SAS_FSB/Pledged loans/CreditCards.xlsx,
CreditCards);

/*Summarized Level*/
proc sql;
	CREATE TABLE PLEDGED.CREDIT_CARDS_FINAL AS (
		SELECT 
		CREDIT_BUREAU_SCORE_CURRENT AS CREDIT_BUREAU_SCORE_SEGMENT, 
		SUM(BALANCE) AS BALANCE_CC, 
		sum(BALANCE*APR)/sum(BALANCE) AS APR,
		sum(BALANCE*CREDIT_BUREAU_SCORE)/sum(BALANCE) AS CREDIT_BUREAU_SCORE, 
		MIN(CALL_REPORT_CODE) AS CALL_REPORT_CODE 
		FROM CREDITCARDS 
		GROUP BY CREDIT_BUREAU_SCORE_CURRENT
	);
quit;


/************Old Treasury Report************/
data Credit_Cards_Old (
keep=PROCDT Subsystem CATEGORY M_COMP_CALL ObligationNumber ObligorName
OriginalBalance Balance InterestRate RISKCODE MaturityDate_format REMAINTERM
MRGNCDE MRGNPCT PDUE_DAYS ObligorState M_NXT_PPYMT_FORMAT 'INTEREST RATE TYPE'n
rename=(
Subsystem = SYS
ObligationNumber = ACCTNBR
ObligorName = CUSTNAME
OriginalBalance = 'ORIG BAL'n
Balance = 'CUR BAL'n
InterestRate = CPNRTE
MaturityDate_format = MATURDTE
PDUE_DAYS = PSTDUEDAYS
ObligorState = STATECD
M_NXT_PPYMT_FORMAT = M_NXT_PPYMT_DATE));
format PROCDT MMDDYY10.;
format Subsystem;
format CATEGORY;
format M_COMP_CALL;
format ObligationNumber;
format ObligorName;
format OriginalBalance;
format Balance;
format InterestRate 6.3;
format RISKCODE;
format MaturityDate_format MMDDYY10.;
format REMAINTERM;
format MRGNCDE;
format MRGNPCT;
format PDUE_DAYS;
format ObligorState;
format M_NXT_PPYMT_FORMAT MMDDYY10.;
format 'INTEREST RATE TYPE'n $10.;
set CreditCards;
	PROCDT = &_processing_date.;

	/*Formatting MaturityDate*/
	year_mat = input(substr(left(MaturityDate),1,4),4.);
	month_mat = input(substr(left(MaturityDate),5,2),2.);
	day_mat = input(substr(left(MaturityDate),7,2),2.);
	MaturityDate_format = mdy(month_mat,day_mat,year_mat);

	/*Formatting M_NXT_PPYMT_DATE*/
	year_nxt = input(substr(left(M_NXT_PPYMT_DATE),1,4),4.);
	month_nxt = input(substr(left(M_NXT_PPYMT_DATE),5,2),2.);
	day_nxt = input(substr(left(M_NXT_PPYMT_DATE),7,2),2.);
	M_NXT_PPYMT_FORMAT = mdy(month_nxt,day_nxt,year_nxt);

	/*INTEREST RATE TYPE values based on FXFLFlag*/
	IF FXFLFlag = "FX" THEN
 		'INTEREST RATE TYPE'n  = "Fixed";
	ELSE IF FXFLFlag = "FL" THEN
		'INTEREST RATE TYPE'n  = "Floating";
run;

/*Exporting*/
%exportXLSX(Credit_Cards_Old,
/SAS_RiskModelDev/SAS_FSB/Pledged loans/CreditCards_Treasury.xlsx,
CreditCards);