
proc sql;	
create table UnsecuredConsumer as (	
	select 
FDBR.ACCT_REF_NUM AS ObligationNumber,
FDBR.CUST_ADD_ID as ObligorNumber,
FDBR.NAME_ADD_1 as ObligorName,
pledge.SYS as Subsystem,
FDBR.CITY as ObligorCity,
FDBR.STATE as ObligorState,
ALS.CF_PERS_CMCL_CD,
MDCCC.CCDESC_H10 as CCDESC_H10_Source,
MDCCC.CCDESC_H02,
EDW_XREF.SRCE_REC_ID as SRCE_REC_ID_Source,
CASE
	WHEN MDCCC.CCDESC_H10 LIKE 'RETAIL%' THEN EDW_XREF.SRCE_REC_ID
	ELSE "US"
END as ObligorCountry,
FDBR.INT_PYMT_FREQ,
case when FDBR.prefix_INT_PYMT_FREQ = 'A' then 'P'
	     when FDBR.prefix_INT_PYMT_FREQ = 'E' then 'M'
	     when FDBR.prefix_INT_PYMT_FREQ = 'D' and 0.75 < FDBR.ratio_Days_INT_PYMT_FREQ or FDBR.ratio_Days_INT_PYMT_FREQ >= 1 then 'A'
	     when FDBR.prefix_INT_PYMT_FREQ = 'D' and 0.375 < FDBR.ratio_Days_INT_PYMT_FREQ and FDBR.ratio_Days_INT_PYMT_FREQ <= 0.75 then 'S'
	     when FDBR.prefix_INT_PYMT_FREQ = 'D' and 0.12 < FDBR.ratio_Days_INT_PYMT_FREQ and FDBR.ratio_Days_INT_PYMT_FREQ <= 0.375 then 'Q'
	     when FDBR.prefix_INT_PYMT_FREQ = 'D' and 0 < FDBR.ratio_Days_INT_PYMT_FREQ and FDBR.ratio_Days_INT_PYMT_FREQ <= 0.12 then 'M'
	     when FDBR.prefix_INT_PYMT_FREQ = 'M' and 0.75 < FDBR.ratio_Months_INT_PYMT_FREQ or FDBR.ratio_Months_INT_PYMT_FREQ >= 1 then 'A'
	     when FDBR.prefix_INT_PYMT_FREQ = 'M' and 0.375 < FDBR.ratio_Months_INT_PYMT_FREQ and FDBR.ratio_Months_INT_PYMT_FREQ <= 0.75 then 'S'
	     when FDBR.prefix_INT_PYMT_FREQ = 'M' and 0.12 < FDBR.ratio_Months_INT_PYMT_FREQ and FDBR.ratio_Months_INT_PYMT_FREQ <= 0.375 then 'Q'
	     when FDBR.prefix_INT_PYMT_FREQ = 'M' and 0 < FDBR.ratio_Months_INT_PYMT_FREQ and FDBR.ratio_Months_INT_PYMT_FREQ <= 0.12 then 'M'
	else 'N' END AS InterestFrequency,
	FDBR.PRIN_PYMT_FREQ,
	case when FDBR.prefix_PRIN_PYMT_FREQ = 'A' then 'P'
	     when FDBR.prefix_PRIN_PYMT_FREQ = 'E' then 'M'
	     when FDBR.prefix_PRIN_PYMT_FREQ = 'D' and 0.75 < FDBR.ratio_Days_PRIN_PYMT_FREQ or FDBR.ratio_Days_PRIN_PYMT_FREQ >= 1 then 'A'
	     when FDBR.prefix_PRIN_PYMT_FREQ = 'D' and 0.375 < FDBR.ratio_Days_PRIN_PYMT_FREQ and FDBR.ratio_Days_PRIN_PYMT_FREQ <= 0.75 then 'S'
	     when FDBR.prefix_PRIN_PYMT_FREQ = 'D' and 0.12 < FDBR.ratio_Days_PRIN_PYMT_FREQ and ratio_Days_PRIN_PYMT_FREQ <= 0.375 then 'Q'
	     when FDBR.prefix_PRIN_PYMT_FREQ = 'D' and 0 < FDBR.ratio_Days_PRIN_PYMT_FREQ and FDBR.ratio_Days_PRIN_PYMT_FREQ <= 0.12 then 'M'
	     when FDBR.prefix_PRIN_PYMT_FREQ = 'M' and 0.75 < FDBR.ratio_Months_PRIN_PYMT_FREQ or FDBR.ratio_Months_PRIN_PYMT_FREQ >= 1 then 'A'
	     when FDBR.prefix_PRIN_PYMT_FREQ = 'M' and 0.375 < FDBR.ratio_Months_PRIN_PYMT_FREQ and FDBR.ratio_Months_PRIN_PYMT_FREQ <= 0.75 then 'S'
	     when FDBR.prefix_PRIN_PYMT_FREQ = 'M' and 0.12 < FDBR.ratio_Months_PRIN_PYMT_FREQ and FDBR.ratio_Months_PRIN_PYMT_FREQ <= 0.375 then 'Q'
	     when FDBR.prefix_PRIN_PYMT_FREQ = 'M' and 0 < FDBR.ratio_Months_PRIN_PYMT_FREQ and FDBR.ratio_Months_PRIN_PYMT_FREQ <= 0.12 then 'M'
	else 'N' END as PrincipalPaymentFrequency,
case when FDBR.NXT_IPYMT_DATE = 0 then . else FDBR.NXT_IPYMT_DATE end as InterestNextDueDate,
case when FDBR.LST_PYMT_DATE = 0 then . else FDBR.LST_PYMT_DATE end as InterestPaidThroughDate,
case when FDBR.NXT_PPYMT_DATE = 0 then . else FDBR.NXT_PPYMT_DATE end as PrincipalNextDueDate,
case when FDBR.LST_PYMT_DATE = 0 then . else FDBR.LST_PYMT_DATE end as PrincipalPaidThroughDate,
FDBR.NXT_PPYMT_DATE as M_NXT_PPYMT_DATE,
FDBR.TRAN_CLASS,
FDBR.CURR_BAL,
FDBR.CURR_LINE,
FDBR.CURR_BAL as Balance,
FDBR.CPN_RATE as InterestRate,
CASE
	WHEN ALS.RT_DURATION_CD = "D" THEN 99991231
	ELSE FDBR.MAT_DATE
END as MaturityDate,
CASE
	WHEN ALS.RT_DURATION_CD = "D" THEN 1
	ELSE 0
END as Demand_Flag,
input(put(FDBR.MAT_DATE,8.),yymmdd10.) as mat_date_format format=yymmdd10.,
FDBR.REPR_CODE,
CASE
	WHEN FDBR.REPR_CODE = 'FM' THEN 'FX'
	ELSE 'FL'
END as FXFLFlag,
FDBR.ORIG_DATE,
FDBR.LST_RENEW_DATE,
CASE
	WHEN FDBR.LST_RENEW_DATE = 0 OR FDBR.LST_RENEW_DATE > &batch_WHS THEN FDBR.ORIG_DATE
	ELSE FDBR.LST_RENEW_DATE 
END as OriginationDate,
FDBR.ORIG_BOOK,
FDBR.ORIG_LINE,
CASE 
	WHEN MDA1.LOAN_LINE_IND = "LINE" THEN FDBR.ORIG_LINE
	WHEN MDA1.LOAN_LINE_IND = "LOAN" THEN FDBR.ORIG_BOOK
END as OriginalBalance,
FDBR.REPR_DRVE_RATE,
CASE
	WHEN FDBR.REPR_CODE = 'FM' THEN ' '
	ELSE
		CASE 
			WHEN FDBR.REPR_DRVE_RATE = 'LIBOR' THEN '01'
			WHEN FDBR.REPR_DRVE_RATE = 'PRIME' THEN '03'
			WHEN FDBR.REPR_DRVE_RATE = 'U.S. LIBOR' THEN '04'
			WHEN FDBR.REPR_DRVE_RATE = 'NONE' THEN 'OT'
			WHEN FDBR.REPR_DRVE_RATE = 'TBILL' THEN '02'
			WHEN FDBR.REPR_DRVE_RATE = 'OTHPRM' THEN '03'
			WHEN FDBR.REPR_DRVE_RATE = 'CBINDX' THEN '03'
		ELSE 'OT'
		END
END as InterestRateIndex,
CASE
	WHEN calculated FXFLFlag = 'FL' THEN FDBR.REPR_SPRD_VAL
	ELSE . 
END as InterestRateSpread,
FDBR.REV_FLAG as Revolving,
MDPT.PROCESS_TYPE_CD,
FDBR.PROD_CODE,
CASE 
	WHEN Subsystem = 'ALS' AND REV_FLAG = 'R' AND PROD_CODE <> 'CPLC' THEN 2
	WHEN Subsystem = 'ALS' AND REV_FLAG = 'R' AND PROD_CODE = 'CPLC' THEN 3
	WHEN Subsystem = 'ALS' AND REV_FLAG = 'N' AND PROD_CODE <> 'CPLC' THEN 4
	WHEN Subsystem = 'ALS' AND REV_FLAG = 'N' AND PROD_CODE = 'CPLC' THEN 5
	ELSE 1
	END AS DrawdownType,
COALESCE(INPUT(ALS.ALN_DAT_EXPIRATION,yymmdd10.),Calculated mat_date_format) as DrawPeriodEndDate format=yymmdd10.,

case when substr(ALS.RT_USER_GRP4_CR_SCORE_3,1,1) NE "0" AND length(ALS.RT_USER_GRP4_CR_SCORE_3) = 4 then 
		.
	 else  
	 	input(substr(ALS.RT_USER_GRP4_CR_SCORE_3,max(1,length(ALS.RT_USER_GRP4_CR_SCORE_3) - 2)), 3.) 
end as MostRecentCreditBureauScore format = 3.,
ALS2.ALN_DAT_REFR_FICO as ALN_DAT_REFR_FICO_Source,
input(ALS2.ALN_DAT_REFR_FICO, 8.) as DateMostRecCreditBurScore format = 8.,
case when substr(ALS.RT_USER_GRP3_CR_SCORE_2,1,1) NE "0" AND length(ALS.RT_USER_GRP3_CR_SCORE_2) = 4 then 
		.
	 else  
	 	input(substr(ALS.RT_USER_GRP3_CR_SCORE_2,max(1,length(ALS.RT_USER_GRP3_CR_SCORE_2) - 2)), 3.) 
end as CreditBureauScoreAtOrigination format = 3.,

COMP_CALL as CallReportCode,
MDA1.MRA_LOAN_ID,
case when Basel.ACCT_REF_NUM ne "" then 1 else 0 end as Flag_Balloon_Basel,
FDBR.PDUE_DAYS,
pledge.CATEGORY,
pledge.M_COMP_CALL,
pledge.RISKCODE, 
pledge.REMAINTERM, 
pledge.MRGNCDE, 
pledge.MRGNPCT
from
	(SELECT *, input(put(FDBR.ORIG_DATE,8.),yymmdd10.) as orig format=yymmdd10. FROM FDBR) FDBR
	
	JOIN (select MRA_LOAN_ID, LOAN_LINE_IND, ACCOUNT_KEY, CIS_ACCT_ID 
	from MRT.D_ACCOUNTS) MDA1
	on MDA1.CIS_ACCT_ID = FDBR.CIS_ACCT_ID
	
	JOIN (select SYS, ACCTNBR, CATEGORY, M_COMP_CALL,
	RISKCODE, REMAINTERM, MRGNCDE, MRGNPCT 
	from PLEDGE_LOANS where CATEGORY = '740') pledge
	on FDBR.ACCT_REF_NUM = pledge.ACCTNBR

	LEFT JOIN (
		SELECT RT_CTL1, RT_CTL2, RT_ACCT_NUM, CF_PERS_CMCL_CD, ALN_DAT_EXPIRATION, RT_USER_GRP4_CR_SCORE_3, RT_USER_GRP3_CR_SCORE_2, RT_DURATION_CD 
		FROM WHS.W_ALS_FLAT WHERE BATCH_ID = &batch_WHS
	) ALS
	on cats(put(input(ALS.RT_CTL1,4.),z4.),						
	put(input(ALS.RT_CTL2,4.),z4.), '00000000',							
	ALS.RT_ACCT_NUM) = FDBR.CIS_ACCT_ID

	LEFT JOIN (
		SELECT RT_CTL1, RT_CTL2, RT_ACCT_NUM, ALN_DAT_REFR_FICO 
		FROM WHS.W_ALS_FLAT2 WHERE BATCH_ID = &batch_WHS
	) ALS2
	on cats(put(input(ALS2.RT_CTL1,4.),z4.),						
	put(input(ALS2.RT_CTL2,4.),z4.), '00000000',							
	ALS2.RT_ACCT_NUM) = FDBR.CIS_ACCT_ID

	LEFT JOIN (
		select CCAR_PENALTY_TERM, CCAR_PREPAY_PENALTY_FLG, CCAR_BANK, CCAR_LN_NO, CCAR_CTL1 from WHS.W_ALS_CCAR where BATCH_ID  = &batch_WHS
	) ALS_CCAR
	ON cats(PUT(input(CCAR_CTL1,4.), z4.),put(input(ALS_CCAR.CCAR_BANK,4.),z4.), '000000000000', ALS_CCAR.CCAR_LN_NO) = FDBR.CIS_ACCT_ID

	LEFT JOIN (SELECT ACCOUNT_KEY, PROCESS_TYPE_KEY, COMMON_COST_CENTER_KEY 
	FROM MRT.F_ACCOUNTS WHERE BATCH_ID = &batch_MRT) MFA
	ON MFA.ACCOUNT_KEY = MDA1.ACCOUNT_KEY

	LEFT JOIN (SELECT PROCESS_TYPE_CD, SUB_SYSTEM_ID, PROCESS_TYPE_KEY 
	FROM MRT.D_PROCESS_TYPE) MDPT
	ON MDPT.PROCESS_TYPE_KEY = MFA.PROCESS_TYPE_KEY
 	AND pledge.SYS = MDPT.SUB_SYSTEM_ID

	LEFT JOIN (SELECT CCDESC_H10, CCDESC_H02, COMMON_COST_CENTER_KEY 
	FROM MRT.D_COMMON_COST_CENTER) MDCCC
	ON MDCCC.COMMON_COST_CENTER_KEY = MFA.COMMON_COST_CENTER_KEY

	LEFT JOIN ORDERED ORD
	ON ORD.ACCT_REF_NUM = FDBR.ACCT_REF_NUM

	LEFT JOIN (SELECT ACCT_REF_NUM, CTZN_CNTRY_ID FROM citizenship) ct
	on ct.ACCT_REF_NUM = pledge.ACCTNBR

	LEFT JOIN (select EDW_XREF_LKP_ID, SRCE_REC_ID, SRCE_REC_DESC
				from  EDWPRD_O.EDW_XREF_LKP
				WHERE edw_lkp_tbl_id = 100494) EDW_XREF
	ON ct.CTZN_CNTRY_ID = EDW_XREF.EDW_XREF_LKP_ID

	LEFT JOIN (select distinct ACCT_REF_NUM from BalloonLoans_Basel_Final) Basel
	ON Basel.ACCT_REF_NUM = pledge.ACCTNBR
);	
quit;	

