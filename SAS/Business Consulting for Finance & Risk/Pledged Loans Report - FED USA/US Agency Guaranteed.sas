
proc sql;
create table US_Agency as (
	SELECT DISTINCT
	FDBR.ACCT_REF_NUM AS ObligationNumber,
	FDBR.CUST_ADD_ID as ObligorNumber,
	FDBR.NAME_ADD_1 as ObligorName,
	pledge.SYS as Subsystem,
	FDBR.CITY as ObligorCity,
	FDBR.STATE as ObligorState,
    'US' as ObligorCountry,
	"" as MasterNoteReferenceNumber, 
	. as MasterNoteOrigBalComm,
	. as MasterNoteCurrCommAm,
	. as MasterNoteMaturityDate,
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
	FDBR.prefix_PRIN_PYMT_FREQ as prefix_PRIN_PYMT_FREQ,
	FDBR.ratio_Days_PRIN_PYMT_FREQ as ratio_Days_PRIN_PYMT_FREQ,
	FDBR.ratio_Months_PRIN_PYMT_FREQ as ratio_Months_PRIN_PYMT_FREQ,
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
    CASE WHEN pledge.SYS = 'SBA' then ROUND(FDBR.CURR_BAL * (FDBR.OPT_NBR1/100), 0.01) ELSE FDBR.CURR_BAL END as GuaranteedBalance,
	CASE WHEN pledge.SYS = 'SBA' then ROUND(FDBR.CURR_BAL * (1-(FDBR.OPT_NBR1/100)), 0.01) ELSE FDBR.CURR_BAL END as NonGuaranteedBalance,
	FDBR.CPN_RATE as InterestRate,
	/*AFS.O_DURATION_CODE,*/
	CASE
		WHEN /*AFS.O_DURATION_CODE = '2'*/ 1 = 2 THEN 99991231
		ELSE FDBR.MAT_DATE
	END as MaturityDate,
	FDBR.REPR_CODE,
	CASE
		WHEN FDBR.REPR_CODE = 'FM' THEN 'FX'
		ELSE 'FL'
	END as FXFLFlag,
	MFA.POD_GRADE_CD as DIInternalRiskRating,
	FDBR.ORIG_DATE,
	FDBR.LST_RENEW_DATE,
	CASE
		WHEN FDBR.LST_RENEW_DATE = 0 OR FDBR.LST_RENEW_DATE > &batch_WHS THEN FDBR.ORIG_DATE
		ELSE FDBR.LST_RENEW_DATE 
	END as OriginationDate,
	FDBR.ORIG_BOOK,
	FDBR.ORIG_LINE,
	CASE 
		WHEN MDA1.LOAN_LINE_IND = "LINE" THEN ROUND(FDBR.ORIG_LINE * (FDBR.OPT_NBR1/100), 0.01) 
		WHEN MDA1.LOAN_LINE_IND = "LOAN" THEN ROUND(FDBR.ORIG_BOOK * (FDBR.OPT_NBR1/100), 0.01)
	END as GuaranteedOriginalBalance,
	CASE 
		WHEN MDA1.LOAN_LINE_IND = "LINE" THEN ROUND(FDBR.ORIG_LINE * (1-(FDBR.OPT_NBR1/100)), 0.01) 
		WHEN MDA1.LOAN_LINE_IND = "LOAN" THEN ROUND(FDBR.ORIG_BOOK * (1-(FDBR.OPT_NBR1/100)), 0.01)
	END as NonGuaranteedOriginalBalance,
	ORD.ORIG_DATE AS ORD_ORIG_DATE format=yymmdd10.,
	CASE
	WHEN 1 = 2 THEN ORD.MAT_DATE 
	ELSE 
		CASE WHEN ORD.ORIG_DATE < 20000101 /*AND ORD.INT_PYMT_FREQ IN ('EXPL', 'M001')*/
		THEN INTNX('MONTH',ORD.ORIG_DATE,1)
		/*WHEN ORD.ORIG_DATE < 20000101 AND ORD.INT_PYMT_FREQ = 'M003' THEN INTNX('MONTH',ORD.ORIG_DATE,1)*/
		ELSE input(PUT(ORD.NXT_PPYMT_DATE, yymmdd10.), yymmdd10.) END
	END as AmortizationStartDate format=yymmdd10.,
	FDBR.PDUE_DAYS,
	Calculated MaturityDate as AmortizationEndDate,
	COMP_CALL as CallReportCode,
	MFA.NAICS_KEY AS NAICS_MRT,
	MFA.SICCODE_KEY,
	CASE WHEN SBA.NAICS_CODE IS NOT NULL THEN NAICS.NAICS_KEY ELSE SIC.SICCODE_KEY END as IndustryCode,
	CASE WHEN SBA.NAICS_CODE IS NOT NULL THEN 1 
	     WHEN SIC.SICCODE_KEY IS NOT NULL THEN 2 
	ELSE . END as IndustryCodeType,
	MDA1.MRA_LOAN_ID,
	case when Basel.ACCT_REF_NUM ne "" then 1 else 0 end as Flag_Balloon_Basel,
	pledge.CATEGORY,
	pledge.M_COMP_CALL,
	pledge.RISKCODE, 
	pledge.REMAINTERM, 
	pledge.MRGNCDE, 
	pledge.MRGNPCT
	FROM (SELECT *, input(put(FDBR.ORIG_DATE,8.),yymmdd10.) as orig format=yymmdd10. FROM FDBR) FDBR
	
	JOIN (select MRA_LOAN_ID, LOAN_LINE_IND, ACCOUNT_KEY, CIS_ACCT_ID 
	from MRT.D_ACCOUNTS) MDA1
	on MDA1.CIS_ACCT_ID = FDBR.CIS_ACCT_ID
	
	JOIN (select DISTINCT ACCTNBR, SYS, CATEGORY, M_COMP_CALL,
	RISKCODE, REMAINTERM, MRGNCDE, MRGNPCT 
	from PLEDGE_LOANS where CATEGORY = '720') pledge
	on FDBR.ACCT_REF_NUM = pledge.ACCTNBR
	
	LEFT JOIN (
	SELECT CIS_ACCT_ID, NAICS_CODE, SIC_CODE FROM WHS.W_SBA_FLAT WHERE BATCH_ID = &batch_WHS
	) SBA
	ON SBA.CIS_ACCT_ID = MDA1.CIS_ACCT_ID

	LEFT JOIN (SELECT SICCODE_KEY, NAICS_KEY, POD_GRADE_CD, 
	COMMON_COST_CENTER_KEY, ACCOUNT_KEY
	FROM MRT.F_ACCOUNTS WHERE BATCH_ID = &batch_MRT) MFA
	ON MFA.ACCOUNT_KEY = MDA1.ACCOUNT_KEY
	/*
	LEFT JOIN (SELECT * FROM MRT.D_COMMON_COST_CENTER) MDCCC
	ON MDCCC.COMMON_COST_CENTER_KEY = MFA.COMMON_COST_CENTER_KEY
	*/
	LEFT JOIN ORDERED ORD
	ON ORD.ACCT_REF_NUM = FDBR.ACCT_REF_NUM

	LEFT JOIN (
		SELECT 
		ACCT_REF_NUM,
		curr_value AS COL_VAL,
		'' AS ORIG_VAL,
		'' AS COL_TP,
		'' AS ZIP,
		'' AS COUNTRY,
		'' AS COLL_TYPE_DESC
		FROM COLLATERALS_SBA_DFP SBA
	) COL
	ON COL.ACCT_REF_NUM = pledge.ACCTNBR

	LEFT JOIN citizenship ct
	on ct.ACCT_REF_NUM = pledge.ACCTNBR

	LEFT JOIN MRT.D_NAICS NAICS
	ON NAICS.NAICS_CD = SBA.NAICS_CODE

	LEFT JOIN (SELECT SICCODE_KEY, SICCODE 
	FROM MRT.D_SICCODE WHERE SUB_SYSTEM_ID = 'SBA') SIC
	ON SIC.SICCODE = FDBR.SIC_CODE

	LEFT JOIN (select distinct ACCT_REF_NUM from BalloonLoans_Basel_Final) Basel
	ON Basel.ACCT_REF_NUM = pledge.ACCTNBR
);
quit;


