
proc sql;
create table Agricultural as (
	SELECT DISTINCT
	FDBR.ACCT_REF_NUM AS ObligationNumber,
	FDBR.CUST_ADD_ID as ObligorNumber,
	FDBR.NAME_ADD_1 as ObligorName,
	pledge.SYS as Subsystem,
	FDBR.CITY as ObligorCity,
	FDBR.STATE as ObligorState,
	COUNTRY_CITIZEN_1,
	US_CITIZEN_IND,
	MDCCC.CCDESC_H10,
	MDCCC.CCDESC_H02,
	EDW_XREF.SRCE_REC_ID,
	CASE
		WHEN MDCCC.CCDESC_H10 LIKE 'RETAIL%' THEN coalesce(AFS_OBLG.COUNTRY_CITIZEN_1, EDW_XREF.SRCE_REC_ID)
		WHEN MDCCC.CCDESC_H10 LIKE 'COMMERCIAL%' THEN AFS.OB_TELEX
		WHEN MDCCC.CCDESC_H10 LIKE 'CORPORATE%' THEN AFS.OB_TELEX
		ELSE "US"
	END as ObligorCountry,
	MASTER.MASTERNOTEREFERENCENUM as MasterNoteReferenceNumber, 
	0 as CurrentCommitment,
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
	AFS.O_NET_BOOK_BALANCE,
	FDBR.CURR_BAL,
	FDBR.CURR_LINE,
	case when pledge.SYS = "CLS" AND AFS.O_NET_BOOK_BALANCE < FDBR.CURR_BAL AND AFS.O_NET_BOOK_BALANCE NOT IN (0,.) then 
			 AFS.O_NET_BOOK_BALANCE 
		 else FDBR.CURR_BAL
    end as Balance,
	FDBR.CPN_RATE as InterestRate,
	AFS.O_DURATION_CODE,
	CASE
		WHEN AFS.O_DURATION_CODE = '2' THEN 99991231
		ELSE FDBR.MAT_DATE
	END as MaturityDate,
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
		WHEN MDA1.LOAN_LINE_IND = "LINE" THEN FDBR.ORIG_LINE
		WHEN MDA1.LOAN_LINE_IND = "LOAN" THEN FDBR.ORIG_BOOK
	END as OriginalBalance,
	ORD.ORIG_DATE AS ORD_ORIG_DATE format=yymmdd10.,
	CASE
	WHEN AFS.O_DURATION_CODE = '5' THEN ORD.MAT_DATE 
	ELSE 
		CASE WHEN ORD.ORIG_DATE < 20000101 /*AND ORD.INT_PYMT_FREQ IN ('EXPL', 'M001')*/
		THEN INTNX('MONTH',ORD.ORIG_DATE,1)
		/*WHEN ORD.ORIG_DATE < 20000101 AND ORD.INT_PYMT_FREQ = 'M003' THEN INTNX('MONTH',ORD.ORIG_DATE,1)*/
		ELSE input(PUT(ORD.NXT_PPYMT_DATE, yymmdd10.), yymmdd10.) END
	END as AmortizationStartDate format=yymmdd10.,
	FDBR.PDUE_DAYS,
	CASE WHEN O_USER_CODE_3 = 'Y' THEN 1 ELSE 0 END AS BALLON_PAYMNT,
	FDBR.AMORT_DATE as AmortizationEndDate,
	FDBR.REPR_CODE,
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
	FDBR.CEILING_RATE,
	CASE
		WHEN Calculated FXFLFlag = 'FL' AND FDBR.CEILING_RATE IS NOT NULL AND FDBR.CEILING_RATE <> 0 AND FDBR.CEILING_RATE < 90 THEN FDBR.CEILING_RATE
		WHEN Calculated FXFLFlag = 'FX' THEN .
	ELSE -99
	END as InterestRateCap,
	FDBR.FLOOR_RATE,
	CASE
		WHEN Calculated FXFLFlag = 'FL' AND FDBR.FLOOR_RATE IS NOT NULL AND FDBR.FLOOR_RATE <> 0 THEN FDBR.FLOOR_RATE
		WHEN Calculated FXFLFlag = 'FX' THEN .
		ELSE -99
	END as InterestRateFloor,
	CASE WHEN COL.ACCT_REF_NUM IS NOT NULL THEN 1 ELSE 0 END as CollateralizedFlag,
	COMP_CALL as CallReportCode,
	CASE WHEN FDBR.NAME_ADD_1 LIKE '%COMPASS BAN%' THEN AFS_OBLN.OBL_NAICS ELSE AFS_OBLG.NAICS_CODE END AS AFS_NAICS,
	MFA.NAICS_KEY,
	FDBR.SIC_CODE,
	0 as IndustryCode,
	0 as IndustryCodeType,
	MDA1.MRA_LOAN_ID,
	MDA1.LOAN_LINE_IND,
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
	from PLEDGE_LOANS where CATEGORY = '705') pledge
	on FDBR.ACCT_REF_NUM = pledge.ACCTNBR

	LEFT JOIN (
		select BANK_NUMBER, OBLIGOR_NUMBER, OBLIGATION_NUMBER, O_DURATION_CODE,
		O_PREPAYMENT_PENALTY_IND, O_PREPAYMENT_PENALTY_TERM, input(O_PREPAYMENT_PENALTY_TERM,5.) as PREPAYMENT_PENALTY_TERM, OB_TELEX, O_USER_CODE_3, O_NET_BOOK_BALANCE
		from WHS.W_AFS_FLAT where BATCH_ID = &batch_WHS
	) AFS
	on cats('0001',put(input(AFS.BANK_NUMBER,4.),z4.),'00000000',						
	put(input(AFS.OBLIGOR_NUMBER,10.),z10.),							
	put(input(AFS.OBLIGATION_NUMBER,10.),z10.)) = FDBR.CIS_ACCT_ID

	LEFT JOIN (
		select OBG_NO, BK_NO, SIC_CODE, COUNTRY_CITIZEN_1, US_CITIZEN_IND,
		NAICS_CODE, SIC_CODE
		from WHS.W_AFS_OBLG where batch_id = &batch_WHS
	) AFS_OBLG	
	ON PUT(AFS_OBLG.OBG_NO, Z10.) = AFS.OBLIGOR_NUMBER
	AND cats('0',PUT(AFS_OBLG.BK_NO, Z2.)) = AFS.BANK_NUMBER

	LEFT JOIN (
		select OBG_NO, BK_NO, OBL_NAICS
		from WHS.W_AFS_OBLN where batch_id = &batch_WHS
	) AFS_OBLN	
	ON PUT(AFS_OBLN.OBG_NO, Z10.) = AFS.OBLIGOR_NUMBER

	LEFT JOIN (SELECT ACCOUNT_KEY, NAICS_KEY, POD_GRADE_CD, COMMON_COST_CENTER_KEY 
	FROM MRT.F_ACCOUNTS WHERE BATCH_ID = &batch_MRT) MFA
	ON MFA.ACCOUNT_KEY = MDA1.ACCOUNT_KEY

	LEFT JOIN (SELECT COMMON_COST_CENTER_KEY, CCDESC_H10, CCDESC_H02 
	FROM MRT.D_COMMON_COST_CENTER) MDCCC
	ON MDCCC.COMMON_COST_CENTER_KEY = MFA.COMMON_COST_CENTER_KEY

	LEFT JOIN ORDERED ORD
	ON ORD.ACCT_REF_NUM = FDBR.ACCT_REF_NUM

	LEFT JOIN (
		SELECT MASTERNOTEREFERENCENUM, ACCTNBR FROM MASTERNOTEAFS
	) MASTER
	ON MASTER.ACCTNBR = pledge.ACCTNBR

	LEFT JOIN (
		SELECT 
		ACCT_REF_NUM, 
		COL_VAL, 
		ORIG_VAL, 
		COL_TP, 
		ZIP, 
		COUNTRY, 
		COLL_TYPE_DESC
		FROM COLLATERALS_AFS AFS
	) COL
	ON COL.ACCT_REF_NUM = pledge.ACCTNBR

	LEFT JOIN citizenship ct
	on ct.ACCT_REF_NUM = pledge.ACCTNBR

	LEFT JOIN (select EDW_XREF_LKP_ID, SRCE_REC_ID, SRCE_REC_DESC
				from  EDWPRD_O.EDW_XREF_LKP
				WHERE edw_lkp_tbl_id = 100494) EDW_XREF
	ON ct.CTZN_CNTRY_ID = EDW_XREF.EDW_XREF_LKP_ID

	LEFT JOIN (select distinct ACCT_REF_NUM from BalloonLoans_Basel_Final) Basel
	ON Basel.ACCT_REF_NUM = pledge.ACCTNBR
);
quit;


