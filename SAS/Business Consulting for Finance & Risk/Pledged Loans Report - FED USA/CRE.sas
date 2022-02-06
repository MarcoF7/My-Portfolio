/*
proc sql;
CREATE TABLE COLLATERAL_TYPE_CRE as (
	SELECT DA.ACCOUNT_KEY, DA.CIS_ACCT_ID, RCPC.CRE_PROP_TYPE, AP.MRA_RATING_ID, pledge.ACCTNBR
	FROM (SELECT * FROM HST.D_ACCOUNTS WHERE BATCH_ID = &batch_HST) DA
	LEFT JOIN (SELECT CIS_ACCT_ID, ACCT_REF_NUM FROM FDBR) FDBR
	ON FDBR.CIS_ACCT_ID = DA.CIS_ACCT_ID
	INNER JOIN (select * from PLEDGE_LOANS where CATEGORY = '780') pledge
	on FDBR.ACCT_REF_NUM = pledge.ACCTNBR
	LEFT JOIN RADB.MTHLY_AUDIT_LOG_APPROVED_CURR AP
	ON (DA.BATCH_ID = AP.BATCH_ID AND DA.MRA_LOAN_ID = AP.MRA_RATING_ID)
	LEFT JOIN RADB.CRE_PROPERTIES RCPC
	ON AP.CUST_ID = RCPC.CUST_ID
	AND AP.CRE_PROP_ID = RCPC.CRE_PROP_ID
	AND AP.LGD_ARCHIVE_ID = RCPC.ARCHIVE_ID
);
quit;
*/


