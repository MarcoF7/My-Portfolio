
proc sql;	
create table SecuredConsumer as (	
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
FDBR.NXT_IPYMT_DATE as NXT_IPYMT_DATE_Source,
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
FDBR.ORIG_DATE,
FDBR.LST_RENEW_DATE,
CASE
	WHEN FDBR.LST_RENEW_DATE = 0 OR FDBR.LST_RENEW_DATE > &batch_WHS. THEN FDBR.ORIG_DATE
	ELSE FDBR.LST_RENEW_DATE 
END as OriginationDate,
FDBR.TRAN_CLASS,
FDBR.ORIG_BOOK,
FDBR.ORIG_LINE,
CASE 
	WHEN MDA1.LOAN_LINE_IND = "LINE" THEN FDBR.ORIG_LINE
	WHEN MDA1.LOAN_LINE_IND = "LOAN" THEN FDBR.ORIG_BOOK
END as OriginalBalance,
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
FDBR.REV_FLAG,
MDPT.PROCESS_TYPE_CD,
ALS.ALN_DAT_EXPIRATION as DrawPeriodEndDate,
ALN_DAT_EXPIRATION,
COL.COLL_TYPE_DESC as collateral_type_desc,
CASE 
	WHEN COL.COLL_TYPE_DESC LIKE ("AUTO-NEW%") OR
		 COL.COLL_TYPE_DESC IN 
		("AIRCRAFT","AUTO-INDIRECT $5 LC (OLD-NOT USED)", "AUTOMOBILE", "TRAVEL TRAILER", "MOTORCYCLE",
		"NEW AUTO - DEALER COMML","NEW AUTO - DEALER INDIRECT") THEN 1
	WHEN COL.COLL_TYPE_DESC LIKE ("AUTO-USED%") OR
		 COL.COLL_TYPE_DESC LIKE ("AUTO - USED%") OR
		 COL.COLL_TYPE_DESC LIKE ("USED AUTO%") OR
		 COL.COLL_TYPE_DESC IN ("AUTOMOBILE-USED") THEN	2
	WHEN COL.COLL_TYPE_DESC = "BOAT" THEN 3
	WHEN COL.COLL_TYPE_DESC IN 
		("ACCOUNTS RECEIVABLE", "ACCTS REC & INVENT ABL DPT", "ACCTS RECEIVBLE & INVENTRY",
		 "OIL OR MINING PROD PMTS-U.S.", "OTHR STOCK (NON-MARKETABL)", "OVER-THE-COUNTER STOCK",
		 "SAVINGS ACCOUNT-OTHER BANK", "SAVINGS ACCOUNT-OUR BANK", "STOCK OF OTHER BANKS 5%+",
		 "STOCK OF OTHER BANKS < 5%", "TRUST ACCOUNT ASSIGNMENT", "CASH VALUE LIFE INSURANCE",
		 "CERTIF OF DEPOSIT-OTHR BNK", "CERTIF OF DEPOSIT-OUR BANK", "COMPASS BANCSHARES STOCK",
		 "FACE VALUE LIFE INSURANCE", "LISTED STOCK", "MUTUAL FUNDS") THEN 5
	WHEN COL.COLL_TYPE_DESC IN 
		("BLANKET LIEN ON ALL ASSETS", "OFFICE EQUIPMENT", "OTH COMML BLDG", "OTHER COLLATERAL",
		"OTHER COMMERCIAL BLDG.", "OTHER CONSUMER GOODS", "PRODUCTION EQUIPMENT", "SHOPPING CENTER", 
		"SINGLE RETAIL ESTABLISHMENT", "UNIMPROVED 1-4 FAM", "UNIMPROVED COMML", "UNIMPROVED MULTI-FAMILY", 
		"UNSECURED", "UNSECURED W/GUARANTOR/COSIGNER", "WAREHOUSE", "MOBILE HOME", "FARM EQUIPMENT",
		"UNKNOWN", "!UNKNOWN") THEN 6
	WHEN COL.COLL_TYPE_DESC IN 
		("1-4 FAM 1ST MTG" ,"1-4 FAM 2ND MTG" ,"APARTMENT BLDG") THEN 7
	END as CollateralType,


HLA.GROUP_FUNDED_AMT,
FDBR.CURR_BAL as Balance2,
HLA.GROUP_CURR_COLL_VALUE,
HLA.CURR_COLL_VALUE,
COL.COL_VAL,
CASE WHEN pledge.SYS = 'CLS' THEN COALESCE(HLA.GROUP_FUNDED_AMT, FDBR.CURR_BAL) ELSE FDBR.CURR_BAL END AS LOAN_BALANCE,
CASE WHEN pledge.SYS = 'CLS' THEN 
	CASE WHEN HLA.GROUP_FUNDED_AMT IS NOT NULL THEN HLA.GROUP_CURR_COLL_VALUE ELSE HLA.CURR_COLL_VALUE END
	 WHEN pledge.SYS = 'ALS' THEN COL.COL_VAL 
END AS PROPERTY_VALUE,
Calculated OriginalBalance as CalcOriginalBalance,
HLA.GROUP_ORIG_FUNDED_AMT,
HLA.GROUP_CK_MTHLY_ORIG_VALUE,
COL.ORIG_VAL,
CASE WHEN pledge.SYS = 'CLS' THEN HLA.GROUP_ORIG_FUNDED_AMT ELSE Calculated OriginalBalance END AS LOAN_BALANCE_ORIGINAL,
CASE WHEN pledge.SYS = 'CLS' THEN HLA.GROUP_CK_MTHLY_ORIG_VALUE
	 WHEN pledge.SYS = 'ALS' THEN COL.ORIG_VAL 
END AS PROPERTY_VALUE_ORIGINAL,
0 as MostRecentLTVCLTV,
/*COL.COL_EFF_DT as DateofMostRecentLTVCLTV,*/
. as DateofMostRecentLTVCLTV,
FDBR.PROD_CODE,
input(put(FDBR.MAT_DATE,8.),yymmdd10.) as mat_date_format format=yymmdd10.,
ALS.RT_USER_GRP4_CR_SCORE_3 as RT_USER_GRP4_CR_SCORE_3_Source,
case when substr(ALS.RT_USER_GRP4_CR_SCORE_3,1,1) NE "0" AND length(ALS.RT_USER_GRP4_CR_SCORE_3) = 4 then 
		.
	 else  
	 	input(substr(ALS.RT_USER_GRP4_CR_SCORE_3,max(1,length(ALS.RT_USER_GRP4_CR_SCORE_3) - 2)), 3.) 
end as MostRecentCreditBureauScore format = 3.,
ALS2.ALN_DAT_REFR_FICO as ALN_DAT_REFR_FICO_Source,
input(ALS2.ALN_DAT_REFR_FICO, 8.) as DateMostRecCreditBurScore,
ALS.RT_USER_GRP3_CR_SCORE_2 as RT_USER_GRP3_CR_SCORE_2_Source,
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
	from PLEDGE_LOANS where CATEGORY = '741') pledge
	on FDBR.ACCT_REF_NUM = pledge.ACCTNBR

	LEFT JOIN (
		select BANK_NUMBER, OBLIGOR_NUMBER, OBLIGATION_NUMBER, O_DURATION_CODE, O_CURRENT_FICO, OB_FICO_DT, OB_TELEX 
		from WHS.W_AFS_FLAT where BATCH_ID = &batch_WHS.
	) AFS
	on cats('0001',put(input(AFS.BANK_NUMBER,4.),z4.),'00000000',						
	put(input(AFS.OBLIGOR_NUMBER,10.),z10.),							
	put(input(AFS.OBLIGATION_NUMBER,10.),z10.)) = FDBR.CIS_ACCT_ID	

	LEFT JOIN (
		select OBG_NO, BK_NO, SIC_CODE, COUNTRY_CITIZEN_1, US_CITIZEN_IND,
		NAICS_CODE, SIC_CODE
		from WHS.W_AFS_OBLG where batch_id = &batch_WHS.
	) AFS_OBLG	
	ON PUT(AFS_OBLG.OBG_NO, Z10.) = AFS.OBLIGOR_NUMBER

	LEFT JOIN (
		SELECT RT_CTL1, RT_CTL2, RT_ACCT_NUM, CF_PERS_CMCL_CD, ALN_DAT_EXPIRATION, RT_USER_GRP4_CR_SCORE_3, RT_USER_GRP3_CR_SCORE_2, RT_DURATION_CD 
		FROM WHS.W_ALS_FLAT WHERE BATCH_ID = &batch_WHS.
	) ALS
	on cats(put(input(ALS.RT_CTL1,4.),z4.),						
	put(input(ALS.RT_CTL2,4.),z4.), '00000000',							
	ALS.RT_ACCT_NUM) = FDBR.CIS_ACCT_ID

	LEFT JOIN (
		SELECT RT_CTL1, RT_CTL2, RT_ACCT_NUM, ALN_DAT_REFR_FICO 
		FROM WHS.W_ALS_FLAT2 WHERE BATCH_ID = &batch_WHS.
	) ALS2
	on cats(put(input(ALS2.RT_CTL1,4.),z4.),						
	put(input(ALS2.RT_CTL2,4.),z4.), '00000000',							
	ALS2.RT_ACCT_NUM) = FDBR.CIS_ACCT_ID


	LEFT JOIN (
		select CCAR_PENALTY_TERM, CCAR_PREPAY_PENALTY_FLG, CCAR_BANK, CCAR_LN_NO, CCAR_CTL1 from WHS.W_ALS_CCAR where BATCH_ID  = &batch_WHS.
	) ALS_CCAR
	ON cats(PUT(input(CCAR_CTL1,4.), z4.),put(input(ALS_CCAR.CCAR_BANK,4.),z4.), '000000000000', ALS_CCAR.CCAR_LN_NO) = FDBR.CIS_ACCT_ID

	LEFT JOIN (SELECT ACCOUNT_KEY, PROCESS_TYPE_KEY, COMMON_COST_CENTER_KEY 
	FROM MRT.F_ACCOUNTS WHERE BATCH_ID = &batch_MRT.) MFA
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

	LEFT JOIN (
		SELECT 
		ACCT_REF_NUM, 
		COL_VAL, 
		ORIG_VAL, 
		COL_TP, 
		ZIP, 
		COUNTRY, 
		COLL_TYPE_DESC,
		COL_EFF_DT
		FROM COLLATERALS_AFS AFS
			UNION ALL
		SELECT 
		ACCT_REF_NUM,
		COLL_AMT AS COL_VAL,
		CO_ORIG_VAL AS ORIG_VAL,
		CO_TYPE AS COL_TP,
		ALN_PA_ZIP_CD AS ZIP,
		COUNTRY,
		COLL_TYPE_DESC,
		. AS COL_EFF_DT
		FROM COLLATERALS_ALS ALS
	) COL
	ON COL.ACCT_REF_NUM = pledge.ACCTNBR

	LEFT JOIN (SELECT ACCT_REF_NUM, CTZN_CNTRY_ID FROM citizenship) ct
	on ct.ACCT_REF_NUM = pledge.ACCTNBR

	LEFT JOIN (SELECT CHILD_KEY, 
					GROUP_FUNDED_AMT, 
					GROUP_CURR_COLL_VALUE, 
					CURR_COLL_VALUE, 
					GROUP_ORIG_FUNDED_AMT, 
					GROUP_CK_MTHLY_ORIG_VALUE
				FROM HST.STG_AFS_HIER_VALUES
	) HLA
	ON MDA1.ACCOUNT_KEY = HLA.CHILD_KEY

	LEFT JOIN (select EDW_XREF_LKP_ID, SRCE_REC_ID, SRCE_REC_DESC
				from  EDWPRD_O.EDW_XREF_LKP
				WHERE edw_lkp_tbl_id = 100494) EDW_XREF
	ON ct.CTZN_CNTRY_ID = EDW_XREF.EDW_XREF_LKP_ID

	LEFT JOIN (select distinct ACCT_REF_NUM from BalloonLoans_Basel_Final) Basel
	ON Basel.ACCT_REF_NUM = pledge.ACCTNBR
);	
quit;	