proc sql;
create table MASTERNOTEAFSRESTAg AS (
	select 
	MASTERNOTEREFERENCENUM, 
	SUM(OriginalBalance) AS MASTERNOTEORIGBAL,
	SUM(CurrentCommitment) AS MASTERNOTECURRCOMMAM,
	MAX(MaturityDate) AS MASTERNOTEMATDATE 
	from (
		select 
		ObligationNumber,
		OriginalBalance,
		CurrentCommitment,
		MaturityDate
		from Agricultural
	) Ag
	JOIN MASTERNOTEAFS
	on MASTERNOTEAFS.ACCTNBR = Ag.ObligationNumber
	WHERE MASTERNOTEREFERENCENUM is not null
	group by MASTERNOTEREFERENCENUM
);
quit;


proc sql;
create table AGRICULTURAL_FINAL_P as (
	select 
	ObligationNumber,
	ObligorNumber,
	ObligorName,
	Subsystem,
	ObligorCity,
	ObligorState,
	CCDESC_H02,
	US_CITIZEN_IND,
	CCDESC_H10 as CCDESC_H10_Source,
	COUNTRY_CITIZEN_1 as COUNTRY_CITIZEN_1_Source,
	SRCE_REC_ID as SRCE_REC_ID_Source,
	ObligorCountry,
	MasterNoteReferenceNumber, 
	MASTER.MASTERNOTEORIGBAL,
	MASTER.MASTERNOTECURRCOMMAM,
	MASTER.MASTERNOTEMATDATE,
	INT_PYMT_FREQ,
	InterestFrequency,
	PRIN_PYMT_FREQ,
	PrincipalPaymentFrequency,
	InterestNextDueDate,
	InterestPaidThroughDate,
	PrincipalNextDueDate,
	PrincipalPaidThroughDate,
	M_NXT_PPYMT_DATE,
	TRAN_CLASS,
	O_NET_BOOK_BALANCE,
	CURR_BAL,
	CURR_LINE,
	Balance,
	InterestRate,
	O_DURATION_CODE,
	MaturityDate,
	FXFLFlag,
	DIInternalRiskRating,
	ORIG_DATE,
	LST_RENEW_DATE,
	OriginationDate,
	ORIG_BOOK,
	ORIG_LINE,
	case when Subsystem = "CLS" then coalesce(MASTER.MASTERNOTEORIGBAL,ORIG_BOOK)
		 else AG.OriginalBalance 
	end as OriginalBalance,
	AmortizationStartDate,
	PDUE_DAYS,
	BALLON_PAYMNT,
	CASE WHEN BALLON_PAYMNT = 1 THEN . ELSE MaturityDate END AS AmortizationEndDate,
	REPR_CODE,
	REPR_DRVE_RATE,
	InterestRateIndex,
	InterestRateSpread,
	CEILING_RATE as CEILING_RATE_Source,
	InterestRateCap,
	FLOOR_RATE as FLOOR_RATE_Source,
	InterestRateFloor,
	CollateralizedFlag,
	CallReportCode,
	CASE WHEN AFS_NAICS IS NOT NULL THEN NAICS.NAICS_KEY ELSE SIC_AFS.SICCODE_KEY END AS IndustryCode,
	CASE WHEN AFS_NAICS IS NOT NULL THEN 1
		 WHEN SIC_AFS.SICCODE_KEY IS NOT NULL THEN 2 
		 ELSE .
	END AS IndustryCodeType	,
	MRA_LOAN_ID,
	Flag_Balloon_Basel,
	CATEGORY,
	M_COMP_CALL,
	RISKCODE, 
	REMAINTERM, 
	MRGNCDE, 
	MRGNPCT

	from AGRICULTURAL AG
	left join MASTERNOTEAFSRESTAg MASTER
	ON MASTER.MASTERNOTEREFERENCENUM = AG.MasterNoteReferenceNumber
	LEFT JOIN MRT.D_NAICS NAICS
	ON NAICS.NAICS_CD = AG.AFS_NAICS
	LEFT JOIN (SELECT * FROM MRT.D_SICCODE) SIC_AFS
	ON SIC_AFS.SICCODE = AG.SIC_CODE
);
quit;


