
proc sql;
create table FDBR_todo as (
	select FDBR.ACCT_REF_NUM,
	FDBR.NXT_PPYMT_DATE,
	FDBR.INT_PYMT_FREQ,
	FDBR.BATCH_ID,
	FDBR.MAT_DATE,
	input(put(FDBR.ORIG_DATE,8.),yymmdd10.) AS ORIG_DATE format=yymmdd10.
	from (select ACCT_REF_NUM, NXT_PPYMT_DATE, INT_PYMT_FREQ, 
	BATCH_ID, MAT_DATE, ORIG_DATE from WHS.W_FDBR_BW) FDBR 
	JOIN (select ACCTNBR from ELIGIBLELOANS_CATEG) pledge /*join against our population*/
	on FDBR.ACCT_REF_NUM = pledge.ACCTNBR 
);
quit;

proc sort data=FDBR_todo out=ordered;
	by ACCT_REF_NUM BATCH_ID;
run;

Proc sort data=ordered nodupkey; by ACCT_REF_NUM; Run;
/*00000000000000658552	20160809	20160731	20190609*/

/*Previous Logic for Master Account Ref Number*/
/*
proc sql;
create table MASTERNOTEAFS AS (
	select 
	pledge.ACCTNBR,
	FDBRMASTERNOTE.ACCT_REF_NUM AS MASTERNOTEREFERENCENUM
	from (						
		SELECT O_TAKEDOWN_OBLIGOR,									
		O_TAKEDOWN_OBLIGATION,					
		BANK_NUMBER,					
		OBLIGOR_NUMBER,					
		OBLIGATION_NUMBER					
		FROM WHS.W_AFS_FLAT WHERE BATCH_ID = &batch_WHS					
	) AFS						
	JOIN (						
	  SELECT * FROM WHS.W_FDBR_BW WHERE BATCH_ID = &batch_WHS							
	) FDBR						
	on cats('0001',put(input(AFS.BANK_NUMBER,4.),z4.),'00000000',					
	put(input(AFS.OBLIGOR_NUMBER,10.),z10.),						
	put(input(AFS.OBLIGATION_NUMBER,10.),z10.))						
    = fdbr.CIS_ACCT_ID						
	JOIN (						
		select * from ELIGIBLELOANS_CATEG WHERE SYS = 'CLS'				
	) pledge						
	on pledge.ACCTNBR = FDBR.ACCT_REF_NUM
	LEFT JOIN (
		SELECT CIS_ACCT_ID, ACCT_REF_NUM FROM WHS.W_FDBR_BW WHERE BATCH_ID = &batch_WHS							
	) FDBRMASTERNOTE
	ON 	FDBRMASTERNOTE.CIS_ACCT_ID = 
	cats('0001',put(input(AFS.BANK_NUMBER,4.),z4.),'00000000',					
	put(AFS.O_TAKEDOWN_OBLIGOR,z10.),						
	put(AFS.O_TAKEDOWN_OBLIGATION,z10.))
);
quit;
*/

/*Getting all the fathers*/
proc sql;
create table MASTERNOTEAFS_fathers as
select FDBR.ACCT_REF_NUM, 
		MFA1.ACCOUNT_KEY as ACCOUNT_KEY,

		MFA1.takedown_account_key as Facility_Level1,
		MDPT2.FACLT_TYPE_DESC as Facility_Desc1,

		MFA2.takedown_account_key as Facility_Level2,
		MDPT3.FACLT_TYPE_DESC as Facility_Desc2,

		MFA3.takedown_account_key as Facility_Level3,
		MDPT4.FACLT_TYPE_DESC as Facility_Desc3,

		MFA4.takedown_account_key as Facility_Desc4
	
	from
	(SELECT BATCH_ID, CIS_ACCT_ID, ACCT_REF_NUM 
		FROM WHS.W_FDBR_BW WHERE BATCH_ID = &batch_WHS) FDBR	
	JOIN MRT.D_ACCOUNTS MDA1
	on MDA1.CIS_ACCT_ID = FDBR.CIS_ACCT_ID	
	JOIN (select * from ELIGIBLELOANS_CATEG WHERE SYS = 'CLS') pledge						
	on pledge.ACCTNBR = FDBR.ACCT_REF_NUM
	LEFT JOIN (SELECT ACCOUNT_KEY, takedown_account_key, PROCESS_TYPE_KEY FROM MRT.F_ACCOUNTS WHERE BATCH_ID = &batch_MRT) MFA1
	ON MDA1.ACCOUNT_KEY = MFA1.ACCOUNT_KEY


	LEFT JOIN (SELECT ACCOUNT_KEY, takedown_account_key, PROCESS_TYPE_KEY FROM MRT.F_ACCOUNTS WHERE BATCH_ID = &batch_MRT) MFA2
	ON MFA1.takedown_account_key = MFA2.ACCOUNT_KEY
	LEFT JOIN (SELECT PROCESS_TYPE_KEY, FACLT_TYPE_DESC FROM MRT.D_PROCESS_TYPE) MDPT2
	ON MDPT2.PROCESS_TYPE_KEY = MFA2.PROCESS_TYPE_KEY
 	AND pledge.SYS = "CLS"
	LEFT JOIN (SELECT ACCOUNT_KEY, takedown_account_key, PROCESS_TYPE_KEY FROM MRT.F_ACCOUNTS WHERE BATCH_ID = &batch_MRT) MFA3
	ON MFA2.takedown_account_key = MFA3.ACCOUNT_KEY
	LEFT JOIN (SELECT PROCESS_TYPE_KEY, FACLT_TYPE_DESC FROM MRT.D_PROCESS_TYPE) MDPT3
	ON MDPT3.PROCESS_TYPE_KEY = MFA3.PROCESS_TYPE_KEY
 	AND pledge.SYS = "CLS"
	LEFT JOIN (SELECT ACCOUNT_KEY, takedown_account_key, PROCESS_TYPE_KEY FROM MRT.F_ACCOUNTS WHERE BATCH_ID = &batch_MRT) MFA4
	ON MFA3.takedown_account_key = MFA4.ACCOUNT_KEY
	LEFT JOIN (SELECT PROCESS_TYPE_KEY, FACLT_TYPE_DESC FROM MRT.D_PROCESS_TYPE) MDPT4
	ON MDPT4.PROCESS_TYPE_KEY = MFA4.PROCESS_TYPE_KEY
 	AND pledge.SYS = "CLS"
