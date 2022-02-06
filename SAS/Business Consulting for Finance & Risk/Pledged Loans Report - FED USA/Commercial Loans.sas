
proc sql;
create table Commercial_Loans as (
	SELECT DISTINCT
	FDBR.ACCT_REF_NUM AS ObligationNumber,
	FDBR.CUST_ADD_ID as ObligorNumber,
	FDBR.NAME_ADD_1 as ObligorName,
	pledge.SYS as Subsystem,
	FDBR.CITY as ObligorCity,
	FDBR.STATE as ObligorState,
	COUNTRY_CITIZEN_1,
	US_CITIZEN_IND,
	ALS.CF_PERS_CMCL_CD,
	MDCCC.CCDESC_H10,
	MDCCC.CCDESC_H02,
	EDW_XREF.SRCE_REC_ID,
	CASE 
		WHEN PLEDGE.SYS IN ('DFP', 'SBA') THEN 'US'
		ELSE
		
			CASE WHEN PLEDGE.SYS IN ('CLS') THEN 
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
				END
				END as ObligorCountry,
	MASTER.MASTERNOTEREFERENCENUM as MasterNoteReferenceNumber, 
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
	FDBR.LST_PYMT_DATE as LST_PYMT_DATE_Source,
	case when FDBR.NXT_IPYMT_DATE = 0 then . else FDBR.NXT_IPYMT_DATE end as InterestNextDueDate,
	case when FDBR.LST_PYMT_DATE = 0 then . else FDBR.LST_PYMT_DATE end as InterestPaidThroughDate,
	case when FDBR.NXT_PPYMT_DATE = 0 then . else FDBR.NXT_PPYMT_DATE end as PrincipalNextDueDate,
	case when FDBR.LST_PYMT_DATE = 0 then . else FDBR.LST_PYMT_DATE end as PrincipalPaidThroughDate,
	FDBR.NXT_PPYMT_DATE as M_NXT_PPYMT_DATE,
	AFS.O_NET_BOOK_BALANCE,
	FDBR.CURR_BAL,
	FDBR.CURR_LINE,
	case when pledge.SYS = "SBA" then
		 	FDBR.CURR_BAL * ROUND(1-(FDBR.OPT_NBR1/100), 0.01)
		 when pledge.SYS = "CLS" AND AFS.O_NET_BOOK_BALANCE < FDBR.CURR_BAL AND AFS.O_NET_BOOK_BALANCE NOT IN (0,.) then 
			AFS.O_NET_BOOK_BALANCE 
		 else 
			FDBR.CURR_BAL
    end as Balance,
	FDBR.CPN_RATE as InterestRate,
	AFS.O_DURATION_CODE,
	CASE
		WHEN (AFS.O_DURATION_CODE = '2' OR 
			 (pledge.SYS = 'DFP' AND (FDBR.NAME_ADD_1 LIKE '%(D)%' OR FDBR.NAME_ADD_1 LIKE '%(D%')) OR
			  ALS.RT_DURATION_CD = "D") THEN 99991231
		ELSE FDBR.MAT_DATE
	END as MaturityDate,
	CASE WHEN (AFS.O_DURATION_CODE = '2' OR 
			 (pledge.SYS = 'DFP' AND (FDBR.NAME_ADD_1 LIKE '%(D)%' OR FDBR.NAME_ADD_1 LIKE '%(D%')) OR
			  ALS.RT_DURATION_CD = "D") THEN 1
		ELSE 0
	END as Demand_Flag,
	CASE
		WHEN FDBR.REPR_CODE = 'FM' THEN 'FX'
		ELSE 'FL'
	END as FXFLFlag,
	MFA.ACCOUNT_KEY,
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
	FDBR.CURR_LINE as CurrentCommitment,
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
	FDBR.REPR_CODE,
	FDBR.REPR_DRVE_RATE,
	input(put(FDBR.MAT_DATE,8.),yymmdd10.) as mat_date_format format=yymmdd10.,
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
	FDBR.PROD_CODE,
	INPUT(ALS.ALN_DAT_EXPIRATION,yymmdd10.) as ALN_DAT_EXPIRATION format=yymmdd10.,
	input(put(INTNX('MONTH',FDBR.orig,48),yymmdd10.),yymmdd10.) as DRAW_PERIOD_SBA format=yymmdd10.,
	CASE WHEN Calculated DRAW_PERIOD_SBA < &_processing_date. then 'N' else 'Y' END AS DRAW_PERIOD_SBA_IND,
	-99 as ResidualValue,
	CASE WHEN COL.ACCT_REF_NUM IS NOT NULL THEN 1 ELSE 0 END as CollateralizedFlag,
	COMP_CALL as CallReportCode,
	AFS.OBLIGOR_NUMBER,
	CASE WHEN FDBR.NAME_ADD_1 LIKE '%COMPASS BAN%' THEN AFS_OBLN.OBL_NAICS ELSE AFS_OBLG.NAICS_CODE END AS AFS_NAICS,
	FDBR.SIC_CODE,
	MFA.NAICS_KEY AS NAICS_MRT,
	MFA.SICCODE_KEY,
	CASE WHEN SUBSYSTEM = 'CLS' THEN Calculated AFS_NAICS
	WHEN SUBSYSTEM = 'ALS' THEN ALS.CF_SMSA_CODE
	WHEN SUBSYSTEM = 'DFP' THEN '441110'
	WHEN SUBSYSTEM = 'SBA' THEN SBA.NAICS_CODE
	END AS NAICS,
	MDA1.MRA_LOAN_ID,
	case when Basel.ACCT_REF_NUM ne "" then 1 else 0 end as Flag_Balloon_Basel,
	MFA.SYNDICATED_FROM_ACCOUNT_KEY,
	MDPT.SYN_PARTC_CD,
	CASE 
	WHEN pledge.SYS = "SBA" THEN
		CASE WHEN Synd.sold_from_cis_acct_id NE "" THEN "Y" 
			ELSE "N" END
	ELSE
		/*
		CASE WHEN FDBR.TRAN_CLASS = "SYN" THEN "Y" 
			ELSE "N" END
		*/
		CASE WHEN MFA.SYNDICATED_FROM_ACCOUNT_KEY > 0 then "Y" 
			else "N" end
	END AS Syndication_Flag,
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
	from PLEDGE_LOANS where CATEGORY = '710' OR (CATEGORY = "720" AND M_COMP_CALL = "04A0")) pledge
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

	LEFT JOIN (
		SELECT CIS_ACCT_ID, NAICS_CODE, SIC_CODE FROM WHS.W_SBA_FLAT WHERE BATCH_ID = &batch_WHS
	) SBA
	ON SBA.CIS_ACCT_ID = MDA1.CIS_ACCT_ID

	LEFT JOIN (
		SELECT RT_CTL1, RT_CTL2, RT_ACCT_NUM, CF_PERS_CMCL_CD, ALN_DAT_EXPIRATION, CF_SMSA_CODE, RT_DURATION_CD FROM WHS.W_ALS_FLAT WHERE BATCH_ID = &batch_WHS
	) ALS
	on cats(put(input(RT_CTL1,4.),z4.),						
	put(input(RT_CTL2,4.),z4.), '00000000',							
	RT_ACCT_NUM) = FDBR.CIS_ACCT_ID

	LEFT JOIN (SELECT SICCODE_KEY, NAICS_KEY, POD_GRADE_CD, ACCOUNT_KEY,
	COMMON_COST_CENTER_KEY, PROCESS_TYPE_KEY, SYS_PRODUCT_KEY, AMORT_KEY,
	SYNDICATED_FROM_ACCOUNT_KEY 
	FROM MRT.F_ACCOUNTS WHERE BATCH_ID = &batch_MRT) MFA
	ON MFA.ACCOUNT_KEY = MDA1.ACCOUNT_KEY

	LEFT JOIN (SELECT PROCESS_TYPE_CD, SUB_SYSTEM_ID, PROCESS_TYPE_KEY, SYN_PARTC_CD 
	FROM MRT.D_PROCESS_TYPE) MDPT
	ON MDPT.PROCESS_TYPE_KEY = MFA.PROCESS_TYPE_KEY
 	AND pledge.SYS = MDPT.SUB_SYSTEM_ID

	LEFT JOIN (SELECT SYS_PROD_CODE, SYS_PRODUCT_KEY 
	FROM MRT.D_SYSTEM_PRODUCT) MDSP
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
		COUNTRY,
		COLL_TYPE_DESC
		FROM COLLATERALS_ALS ALS

			UNION ALL

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

	LEFT JOIN (SELECT ACCT_REF_NUM, CTZN_CNTRY_ID FROM citizenship) ct
	on ct.ACCT_REF_NUM = pledge.ACCTNBR

	LEFT JOIN (select EDW_XREF_LKP_ID, SRCE_REC_ID, SRCE_REC_DESC
				from  EDWPRD_O.EDW_XREF_LKP
				WHERE edw_lkp_tbl_id = 100494) EDW_XREF
	ON ct.CTZN_CNTRY_ID = EDW_XREF.EDW_XREF_LKP_ID

	LEFT JOIN (select distinct ACCT_REF_NUM from BalloonLoans_Basel_Final) Basel
	ON Basel.ACCT_REF_NUM = pledge.ACCTNBR

	LEFT JOIN Syndicated_SBA Synd
	ON compress(Synd.sold_from_cis_acct_id) = compress(FDBR.CIS_ACCT_ID)
);
quit;