proc sql;	
create table CRE as (	
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
	 else 
		 FDBR.CURR_BAL
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
MFA.INT_RATE_SPREAD_PCT,
FDBR.CEILING_RATE,
CASE
	WHEN Calculated FXFLFlag = 'FL' AND FDBR.CEILING_RATE IS NOT NULL AND FDBR.CEILING_RATE <> 0 AND FDBR.CEILING_RATE < 90 THEN FDBR.CEILING_RATE
	WHEN Calculated FXFLFlag = 'FX' THEN .
	ELSE -99
END as InterestRateCap,
FDBR.FLOOR_RATE as FLOOR_RATE_Source,
CASE
	WHEN Calculated FXFLFlag = 'FL' AND FDBR.FLOOR_RATE IS NOT NULL AND FDBR.FLOOR_RATE <> 0 THEN FDBR.FLOOR_RATE
	WHEN Calculated FXFLFlag = 'FX' THEN .
	ELSE -99
END as InterestRateFloor,
O_PREPAYMENT_PENALTY_IND,
PREPAYMENT_PENALTY_TERM,
input(put(FDBR.MAT_DATE,8.),yymmdd10.) as mat_date_format format=yymmdd10.,
input(put(FDBR.orig,8.),yymmdd10.) as orig_date_format format=yymmdd10.,
input(put(INTNX('MONTH',&_processing_date.,PREPAYMENT_PENALTY_TERM),yymmdd10.),yymmdd10.) as prepayment_penalty_datecalc format=yymmdd10.,
CCAR_PREPAY_PENALTY_FLG,
FDBR.orig,
RT_MSG_CD as message_code_als,
CCAR_PENALTY_TERM,
/*input(put(INTNX('MONTH',FDBR.orig,CCAR_PENALTY_TERM),yymmdd10.),yymmdd10.) as prepayment_penalty_datecalc_als format=yymmdd10.,*/
input(put(INTNX('MONTH',FDBR.orig,60),yymmdd10.),yymmdd10.) as prepayment_penalty_datecalc_als format=yymmdd10.,
FDBR.REV_FLAG,
MDPT.PROCESS_TYPE_CD,
INPUT(ALS.ALN_DAT_EXPIRATION,yymmdd10.) as ALN_DAT_EXPIRATION format=yymmdd10.,
input(put(INTNX('MONTH',FDBR.orig,48),yymmdd10.),yymmdd10.) as DRAW_PERIOD_SBA format=yymmdd10.,
CASE WHEN Calculated DRAW_PERIOD_SBA < &_processing_date. then 'N' else 'Y' END AS DRAW_PERIOD_SBA_IND,
case when substr(COL.COLL_TYPE_DESC ,length(COL.COLL_TYPE_DESC ),1) = '.' then substr(COL.COLL_TYPE_DESC,1,length(COL.COLL_TYPE_DESC )-1) else COL.COLL_TYPE_DESC end as CollateralType,
/*CRE_COLL_TYPE.CRE_PROP_TYPE,*/
HLA.GROUP_FUNDED_AMT,
FDBR.CURR_BAL as Balance2,
HLA.GROUP_CURR_COLL_VALUE,
HLA.CURR_COLL_VALUE,
COL.COL_VAL,
CASE WHEN pledge.SYS = 'CLS' THEN COALESCE(HLA.GROUP_FUNDED_AMT, FDBR.CURR_BAL) ELSE FDBR.CURR_BAL END AS LOAN_BALANCE,
CASE WHEN pledge.SYS = 'CLS' THEN 
	CASE WHEN HLA.GROUP_FUNDED_AMT IS NOT NULL THEN HLA.GROUP_CURR_COLL_VALUE ELSE HLA.CURR_COLL_VALUE END
	 WHEN pledge.SYS = 'ALS' THEN COL.COL_VAL
	 WHEN pledge.SYS = 'SBA' THEN COL.COL_VAL
END AS PROPERTY_VALUE,
HLA.GROUP_ORIG_FUNDED_AMT,
HLA.GROUP_CK_MTHLY_ORIG_VALUE,
COL.ORIG_VAL,
CASE WHEN pledge.SYS = 'CLS' THEN HLA.GROUP_ORIG_FUNDED_AMT ELSE Calculated OriginalBalance END AS LOAN_BALANCE_ORIGINAL,
CASE WHEN pledge.SYS = 'CLS' THEN HLA.GROUP_CK_MTHLY_ORIG_VALUE
	 WHEN pledge.SYS = 'ALS' THEN COL.ORIG_VAL 
	 WHEN pledge.SYS = 'SBA' THEN COL.ORIG_VAL 
END AS PROPERTY_VALUE_ORIGINAL,
COL.COL_EFF_DT as COL_EFF_DT_Source,
COL.COL_EFF_DT as DateofMostRecentLTVCLTV,
FDBR.PROD_CODE,
COMP_CALL as CallReportCode,
COL.ZIP	 as CollateralLocationZipCode,
"" as CollateralLocationCountry,
COL.STATE AS STATE_COLLATERAL,
COL.COUNTRY AS COUNTRY_COLLATERAL,
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
from
	(SELECT *, input(put(FDBR.ORIG_DATE,8.),yymmdd10.) as orig format=yymmdd10. FROM FDBR) FDBR
	
	JOIN (SELECT MRA_LOAN_ID, LOAN_LINE_IND, ACCOUNT_KEY, CIS_ACCT_ID 
	FROM MRT.D_ACCOUNTS) MDA1
	on MDA1.CIS_ACCT_ID = FDBR.CIS_ACCT_ID
	
	JOIN (select SYS, ACCTNBR, CATEGORY, M_COMP_CALL,
	RISKCODE, REMAINTERM, MRGNCDE, MRGNPCT 
	from PLEDGE_LOANS where CATEGORY = '780' OR (CATEGORY = "720" AND M_COMP_CALL IN ("01E1","01E2"))) pledge
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
			SELECT RT_CTL1, RT_CTL2, RT_ACCT_NUM, CF_PERS_CMCL_CD, ALN_DAT_EXPIRATION, RT_MSG_CD, RT_DURATION_CD FROM WHS.W_ALS_FLAT WHERE BATCH_ID = &batch_WHS
	) ALS
	on cats(put(input(RT_CTL1,4.),z4.),						
	put(input(RT_CTL2,4.),z4.), '00000000',							
	RT_ACCT_NUM) = FDBR.CIS_ACCT_ID

	LEFT JOIN (
		select CCAR_PENALTY_TERM, CCAR_PREPAY_PENALTY_FLG, CCAR_BANK, CCAR_LN_NO, CCAR_CTL1 from WHS.W_ALS_CCAR where BATCH_ID  = &batch_WHS
	) ALS_CCAR
	ON cats(PUT(input(CCAR_CTL1,4.), z4.),put(input(ALS_CCAR.CCAR_BANK,4.),z4.), '000000000000', ALS_CCAR.CCAR_LN_NO) = FDBR.CIS_ACCT_ID

	LEFT JOIN (SELECT ACCOUNT_KEY, PROCESS_TYPE_KEY, COMMON_COST_CENTER_KEY,
	SYNDICATED_FROM_ACCOUNT_KEY, INT_RATE_SPREAD_PCT, POD_GRADE_CD, AMORT_KEY,
	SYS_PRODUCT_KEY
	FROM MRT.F_ACCOUNTS WHERE BATCH_ID = &batch_MRT) MFA
	ON MFA.ACCOUNT_KEY = MDA1.ACCOUNT_KEY

	LEFT JOIN (SELECT SYN_PARTC_CD, PROCESS_TYPE_CD, PROCESS_TYPE_KEY, SUB_SYSTEM_ID 
	FROM MRT.D_PROCESS_TYPE) MDPT
	ON MDPT.PROCESS_TYPE_KEY = MFA.PROCESS_TYPE_KEY
 	AND pledge.SYS = MDPT.SUB_SYSTEM_ID

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
		AFS.COL_VAL, 
		ORIG_VAL, 
		COL_TP, 
		ZIP,
		STATE, 
		COUNTRY, 
		COLL_TYPE_DESC,
		AFS.COL_EFF_DT
		FROM COLLATERALS_AFS AFS
			UNION ALL
		SELECT 
		ACCT_REF_NUM,
		ALS.COLL_AMT AS COL_VAL,
		CO_ORIG_VAL AS ORIG_VAL,
		CO_TYPE AS COL_TP,
		ALN_PA_ZIP_CD AS ZIP,
		ALN_PA_STATE AS STATE,
		COUNTRY,
		COLL_TYPE_DESC,
		. AS COL_EFF_DT
		FROM COLLATERALS_ALS ALS
			UNION ALL
		SELECT 
		ACCT_REF_NUM,
		curr_value AS COL_VAL,
		orig_value AS ORIG_VAL,
		'' AS COL_TP,
		'' AS ZIP,
		'' AS STATE,
		'' AS COUNTRY,
		COLL_TYPE_DESC,
		. AS COL_EFF_DT
		FROM COLLATERALS_SBA_DFP SBA
	) COL
	ON COL.ACCT_REF_NUM = pledge.ACCTNBR