;	
quit;

/*Calculating the Master Facility based on Guidance and Advised descriptions*/
data MASTERNOTEAFS_CalcMaster(drop=i Facility_Desc4);
set MASTERNOTEAFS_fathers;
format Position_Guidance 1.;
format Position_Advised 1.;
format Facility_Master;

array Facility_Lev{3} Facility_Level1 Facility_Level2 Facility_Level3;
array Facility_Des{3} Facility_Desc1 Facility_Desc2 Facility_Desc3;

	do i=1 to dim(Facility_Lev);
		if Facility_Des(i)= "Guidance" then
			do;
				Position_Guidance = i;
				leave;
			end;
	end;

	do i=1 to dim(Facility_Lev);
		if Facility_Des(i)= "Advised" then
			do;
				Position_Advised = i;
			end;
	end;

	if Position_Guidance NE . then
		do;
			if Position_Guidance = 1 then
				do;
					Facility_Master = .;
				end;
			else
				do;
					Facility_Master = Facility_Lev(Position_Guidance-1);
				end;
		end;
	else if Position_Advised NE . then
		do;
			Facility_Master = Facility_Lev(Position_Advised);
		end;

run;

/*Consolidating the ACCT_REF_NUM and the ACCT_REF_NUM of
its highest level father*/
proc sql;
	create table MASTERNOTEAFS as
		select Master.ACCT_REF_NUM as ACCTNBR,
				FDBR.ACCT_REF_NUM as MASTERNOTEREFERENCENUM
			from MASTERNOTEAFS_CalcMaster Master 
				 LEFT JOIN MRT.D_ACCOUNTS MDA1
				 	ON Master.Facility_Master = MDA1.ACCOUNT_KEY
				 LEFT JOIN (SELECT BATCH_ID, CIS_ACCT_ID, ACCT_REF_NUM 
					FROM WHS.W_FDBR_BW WHERE BATCH_ID = &batch_WHS) FDBR
					ON MDA1.CIS_ACCT_ID = FDBR.CIS_ACCT_ID;
quit;


proc sql;
create table COLLATERALS_AFS AS (
	SELECT FDBR.ACCT_REF_NUM, i.COL_VAL, I.ORIG_VAL, put(i.COL_TP,z3.) as COL_TP, i.ZIP, i.STATE, ' ' as COUNTRY, ct.COLL_TYPE_DESC,
	i.COL_EFF_DT
	FROM (
	  select OBLN.BK_NO, OBLN.OBG_NO, OBLN.OBL_NO, COLL_ITEM.ITEM_NO, COLL_ITEM.COL_TP, COLL_ITEM.ORIG_VAL, COLL_ITEM.COL_VAL, 
	  seg.zip, seg.STATE, COLL_ITEM.COL_EFF_DT from (
	    select BK_NO, OBG_NO, OBL_NO 
	    from WHS.W_AFS_OBLN 
	    WHERE BATCH_ID = &batch_WHS
	  ) OBLN

	join (
	  select BK_NO0, OBG_NO0, OBL_NO, 
	  ITEM_NO, OBG_NO, BK_NO 
	  from WHS.W_AFS_COLL_OBLN_PNTR
	  where BATCH_ID = &batch_WHS
	) OBLN_PNTR
	ON OBLN.BK_NO = OBLN_PNTR.BK_NO0 AND OBLN.OBG_NO = OBLN_PNTR.OBG_NO0 AND OBLN.OBL_NO = OBLN_PNTR.OBL_NO

	JOIN (
	  select ITEM_NO, OBG_NO, BK_NO, COL_TP, LOC_HELD, COL_VAL, ORIG_VAL, COL_EFF_DT
	  from WHS.W_AFS_COLL_ITEM 
	  where BATCH_ID = &batch_WHS
	) COLL_ITEM
	ON OBLN_PNTR.ITEM_NO = COLL_ITEM.ITEM_NO AND OBLN_PNTR.OBG_NO = COLL_ITEM.OBG_NO AND OBLN_PNTR.BK_NO = COLL_ITEM.BK_NO

	LEFT JOIN WHS.W_AFS_COLL_092_SEG seg
	ON &batch_WHS = seg.BATCH_ID
	AND COLL_ITEM.BK_NO = seg.BK_NO
	AND COLL_ITEM.OBG_NO = SEG.OBG_NO
	AND COLL_ITEM.ITEM_NO = seg.ITEM_NO
	) i 

	LEFT JOIN MRT.D_COLLATERAL_TYPE CT
	ON 'CLS' = ct.SUB_SYSTEM_ID
	AND put(i.COL_TP,z3.) = ct.COLL_TYPE_CD
	 
	LEFT JOIN (
	  SELECT * FROM WHS.W_FDBR_BW WHERE BATCH_ID = &batch_WHS
	) FDBR
	ON        cats('0001',put(i.BK_NO,z4.),'00000000',					
			  put(i.OBG_NO,z10.),						
			  put(i.OBL_NO,z10.)) =
	          FDBR.CIS_ACCT_ID
	)