proc sql;
create table MASTERNOTEAFSRESTCL AS (
	select 
	MASTERNOTEREFERENCENUM, 
	SUM(OriginalBalance) AS MASTERNOTEORIGBAL,
	SUM(CurrentCommitment) AS MASTERNOTECURCOM,
	MAX(MaturityDate) AS MASTERNOTEMATDATE,
	input(put(MIN(MaturityDate),8.),yymmdd10.) as DRAW_PERIOD_AFS format=yymmdd10.
	from (
		select 
		ObligationNumber,
		OriginalBalance,
		CurrentCommitment,
		MaturityDate
		from COMMERCIAL_LOANS
	) CL
	JOIN MASTERNOTEAFS
	on MASTERNOTEAFS.ACCTNBR = CL.ObligationNumber
	WHERE MASTERNOTEREFERENCENUM is not null
	group by MASTERNOTEREFERENCENUM
);
quit;

proc sql;
create table LEVERAGE AS (
	select CL.ACCTNBR,
	CL.SYS,
	HDA.ACCOUNT_KEY,
	HFCC.ACCOUNT_KEY AS ACCOUNT_KEY2, 
	HFCC.TOTALASSETSCURRENT, 
	HFCC.CURRENTLIABILITIESCURRENT,
	HFCY.ACCOUNT_KEY AS ACCOUNT_KEY3,
	HFCY.TOTALASSETSCURRENT AS TOTALASSETSCURRENT2, 
	HFCY.CURRENTLIABILITIESCURRENT AS CURRENTLIABILITIESCURRENT2,
	HFCY.DATEFINANCIALS
	from (
		select DISTINCT ACCTNBR, SYS, CATEGORY, M_COMP_CALL from PLEDGE_LOANS where CATEGORY = '710' OR (CATEGORY = "720" AND M_COMP_CALL = "04A0") 
	) CL
	LEFT JOIN (SELECT ACCOUNT_KEY, ACCT_REF_NUM 
	FROM HST.D_ACCOUNTS WHERE BATCH_ID = &batch_HST) HDA
	ON HDA.ACCT_REF_NUM = CL.ACCTNBR
	LEFT JOIN (SELECT ACCOUNT_KEY, TOTALASSETSCURRENT, CURRENTLIABILITIESCURRENT  
	FROM HST.F_CCAR_CORPORATE WHERE BATCH_ID = &batch_HST) HFCC
	ON HFCC.ACCOUNT_KEY = HDA.ACCOUNT_KEY
	LEFT JOIN (SELECT ACCOUNT_KEY, TOTALASSETSCURRENT, CURRENTLIABILITIESCURRENT, 
	DATEFINANCIALS FROM HST.VF_CCAR_RADB_FINANCIALS_CY WHERE BATCH_ID = &batch_HST) HFCY
	ON HFCY.ACCOUNT_KEY = HDA.ACCOUNT_KEY
);
quit;