/*
	left join COLLATERAL_TYPE_CRE CRE_COLL_TYPE
	ON CRE_COLL_TYPE.ACCTNBR = COL.ACCT_REF_NUM
*/
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

	LEFT JOIN Syndicated_SBA Synd
	ON compress(Synd.sold_from_cis_acct_id) = compress(FDBR.CIS_ACCT_ID)
);	
quit;
	
 
proc sql;
create table MASTERNOTEAFSRESTCRE AS (
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
		from CRE
	)
	JOIN MASTERNOTEAFS
	on MASTERNOTEAFS.ACCTNBR = CRE.ObligationNumber
	WHERE MASTERNOTEREFERENCENUM is not null
	group by MASTERNOTEREFERENCENUM
);
quit;

proc sql;
create table CRE_FINAL_p as (
	select distinct
	ObligationNumber,
	ObligorNumber,
	ObligorName,
	Subsystem,
	ObligorCity,
	ObligorState,
	CF_PERS_CMCL_CD,
	CCDESC_H10,
	CCDESC_H02,
	ObligorCountry,
	MasterNoteReferenceNumber,
	MASTER.MASTERNOTEORIGBAL as MasterNoteOrigBalComm,
	MASTER.MASTERNOTECURCOM as MasterNoteCurrCommAm,
	MASTER.MASTERNOTEMATDATE as MasterNoteMaturityDate,
	INT_PYMT_FREQ,
	InterestFrequency,
	PRIN_PYMT_FREQ,
	prefix_PRIN_PYMT_FREQ_Source,
	PrincipalPaymentFrequency,
	LST_PYMT_DATE_Source,
	InterestNextDueDate,
	InterestPaidThroughDate,
	PrincipalNextDueDate,
	PrincipalPaidThroughDate,
	M_NXT_PPYMT_DATE,
	TRAN_CLASS,
	CURR_BAL,
	CURR_LINE,
	O_NET_BOOK_BALANCE,
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
		 else CRE.OriginalBalance 
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
	CEILING_RATE,
	InterestRateCap,
	FLOOR_RATE_Source,
	InterestRateFloor,
	O_PREPAYMENT_PENALTY_IND,
	PREPAYMENT_PENALTY_TERM,
	mat_date_format, 
	prepayment_penalty_datecalc,
	CCAR_PREPAY_PENALTY_FLG,
	orig,
	CCAR_PENALTY_TERM,
	prepayment_penalty_datecalc_als,
	message_code_als,
	CASE WHEN Subsystem = "SBA" THEN orig
		WHEN O_PREPAYMENT_PENALTY_IND = 'N' THEN mat_date_format 
		WHEN O_PREPAYMENT_PENALTY_IND = 'Y' AND prepayment_penalty_datecalc > &_processing_date. THEN prepayment_penalty_datecalc
		WHEN O_PREPAYMENT_PENALTY_IND = 'Y' AND prepayment_penalty_datecalc <= &_processing_date. THEN orig
		WHEN message_code_als = '01' AND prepayment_penalty_datecalc_als > &_processing_date. THEN prepayment_penalty_datecalc_als
		WHEN message_code_als = '01' AND prepayment_penalty_datecalc_als <= &_processing_date. THEN orig
		ELSE mat_date_format
	END as PrepayLockoutEndDate format=yymmdd10.,
	REV_FLAG as Revolving,
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
	ELSE '1'
	END AS DrawdownType,
	CASE 
	WHEN Calculated DrawdownType <> '1' and Subsystem = 'ALS' THEN coalesce(ALN_DAT_EXPIRATION,mat_date_format) 
	WHEN Calculated DrawdownType <> '1' and Subsystem = 'CLS' THEN COALESCE(MASTER.DRAW_PERIOD_AFS,mat_date_format)
	WHEN Subsystem = 'SBA' AND DRAW_PERIOD_SBA_IND <> 'N' THEN DRAW_PERIOD_SBA
	END AS DrawPeriodEndDate format=yymmdd10.,
	CollateralType as collateral_type_desc,
	CASE 
	WHEN CollateralType IN 
		('CONVENIENCE STORE-NON OWNER OCC',
		'CONVENIENCE STORE-NON OWNER OCC.',
		'CONVENIENCE STORE-OWNER OCC',
		'CONVENIENCE STORE-OWNER OCC.',
		'SHOPPING CENTER',
		'SINGLE RETAIL ESTABLISHMENT',
		'SINGLE RETAIL ESTABLISHMENT OWNER OCC') THEN 1
	WHEN CollateralType IN 
		('MANUF/INDUST PLANT',
		'COMMERCIAL/INDUSTRIAL',
		'MANUFACTURING/INDUSTRIAL',
		'MANUFACTURING/INDUSTRIAL PLANT',
		'WAREHOUSE',
		'WAREHOUSE 50% OR MORE OWNER OCC',
		'WAREHOUSE 50% OR MORE OWNER OCC.') THEN 2
	WHEN CollateralType IN ( 
		'HOTEL/MOTEL',
		'SPORTS LEISURE FACILITY',
		'SPORTS/LEISURE FACILITY') THEN 3
	WHEN CollateralType IN (
		'FIVE OR MORE FAMILY UNITS',
		'MULTI-FAMILY RESIDENTIAL',
		'TWO-FOUR-FAMILY UNITS',
		'APARTMENT BLDG') THEN 4
	WHEN CollateralType LIKE 'OFFICE BLDG%' THEN 5
	WHEN CollateralType IN (
		'FARMLAND',
		'LIVESTOCK') THEN 6
	WHEN CollateralType IN (
		'OFFICE/WAREHOUSE 50% OR MORE OWNER OCC',
		'OFFICE/WAREHOUSE LESS THAN 50% OWNER OCC') THEN 7
	WHEN CollateralType like 'CONDO%' OR CollateralType IN (
		'SINGLE FAMILY',
		'1-4 FAM 1ST MTG',
		'1-4 FAM 2ND MTG',
		'1-4 FAM/PRIMARY RES-1ST MTG',
		'1-4 FAM/PRIMARY RES-2ND MTG',
		'1-4 FAM/SECONDARY RES-1ST MTG',
		'1-4 FAM/SECONDARY RES-2ND MTG',
		'1-4 FAMILY 2ND MTG',
		'APARTMENT FOR CONVERSION',
		'PLANNED UNIT DEVELOPMENT',
		'CONDO BLDG(NOT SINGLE UNIT',
		'CONDO MULTI UNITS',
		'CONDO-SINGLE UNIT-PRIMARY RES',
		'CONDO-SINGLE UNIT-SECOND RES',
		'CONDOMINIUM',
		'REL LOTS ZONED 1-4 FAMILY RESIDENCE',
		'UNIMPROVED 1-4 FAM',
		'UNIMPROVED COMML',
		'UNIMPROVED LAND',
		'UNIMPROVED LAND - UNZONED',
		'UNIMPROVED LAND - ZONED 1-4 RESIDENTIAL',
		'UNIMPROVED LAND - ZONED COMMERCIAL',
		'UNIMPROVED MULTI-FAMILY',
		'UNIMPROVED-ZONED 1-4 FAMILY',
		'UNIMPROVED-ZONED COMMERCIAL',
		'UNIMPROVED-ZONED MULTIFAMILY',
		'!UNKNOWN',
		'UNKNOWN',
		'ACCOUNTS RECEIVABLE',
		'AUTOMOBILE-USED',
		'CERT OF DEPOSIT-COMPASS',
		'CHURCH/NON PROFIT ORG BLDG',
		'CHURCH/NON-PROFIT',
		'COMMERCIAL - 2ND MTG',
		'COMMERCIAL 2ND MTG',
		'DEALER FLOORPLAN',
		'FACE VALUE LIFE INSURANCE',
		'HEALTH CARE FAC LESS THAN 50%',
		'HEALTH CARE FACILITY 50% OR MORE OWNER OCC',
		'HEALTHCARE FACILITY',
		'HEAVY MACHINERY',
		'INVENTORY',
		'LEASE ASSIGNMENT',
		'LIFE INSURANCE PREMIUM REDEMPT',
		'MINI-WAREHOUSE',
		'MUNICIPAL BONDS',
		'MUTUAL FUNDS',
		/**'MUTUAL FUNDS ' || '&' || ' BROKERAGE ACCTS - COMPASS EXPEDITI',*/
		'NOTES RECEIVABLE',
		'NOTES RECEIVABLES',
		'OFFICE EQUIPMENT',
		'OIL OR MINING PROD PMTS-U.S.',
		'OIL/MINING PROD PYMT-NON US',
		'OIL/MINING PROD PYMT-US',
		'OTH COMML BLDG',
		'OTHER',
		'OTHER COLLATERAL',
		'OTHER COMMERCIAL BLDG',
		'OTHER COMMERCIAL BUILDING',
		'OTHER STOCK(CLOSELY HELD)',
		'OTHR STOCK (NON-MARKETABL)',
		'OVER THE COUNTER STOCK',
		'OVER-THE-COUNTER STOCK',
		'PRODUCTION EQUIPMENT',
		'REST HOME (HOUSING FOR AGED)',
		'SAVINGS ACCOUNT-OTHER BANK',
		'SAVINGS ACCOUNT-OUR BANK',
		'SAVINGS ACCT-COMPASS',
		'SAVINGS ACCT-OTHER BANK',
		'SINGLE ESTABLISHMENT - NON-OWNE',
		'SINGLE ESTABLISHMENT - NON-OWNER OCC',
		'STOCK OF OTHER BANKS < 5%',
		'STOCK OF OTHER BANKS 5%+',
		'STOCK OF OTHER BKS-GE 5%',
		'STOCK OF OTHER BKS-LT 5%',
		'TRAVEL TRAILER',
		'TRAVEL TRAILER/RV',
		'TRUST ACCOUNT ASSIGNMENT',
		'TRUST ACCT ASSIGNMENT',
		'UNKNOWN',
		'UNSECURED',
		'UNSECURED W/GUARANTOR',
		'UNSECURED W/GUARANTOR/COSIGNER',
		'UNSECURED WITH NEGATIVE PLEDGE') THEN 8
	END AS CollateralType,
	DSCR_MAX.DSCR as DSCR_MAX_DSCR_Source,
	DSCR_MAX.DSCR as MostRecentDSCR,
	DSCR_MAX.STMT_DATE as DSCR_MAX_STMT_DATE_Source,
	DSCR_MAX.STMT_DATE AS DateofMostRecentDSCR,
	DSCR_MIN.DSCR as DSCR_MIN_DSCR_Source,
	DSCR_MIN.DSCR as DSCRatOrigination,
	DSCR_MIN.STMT_DATE AS DateofOriginationDSCR,
	GROUP_FUNDED_AMT,
	Balance2,
	GROUP_CURR_COLL_VALUE,
	CURR_COLL_VALUE,
	COL_VAL,
	LOAN_BALANCE,
	PROPERTY_VALUE,
	COL_EFF_DT_Source,
	CASE WHEN SUBSYSTEM NOT IN ('ALS','SBA') THEN DateofMostRecentLTVCLTV ELSE . END AS DateofMostRecentLTVCLTV format=datetime20.,
	CASE WHEN calculated DateofMostRecentLTVCLTV = . OR PROPERTY_VALUE = 0 OR SUBSYSTEM IN ('ALS', 'SBA') THEN . ELSE LOAN_BALANCE/PROPERTY_VALUE END AS MostRecentLTVCLTV,
	GROUP_ORIG_FUNDED_AMT,
	GROUP_CK_MTHLY_ORIG_VALUE,
	ORIG_VAL,
	LOAN_BALANCE_ORIGINAL,
	PROPERTY_VALUE_ORIGINAL,
	CASE WHEN PROPERTY_VALUE_ORIGINAL = 0 THEN . ELSE LOAN_BALANCE_ORIGINAL/PROPERTY_VALUE_ORIGINAL END AS LTVCLTVatOrigination,
	CallReportCode,
	CollateralLocationZipCode,
	CollateralLocationCountry,
	STATE_COLLATERAL,
	COUNTRY_COLLATERAL,
	MRA_LOAN_ID,
	Flag_Balloon_Basel,
	Syndication_Flag,
	CATEGORY,
	M_COMP_CALL,
	RISKCODE, 
	REMAINTERM, 
	MRGNCDE, 
	MRGNPCT
	from CRE
	left join MASTERNOTEAFSRESTCRE MASTER
	ON MASTER.MASTERNOTEREFERENCENUM = CRE.MasterNoteReferenceNumber
	LEFT JOIN DSCR_MAX
	ON DSCR_MAX.ACCT_REF_NUM = CRE.ObligationNumber
	LEFT JOIN DSCR_MIN
	ON DSCR_MIN.ACCT_REF_NUM = CRE.ObligationNumber
	/*Do not inform 1-4 FAM Collateral Type Description*/
	where collateral_type_desc NOT IN ("1-4 FAM 1ST MTG" ,"1-4 FAM 2ND MTG" ,"1-4 FAM/PRIMARY RES-1ST MTG" ,"UNIMPROVED 1-4 FAM" ,"UNIMPROVED-ZONED 1-4 FAMILY")
);
quit;