ORDER BY FDBR.ACCT_REF_NUM, i.COL_VAL DESC;
quit;

data SEQUENCE;
input number;
cards;
2
3
4
5
6
7
8
9
10
11
;
run;

Proc sort data=COLLATERALS_AFS nodupkey; by ACCT_REF_NUM; Run;

PROC SQL;							
CREATE TABLE COLLATERALS_ALS AS	(
	SELECT 
	ACCT_REF_NUM,
	/*COLL_AMT,*/CO_ORIG_VAL AS COLL_AMT,
	CO_ORIG_VAL,
	CO_TYPE,
	ALN_PA_ZIP_CD,
	ALN_PA_STATE,
	COUNTRY,
	ct.COLL_TYPE_DESC
	FROM (	
		SELECT 
	    FDBR.ACCT_REF_NUM,
	    /*,COALESCE(F.COLL_AMT, B.COLLATERAL_VALUE) AS COLL_AMT,*/
		FDBR.COLL_AMT,
		FLAT.CO_ORIG_VAL,
		FLAT.CO_TYPE,
		FLAT.ALN_PA_ZIP_CD,
		FLAT.ALN_PA_STATE,
		' ' AS COUNTRY,
		1 AS PART
		FROM (SELECT ACCT_REF_NUM, CIS_ACCT_ID, COLL_AMT FROM WHS.W_FDBR_BW WHERE BATCH_ID = &batch_WHS) FDBR
		JOIN (SELECT * FROM ELIGIBLELOANS_CATEG WHERE SYS = 'ALS') pledge
		ON pledge.ACCTNBR = FDBR.ACCT_REF_NUM
	    /*FROM (SELECT ACCOUNT_KEY, COLL_AMT, SUB_SYSTEM_KEY, GL_ACCOUNT_KEY, BATCH_ID FROM MRT.F_ACCOUNTS WHERE BATCH_ID = 20180930) F
	    JOIN (SELECT CIS_ACCT_ID, SUB_SYSTEM_ID, ACCOUNT_NUMBER, ACCOUNT_KEY, ACCT_REF_NUM FROM MRT.D_ACCOUNTS) D
	    ON F.ACCOUNT_KEY = D.ACCOUNT_KEY
		JOIN (SELECT * FROM ELIGIBLELOANS_CATEG WHERE SYS = 'ALS') pledge
		ON pledge.ACCTNBR = D.ACCT_REF_NUM
	    JOIN (SELECT * FROM MRT.D_SUB_SYSTEM WHERE SUB_SYSTEM_ID = 'ALS') S
	    ON S.SUB_SYSTEM_KEY = F.SUB_SYSTEM_KEY
	    JOIN MRT.D_GL_ACCOUNT GL
	    ON GL.GL_ACCOUNT_KEY = F.GL_ACCOUNT_KEY
	    LEFT JOIN (SELECT ACCOUNT_KEY, APPLICATION_KEY FROM MRT.APP_ACCT_MAP) MAP
	    ON MAP.ACCOUNT_KEY = F.ACCOUNT_KEY
	    LEFT JOIN (SELECT APPLICATION_KEY, BATCH_ID, COLLATERAL_VALUE FROM MRT.F_APPLICATIONS) B
	    ON MAP.APPLICATION_KEY = B.APPLICATION_KEY
	    AND F.BATCH_ID = B.BATCH_ID*/     

		LEFT JOIN (
				SELECT RT_CTL1, RT_CTL2, RT_ACCT_NUM, CO_ORIG_VAL, CO_TYPE, ALN_PA_ZIP_CD, ALN_PA_STATE FROM WHS.W_ALS_FLAT WHERE BATCH_ID = &batch_WHS
		) FLAT
		on cats(put(input(RT_CTL1,4.),z4.),						
		put(input(RT_CTL2,4.),z4.), '00000000',							
		RT_ACCT_NUM) = FDBR.CIS_ACCT_ID


	    UNION ALL


		SELECT 
		fdbr.ACCT_REF_NUM, 
		FLAT.curr_value,
		FLAT.orig_value, 
		FLAT.coll_type_cd, 
		FLAT.coll_zip_code, 
		"" as ALN_PA_STATE,
		FLAT.coll_country,
		2 AS PART
		FROM 
		(													
			SELECT 							
			coll.BATCH_ID													
			,'ALS' AS sub_system_id													
			,(coll.RSK_CO_CTL2)													
			AS bank_number													
			,cats(			
			put(input(coll.RSK_CO_CTL1,4.),z4.),			
			put(input(coll.RSK_CO_CTL2,4.),z4.),			
			'00000000',			
			coll.RSK_CO_ACCT_NUM,			
			put(c.number,z2.)			
			) as item_number																										
			,CASE c.number													
			WHEN 2 THEN coll.RSK_CO_ORIG_VAL_02													
			WHEN 3 THEN coll.RSK_CO_ORIG_VAL_03													
			WHEN 4 THEN coll.RSK_CO_ORIG_VAL_04													
			WHEN 5 THEN coll.RSK_CO_ORIG_VAL_05													
			WHEN 6 THEN coll.RSK_CO_ORIG_VAL_06													
			WHEN 7 THEN coll.RSK_CO_ORIG_VAL_07													
			WHEN 8 THEN coll.RSK_CO_ORIG_VAL_08													
			WHEN 9 THEN coll.RSK_CO_ORIG_VAL_09													
			WHEN 10 THEN coll.RSK_CO_ORIG_VAL_10													
			WHEN 11 THEN coll.RSK_CO_ORIG_VAL_11													
			END													
			AS orig_value													
			,CASE c.number													
			WHEN 2 THEN coll.RSK_CO_CURR_VAL_02													
			WHEN 3 THEN coll.RSK_CO_CURR_VAL_03													
			WHEN 4 THEN coll.RSK_CO_CURR_VAL_04													
			WHEN 5 THEN coll.RSK_CO_CURR_VAL_05													
			WHEN 6 THEN coll.RSK_CO_CURR_VAL_06													
			WHEN 7 THEN coll.RSK_CO_CURR_VAL_07													
			WHEN 8 THEN coll.RSK_CO_CURR_VAL_08													
			WHEN 9 THEN coll.RSK_CO_CURR_VAL_09													
			WHEN 10 THEN coll.RSK_CO_CURR_VAL_10													
			WHEN 11 THEN coll.RSK_CO_CURR_VAL_11													
			END													
			AS curr_value													
			,CASE c.number													
			WHEN 2 THEN coll.RSK_CO_TYPE_02													
			WHEN 3 THEN coll.RSK_CO_TYPE_03													
			WHEN 4 THEN coll.RSK_CO_TYPE_04													
			WHEN 5 THEN coll.RSK_CO_TYPE_05													
			WHEN 6 THEN coll.RSK_CO_TYPE_06													
			WHEN 7 THEN coll.RSK_CO_TYPE_07													
			WHEN 8 THEN coll.RSK_CO_TYPE_08													
			WHEN 9 THEN coll.RSK_CO_TYPE_09													
			WHEN 10 THEN coll.RSK_CO_TYPE_10													
			WHEN 11 THEN coll.RSK_CO_TYPE_11													
			END													
			AS coll_type_cd													
			,CASE c.number													
			WHEN 2 THEN coll.RSK_CO_ZIP_CD_02													
			WHEN 3 THEN coll.RSK_CO_ZIP_CD_03													
			WHEN 4 THEN coll.RSK_CO_ZIP_CD_04													
			WHEN 5 THEN coll.RSK_CO_ZIP_CD_05													
			WHEN 6 THEN coll.RSK_CO_ZIP_CD_06													
			WHEN 7 THEN coll.RSK_CO_ZIP_CD_07													
			WHEN 8 THEN coll.RSK_CO_ZIP_CD_08													
			WHEN 9 THEN coll.RSK_CO_ZIP_CD_09													
			WHEN 10 THEN coll.RSK_CO_ZIP_CD_10													
			WHEN 11 THEN coll.RSK_CO_ZIP_CD_11													
			END													
			AS coll_zip_code																										
			,CASE c.number													
			WHEN 2 THEN coll.RSK_CO_CONTRY_02													
			WHEN 3 THEN coll.RSK_CO_CONTRY_03													
			WHEN 4 THEN coll.RSK_CO_CONTRY_04													
			WHEN 5 THEN coll.RSK_CO_CONTRY_05													
			WHEN 6 THEN coll.RSK_CO_CONTRY_06													
			WHEN 7 THEN coll.RSK_CO_CONTRY_07													
			WHEN 8 THEN coll.RSK_CO_CONTRY_08													
			WHEN 9 THEN coll.RSK_CO_CONTRY_09													
			WHEN 10 THEN coll.RSK_CO_CONTRY_10													
			WHEN 11 THEN coll.RSK_CO_CONTRY_11													
			END													
			AS coll_country													
			FROM WHS.W_ALS_COLLSUPP coll													
			CROSS JOIN SEQUENCE c													
			WHERE coll.BATCH_ID = &batch_WHS					
		) FLAT
		LEFT JOIN MRT.D_ACCOUNTS m							
		ON SUBSTR (item_number, 1, (LENGTH (item_number) - 2)) = CIS_ACCT_ID													
		join (select CIS_ACCT_ID, ACCT_REF_NUM from WHS.W_FDBR_BW where BATCH_ID = &batch_WHS) fdbr							
		on m.ACCT_REF_NUM = fdbr.ACCT_REF_NUM							
		JOIN ELIGIBLELOANS_CATEG pledge							
		on fdbr.ACCT_REF_NUM = pledge.ACCTNBR
	) ALS
	LEFT JOIN MRT.D_COLLATERAL_TYPE CT
	ON 'ALS' = ct.SUB_SYSTEM_ID
	AND ALS.CO_TYPE = ct.COLL_TYPE_CD
	)
	ORDER BY ALS.ACCT_REF_NUM, ALS.COLL_AMT DESC                    							