proc sql;
create table HISTORICAL_LEVERAGE AS (
	select CL.ACCTNBR,
	CL.SYS,
	CL.ACCOUNT_KEY,
	HFCC.ACCOUNT_KEY AS ACCOUNT_KEY2, 
	HFCC.TOTALASSETSCURRENT AS TOTALASSETSCURRENT, 
	HFCC.CURRENTLIABILITIESCURRENT AS CURRENTLIABILITIESCURRENT,
	HFCC.BATCH_ID,
	HFCC.FACILITYTYPE
	from ( 
		select DISTINCT CL.ACCTNBR, CL.SYS, HDA.ACCT_REF_NUM, HDA.ACCOUNT_KEY, HDA.BATCH_ID from PLEDGE_LOANS CL
		JOIN HST.D_ACCOUNTS HDA 
		ON (CL.CATEGORY = '710' OR (CL.CATEGORY = "720" AND CL.M_COMP_CALL = "04A0"))
		AND HDA.ACCT_REF_NUM = CL.ACCTNBR
	) CL
	JOIN (
		SELECT ACCOUNT_KEY, TOTALASSETSCURRENT, CURRENTLIABILITIESCURRENT, BATCH_ID, FACILITYTYPE
		FROM HST.F_CCAR_CORPORATE 
		WHERE TOTALASSETSCURRENT IS NOT NULL OR CURRENTLIABILITIESCURRENT IS NOT NULL
	) HFCC
	ON HFCC.ACCOUNT_KEY = CL.ACCOUNT_KEY AND CL.BATCH_ID = HFCC.BATCH_ID
)
ORDER BY CL.ACCTNBR, HFCC.BATCH_ID ASC;
quit;