/*Final Step to adjust the format of the columns*/
data US_Agency_formats
(drop=AmortizationStartDate IndustryCode
rename=(
AmortizationStartDate_f = AmortizationStartDate
IndustryCode_format = IndustryCode)
);
format ObligationNumber;
format ObligorNumber;
format ObligorName;
format ObligorCity;
format ObligorState;
format ObligorCountry;
format MasterNoteReferenceNumber;
format MasterNoteOrigBalComm 14.2;
format MasterNoteCurrCommAm 14.2;
format MasterNoteMaturityDate;
format InterestFrequency;
format prefix_PRIN_PYMT_FREQ;
format ratio_Days_PRIN_PYMT_FREQ;
format ratio_Months_PRIN_PYMT_FREQ;
format PrincipalPaymentFrequency;
format InterestNextDueDate;
format InterestPaidThroughDate;
format PrincipalNextDueDate;
format PrincipalPaidThroughDate;
format M_NXT_PPYMT_DATE;
format GuaranteedBalance 14.2;
format NonGuaranteedBalance 14.2;
format InterestRate 5.2;
format MaturityDate;
format FXFLFlag;
format DIInternalRiskRating;
format OriginationDate;
format GuaranteedOriginalBalance 14.2;
format NonGuaranteedOriginalBalance 14.2;
format AmortizationStartDate_f 8.;
format PDUE_DAYS;
format AmortizationEndDate;
format CallReportCode;
format IndustryCode_format $10.;
format IndustryCodeType 1.;
set US_Agency;