;							
QUIT;

Proc sort data=COLLATERALS_ALS nodupkey; by ACCT_REF_NUM; Run;

proc sql;
CREATE TABLE COLLATERALS_SBA_DFP AS (
	SELECT 
	FDBR.ACCT_REF_NUM AS ACCT_REF_NUM, 
	FDBR.COLL_AMT AS curr_value,
	0 AS orig_value, 
	0 AS coll_type_cd, 
	0 AS coll_zip_code, 
	0 AS coll_country
	FROM (SELECT * FROM WHS.W_FDBR_BW WHERE BATCH_ID = &batch_WHS AND COLL_AMT IS NOT NULL AND COLL_AMT > 0) FDBR
	JOIN (SELECT * FROM ELIGIBLELOANS_CATEG WHERE CATEGORY = '710' AND SYS IN ('DFP')) pledge
	on pledge.ACCTNBR = FDBR.ACCT_REF_NUM

	UNION 

	SELECT 
	FDBR.ACCT_REF_NUM,
	SBA_COL.CURR_FMV_VALUE AS CURR_VALUE,
	SBA_COL.ORIG_APPR_VAL AS orig_value, 
	0 AS coll_type_cd,  
	0 AS coll_zip_code, 
	0 AS coll_country,

	SBA_COL.COLLAT_CODE,
	CT.COLL_TYPE_DESC

	FROM (SELECT SBA_LN_MGR_NBR, CIS_ACCT_ID FROM WHS.W_SBA_FLAT WHERE BATCH_ID = &batch_WHS) SBA
	JOIN (SELECT SBA_LN_MGR_NBR, COLLAT_CODE, 
			SUM(CURR_FMV_VALUE) AS CURR_FMV_VALUE, 
			SUM(input(ORIG_APPR_VAL, 10.2)) as ORIG_APPR_VAL format = 10.2
			FROM WHS.W_SBA_COLLAT WHERE BATCH_ID = &batch_WHS /*AND CURR_FMV_VALUE > 0*/
			GROUP BY 1,2) SBA_COL
			ON COMPRESS(SBA_COL.SBA_LN_MGR_NBR) = SBA.SBA_LN_MGR_NBR
	JOIN (SELECT * FROM WHS.W_FDBR_BW WHERE BATCH_ID = &batch_WHS) FDBR
	ON FDBR.CIS_ACCT_ID = SBA.CIS_ACCT_ID

	LEFT JOIN MRT.D_COLLATERAL_TYPE CT
	ON 'SBA' = ct.SUB_SYSTEM_ID
	AND SBA_COL.COLLAT_CODE = ct.COLL_TYPE_CD

)
ORDER BY ACCT_REF_NUM, CURR_VALUE DESC
;
quit;