Proc sort data=HISTORICAL_LEVERAGE nodupkey; by ACCTNBR; Run;

proc sql;
create table CL_FINAL_P as (
	select 
	ObligationNumber,
	ObligorNumber,
	ObligorName,
	Subsystem,
	ObligorCity,
	ObligorState,
	COUNTRY_CITIZEN_1 as COUNTRY_CITIZEN_1_Source,
	US_CITIZEN_IND,
	CF_PERS_CMCL_CD,
	SRCE_REC_ID as SRCE_REC_ID_Source,
	CCDESC_H10 as CCDESC_H10_Source,
	CCDESC_H02,
	ObligorCountry,
	MasterNoteReferenceNumber, 
	MASTER.MASTERNOTEORIGBAL as MasterNoteOrigBalComm,
	MASTER.MASTERNOTECURCOM as MasterNoteCurrCommAm,
	MASTER.MASTERNOTEMATDATE as MasterNoteMaturityDate,
	INT_PYMT_FREQ,
	InterestFrequency,
	PRIN_PYMT_FREQ,
	LST_PYMT_DATE_Source,
	prefix_PRIN_PYMT_FREQ,
	ratio_Days_PRIN_PYMT_FREQ,
	ratio_Months_PRIN_PYMT_FREQ,
	PrincipalPaymentFrequency,
	InterestNextDueDate,
	InterestPaidThroughDate,
	PrincipalNextDueDate,
	PrincipalPaidThroughDate,
	M_NXT_PPYMT_DATE,
	O_NET_BOOK_BALANCE,
	CURR_BAL,
	CURR_LINE,
	Balance,
	InterestRate,
	O_DURATION_CODE,
	MaturityDate,
	Demand_Flag,
	FXFLFlag,
	DIInternalRiskRating,
	ORIG_DATE,
	LST_RENEW_DATE,
	OriginationDate,
	ORIG_BOOK,
	ORIG_LINE,
	case when Subsystem = "CLS" then coalesce(MASTER.MASTERNOTEORIGBAL, ORIG_BOOK)
		 else CL.OriginalBalance 
	end as OriginalBalance,
	CurrentCommitment,
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
	REV_FLAG AS Revolving_flag,
	PROCESS_TYPE_CD,
	PROD_CODE,
	CASE 
	WHEN Subsystem = 'CLS' AND REV_FLAG = 'N' AND PROCESS_TYPE_CD = '5151' THEN '1' 
	WHEN Subsystem = 'CLS' AND REV_FLAG = 'N' AND PROCESS_TYPE_CD = '0103' THEN '4' 
	WHEN Subsystem = 'CLS' AND REV_FLAG = 'N' AND PROCESS_TYPE_CD <> '0103' THEN '5'
	WHEN Subsystem = 'ALS' AND REV_FLAG = 'R' AND PROD_CODE <> 'CPLC' THEN '2'
	WHEN Subsystem = 'ALS' AND REV_FLAG = 'R' AND PROD_CODE = 'CPLC' THEN '3'
	WHEN Subsystem = 'ALS' AND REV_FLAG = 'N' AND PROD_CODE <> 'CPLC' THEN '4'
	WHEN Subsystem = 'ALS' AND REV_FLAG = 'N' AND PROD_CODE = 'CPLC' THEN '5'
	WHEN Subsystem = 'SBA' AND REV_FLAG = 'N' AND DRAW_PERIOD_SBA_IND <> 'N' THEN '5'
	WHEN Subsystem = 'DFP' AND REV_FLAG = 'N' THEN '5'
	WHEN Subsystem = 'DFP' AND REV_FLAG = 'R' THEN '3'
	ELSE '1'
	END AS DrawdownType,
	CASE WHEN Calculated DrawdownType <> '1' and Subsystem = 'ALS' THEN COALESCE(ALN_DAT_EXPIRATION,mat_date_format)
	WHEN Calculated DrawdownType <> '1' and Subsystem = 'CLS' THEN COALESCE(MASTER.DRAW_PERIOD_AFS,mat_date_format)
	WHEN Subsystem = 'SBA' AND DRAW_PERIOD_SBA_IND <> 'N' THEN DRAW_PERIOD_SBA
	WHEN Calculated DrawdownType <> '1' AND Subsystem = 'DFP' THEN mat_date_format
	END AS DrawPeriodEndDate format=yymmdd10.,
	ResidualValue,
	LEV.CURRENTLIABILITIESCURRENT2 as CURRENTLIABILITIESCURRENT2_Sourc,
	LEV.TOTALASSETSCURRENT2 as TOTALASSETSCURRENT2_Source,
	CASE WHEN LEV.TOTALASSETSCURRENT2 = 0 THEN . ELSE LEV.CURRENTLIABILITIESCURRENT2 / LEV.TOTALASSETSCURRENT2 END AS MostRecentLeverage,
	LEV.DATEFINANCIALS AS DataMostRecentLeverage,
	HLEV.BATCH_ID AS BATCH_ID_HISTORIC,
	HLEV.CURRENTLIABILITIESCURRENT as CURRENTLIABILITIESCURRENT_Source,
	HLEV.TOTALASSETSCURRENT as TOTALASSETSCURRENT_Source,
	CASE WHEN HLEV.TOTALASSETSCURRENT = 0 THEN . ELSE HLEV.CURRENTLIABILITIESCURRENT / HLEV.TOTALASSETSCURRENT END AS LeverageAtOrigination,
	CollateralizedFlag,
	CallReportCode,
	CASE WHEN NAICS.NAICS_KEY IS NOT NULL THEN NAICS.NAICS_KEY ELSE 
	CASE WHEN SUBSYSTEM = 'ALS' THEN SICALS.SICCODE_KEY 
		 WHEN SUBSYSTEM = 'CLS' THEN SICCLS.SICCODE_KEY 
		 WHEN SUBSYSTEM = 'DFP' THEN SICDFP.SICCODE_KEY 
		 WHEN SUBSYSTEM = 'SBA' THEN SICSBA.SICCODE_KEY 
	END END AS IndustryCode,
	CASE WHEN NAICS.NAICS_KEY IS NOT NULL THEN 1 
		 WHEN SICALS.SICCODE_KEY IS NOT NULL OR SICCLS.SICCODE_KEY IS NOT NULL 
			OR SICDFP.SICCODE_KEY IS NOT NULL OR SICSBA.SICCODE_KEY IS NOT NULL THEN 2
	     ELSE .
	END as IndustryCodeType,
	MRA_LOAN_ID,
	Flag_Balloon_Basel,
	Syndication_Flag,
	CATEGORY,
	M_COMP_CALL,
	RISKCODE, 
	REMAINTERM, 
	MRGNCDE, 
	MRGNPCT
	from COMMERCIAL_LOANS CL

	left join MASTERNOTEAFSRESTCL MASTER
	ON MASTER.MASTERNOTEREFERENCENUM = CL.MasterNoteReferenceNumber

	LEFT JOIN MRT.D_NAICS NAICS
	ON NAICS.NAICS_CD = CL.NAICS

	LEFT JOIN (SELECT SICCODE_KEY, SICCODE 
	FROM MRT.D_SICCODE WHERE SUB_SYSTEM_ID = 'ALS') SICALS
	ON SICALS.SICCODE = CL.SIC_CODE

	LEFT JOIN (SELECT SICCODE_KEY, SICCODE 
	FROM MRT.D_SICCODE WHERE SUB_SYSTEM_ID = 'CLS') SICCLS
	ON SICCLS.SICCODE = CL.SIC_CODE

	LEFT JOIN (SELECT SICCODE_KEY, SICCODE 
	FROM MRT.D_SICCODE WHERE SUB_SYSTEM_ID = 'DFP') SICDFP
	ON SICDFP.SICCODE = CL.SIC_CODE

	LEFT JOIN (SELECT SICCODE_KEY, SICCODE 
	FROM MRT.D_SICCODE WHERE SUB_SYSTEM_ID = 'SBA') SICSBA
	ON SICSBA.SICCODE = CL.SIC_CODE

	LEFT JOIN LEVERAGE LEV
	ON LEV.ACCTNBR = CL.ObligationNumber

	LEFT JOIN HISTORICAL_LEVERAGE HLEV
	ON HLEV.ACCTNBR = CL.ObligationNumber
);
quit;