/*Final Step to adjust the format of the columns*/
data AGRICULTURAL_Formats
(drop=IndustryCode AmortizationStartDate
rename=(IndustryCode_format=IndustryCode
AmortizationStartDate_f = AmortizationStartDate)
);
format ObligationNumber;
format ObligorNumber;
format ObligorName;
format ObligorCity;
format ObligorState;
format CCDESC_H10_Source;
format COUNTRY_CITIZEN_1_Source;
format SRCE_REC_ID_Source;
format ObligorCountry;
format MasterNoteReferenceNumber;
format MASTERNOTEORIGBAL 14.2;
format MasterNoteCurrCommAm 14.2;
format MASTERNOTEMATDATE;
format InterestFrequency;
format PrincipalPaymentFrequency;
format InterestNextDueDate;
format InterestPaidThroughDate;
format PrincipalNextDueDate;
format PrincipalPaidThroughDate;
format O_NET_BOOK_BALANCE;
format Balance 14.2;
format InterestRate 5.2;
format MaturityDate;
format FXFLFlag;
format MRA_LOAN_ID;
format DIInternalRiskRating;
format OriginationDate;
format OriginalBalance 14.2;
format AmortizationStartDate_f 8.;
format PDUE_DAYS;
format AmortizationEndDate;
format InterestRateIndex;
format InterestRateSpread 6.2;
format CEILING_RATE_Source;
format InterestRateCap 6.2;
format FLOOR_RATE_Source;
format InterestRateFloor 6.2;
format CollateralizedFlag 1.;
format CallReportCode;
format IndustryCode_format $10.;
format IndustryCodeType 1.;
set AGRICULTURAL_FINAL_P;