Proc sort data=COLLATERALS_SBA_DFP nodupkey; by ACCT_REF_NUM; Run;

PROC SQL;
create table FDBR AS (
	select 
	CIS_ACCT_ID,
	ACCT_REF_NUM,
	CUST_ADD_ID,
	NAME_ADD_1,
	TRAN_CLASS,
	CITY,
	STATE,
	ZIP_CODE,
	INT_PYMT_FREQ,
	substr(INT_PYMT_FREQ,1,1) as prefix_INT_PYMT_FREQ, 
	substr(INT_PYMT_FREQ,2,3) as sufix_INT_PYMT_FREQ, 
	input(substr(INT_PYMT_FREQ,2,4),3.)/365 as ratio_Days_INT_PYMT_FREQ, 
	input(substr(INT_PYMT_FREQ,2,4),3.)/12 as ratio_Months_INT_PYMT_FREQ,
	PRIN_PYMT_FREQ,
	substr(PRIN_PYMT_FREQ,1,1) as prefix_PRIN_PYMT_FREQ, 
	substr(PRIN_PYMT_FREQ,2,3) as sufix_PRIN_PYMT_FREQ, 
	input(substr(PRIN_PYMT_FREQ,2,4),3.)/365 as ratio_Days_PRIN_PYMT_FREQ, 
	input(substr(PRIN_PYMT_FREQ,2,4),3.)/12 as ratio_Months_PRIN_PYMT_FREQ,
	NXT_IPYMT_DATE,
	LST_PYMT_DATE,
	NXT_PPYMT_DATE,
	CURR_BAL, 
	CURR_LINE,
	CPN_RATE,
	MAT_DATE,
	REPR_CODE,
	ORIG_DATE,
	input(put(ORIG_DATE,8.),yymmdd10.) as ORIGINAL_DATE,
	LST_RENEW_DATE,
	ORIG_BOOK,
	ORIG_LINE,
	ORIG_TRM_INTERVAL,
	ORIG_TRM_PERIODS,
	CASE WHEN ORIG_TRM_INTERVAL = 'M' THEN 
		input(put(INTNX('MONTH',Calculated ORIGINAL_DATE,ORIG_TRM_PERIODS),yymmdd10.),yymmdd10.) 
		WHEN ORIG_TRM_INTERVAL = 'D' THEN 
		input(put(INTNX('DAY',Calculated ORIGINAL_DATE,ORIG_TRM_PERIODS),yymmdd10.),yymmdd10.) 
		ELSE .
	END as AMORT_DATE format=yymmdd10.,
	PDUE_DAYS,
	REPR_DRVE_RATE,
	REPR_SPRD_VAL,
	CEILING_RATE,
	FLOOR_RATE,
	COMP_CALL,
	UNFUND_AMT,
	SIC_CODE,
	PROD_CODE,
	REV_FLAG,
	OPT_NBR1	
	from WHS.W_FDBR_BW where BATCH_ID = &batch_WHS
);
QUIT;