data CRE_Formats
(drop=AmortizationStartDate PrepayLockoutEndDate DrawPeriodEndDate DateofMostRecentDSCR
DateofMostRecentLTVCLTV CollateralLocationZipCode
rename=(AmortizationStartDate_f = AmortizationStartDate
PrepayLockoutEndDate_f = PrepayLockoutEndDate
DrawPeriodEndDate_f = DrawPeriodEndDate
DateofMostRecentDSCR_f = DateofMostRecentDSCR
DateofMostRecentLTVCLTV_f = DateofMostRecentLTVCLTV
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
format CURR_BAL;
format CURR_LINE;
format O_NET_BOOK_BALANCE;
format Balance 14.2;
format InterestRate 5.2;
format O_DURATION_CODE;
format MaturityDate;
format Demand_Flag;
format FXFLFlag;
format DIInternalRiskRating;
format ORIG_DATE;
format LST_RENEW_DATE;
format OriginationDate;
format ORIG_BOOK;
format ORIG_LINE;
format OriginalBalance 14.2;
format CurrentCommitment 14.2;
format AmortizationStartDate_f 8.;
format PDUE_DAYS;
format BALLON_PAYMNT;
format AmortizationEndDate;
format REPR_CODE;
format REPR_DRVE_RATE;
format InterestRateIndex;
format InterestRateSpread 6.2;
format CEILING_RATE;
format InterestRateCap 6.2;
format FLOOR_RATE_Source;
format InterestRateFloor 6.2;
format O_PREPAYMENT_PENALTY_IND;
format PREPAYMENT_PENALTY_TERM;
format mat_date_format; 
format prepayment_penalty_datecalc;
format CCAR_PREPAY_PENALTY_FLG;
format orig;
format CCAR_PENALTY_TERM;
format prepayment_penalty_datecalc_als;
format message_code_als;
format PrepayLockoutEndDate_f 8.;
format REV_FLAG as Revolving;
format PROCESS_TYPE_CD;
format PROD_CODE;
format DrawdownType;
format DrawPeriodEndDate_f 8.;
format collateral_type_desc;
format CollateralType;
format DSCR_MAX_DSCR_Source;
format MostRecentDSCR 6.2;
format DSCR_MAX_STMT_DATE_Source;
format DateofMostRecentDSCR_f 8.;
format DSCR_MIN_DSCR_Source;
format DSCRatOrigination 6.2;
format DateofOriginationDSCR;
format GROUP_FUNDED_AMT;
format Balance2;
format GROUP_CURR_COLL_VALUE;
format CURR_COLL_VALUE;
format COL_VAL;
format LOAN_BALANCE;
format PROPERTY_VALUE;
format COL_EFF_DT_Source;
format DateofMostRecentLTVCLTV_f 8.;
format MostRecentLTVCLTV 6.2;
format GROUP_ORIG_FUNDED_AMT;
format GROUP_CK_MTHLY_ORIG_VALUE;
format ORIG_VAL;
format LOAN_BALANCE_ORIGINAL;
format PROPERTY_VALUE_ORIGINAL;
format LTVCLTVatOrigination 6.2;
format CallReportCode;
format CollateralLocationZipCode2 $5.;
format CollateralLocationCountry;
format STATE_COLLATERAL;
format COUNTRY_COLLATERAL;
format MRA_LOAN_ID;
format Syndication_Flag;
set CRE_FINAL_p;

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

PrepayLockoutEndDate_f = input(cats(
substr(put(PrepayLockoutEndDate, YYMMDD10.),1,4),
substr(put(PrepayLockoutEndDate, YYMMDD10.),6,2),
substr(put(PrepayLockoutEndDate, YYMMDD10.),9,2)
),$8.);

DrawPeriodEndDate_f = input(cats(
substr(put(DrawPeriodEndDate, YYMMDD10.),1,4),
substr(put(DrawPeriodEndDate, YYMMDD10.),6,2),
substr(put(DrawPeriodEndDate, YYMMDD10.),9,2)
),$8.);

DateofMostRecentDSCR_f = input(cats(
substr(put(datepart(DateofMostRecentDSCR), YYMMDD10.),1,4),
substr(put(datepart(DateofMostRecentDSCR), YYMMDD10.),6,2),
substr(put(datepart(DateofMostRecentDSCR), YYMMDD10.),9,2)
),$8.);

DateofMostRecentLTVCLTV_f = input(cats(
substr(put(datepart(DateofMostRecentLTVCLTV), YYMMDD10.),1,4),
substr(put(datepart(DateofMostRecentLTVCLTV), YYMMDD10.),6,2),
substr(put(datepart(DateofMostRecentLTVCLTV), YYMMDD10.),9,2)
),$8.);

/*Do not inform Foreign Countries*/
WHERE ObligorCountry IN ("US", "");

run;

/*Excluding new loans*/
data PLEDGED.CRE_FINAL;
set CRE_Formats;
	where ORIGINATIONDATE <= &batch_prev.;
run;


/*Exporting*/
%exportXLSX(PLEDGED.CRE_FINAL,
/SAS_RiskModelDev/SAS_FSB/Pledged loans/CRE.xlsx,
CRE);



/************Exclusions Log************/

/*1-4 FAM Collateral Type Description*/
data Exclusion_FAM_Collat_CRE(keep=ObligationNumber Portfolio Reason CollateralType);
format ObligationNumber;
format Portfolio $50.;
format Reason $100.;
format CollateralType;
set CRE;
	Portfolio = "CRE";
	Reason = "1-4 FAM Collateral Type Description";
	where CollateralType IN ("1-4 FAM 1ST MTG" ,"1-4 FAM 2ND MTG" ,"1-4 FAM/PRIMARY RES-1ST MTG" ,"UNIMPROVED 1-4 FAM" ,"UNIMPROVED-ZONED 1-4 FAMILY");
run;

/*Exporting*/
%exportXLSX(Exclusion_FAM_Collat_CRE,
/SAS_RiskModelDev/SAS_FSB/Pledged loans/Exclusions_Log.xlsx,
1-4 FAM Collateral Type);

/*Foreign Countries*/
data Exclusion_Country_CRE(keep=ObligationNumber Portfolio Reason ObligorCountry);
format ObligationNumber;
format Portfolio $50.;
format Reason $100.;
format ObligorCountry;
set CRE_FINAL_p;
	Portfolio = "CRE";
	Reason = "Foreign Country";
	where ObligorCountry NOT IN ("US", "");
run;

/*New Loans Exclusion*/
data CRE_Origination(keep=ObligationNumber Portfolio Reason ORIGINATIONDATE);
format ObligationNumber;
format Portfolio $50.;
format Reason $100.;
format ORIGINATIONDATE;
set CRE_Formats;
	Portfolio = "CRE";
	Reason = "New Loans";
	where ORIGINATIONDATE > &batch_prev.;
run;


/************Old Treasury Report************/
data CRE_Old (
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
set PLEDGED.CRE_FINAL;
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
%exportXLSX(CRE_Old,
/SAS_RiskModelDev/SAS_FSB/Pledged loans/CRE_Treasury.xlsx,
CRE);