proc sql;	
create table SecuredConsumerFinal_p as (	
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
	INT_PYMT_FREQ,
	InterestFrequency,
	PRIN_PYMT_FREQ,
	PrincipalPaymentFrequency,
	NXT_IPYMT_DATE_Source,
	InterestNextDueDate,
	InterestPaidThroughDate,
	PrincipalNextDueDate,
	PrincipalPaidThroughDate,
	M_NXT_PPYMT_DATE,
	CURR_BAL,
	CURR_LINE,
	Balance,
	InterestRate,
	O_DURATION_CODE,
	MaturityDate,
	Demand_Flag,
	FXFLFlag,
	ORIG_DATE,
	LST_RENEW_DATE,
	OriginationDate,
	TRAN_CLASS,
	ORIG_BOOK,
	ORIG_LINE,
	OriginalBalance,
	REPR_CODE,
	REPR_DRVE_RATE,
	InterestRateIndex,
	InterestRateSpread,
	CEILING_RATE,
	InterestRateCap,
	FLOOR_RATE,
	InterestRateFloor,
	REV_FLAG as Revolving,
	PROD_CODE,
	CASE 
	WHEN Subsystem = 'ALS' AND REV_FLAG = 'R' AND PROD_CODE <> 'CPLC' THEN 2
	WHEN Subsystem = 'ALS' AND REV_FLAG = 'R' AND PROD_CODE = 'CPLC' THEN 3
	WHEN Subsystem = 'ALS' AND REV_FLAG = 'N' AND PROD_CODE <> 'CPLC' THEN 4
	WHEN Subsystem = 'ALS' AND REV_FLAG = 'N' AND PROD_CODE = 'CPLC' THEN 5
	ELSE 1
	END AS DrawdownType,
	CASE 
	WHEN Calculated DrawdownType <> 1 and Subsystem = 'ALS' THEN 
		coalesce(input(ALN_DAT_EXPIRATION,yymmdd10.), mat_date_format) 
	END AS DrawPeriodEndDate format=yymmdd10.,
	collateral_type_desc,
	CollateralType,
	GROUP_FUNDED_AMT,
	Balance2,
	GROUP_CURR_COLL_VALUE,
	CURR_COLL_VALUE,
	COL_VAL,
	LOAN_BALANCE,
	PROPERTY_VALUE,
	CalcOriginalBalance,
	GROUP_ORIG_FUNDED_AMT,
	GROUP_CK_MTHLY_ORIG_VALUE,
	ORIG_VAL,
	/*CASE WHEN PROPERTY_VALUE = 0 THEN . ELSE LOAN_BALANCE/PROPERTY_VALUE END as MostRecentLTVCLTV,*/
	. as MostRecentLTVCLTV,
	/*CASE WHEN Calculated MostRecentLTVCLTV IS NOT NULL THEN DateofMostRecentLTVCLTV ELSE . END AS DateofMostRecentLTVCLTV format=datetime20.,*/
	. as DateofMostRecentLTVCLTV,
	LOAN_BALANCE_ORIGINAL as LOAN_BALANCE_ORIGINAL_Source,
	PROPERTY_VALUE_ORIGINAL as PROPERTY_VALUE_ORIGINAL_Source,
	CASE WHEN PROPERTY_VALUE_ORIGINAL = 0 THEN . ELSE LOAN_BALANCE_ORIGINAL/PROPERTY_VALUE_ORIGINAL END as LTVCLTVatOrigination,
	RT_USER_GRP4_CR_SCORE_3_Source,
	MostRecentCreditBureauScore,
	ALN_DAT_REFR_FICO_Source,
	DateMostRecCreditBurScore,
	RT_USER_GRP3_CR_SCORE_2_Source,
	CreditBureauScoreAtOrigination,
	CallReportCode,
	MRA_LOAN_ID,
	Flag_Balloon_Basel,
	PDUE_DAYS,
	CATEGORY,
	M_COMP_CALL,
	RISKCODE, 
	REMAINTERM, 
	MRGNCDE, 
	MRGNPCT
	from SecuredConsumer
	/*Do not inform the Blanks Collateral Type for Now*/
	where CollateralType NE .
);
quit;