proc sql;
create table citizenship as (
	select ACCT.*
	,PARTY.CTZN_CNTRY_ID, 
	PARTY.FULL_NAME from (
	  SELECT 
	  FDBR.ACCT_REF_NUM, FDBR.BATCH_ID,
	  pledge.SYS,
	  pledge.CATEGORY,
	  party_lnk.Cust_nbr
	  FROM (
	    select ACCT_REF_NUM, BATCH_ID, CIS_ACCT_ID  
		from WHS.W_FDBR_BW where BATCH_ID = &batch_WHS
	  ) fdbr
	  JOIN (select * from ELIGIBLELOANS_CATEG WHERE CATEGORY <> '842') pledge
		on FDBR.ACCT_REF_NUM = pledge.ACCTNBR
	  LEFT JOIN (
	    select BATCH_ID, CIS_ACCT_ID, Cust_nbr from WHS.W_CIF_PARTY_LINK
	  ) party_lnk
	  ON PARTY_LNK.CIS_ACCT_ID = FDBR.CIS_ACCT_ID AND PARTY_LNK.BATCH_ID = FDBR.BATCH_ID
	) acct
	LEFT JOIN (  
		select CUST_NBR, CTZN_CNTRY_ID, FULL_NAME, BATCH_ID from WHS.W_CIF_PARTY where BATCH_ID = &batch_WHS
	) PARTY
	ON PARTY.BATCH_ID = acct.BATCH_ID and party.CUST_NBR = acct.Cust_nbr
);
quit;


proc sql;
CREATE TABLE DSCR AS (
SELECT *
                 FROM (SELECT DISTINCT
				 			  DA.ACCT_REF_NUM,
                              DA.ACCOUNT_KEY
                             /*,DA.BATCH_ID*/
                             /*,DA.CIS_ACCT_ID*/
                             /*,NOI.CUST_ID*/
                             /*,NOI.CRE_PROP_ID*/
                             /*,NOI.ARCHIVE_ID*/
                             ,NOI.STMT_DATE
                             ,NOI.STMT_ID
                             ,NOI.ALLDEBTSERV_DSCR AS DSCR
							 /*,AP.MRA_RATING_ID*/
                         FROM HST.D_ACCOUNTS DA
                              LEFT JOIN RADB.MTHLY_AUDIT_LOG_APPROVED_CURR AP
                                 ON (    DA.BATCH_ID = AP.BATCH_ID
                                     AND DA.MRA_LOAN_ID = AP.MRA_RATING_ID)
                              LEFT JOIN
                              (SELECT AP.BATCH_ID
                                     ,N.CUST_ID
                                     ,N.CRE_PROP_ID
                                     ,N.ARCHIVE_ID
                                     ,N.STMT_ID
                                     ,S.STMT_DATE
                                     ,SN.STMT_DATE2
                                     ,N.ALLDEBTSERV_DSCR
                                 FROM RADB.CRE_PROPERTY_NOI N
                                      LEFT JOIN
                                      (SELECT CUST_ID
                                             ,CRE_PROP_ID
                                             ,ARCHIVE_ID
                                             ,ID
                                             ,STMT_DATE
                                                 AS STMT_DATE2
                                         FROM RADB.CRE_STATEMENTS) SN
                                         ON     N.CUST_ID = SN.CUST_ID
                                            AND N.CRE_PROP_ID =
                                                   SN.CRE_PROP_ID
                                            AND N.ARCHIVE_ID = SN.ARCHIVE_ID
                                            AND N.STMT_ID = SN.ID
                                      INNER JOIN RADB.CRE_STATEMENTS S
                                         ON     N.CUST_ID = S.CUST_ID
                                            AND N.CRE_PROP_ID = S.CRE_PROP_ID
                                            AND N.ARCHIVE_ID = S.ARCHIVE_ID
                                            AND N.STMT_ID = S.ID
                                      INNER JOIN
                                      RADB.MTHLY_AUDIT_LOG_APPROVED_CURR AP
                                         ON     S.CUST_ID = AP.CUST_ID
                                            AND S.CRE_PROP_ID =
                                                   AP.CRE_PROP_ID
                                            AND S.ARCHIVE_ID =
                                                   AP.LGD_ARCHIVE_ID
                                WHERE     UPPER (S.HIDDEN) = 'FALSE'
                                      AND AP.BATCH_ID = &batch_WHS
                                      AND datepart(SN.STMT_DATE2) <= &_processing_date.) NOI
                                 ON (    AP.CUST_ID = NOI.CUST_ID
                                     AND AP.CRE_PROP_ID = NOI.CRE_PROP_ID
                                     AND AP.LGD_ARCHIVE_ID = NOI.ARCHIVE_ID)
                        WHERE DA.BATCH_ID = &batch_HST)
                WHERE DSCR IS NOT NULL
)
ORDER BY DA.ACCT_REF_NUM, NOI.STMT_DATE DESC, NOI.STMT_ID DESC
;
quit;