IF (strip(put(IndustryCode,10.)) = ".") THEN
	IndustryCode_format = "";
ELSE
	IndustryCode_format = strip(put(IndustryCode,10.));

AmortizationStartDate_f = input(cats(
substr(put(AmortizationStartDate, YYMMDD10.),1,4),
substr(put(AmortizationStartDate, YYMMDD10.),6,2),
substr(put(AmortizationStartDate, YYMMDD10.),9,2)
),$8.);

/*Do not inform foreign countries*/
WHERE ObligorCountry IN ("US", "");

run;

/*Excluding new loans*/
data PLEDGED.AGRICULTURAL_FINAL;
set AGRICULTURAL_Formats;
	where ORIGINATIONDATE <= &batch_prev.;
run;


/*Exporting*/
%exportXLSX(PLEDGED.AGRICULTURAL_FINAL,
/SAS_RiskModelDev/SAS_FSB/Pledged loans/Agricultural.xlsx,
Agricultural);



/************Exclusions Log************/

/*Foreign Countries*/
data Exclusion_Country_Agri(keep=ObligationNumber Portfolio Reason ObligorCountry);
format ObligationNumber;
format Portfolio $50.;
format Reason $100.;
format ObligorCountry;
set AGRICULTURAL_FINAL_P;
	Portfolio = "Agricultural";
	Reason = "Foreign Country";
	where ObligorCountry NOT IN ("US", "");
run;

/*New Loans Exclusion*/
data Agricultural_Origination(keep=ObligationNumber Portfolio Reason ORIGINATIONDATE);
format ObligationNumber;
format Portfolio $50.;
format Reason $100.;
format ORIGINATIONDATE;
set AGRICULTURAL_Formats;
	Portfolio = "Agricultural";
	Reason = "New Loans";
	where ORIGINATIONDATE > &batch_prev.;
run;



/************Old Treasury Report************/
data Agricultural_Old (
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
set PLEDGED.AGRICULTURAL_FINAL;
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
%exportXLSX(Agricultural_Old,
/SAS_RiskModelDev/SAS_FSB/Pledged loans/Agricultural_Treasury.xlsx,
Agricultural);