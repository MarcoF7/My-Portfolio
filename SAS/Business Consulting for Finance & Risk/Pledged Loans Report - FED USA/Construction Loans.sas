
proc sql;	
create table ConstructionLoans as (	
	select 
FDBR.ACCT_REF_NUM AS ObligationNumber,
FDBR.CUST_ADD_ID as ObligorNumber,
FDBR.NAME_ADD_1 as ObligorName,
pledge.SYS as Subsystem,
FDBR.CITY as ObligorCity,
FDBR.STATE as ObligorState,
ALS.CF_PERS_CMCL_CD,
MDCCC.CCDESC_H10,
MDCCC.CCDESC_H02,
AFS_OBLG.COUNTRY_CITIZEN_1,
CASE 
	WHEN PLEDGE.SYS IN ('SBA') THEN "US"
	WHEN PLEDGE.SYS IN ('CLS') THEN 
		CASE
			WHEN MDCCC.CCDESC_H10 LIKE 'RETAIL%' THEN coalesce(AFS_OBLG.COUNTRY_CITIZEN_1, EDW_XREF.SRCE_REC_ID)
			WHEN MDCCC.CCDESC_H10 LIKE 'COMMERCIAL%' THEN AFS.OB_TELEX
			WHEN MDCCC.CCDESC_H10 LIKE 'CORPORATE%' THEN AFS.OB_TELEX
			ELSE "US"
		END
	WHEN PLEDGE.SYS IN ('ALS') THEN
		CASE
			WHEN MDCCC.CCDESC_H10 LIKE 'RETAIL%' THEN EDW_XREF.SRCE_REC_ID
			ELSE "US"
		END
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
	FDBR.prefix_PRIN_PYMT_FREQ as prefix_PRIN_PYMT_FREQ_Source,
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
FDBR.LST_PYMT_DATE as LST_PYMT_DATE_Source,
case when FDBR.NXT_IPYMT_DATE = 0 then . else FDBR.NXT_IPYMT_DATE end as InterestNextDueDate,
case when FDBR.LST_PYMT_DATE = 0 then . else FDBR.LST_PYMT_DATE end as InterestPaidThroughDate,
case when FDBR.NXT_PPYMT_DATE = 0 then . else FDBR.NXT_PPYMT_DATE end as PrincipalNextDueDate,
case when FDBR.LST_PYMT_DATE = 0 then . else FDBR.LST_PYMT_DATE end as PrincipalPaidThroughDate,
FDBR.NXT_PPYMT_DATE as M_NXT_PPYMT_DATE,
FDBR.TRAN_CLASS,
AFS.O_NET_BOOK_BALANCE,
FDBR.CURR_BAL,
FDBR.CURR_LINE,
case when pledge.SYS = "SBA" then
		 FDBR.CURR_BAL * ROUND(1-(FDBR.OPT_NBR1/100), 0.01) 
	 when pledge.SYS = "CLS" AND AFS.O_NET_BOOK_BALANCE < FDBR.CURR_BAL AND AFS.O_NET_BOOK_BALANCE NOT IN (0,.) then 
		 AFS.O_NET_BOOK_BALANCE 
	 else FDBR.CURR_BAL
end as Balance,
FDBR.CPN_RATE as InterestRate,
AFS.O_DURATION_CODE,
CASE
	WHEN AFS.O_DURATION_CODE = '2' OR ALS.RT_DURATION_CD = "D" THEN 99991231
	ELSE FDBR.MAT_DATE
END as MaturityDate,
CASE
	WHEN AFS.O_DURATION_CODE = '2' OR ALS.RT_DURATION_CD = "D" THEN 1
	ELSE 0
END as Demand_Flag,
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
CASE WHEN pledge.SYS = "SBA" THEN
	CASE 
		WHEN MDA1.LOAN_LINE_IND = "LINE" THEN ROUND(FDBR.ORIG_LINE * (1-(FDBR.OPT_NBR1/100)), 0.01) 
		WHEN MDA1.LOAN_LINE_IND = "LOAN" THEN ROUND(FDBR.ORIG_BOOK * (1-(FDBR.OPT_NBR1/100)), 0.01)
	END
ELSE
	CASE 
		WHEN MDA1.LOAN_LINE_IND = "LINE" THEN FDBR.ORIG_LINE
		WHEN MDA1.LOAN_LINE_IND = "LOAN" THEN FDBR.ORIG_BOOK
	END 
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
CASE WHEN MDA2.AMORT_CD = 'MAT' OR MDSP.SYS_PROD_CODE like '%BLN%' OR MDSP.SYS_PROD_CODE like '%BALL%' OR MDSP.SYS_PROD_CODE like '%BLLN%'
OR O_USER_CODE_3 = 'Y' THEN 1 ELSE 0 END AS BALLON_PAYMNT,
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
	WHEN Calculated FXFLFlag = 'FL' THEN FDBR.REPR_SPRD_VAL
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
COMP_CALL as CallReportCode,
COL.ZIP	 as CollateralLocationZipCode,
"" as CollateralLocationCountry,
COL.STATE as STATE_COLLATERAL,
COL.COUNTRY as COUNTRY_COLLATERAL,
MDA1.MRA_LOAN_ID,
case when Basel.ACCT_REF_NUM ne "" then 1 else 0 end as Flag_Balloon_Basel,
pledge.CATEGORY,
pledge.M_COMP_CALL,
pledge.RISKCODE, 
pledge.REMAINTERM, 
pledge.MRGNCDE, 
pledge.MRGNPCT
from
	(SELECT *, input(put(FDBR.ORIG_DATE,8.),yymmdd10.) as orig format=yymmdd10. FROM FDBR) FDBR
	
	JOIN (SELECT MRA_LOAN_ID, LOAN_LINE_IND, ACCOUNT_KEY, CIS_ACCT_ID 
	FROM MRT.D_ACCOUNTS) MDA1
	on MDA1.CIS_ACCT_ID = FDBR.CIS_ACCT_ID
	
	JOIN (select SYS, ACCTNBR, CATEGORY, M_COMP_CALL,
	RISKCODE, REMAINTERM, MRGNCDE, MRGNPCT 
	from PLEDGE_LOANS where CATEGORY = '790' OR (CATEGORY = "720" AND M_COMP_CALL = "01A2")) pledge
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
			SELECT RT_CTL1, RT_CTL2, RT_ACCT_NUM, CF_PERS_CMCL_CD, ALN_DAT_EXPIRATION, RT_DURATION_CD FROM WHS.W_ALS_FLAT WHERE BATCH_ID = &batch_WHS
	) ALS
	on cats(put(input(RT_CTL1,4.),z4.),						
	put(input(RT_CTL2,4.),z4.), '00000000',							
	RT_ACCT_NUM) = FDBR.CIS_ACCT_ID

	LEFT JOIN (
		select CCAR_PENALTY_TERM, CCAR_PREPAY_PENALTY_FLG, CCAR_BANK, CCAR_LN_NO, CCAR_CTL1 from WHS.W_ALS_CCAR where BATCH_ID  = &batch_WHS
	) ALS_CCAR
	ON cats(PUT(input(CCAR_CTL1,4.), z4.),put(input(ALS_CCAR.CCAR_BANK,4.),z4.), '000000000000', ALS_CCAR.CCAR_LN_NO) = FDBR.CIS_ACCT_ID

	LEFT JOIN (SELECT POD_GRADE_CD, ACCOUNT_KEY, SYS_PRODUCT_KEY, 
	AMORT_KEY, COMMON_COST_CENTER_KEY 
	FROM MRT.F_ACCOUNTS WHERE BATCH_ID = &batch_MRT) MFA
	ON MFA.ACCOUNT_KEY = MDA1.ACCOUNT_KEY

	LEFT JOIN (SELECT SYS_PROD_CODE, SYS_PRODUCT_KEY FROM MRT.D_SYSTEM_PRODUCT) MDSP
    ON MFA.SYS_PRODUCT_KEY = MDSP.SYS_PRODUCT_KEY

	LEFT JOIN (SELECT AMORT_CD, AMORT_KEY 
	FROM MRT.D_AMORT WHERE SUB_SYSTEM_ID = 'ALS') MDA2
    ON MFA.AMORT_KEY = MDA2.AMORT_KEY

	LEFT JOIN (SELECT CCDESC_H10, CCDESC_H02, COMMON_COST_CENTER_KEY 
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
		STATE,
		COUNTRY, 
		COLL_TYPE_DESC
		FROM COLLATERALS_AFS AFS
			UNION ALL
		SELECT 
		ACCT_REF_NUM,
		COLL_AMT AS COL_VAL,
		CO_ORIG_VAL AS ORIG_VAL,
		CO_TYPE AS COL_TP,
		ALN_PA_ZIP_CD AS ZIP,
		ALN_PA_STATE AS STATE,
		COUNTRY,
		COLL_TYPE_DESC
		FROM COLLATERALS_ALS ALS
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
create table MASTERNOTEAFSRESTCONS AS (
	select 
	MASTERNOTEREFERENCENUM, 
	SUM(OriginalBalance) AS MASTERNOTEORIGBAL,
	SUM(CurrentCommitment) AS CURRENTCOMMITMENT,
	MAX(MaturityDate) AS MASTERNOTEMATDATE
	from (
		select 
		ObligationNumber,
		OriginalBalance,
		CurrentCommitment,
		MaturityDate
		from CONSTRUCTIONLOANS
	) CONL
	JOIN MASTERNOTEAFS
	on MASTERNOTEAFS.ACCTNBR = CONL.ObligationNumber
	WHERE MASTERNOTEREFERENCENUM is not null
	group by MASTERNOTEREFERENCENUM
);
quit;

proc sql;	
create table ConstructionLoansFinal_p as (	
select 
ObligationNumber,
ObligorNumber,
ObligorName,
Subsystem,
ObligorCity,
ObligorState,
CF_PERS_CMCL_CD,
CCDESC_H10,
CCDESC_H02,
COUNTRY_CITIZEN_1,
ObligorCountry,
MasterNoteReferenceNumber,
MASTER.MASTERNOTEORIGBAL as MasterNoteOrigBalComm,
MASTER.CURRENTCOMMITMENT as MasterNoteCurrCommAm,
MASTER.MASTERNOTEMATDATE as MasterNoteMaturityDate,
INT_PYMT_FREQ,
InterestFrequency,
PRIN_PYMT_FREQ,
prefix_PRIN_PYMT_FREQ_Source,
PrincipalPaymentFrequency,
InterestNextDueDate,
LST_PYMT_DATE_Source,
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
Demand_Flag,
REPR_CODE,
FXFLFlag,
DIInternalRiskRating,
ORIG_DATE,
LST_RENEW_DATE,
OriginationDate,
ORIG_BOOK,
ORIG_LINE,
case when Subsystem = "CLS" then coalesce(MASTER.MASTERNOTEORIGBAL, ORIG_BOOK)
	 else CONS.OriginalBalance 
end as OriginalBalance,
AmortizationStartDate,
PDUE_DAYS,
BALLON_PAYMNT,
CASE WHEN BALLON_PAYMNT = 1 THEN . ELSE MaturityDate END AS AmortizationEndDate,
REPR_DRVE_RATE,
InterestRateIndex,
InterestRateSpread,
CEILING_RATE,
InterestRateCap,
FLOOR_RATE as FLOOR_RATE_Source,
InterestRateFloor,
CallReportCode,
CollateralLocationZipCode,
CollateralLocationCountry,
STATE_COLLATERAL,
COUNTRY_COLLATERAL,
MRA_LOAN_ID,
Flag_Balloon_Basel,
CATEGORY,
M_COMP_CALL,
RISKCODE, 
REMAINTERM, 
MRGNCDE, 
MRGNPCT
from CONSTRUCTIONLOANS CONS
left join MASTERNOTEAFSRESTCONS MASTER
ON MASTER.MASTERNOTEREFERENCENUM = CONS.MasterNoteReferenceNumber
);
quit;


data Construction_Formats
(drop=AmortizationStartDate CollateralLocationZipCode
rename=(AmortizationStartDate_f = AmortizationStartDate
CollateralLocationZipCode2 = CollateralLocationZipCode)); 
format ObligationNumber;
format ObligorNumber;
format ObligorName;
format Subsystem;
format ObligorCity;
format ObligorState;
format CF_PERS_CMCL_CD;
format CCDESC_H10;
format CCDESC_H02;
format COUNTRY_CITIZEN_1;
format ObligorCountry;
format MasterNoteReferenceNumber;
format MasterNoteOrigBalComm 14.2;
format MasterNoteCurrCommAm 14.2;
format MasterNoteMaturityDate;
format INT_PYMT_FREQ;
format InterestFrequency;
format PRIN_PYMT_FREQ;
format prefix_PRIN_PYMT_FREQ_Source;
format PrincipalPaymentFrequency;
format InterestNextDueDate;
format LST_PYMT_DATE_Source;
format InterestPaidThroughDate;
format PrincipalNextDueDate;
format PrincipalPaidThroughDate;
format M_NXT_PPYMT_DATE;
format TRAN_CLASS;
format O_NET_BOOK_BALANCE;
format CURR_BAL;
format CURR_LINE;
format Balance 14.2;
format InterestRate 5.2;
format O_DURATION_CODE;
format MaturityDate;
format Demand_Flag;
format REPR_CODE;
format FXFLFlag;
format DIInternalRiskRating;
format ORIG_DATE;
format LST_RENEW_DATE;
format OriginationDate;
format ORIG_BOOK;
format ORIG_LINE;
format OriginalBalance 14.2;
format AmortizationStartDate_f 8.;
format PDUE_DAYS;
format BALLON_PAYMNT;
format AmortizationEndDate;
format REPR_DRVE_RATE;
format InterestRateIndex;
format InterestRateSpread 6.2;
format CEILING_RATE;
format InterestRateCap 6.2;
format FLOOR_RATE_Source;
format InterestRateFloor 6.2;
format CallReportCode;
format CollateralLocationZipCode2 $5.;
format CollateralLocationCountry;
format STATE_COLLATERAL;
format COUNTRY_COLLATERAL;
format MRA_LOAN_ID;
set ConstructionLoansFinal_p;

IF input(substr(CollateralLocationZipCode,1,5),5.) = . THEN
	CollateralLocationZipCode2 = "";
ELSE
	CollateralLocationZipCode2 = substr(CollateralLocationZipCode,1,5);

IF Subsystem = "SBA" THEN
/*ObligorNumber was having more than 30 characters long for SBA
We assigned it the ObligationNumber field*/
	ObligorNumber = ObligationNumber;

AmortizationStartDate_f = input(cats(
substr(put(AmortizationStartDate, YYMMDD10.),1,4),
substr(put(AmortizationStartDate, YYMMDD10.),6,2),
substr(put(AmortizationStartDate, YYMMDD10.),9,2)
),$8.);

/*Do not inform foreign countries*/
WHERE ObligorCountry IN ("US", "");

run;

/*Excluding new loans*/
data PLEDGED.ConstructionLoansFinal;
set Construction_Formats;
	where ORIGINATIONDATE <= &batch_prev.;
run;


/*Exporting*/
%exportXLSX(PLEDGED.ConstructionLoansFinal,
/SAS_RiskModelDev/SAS_FSB/Pledged loans/ConstructionLoans.xlsx,
Construction);


/************Exclusions Log************/

/*Foreign Countries*/
data Exclusion_Country_Constr(keep=ObligationNumber Portfolio Reason ObligorCountry);
format ObligationNumber;
format Portfolio $50.;
format Reason $100.;
format ObligorCountry;
set ConstructionLoansFinal_p;
	Portfolio = "Construction";
	Reason = "Foreign Country";
	where ObligorCountry NOT IN ("US", "");
run;

/*New Loans Exclusion*/
data Construction_Origination(keep=ObligationNumber Portfolio Reason ORIGINATIONDATE);
format ObligationNumber;
format Portfolio $50.;
format Reason $100.;
format ORIGINATIONDATE;
set Construction_Formats;
	Portfolio = "Construction";
	Reason = "New Loans";
	where ORIGINATIONDATE > &batch_prev.;
run;


/************Old Treasury Report************/
data ConstructionLoans_Old (
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
set PLEDGED.ConstructionLoansFinal;
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
%exportXLSX(ConstructionLoans_Old,
/SAS_RiskModelDev/SAS_FSB/Pledged loans/ConstructionLoans_Treasury.xlsx,
Construction);