Proc sort data=DSCR out=DSCR_MAX ; by ACCOUNT_KEY; Run;

Proc sort data=DSCR out=DSCR_MIN; by ACCOUNT_KEY STMT_DATE; Run;

Proc sort data=DSCR_MIN nodupkey; by ACCOUNT_KEY; Run;

Proc sort data=DSCR_MAX nodupkey; by ACCOUNT_KEY; Run;



/*********Additional data sets for Balloon Loans*********/

/*Importing balloon loans from Basel*/
data BalloonLoans_Basel;
infile '/SAS_RiskModelDev/SAS_FSB/Pledged loans/Inputs/Ballon Loans/Balloon loans QUERY_RESULT.csv'
/*delimiter=','*/
missover
/*firstobs=2*/
DSD
lrecl = 32767;

    format CIS_ACCT_ID $40.;
    format SBSYS_CD $8.;
    format MATY_DT $9.;
    format GL_ACCT_NBR $8.;
    format PRDT_CODE_DESC $200.;
    format LAST_PERIOD $9.;
    format PRIN_BAL;
    format PAYMENT_VAL ;
    format PCT_LAST_PAYMENT;
 input
             CIS_ACCT_ID $
             SBSYS_CD $
             MATY_DT $
             GL_ACCT_NBR $
             PRDT_CODE_DESC $
             LAST_PERIOD $
             PRIN_BAL
             PAYMENT_VAL
             PCT_LAST_PAYMENT
 ;
 run;


/*Applying the Pledge Loans Filter

->0.6  -->  69950
->0.4  --> 133029
->0.25 --> 241458
 But the DQ for PrincipalPaymentFrequency doesn't improve*/
proc sql;
create table BalloonLoans_Basel_Final as
	select Balloon.*, pledge.ACCTNBR as ACCT_REF_NUM
	from BalloonLoans_Basel Balloon 
		JOIN (SELECT CIS_ACCT_ID, ACCT_REF_NUM FROM FDBR) FDBR
		ON Balloon.CIS_ACCT_ID= FDBR.CIS_ACCT_ID
		JOIN MRT.D_ACCOUNTS MDA1
		ON MDA1.CIS_ACCT_ID = FDBR.CIS_ACCT_ID
		JOIN (select DISTINCT ACCTNBR, SYS from ELIGIBLELOANS_CATEG) pledge
		ON FDBR.ACCT_REF_NUM = pledge.ACCTNBR
			WHERE pledge.ACCTNBR NE "" AND Balloon.PCT_LAST_PAYMENT>0.6;
quit;


/*Additional Logic for Syndicated SBA*/
PROC SQL;
create table Syndicated_SBA_prev as
  SELECT 'SBA' AS sub_system_id
      ,syndicated_from_cis_acct_id AS sold_from_cis_acct_id
      ,child_cis_acct_id AS sold_to_cis_acct_id
  FROM (SELECT chld.cis_acct_id AS child_cis_acct_id, 
		prnt.cis_acct_id AS syndicated_from_cis_acct_id
          FROM (SELECT cis_acct_id, SUBSTR(cis_acct_id, 1,28) AS grp_id
                  FROM MRT.D_ACCOUNTS
                 WHERE SUBSTR(cis_acct_id, 31, 1) =  'B') chld
               JOIN (SELECT cis_acct_id, SUBSTR(cis_acct_id, 1,28) AS grp_id
                       FROM MRT.D_ACCOUNTS
                      WHERE SUBSTR(cis_acct_id, 31, 1) =  'A') prnt
                  ON chld.grp_id = prnt.grp_id);
QUIT;

proc sql;
create table Syndicated_SBA as
select distinct sold_from_cis_acct_id
from Syndicated_SBA_prev;
quit;



/*Replicating the Secured/Unsecured Indicator Logic from IFRS9*/
proc sql;
create table Eligible_Sec_Unsec_base as
select LOANS.*, COL.COL_TP, COL.COLL_TYPE_DESC,
	case when CATEGORY IN ("741","740") then
		case when COL.COL_TP IN ("@","") then "740"
			 when LOANS.SYS||COL.COL_TP 
				NOT IN ('CLS999',
						'CLS418',
						'ALSPYI',
						'ALS111',
						'CLS499',
						'LIQ499',
						'SBLOC2UNS',
						'IMCORUNS',
						'SAVUNS',
						'ELCUNS',
						'DDAUNS',
						'ELC2UNS',
						'CORR2UNS',
						'PRSPRUNS',
						'SBAUNS',
						'ODLUNS',
						'OECUNS',
						'OEC2UNS',
						'SBLOCUNS',
						'ALSUNS',
						'CLS403',
						'LIQ403',
						'ALSEND',
						'CLSEND',
						'CLS421',
						'LIQ421',
						'CLSUNS',
						'ALS151') THEN "741"
						ELSE "740" END 
	END as CATEGORY_SEC_UNSEC