data Secured_Formats(
drop=DrawPeriodEndDate
rename= (DrawPeriodEndDate_f = DrawPeriodEndDate)
);
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
format INT_PYMT_FREQ;
format InterestFrequency;
format PRIN_PYMT_FREQ;
format PrincipalPaymentFrequency;
format NXT_IPYMT_DATE_Source;
format InterestNextDueDate;
format InterestPaidThroughDate;
format PrincipalNextDueDate;
format PrincipalPaidThroughDate;
format M_NXT_PPYMT_DATE;
format CURR_BAL;
format CURR_LINE;
format Balance 14.2;
format InterestRate 5.2;
format O_DURATION_CODE;
format MaturityDate;
format Demand_Flag;
format FXFLFlag;
format ORIG_DATE;
format LST_RENEW_DATE;
format OriginationDate;
format TRAN_CLASS;
format ORIG_BOOK;
format ORIG_LINE;
format OriginalBalance 14.2;
format REPR_CODE;
format REPR_DRVE_RATE;
format InterestRateIndex;
format InterestRateSpread 6.2;
format CEILING_RATE;
format InterestRateCap 6.2;
format FLOOR_RATE;
format InterestRateFloor 6.2;
format REV_FLAG as Revolving;
format PROD_CODE;
format DrawdownType;
format DrawPeriodEndDate_f 8.;
format collateral_type_desc;
format CollateralType;
format GROUP_FUNDED_AMT;
format Balance2;
format GROUP_CURR_COLL_VALUE;
format CURR_COLL_VALUE;
format COL_VAL;
format LOAN_BALANCE;
format PROPERTY_VALUE;
format CalcOriginalBalance;
format GROUP_ORIG_FUNDED_AMT;
format GROUP_CK_MTHLY_ORIG_VALUE;
format ORIG_VAL;
format MostRecentLTVCLTV 6.2;
format DateofMostRecentLTVCLTV;
format LOAN_BALANCE_ORIGINAL_Source;
format PROPERTY_VALUE_ORIGINAL_Source;
format LTVCLTVatOrigination 6.2;
format RT_USER_GRP4_CR_SCORE_3_Source;
format MostRecentCreditBureauScore;
format ALN_DAT_REFR_FICO_Source;
format DateMostRecCreditBurScore;
format RT_USER_GRP3_CR_SCORE_2_Source;
format CreditBureauScoreAtOrigination;
format CallReportCode;
format PDUE_DAYS;
set SecuredConsumerFinal_p;