data Unsecured_Formats
(drop= DrawPeriodEndDate
rename= (DrawPeriodEndDate_f = DrawPeriodEndDate));

format ObligationNumber;
format ObligorNumber;
format ObligorName;
format ObligorCity;
format ObligorState;
format CCDESC_H10_Source;
format SRCE_REC_ID_Source;
format ObligorCountry;
format InterestFrequency;
format PrincipalPaymentFrequency;
format InterestNextDueDate;
format InterestPaidThroughDate;
format PrincipalNextDueDate;
format PrincipalPaidThroughDate;
format M_NXT_PPYMT_DATE;
format Balance 14.2;
format InterestRate 5.2;
format MaturityDate;
format Demand_Flag;
format FXFLFlag;
format OriginationDate;
format OriginalBalance 14.2;
format InterestRateIndex;
format InterestRateSpread 6.2;
format DrawdownType;
format DrawPeriodEndDate_f 8.;
format MostRecentCreditBureauScore 4.;
format ALN_DAT_REFR_FICO_Source;
format DateMostRecCreditBurScore;
format CreditBureauScoreAtOrigination 4.;
format CallReportCode;
format PDUE_DAYS;
set UnsecuredConsumer;

DrawPeriodEndDate_f = input(cats(
substr(put(DrawPeriodEndDate, YYMMDD10.),1,4),
substr(put(DrawPeriodEndDate, YYMMDD10.),6,2),
substr(put(DrawPeriodEndDate, YYMMDD10.),9,2)
),$8.);