from ELIGIBLELOANS_CATEG LOANS
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
	ON COL.ACCT_REF_NUM = LOANS.ACCTNBR;
quit;

/*Additional logic for Secured/Unsecured Indicator*/
proc sql;
create table Eligible_Sec_Unsec_Addit
(drop= CATEGORY_SEC_UNSEC COL_TP COLL_TYPE_DESC
rename=(CATEGORY_SEC_UNSEC_NEW = CATEGORY_SEC_UNSEC))as
select Elig.*,
case when Elig.CATEGORY IN ("741","740") then
	case when GL.GLDESC_H02 = 'CONSUMER DIRECT' then
		case when MSP.SYS_PROD_CODE = 'ACUN' OR Elig.COL_TP = 'UNS' then "740"
		else 
			case when (Elig.COL_TP IN ('CAR','USE') OR Elig.COL_TP LIKE 'CD%') OR 
		    (FIND(Elig.COLL_TYPE_DESC,'AUTO') > 0 AND FIND(Elig.COLL_TYPE_DESC,'NEW') > 0) OR
		    (FIND(Elig.COLL_TYPE_DESC,'AUTO') > 0 AND FIND(Elig.COLL_TYPE_DESC,'USED') > 0) OR 
		    (FIND(Elig.COLL_TYPE_DESC,'CERT') > 0 AND FIND(Elig.COLL_TYPE_DESC,'DEPOSIT') > 0) OR
		    MSP.SYS_PROD_CODE LIKE 'D%' then "741"
			else Elig.CATEGORY_SEC_UNSEC
			end
		end
	else Elig.CATEGORY_SEC_UNSEC
	end
end as CATEGORY_SEC_UNSEC_NEW format = $3.

from Eligible_Sec_Unsec_base Elig
LEFT JOIN (select MRA_LOAN_ID, LOAN_LINE_IND, ACCOUNT_KEY, CIS_ACCT_ID
from MRT.D_ACCOUNTS) MDA1
on MDA1.CIS_ACCT_ID = Elig.CIS_ACCT_ID
LEFT JOIN (select ACCOUNT_KEY, GL_ACCOUNT_KEY from HST.F_ACCOUNTS where batch_id = &batch_HST) FA
ON MDA1.ACCOUNT_KEY = FA.ACCOUNT_KEY
LEFT JOIN (select ACCOUNT_KEY, APPLICATION_KEY from MRT.APP_ACCT_MAP) AAM
ON FA.ACCOUNT_KEY = AAM.ACCOUNT_KEY
LEFT JOIN (select APPLICATION_KEY, SYS_PRODUCT_KEY from MRT.F_APPLICATIONS where batch_id = &batch_MRT) FAPP
ON FAPP.APPLICATION_KEY = AAM.APPLICATION_KEY
LEFT JOIN (select SYS_PRODUCT_KEY, SYS_PROD_CODE from MRT.D_SYSTEM_PRODUCT) MSP
ON MSP.SYS_PRODUCT_KEY = FAPP.SYS_PRODUCT_KEY
LEFT JOIN (select GL_ACCOUNT_KEY, GLDESC_H02 from HST.D_GL_ACCOUNT where batch_id = &batch_HST) GL
ON FA.GL_ACCOUNT_KEY = GL.GL_ACCOUNT_KEY;
quit;

/*Overwriting Category for Secured/Unsecured based on IFRS9 Logic*/
data PLEDGE_LOANS_RECAT(drop=CATEGORY_SEC_UNSEC);
set Eligible_Sec_Unsec_Addit;
	IF CATEGORY IN ("741","740") THEN
		CATEGORY = CATEGORY_SEC_UNSEC;
run;



/*Log to show which loans were recategorized*/
proc sql;
create table Loans_Recateg as
select cat.*
from ELIGIBLELOANS_CATEG cat LEFT JOIN
PLEDGE_LOANS_RECAT recat
ON cat.ACCTNBR = recat.ACCTNBR AND cat.CATEGORY = recat.CATEGORY
WHERE recat.ACCTNBR = "" AND recat.CATEGORY = "";
quit;

/*Getting the details*/
proc sql;
create table Loans_Recat_Detail as
select Loans.ACCTNBR, Loans.CATEGORY, Recat.CATEGORY as NEW_CATEGORY
from Loans_Recateg Loans LEFT JOIN
PLEDGE_LOANS_RECAT Recat
ON Loans.ACCTNBR = Recat.ACCTNBR;
quit;

/*Exporting*/
%exportXLSX(Loans_Recat_Detail,
/SAS_RiskModelDev/SAS_FSB/Pledged loans/Recategorized_Loans.xlsx,
Recategorized);