/*Final Step to adjust the format of the columns*/
data Commercial_FORMATS
(drop=IndustryCode AmortizationStartDate DrawPeriodEndDate
DataMostRecentLeverage
rename=(IndustryCode_format=IndustryCode
AmortizationStartDate_f = AmortizationStartDate
DrawPeriodEndDate_f = DrawPeriodEndDate
DataMostRecentLeverage_f = DataMostRecentLeverage)
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
format MasterNoteOrigBalComm 14.2;
format MasterNoteCurrCommAm 14.2;
format MasterNoteMaturityDate;
format InterestFrequency;
format prefix_PRIN_PYMT_FREQ;
format ratio_Days_PRIN_PYMT_FREQ;
format ratio_Months_PRIN_PYMT_FREQ;
format PrincipalPaymentFrequency;
format InterestNextDueDate;
format LST_PYMT_DATE_Source;
format InterestPaidThroughDate;
format PrincipalNextDueDate;
format PrincipalPaidThroughDate;
format M_NXT_PPYMT_DATE;
format O_NET_BOOK_BALANCE;
format Balance 14.2;
format InterestRate 5.2;
format MaturityDate;
format Demand_Flag;
format FXFLFlag;
format DIInternalRiskRating;
format OriginationDate;
format OriginalBalance 14.2;
format CurrentCommitment 14.2;
format AmortizationStartDate_f 8.;
format PDUE_DAYS;
format AmortizationEndDate;
format InterestRateIndex;
format InterestRateSpread 6.2;
format CEILING_RATE_Source;
format InterestRateCap 6.2;
format FLOOR_RATE_Source;
format InterestRateFloor 6.2;
format DrawdownType;
format DrawPeriodEndDate_f 8.;
format ResidualValue 14.2;
format CURRENTLIABILITIESCURRENT2_Sourc;
format TOTALASSETSCURRENT2_Source;
format MostRecentLeverage 6.2;
format DataMostRecentLeverage_f 8.;
format CURRENTLIABILITIESCURRENT_Source;
format TOTALASSETSCURRENT_Source;
format LeverageAtOrigination 6.2;
format CollateralizedFlag 1.;
format CallReportCode;
format IndustryCode_format $10.;
format IndustryCodeType 1.;
format Syndication_Flag;

set CL_FINAL_P;

IF (strip(put(IndustryCode,10.)) = ".") THEN
	IndustryCode_format = "";
ELSE
	IndustryCode_format = strip(put(IndustryCode,10.));

IF Subsystem = "SBA" THEN
/*ObligorNumber was having more than 30 characters long for SBA
We assigned it the ObligationNumber field*/
	ObligorNumber = ObligationNumber;

AmortizationStartDate_f = input(cats(
substr(put(AmortizationStartDate, YYMMDD10.),1,4),
substr(put(AmortizationStartDate, YYMMDD10.),6,2),
substr(put(AmortizationStartDate, YYMMDD10.),9,2)
),$8.);

DrawPeriodEndDate_f = input(cats(
substr(put(DrawPeriodEndDate, YYMMDD10.),1,4),
substr(put(DrawPeriodEndDate, YYMMDD10.),6,2),
substr(put(DrawPeriodEndDate, YYMMDD10.),9,2)
),$8.);

DataMostRecentLeverage_f = input(cats(
substr(DataMostRecentLeverage,1,4),
substr(DataMostRecentLeverage,6,2),
substr(DataMostRecentLeverage,9,2)
),$8.);

/*Do not inform foreign countries*/
WHERE ObligorCountry IN ("US", "");

run;

/*Excluding new loans*/
data PLEDGED.CL_FINAL;
set Commercial_FORMATS;
	where ORIGINATIONDATE <= &batch_prev.;
run;


/*Exporting*/
%exportXLSX(PLEDGED.CL_FINAL,
/SAS_RiskModelDev/SAS_FSB/Pledged loans/Commercial.xlsx,
Commercial);


/************Exclusions Log************/

/*Foreign Countries*/
data Exclusion_Country_Com(keep=ObligationNumber Portfolio Reason ObligorCountry);
format ObligationNumber;
format Portfolio $50.;
format Reason $100.;
format ObligorCountry;
set CL_FINAL_P;
	Portfolio = "Commercial";
	Reason = "Foreign Country";
	where ObligorCountry NOT IN ("US", "");
run;

/*New Loans Exclusion*/
data Commercial_Origination(keep=ObligationNumber Portfolio Reason ORIGINATIONDATE);
format ObligationNumber;
format Portfolio $50.;
format Reason $100.;
format ORIGINATIONDATE;
set Commercial_FORMATS;
	Portfolio = "Commercial";
	Reason = "New Loans";
	where ORIGINATIONDATE > &batch_prev.;
run;


/************Old Treasury Report************/
data Commercial_Old (
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
set PLEDGED.CL_FINAL;
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
%exportXLSX(Commercial_Old,
/SAS_RiskModelDev/SAS_FSB/Pledged loans/Commercial_Treasury.xlsx,
Commercial);