/*Do not inform foreign countries*/
WHERE ObligorCountry IN ("US", "");

run;

/*Excluding new loans*/
data PLEDGED.UnsecuredConsumerFinal;
set Unsecured_Formats;
	where ORIGINATIONDATE <= &batch_prev.;
run;


/*Exporting*/
%exportXLSX(PLEDGED.UnsecuredConsumerFinal,
/SAS_RiskModelDev/SAS_FSB/Pledged loans/UnsecuredConsumer.xlsx,
UnsecuredConsumer);


/************Exclusions Log************/

/*Foreign Countries*/
data Exclusion_Country_Unsec(keep=ObligationNumber Portfolio Reason ObligorCountry);
format ObligationNumber;
format Portfolio $50.;
format Reason $100.;
format ObligorCountry;
set UnsecuredConsumer;
	Portfolio = "Unsecured Consumer";
	Reason = "Foreign Country";
	where ObligorCountry NOT IN ("US", "");
run;

/*New Loans Exclusion*/
data Unsecured_Origination(keep=ObligationNumber Portfolio Reason ORIGINATIONDATE);
format ObligationNumber;
format Portfolio $50.;
format Reason $100.;
format ORIGINATIONDATE;
set Unsecured_Formats;
	Portfolio = "Unsecured Consumer";
	Reason = "New Loans";
	where ORIGINATIONDATE > &batch_prev.;
run;



/************Old Treasury Report************/
data UnsecuredConsumer_Old (
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
set PLEDGED.UnsecuredConsumerFinal;
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
%exportXLSX(UnsecuredConsumer_Old,
/SAS_RiskModelDev/SAS_FSB/Pledged loans/UnsecuredConsumer_Treasury.xlsx,
UnsecuredConsumer);