DrawPeriodEndDate_f = input(cats(
substr(put(DrawPeriodEndDate, YYMMDD10.),1,4),
substr(put(DrawPeriodEndDate, YYMMDD10.),6,2),
substr(put(DrawPeriodEndDate, YYMMDD10.),9,2)
),$8.);


/*Do not inform foreign countries*/
WHERE ObligorCountry IN ("US", "");

run;

/*Excluding new loans*/
data PLEDGED.SecuredConsumerFinal;
set Secured_Formats;
	where ORIGINATIONDATE <= &batch_prev.;
run;

/*Exporting*/
%exportXLSX(PLEDGED.SECUREDCONSUMERFINAL,
/SAS_RiskModelDev/SAS_FSB/Pledged loans/SecuredConsumer.xlsx,
SecuredConsumer);


/************Exclusions Log************/

/*Collateral Type Blanks*/
data Exclusion_Collat_Sec(keep=ObligationNumber Portfolio Reason collateral_type_desc Balance);
format ObligationNumber;
format Portfolio $50.;
format Reason $100.;
format collateral_type_desc;
format Balance;
set SecuredConsumer;
	Portfolio = "Secured Consumer";
	Reason = "Blank Collateral Type";
	where CollateralType = .;
run;

/*Exporting*/
%exportXLSX(Exclusion_Collat_Sec,
/SAS_RiskModelDev/SAS_FSB/Pledged loans/Exclusions_Log.xlsx,
Secured_Collat_Blank);


/*Foreign Countries*/
data Exclusion_Country_Sec(keep=ObligationNumber Portfolio Reason ObligorCountry);
format ObligationNumber;
format Portfolio $50.;
format Reason $100.;
format ObligorCountry;
set SecuredConsumerFinal_p;
	Portfolio = "Secured Consumer";
	Reason = "Foreign Country";
	where ObligorCountry NOT IN ("US", "");
run;

/*New Loans Exclusion*/
data Secured_Origination(keep=ObligationNumber Portfolio Reason ORIGINATIONDATE);
format ObligationNumber;
format Portfolio $50.;
format Reason $100.;
format ORIGINATIONDATE;
set Secured_Formats;
	Portfolio = "Secured Consumer";
	Reason = "New Loans";
	where ORIGINATIONDATE > &batch_prev.;
run;


/************Old Treasury Report************/
data SecuredConsumer_Old (
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
set PLEDGED.SECUREDCONSUMERFINAL;
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
%exportXLSX(SecuredConsumer_Old,
/SAS_RiskModelDev/SAS_FSB/Pledged loans/SecuredConsumer_Treasury.xlsx,
SecuredConsumer);