/*ObligorNumber was having more than 30 characters long
We assigned it the ObligationNumber field*/
ObligorNumber = ObligationNumber;

AmortizationStartDate_f = input(cats(
substr(put(AmortizationStartDate, YYMMDD10.),1,4),
substr(put(AmortizationStartDate, YYMMDD10.),6,2),
substr(put(AmortizationStartDate, YYMMDD10.),9,2)
),$8.);

IF (strip(put(IndustryCode,10.)) = ".") THEN
	IndustryCode_format = "";
ELSE
	IndustryCode_format = strip(put(IndustryCode,10.));


WHERE ObligorCountry IN ("US", "");

run;

/*Dropping fields that do not apply to US Agency Guaranteed
and Exclusion of new loans*/
data PLEDGED.US_Agency_Guaranteed
(drop=DIInternalRiskRating NonGuaranteedBalance NonGuaranteedOriginalBalance
rename=(GuaranteedBalance = Balance GuaranteedOriginalBalance = OriginalBalance));
set US_Agency_formats;
	where ORIGINATIONDATE <= &batch_prev.;
run;

/*Exporting*/
%exportXLSX(PLEDGED.US_Agency_Guaranteed,
/SAS_RiskModelDev/SAS_FSB/Pledged loans/Guaranteed.xlsx,
Guaranteed);



/************Exclusions Log************/

/*Foreign Countries*/
data Exclusion_Country_Agency(keep=ObligationNumber Portfolio Reason ObligorCountry);
format ObligationNumber;
format Portfolio $50.;
format Reason $100.;
format ObligorCountry;
set US_Agency;
	Portfolio = "US Agency Guaranteed";
	Reason = "Foreign Country";
	where ObligorCountry NOT IN ("US", "");
run;

/*New Loans Exclusion*/
data Agency_Origination(keep=ObligationNumber Portfolio Reason ORIGINATIONDATE);
format ObligationNumber;
format Portfolio $50.;
format Reason $100.;
format ORIGINATIONDATE;
set US_Agency_formats;
	Portfolio = "US Agency Guaranteed";
	Reason = "New Loans";
	where ORIGINATIONDATE > &batch_prev.;
run;


/************Old Treasury Report************/
data US_Agency_Guaranteed_Old (
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
set PLEDGED.US_Agency_Guaranteed;
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
%exportXLSX(US_Agency_Guaranteed_Old,
/SAS_RiskModelDev/SAS_FSB/Pledged loans/Guaranteed_Treasury.xlsx,
Guaranteed);



/****US Agency Non Guaranteed will be reported from CRE, Constrution and Commercial******/
/*Dropping fields that do not apply to US Agency Non Guaranteed*/
/*
data PLEDGED.US_Agency_Non_Guaranteed
(drop= GuaranteedBalance GuaranteedOriginalBalance
rename=(NonGuaranteedBalance = Balance NonGuaranteedOriginalBalance = OriginalBalance));
set US_Agency_formats;
run;
*/
/*
%exportXLSX(PLEDGED.US_Agency_Non_Guaranteed,
/SAS_RiskModelDev/SAS_FSB/Pledged loans/Non_Guaranteed.xlsx,
Non_Guaranteed);
*/