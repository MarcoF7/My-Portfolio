SET DEFINE ON
DEFINE dayid = 20181231
DEFINE monthid = DEC18

--We pull important fields from the CUST_COUNTS_BETA_CUMULATIVE
CREATE TABLE ONLINE_Demos_&&monthid AS
SELECT t1.DAY_ID, 
      t1.CUST_ID, 
      t1.ACTIVE_BILLPAY_30DAY, 
      t1.ACTIVE_BILLPAY_90DAY, 
      t1.BILLPAY2OF3, 
      t1.BILLPAY3OF3, 
      t1.ACTIVE_MOBILE_30DAY, 
      t1.ACTIVE_MOBILE_90DAY, 
      t1.MOBILE2OF3, 
      t1.MOBILE3OF3, 
      t1.ACTIVE_PROFILE_30DAY, 
      t1.ACTIVE_PROFILE_90DAY, 
      t1.PROFILE2OF3, 
      t1.PROFILE3OF3
  FROM CI_RPT.CUST_COUNTS_BETA_CUMULATIVE t1
  WHERE t1.DAY_ID = &&dayid;

--We pull important fields from RPTG_TRANSACTION_SEGMENT
CREATE TABLE segment_demos_&&monthid AS
SELECT t1.MONTH_CODE, 
      t1.CUST_ID, 
      t1.SEGMENT
  FROM SC90866.RPTG_TRANSACTION_SEGMENT t1
  WHERE t1.MONTH_CODE = substr(&&dayid,1,6); --YYYYMM

--We pull important fields from CA_DIM_ACCT
CREATE TABLE EPL_Demos_&&monthid AS 
SELECT t1.DAY_ID, 
      t1.CUST_ID, 
      t1.ACCT_ID, 
      t1.PTYP_CD, 
      t1.STYP_CD, 
      t1.CLOS_DT
  FROM CA_OWNER.CA_DIM_ACCT t1
  WHERE t1.DAY_ID = &&dayid AND t1.CLOS_DT = to_date('30-DEC-9999','DD-MON-YY') AND t1.PTYP_CD = 'IL' AND t1.STYP_CD = 'EXP';

CREATE TABLE QUERY_FOR_EPL_&&monthid AS 
SELECT DISTINCT t1.DAY_ID, 
      t1.CUST_ID, 
      1 AS EXP_LN
  FROM EPL_Demos_&&monthid t1;

--Pull important fields from DIM_CUST_AUX
CREATE TABLE GEN_1_&&monthid AS 
SELECT t1.DAY_ID,
      t1.CUST_NBR,
      t1.DIM_CUST_KEY,
      t1.MTH_ID,
      --We don't want to report DOB for customers over 120 years old
      case when extract(year from t2.DT) - extract(year from t1.DOB) <= 120 then t1.DOB end AS DOB,
      t2.DT,
      --We don't want to report Age_yrs for customers over 120 years old
      case when extract(year from t2.DT) - extract(year from t1.DOB) <= 120 then
                extract(year from t2.DT) - extract(year from t1.DOB) end AS Age_yrs
  FROM (SELECT DAY_ID, CUST_NBR, DIM_CUST_KEY, MTH_ID, DOB 
        FROM SDSS_OWNER.DIM_CUST_AUX WHERE DAY_ID = &&dayid) t1
       INNER JOIN SDSS_OWNER.DIM_DAY t2 
        ON (t1.DAY_ID = t2.DAY_ID);

--We calculate GEN1 based on the DOB
CREATE TABLE GEN_2_&&monthid AS 
SELECT t1.*, 
        (CASE WHEN t1.DOB >= to_date('01-JAN-2005','DD-MON-YY') THEN 'G. Generation Z'
                WHEN t1.DOB>=to_date('01-JAN-1981','DD-MON-YY') THEN 'F. Millennials'
                WHEN t1.DOB>=to_date('01-JAN-1961','DD-MON-YY') THEN 'E. Generation X'
                WHEN t1.DOB>=to_date('01-JAN-1946','DD-MON-YY') THEN 'D. Baby Boomers'
                WHEN t1.DOB>=to_date('01-JAN-1924','DD-MON-YY') THEN 'C. Silent Generation'
                WHEN t1.DOB>=to_date('01-JAN-1900','DD-MON-YY') THEN 'B. Greatest Generation'
                WHEN t1.DOB>=to_date('01-JAN-1883','DD-MON-YY') THEN 'A. Lost Generation'
                ELSE 'H. Unknown' END) AS GEN1, 
        t2.CUST_ID
  FROM GEN_1_&&monthid t1, (SELECT DAY_ID, DIM_CUST_KEY, CUST_ID, CUST_NBR FROM CA_OWNER.CA_DIM_CUST WHERE DAY_ID = &&dayid) t2
    WHERE t1.DAY_ID = t2.DAY_ID AND t1.CUST_NBR = t2.CUST_NBR;

--We pull important fields from CA_DIM_CUST
CREATE TABLE TENURE1_&&monthid AS 
SELECT t1.*,
       t2.DT,
       --We calculate the rounded number of months between the CALC_CUST_OPEN_DT and the present date
       round(months_between(t2.DT, t1.CALC_CUST_OPEN_DT),0) as TENURE_MONTHS,
       (CASE WHEN months_between(t2.DT, t1.CALC_CUST_OPEN_DT) < 1 THEN 0
            ELSE round(months_between(t2.DT, t1.CALC_CUST_OPEN_DT),0) END) AS TENURE_MTHS_FINAL
      FROM 
      (SELECT DAY_ID, DIM_CUST_KEY, CUST_ID, CUST_NBR, CALC_CUST_OPEN_DT, CALC_CUST_CLOS_DT, OPEN_MTH_ID
       FROM CA_OWNER.CA_DIM_CUST WHERE DAY_ID = &&dayid) t1
        INNER JOIN SDSS_OWNER.DIM_DAY t2 
            ON (t1.DAY_ID = t2.DAY_ID);

--We pull important fields from DIM_CUST_DEMOG
CREATE TABLE step1_Demos_&&monthid AS 
SELECT t1.DAY_ID, 
      t1.CUST_ID, 
      t1.OCPN_CD, 
      t1.ETHNICY_CD, 
      t1.EDUC_LVL
  FROM 
    (SELECT DAY_ID, CUST_ID, OCPN_CD, ETHNICY_CD, EDUC_LVL FROM SDSS_OWNER.DIM_CUST_DEMOG WHERE DAY_ID = &&dayid) t1, 
    (SELECT DAY_ID, DIM_CUST_KEY, CUST_ID FROM CA_OWNER.CA_DIM_CUST WHERE DAY_ID = &&dayid) t2
        WHERE t1.DAY_ID = t2.DAY_ID AND t1.CUST_ID = t2.CUST_ID;

--We pull some fields from DNB_DIM_MASTER
CREATE TABLE DUNS_Demos_&&monthid AS 
SELECT DISTINCT t1.HSHLD_ID, 
      t1.CUST_ID, 
      t1.SALES_VOL, 
      t1.SALES_V_CD, 
      t1.EES_TOTAL, 
      t1.EES_TTL_CD, 
      t1.EES_HERE, 
      t1.YR_STARTED, 
      t1.STATUS_IND, 
      t1.SUB_IND, 
      t1.MANUF_IND, 
      t1.LEGAL_STAT, 
      t1.OWNS_RENTS, 
      t1.SQ_FOOTAGE, 
      t1.SIC1, 
      t1.COTTAGE_IND, 
      t1.COMPANYTYPE, 
      t1.NAICS_CD, 
      t1.NAICS_DESC, 
      (SUBSTR(t1.SIC1, 1, 8)) AS SIC_8, 
      (SUBSTR(t1.SIC1, 1, 6)) AS SIC_6, 
      (SUBSTR(t1.SIC1, 1, 4)) AS SIC_4, 
      (SUBSTR(t1.SIC1, 1, 2)) AS SIC_2
  FROM CI_OPS.DNB_DIM_MASTER t1
  WHERE t1.CUST_ID IS NOT NULL;

--We need some fields from CUST_GEO_CODE
CREATE TABLE GEO1_Demos_&&monthid AS 
SELECT t1.*,
      t2.STATE_NAME, 
      t3.CBSA_NAME, 
      --If the FIPS_STATE_CD is null, we want the FOOTPRINT to be null as well
      (CASE WHEN t1.FIPS_STATE_CD is null then null
            WHEN t1.FIPS_STATE_CD IN ('01','04','06','08','12','35','48') THEN 1 
            ELSE 0 END) AS FOOTPRINT
  FROM (SELECT DAY_ID, CUST_ID, DIM_CUST_KEY, LATITUDE, LONGITUDE, MATCH_CODE, BG_CODE, CBSA_CODE, 
        CUST_NBR, FIPS_STATE_CD, FIPS_COUNTY_CD, CENSUS_TRACK_CD, CENSUS_BLOCK_CD, ZIP5_CD, ZIP5_PLUS_4_CD
        FROM CI_OPS.CUST_GEO_CODE WHERE DAY_ID = &&dayid) t1
   LEFT JOIN (SELECT DISTINCT STATE_NAME, STATE_CODE FROM CI_OPS.DIM_CBSA) t2 
    ON t1.FIPS_STATE_CD = t2.STATE_CODE
   LEFT JOIN (SELECT DISTINCT CBSA_NAME, CBSA_CODE FROM CI_OPS.DIM_CBSA) t3 
    ON t1.CBSA_CODE = t3.CBSA_CODE;

--We pull some columns from the CUST_COUNTS_BETA_CUMULATIVE table
CREATE TABLE STEP2_Demos_&&monthid AS 
SELECT t1.*, 
      t2.HSHLD_ID, 
      t2.DIM_HSHLD_KEY
      --Commented DIM_CUST_KEY1 because it is not used anywhere in the program
      --,t2.DIM_CUST_KEY AS DIM_CUST_KEY1
  FROM (SELECT DAY_ID, CUST_ID, DIM_CUST_KEY, CUST_OPEN_FLAG, CUST_REPORTABLE_FLAG, LOB_CD, CUST_TYPE, CUST_STRUCTURAL_SEGMENT, 
        TOT_DPST_AMT, TOT_LOAN_AMT, TOT_INVST_AMT, CLRSPND_IND, INVST_IND, MERCHNT_IND, OLD_CROSS_SELL, NEW_CROSS_SELL, BUS_CHKG_IND, 
        BUS_CR_CARD_IND, BUS_LOANS_IND, BUS_MONEY_MKT_IND, BUS_SVNGS_IND, CD_IND, CNSMR_CHKG_IND, CNSMR_CR_CARD_IND, 
        CNSMR_INSTLMT_LOANS_IND, CNSMR_MONEY_MKT_IND, CNSMR_SVNGS_IND, MTGE_IND, OVRDFT_LOC_IND, TOT_HOME_EQTY_IND
        FROM CI_RPT.CUST_COUNTS_BETA_CUMULATIVE WHERE DAY_ID = &&dayid) t1
        LEFT JOIN (SELECT DAY_ID, MTH_ID, HSHLD_ID, DIM_HSHLD_KEY, CUST_ID, DIM_CUST_KEY FROM SDSS_OWNER.LNK_CUST_HSHLD
                    WHERE DAY_ID = &&dayid) t2 
            ON t1.CUST_ID = t2.CUST_ID;

--Join to pull OCPN_CD and EDUC_LVL
CREATE TABLE STEP3_Demos_&&monthid AS 
SELECT t1.*, 
      t2.OCPN_CD,
      --Commented the following because ETHNICY_CD and CUST_ID1 are not used anywhere in the program
      --t2.ETHNICY_CD, 
      --t2.CUST_ID AS CUST_ID1, 
      t2.EDUC_LVL
  FROM STEP2_Demos_&&monthid t1
       LEFT JOIN step1_Demos_&&monthid t2 
       ON t1.DAY_ID = t2.DAY_ID AND t1.CUST_ID = t2.CUST_ID;

--Join to pull some fields from the DIM_HSHLD_WLTH table
CREATE TABLE STEP4_Demos_&&monthid AS 
SELECT t1.*, 
      t2.TOT_ASSET_AMT, 
      t2.TOT_DPST_AMT AS TOT_DPST_AMT1, 
      t2.TOT_STK_AMT, 
      t2.TOT_BOND_AMT, 
      t2.TOT_MUTL_FUND_AMT, 
      t2.TOT_ANNUITY_AMT, 
      t2.TOT_OTH_EQTY_AMT
  FROM STEP3_Demos_&&monthid t1
  LEFT JOIN (SELECT DAY_ID, MTH_ID, DIM_HSHLD_KEY, HSHLD_ID, TOT_ASSET_AMT, TOT_DPST_AMT, TOT_STK_AMT, TOT_BOND_AMT, 
            TOT_MUTL_FUND_AMT, TOT_ANNUITY_AMT, TOT_OTH_EQTY_AMT FROM SDSS_OWNER.DIM_HSHLD_WLTH WHERE DAY_ID = &&dayid) t2 
    ON t1.HSHLD_ID = t2.HSHLD_ID
        WHERE t1.CUST_OPEN_FLAG = 1;

--Join to pull some fields from the DIM_HSHLD_DEMOG table
CREATE TABLE STEP5_Demos_&&monthid AS 
SELECT t1.*, 
      t2.AGE_CD, 
      t2.INCRM_AGE, 
      t2.EST_INCM_CD, 
      t2.IPA_CD, 
      t2.PCYC_CD, 
      t2.PCYC_LIFESTAGE_GRP, 
      t2.PRIZM_CD, 
      t2.PRIZM_SOC_GRP, 
      t2.PRIZM_LIFESTAGE_GROUP, 
      t2.MARTL_STATUS_CD, 
      t2.CHILD_IND, 
      t2.AGE_0_TO_2_MALE_IND, 
      t2.AGE_0_TO_2_FEML_IND, 
      t2.AGE_0_TO_2_UNKN_GNDR_IND, 
      t2.AGE_3_TO_5_MALE_IND, 
      t2.AGE_3_TO_5_FEML_IND, 
      t2.AGE_3_TO_5_UNKN_GNDR_IND, 
      t2.AGE_6_TO_10_MALE_IND, 
      t2.AGE_6_TO_10_FEML_IND, 
      t2.AGE_6_TO_10_UNKN_GNDR_IND, 
      t2.AGE_11_TO_15_MALE_IND, 
      t2.AGE_11_TO_15_FEML_IND, 
      t2.AGE_11_TO_15_UNKN_GNDR_IND, 
      t2.AGE_16_TO_17_MALE_IND, 
      t2.AGE_16_TO_17_FEML_IND, 
      t2.AGE_16_TO_17_UNKN_GNDR_IND
  FROM STEP4_Demos_&&monthid t1
       LEFT JOIN (SELECT DAY_ID, MTH_ID, DIM_HSHLD_KEY, HSHLD_ID, AGE_CD, INCRM_AGE, EST_INCM_CD, IPA_CD, PCYC_CD, 
                 PCYC_LIFESTAGE_GRP, PRIZM_CD, PRIZM_SOC_GRP, PRIZM_LIFESTAGE_GROUP, MARTL_STATUS_CD, CHILD_IND, 
                 AGE_0_TO_2_MALE_IND, AGE_0_TO_2_FEML_IND, AGE_0_TO_2_UNKN_GNDR_IND, AGE_3_TO_5_MALE_IND, AGE_3_TO_5_FEML_IND, 
                 AGE_3_TO_5_UNKN_GNDR_IND, AGE_6_TO_10_MALE_IND, AGE_6_TO_10_FEML_IND, AGE_6_TO_10_UNKN_GNDR_IND, 
                 AGE_11_TO_15_MALE_IND, AGE_11_TO_15_FEML_IND, AGE_11_TO_15_UNKN_GNDR_IND, AGE_16_TO_17_MALE_IND, 
                 AGE_16_TO_17_FEML_IND, AGE_16_TO_17_UNKN_GNDR_IND FROM SDSS_OWNER.DIM_HSHLD_DEMOG WHERE DAY_ID = &&dayid) t2 
                    ON t1.HSHLD_ID = t2.HSHLD_ID;

--Join to pull some fields from the CA_FACT_CUST_BAL_XSELL_MTHLY table
CREATE TABLE STEP6_Demos_&&monthid AS 
SELECT t1.*,
      t2.BUS_CHKG_BAL, 
      t2.BUS_CR_CARD_BAL, 
      t2.BUS_LOANS_BAL, 
      t2.BUS_MONEY_MKT_BAL, 
      t2.BUS_SVNGS_BAL, 
      t2.CD_BAL, 
      t2.CNSMR_CHKG_BAL, 
      t2.CNSMR_CR_CARD_BAL, 
      t2.CNSMR_INSTLMT_LOANS_BAL, 
      t2.CNSMR_MONEY_MKT_BAL, 
      t2.CNSMR_SVNGS_BAL, 
      t2.MTGE_BAL, 
      t2.OVRDFT_LOC_BAL, 
      t2.TOT_HOME_EQTY_BAL
  FROM STEP5_Demos_&&monthid t1
       LEFT JOIN (SELECT DAY_ID, DIM_CUST_KEY, CUST_NBR, CUST_ID, BUS_CHKG_BAL, BUS_CR_CARD_BAL, BUS_LOANS_BAL, BUS_MONEY_MKT_BAL, 
                  BUS_SVNGS_BAL, CD_BAL, CNSMR_CHKG_BAL, CNSMR_CR_CARD_BAL, CNSMR_INSTLMT_LOANS_BAL, CNSMR_MONEY_MKT_BAL, 
                  CNSMR_SVNGS_BAL, MTGE_BAL, OVRDFT_LOC_BAL, TOT_HOME_EQTY_BAL FROM CI_OPS.CA_FACT_CUST_BAL_XSELL_MTHLY 
                  WHERE DAY_ID = &&dayid) t2 
                    ON t1.DAY_ID = t2.DAY_ID AND t1.CUST_ID = t2.CUST_ID;

--Join to pull DOB, DT, Age_yrs and GEN1
CREATE TABLE STEP7_Demos_&&monthid AS 
SELECT t1.*, 
      t2.DOB, 
      t2.DT, 
      t2.Age_yrs, 
      t2.GEN1
  FROM STEP6_Demos_&&monthid t1
       LEFT JOIN GEN_2_&&monthid t2 ON (t1.DAY_ID = t2.DAY_ID) AND (t1.CUST_ID = t2.CUST_ID);

--We calculate the indicators UA, AF, MA, HV
CREATE TABLE STEP8_Demos_&&monthid AS 
SELECT t1.*, 
      /* UA */
        (CASE WHEN (t1.TOT_DPST_AMT + t1.TOT_INVST_AMT) > 999999 THEN 1
              WHEN t1.TOT_LOAN_AMT>999999 THEN 1
              WHEN t1.TOT_ASSET_AMT>999999 THEN 1
              WHEN t1.IPA_CD in('1','2') THEN 1
              ELSE 0 END) AS UA, 
      /* AF */
        (CASE WHEN (t1.TOT_DPST_AMT + t1.TOT_INVST_AMT)>424999 and (t1.TOT_DPST_AMT + t1.TOT_INVST_AMT)<1000000 THEN 1
              WHEN t1.TOT_LOAN_AMT>749999 AND  t1.TOT_LOAN_AMT<1000000 THEN 1
              WHEN t1.TOT_ASSET_AMT>429999 AND t1.TOT_ASSET_AMT<1000000 THEN 1
              WHEN t1.IPA_CD in('3','4') THEN 1
              WHEN t1.PCYC_LIFESTAGE_GRP = 'M1 FINANCIAL ELITE' THEN 1
              ELSE 0 END) AS AF, 
      /* MA */
        (CASE WHEN (t1.TOT_DPST_AMT + t1.TOT_INVST_AMT)>74999 and (t1.TOT_DPST_AMT + t1.TOT_INVST_AMT)<499999 THEN 1
              WHEN t1.TOT_LOAN_AMT>299999 AND  t1.TOT_LOAN_AMT<750000 THEN 1
              WHEN t1.TOT_ASSET_AMT>74999 AND t1.TOT_ASSET_AMT<425000 THEN 1
              WHEN t1.IPA_CD in('7','6','5') THEN 1
              WHEN t1.PCYC_LIFESTAGE_GRP IN('M2 WEALTHY ACHIEVERS', 'Y1 UPWARDLY MOBILE', 'F1 FLOURISHING FAMILIES') THEN 1
              ELSE 0 END) AS MA, 
      /* HV */
        (CASE WHEN (t1.TOT_DPST_AMT + t1.TOT_INVST_AMT)>4999 and (t1.TOT_DPST_AMT + t1.TOT_INVST_AMT)<74999 THEN 1
              WHEN t1.TOT_LOAN_AMT>24999 AND  t1.TOT_LOAN_AMT<300000 THEN 1
              WHEN t1.TOT_ASSET_AMT>4999 AND t1.TOT_ASSET_AMT<75000 THEN 1
              WHEN t1.IPA_CD in('8','9') THEN 1
              WHEN t1.PCYC_LIFESTAGE_GRP IN('M3 UPSCALE EMPTY NESTS', 'F2 UPSCALE EARNERS', 'F3 MASS MIDDLE CLASS') THEN 1
              ELSE 0 END) AS HV
  FROM STEP7_Demos_&&monthid t1;

--We calculate the Affluence based on previous calculated UA, AF, MA, HV indicators
CREATE TABLE STEP9_Demos_&&monthid AS 
SELECT t1.*, 
      /* Affluence */
        (CASE WHEN t1.UA=1 AND t1.CUST_TYPE IN ('R','N') THEN 'A. Ultra Affluent'
              WHEN t1.UA!=1 AND AF=1 AND t1.CUST_TYPE IN ('R','N') THEN 'B. Affluent'
              WHEN t1.UA!=1 AND AF!=1 AND MA=1 AND t1.CUST_TYPE IN ('R','N') THEN 'C. Mass Affluent'
              WHEN t1.UA!=1 AND AF!=1 AND MA!=1 AND HV=1 AND t1.CUST_TYPE IN('R','N') THEN 'D. High Value Mass Market'
              WHEN t1.UA!=1 AND AF!=1 AND MA!=1 AND HV!=1 AND t1.CUST_TYPE IN('R','N') THEN 'E. Low Value Mass Market'
              ELSE 'F. Unknown' END) AS Affluence
  FROM STEP8_Demos_&&monthid t1;

--We calculate indicators YU, YW, YP, FY, FO, IS, MC, PC, GY, PI
CREATE TABLE STEP10_Demos_&&monthid AS 
SELECT t1.*, 

      /* YU */
        (CASE WHEN t1.AGE_CD='1' and t1.INCRM_AGE<36 and NVL(t1.CHILD_IND,0)<1 and t1.OCPN_CD IN ('6','Z') THEN 1
              WHEN t1.PCYC_CD IN ('57','58') THEN 1
              WHEN NVL(t1.Age_yrs,0)<36 and NVL(t1.CHILD_IND,0)<1 and t1.OCPN_CD IN ('6','Z') THEN 1
              ELSE 0 END) AS YU, 
      /* YW */
        (CASE WHEN t1.AGE_CD='1' and t1.INCRM_AGE<36 and NVL(t1.CHILD_IND,0)<1 and t1.EDUC_LVL IN (1,4) THEN 1
              WHEN t1.PCYC_CD IN ('43','54') THEN 1
              WHEN NVL(t1.Age_yrs,0)<36 and NVL(t1.CHILD_IND,0)<1 and t1.EDUC_LVL IN (1,4) THEN 1
              ELSE 0 END) AS YW, 
      /* YP */
        (CASE WHEN t1.AGE_CD='1' and t1.INCRM_AGE<36 and NVL(t1.CHILD_IND,0)<1 and t1.EDUC_LVL IN (2,3) THEN 1
              WHEN t1.PCYC_CD IN ('30','34','39','49') THEN 1
              WHEN NVL(t1.Age_yrs,0)<36 and NVL(t1.CHILD_IND,0)<1 and t1.EDUC_LVL IN (2,3) THEN 1 ELSE 0 END) AS YP, 
      /* FY */
        (CASE WHEN t1.PCYC_CD IN('25','41','47','48','51','56') THEN 1
              WHEN NVL(t1.Age_yrs,0)<65 and t1.CHILD_IND=1 and t1.AGE_0_TO_2_MALE_IND=1 THEN 1
              WHEN NVL(t1.Age_yrs,0)<65 and t1.CHILD_IND=1 and t1.AGE_0_TO_2_FEML_IND=1 THEN 1
              WHEN NVL(t1.Age_yrs,0)<65 and t1.CHILD_IND=1 and t1.AGE_0_TO_2_UNKN_GNDR_IND=1 THEN 1
              WHEN NVL(t1.Age_yrs,0)<65 and t1.CHILD_IND=1 and t1.AGE_3_TO_5_MALE_IND=1 THEN 1
              WHEN NVL(t1.Age_yrs,0)<65 and t1.CHILD_IND=1 and t1.AGE_3_TO_5_FEML_IND=1 THEN 1
              WHEN NVL(t1.Age_yrs,0)<65 and t1.CHILD_IND=1 and t1.AGE_3_TO_5_UNKN_GNDR_IND=1 THEN 1
              WHEN NVL(t1.Age_yrs,0)<65 and t1.CHILD_IND=1 and t1.AGE_6_TO_10_MALE_IND=1 THEN 1
              WHEN NVL(t1.Age_yrs,0)<65 and t1.CHILD_IND=1 and t1.AGE_6_TO_10_FEML_IND=1 THEN 1
              WHEN NVL(t1.Age_yrs,0)<65 and t1.CHILD_IND=1 and t1.AGE_6_TO_10_UNKN_GNDR_IND=1 THEN 1
              WHEN t1.AGE_CD='1' and t1.INCRM_AGE<65 and t1.CHILD_IND=1 and t1.AGE_0_TO_2_MALE_IND=1 THEN 1
              WHEN t1.AGE_CD='1' and t1.INCRM_AGE<65 and t1.CHILD_IND=1 and t1.AGE_0_TO_2_FEML_IND=1 THEN 1
              WHEN t1.AGE_CD='1' and t1.INCRM_AGE<65 and t1.CHILD_IND=1 and t1.AGE_0_TO_2_UNKN_GNDR_IND=1 THEN 1
              WHEN t1.AGE_CD='1' and t1.INCRM_AGE<65 and t1.CHILD_IND=1 and t1.AGE_3_TO_5_MALE_IND=1 THEN 1
              WHEN t1.AGE_CD='1' and t1.INCRM_AGE<65 and t1.CHILD_IND=1 and t1.AGE_3_TO_5_FEML_IND=1 THEN 1
              WHEN t1.AGE_CD='1' and t1.INCRM_AGE<65 and t1.CHILD_IND=1 and t1.AGE_3_TO_5_UNKN_GNDR_IND=1 THEN 1
              WHEN t1.AGE_CD='1' and t1.INCRM_AGE<65 and t1.CHILD_IND=1 and t1.AGE_6_TO_10_MALE_IND=1 THEN 1
              WHEN t1.AGE_CD='1' and t1.INCRM_AGE<65 and t1.CHILD_IND=1 and t1.AGE_6_TO_10_FEML_IND=1 THEN 1
              WHEN t1.AGE_CD='1' and t1.INCRM_AGE<65 and t1.CHILD_IND=1 and t1.AGE_6_TO_10_UNKN_GNDR_IND=1 THEN 1
              ELSE 0 END) AS FY, 
      /* FO */
        (CASE WHEN t1.PCYC_CD IN ('07','09','23','32','33','36','44','46') THEN 1
              WHEN NVL(t1.Age_yrs,0)<65 and t1.CHILD_IND=1 and t1.AGE_11_TO_15_MALE_IND=1 THEN 1
              WHEN NVL(t1.Age_yrs,0)<65 and t1.CHILD_IND=1 and t1.AGE_11_TO_15_FEML_IND=1 THEN 1
              WHEN NVL(t1.Age_yrs,0)<65 and t1.CHILD_IND=1 and t1.AGE_11_TO_15_UNKN_GNDR_IND=1 THEN 1
              WHEN NVL(t1.Age_yrs,0)<65 and t1.CHILD_IND=1 and t1.AGE_16_TO_17_MALE_IND=1 THEN 1
              WHEN NVL(t1.Age_yrs,0)<65 and t1.CHILD_IND=1 and t1.AGE_16_TO_17_FEML_IND=1 THEN 1
              WHEN NVL(t1.Age_yrs,0)<65 and t1.CHILD_IND=1 and t1.AGE_16_TO_17_UNKN_GNDR_IND=1 THEN 1
              WHEN t1.AGE_CD='1' and t1.INCRM_AGE<65 and t1.CHILD_IND=1 and t1.AGE_11_TO_15_MALE_IND=1 THEN 1
              WHEN t1.AGE_CD='1' and t1.INCRM_AGE<65 and t1.CHILD_IND=1 and t1.AGE_11_TO_15_FEML_IND=1 THEN 1
              WHEN t1.AGE_CD='1' and t1.INCRM_AGE<65 and t1.CHILD_IND=1 and t1.AGE_11_TO_15_UNKN_GNDR_IND=1 THEN 1
              WHEN t1.AGE_CD='1' and t1.INCRM_AGE<65 and t1.CHILD_IND=1 and t1.AGE_16_TO_17_MALE_IND=1 THEN 1
              WHEN t1.AGE_CD='1' and t1.INCRM_AGE<65 and t1.CHILD_IND=1 and t1.AGE_16_TO_17_FEML_IND=1 THEN 1
              WHEN t1.AGE_CD='1' and t1.INCRM_AGE<65 and t1.CHILD_IND=1 and t1.AGE_16_TO_17_UNKN_GNDR_IND=1 THEN 1
              ELSE 0 END) AS FO, 
      /* IS */
        --Since IS is a keyword, we have to use Double Quotes in the alias
        (CASE WHEN t1.AGE_CD='1' and t1.INCRM_AGE>35  and t1.INCRM_AGE<65 and NVL(t1.CHILD_IND,0)<1 and t1.MARTL_STATUS_CD IN('S','B') THEN 1
              WHEN t1.PCYC_CD IN('35','40','45','50','52','55') THEN 1
              WHEN t1.Age_yrs>35 and  NVL(t1.Age_yrs,0)<65 and NVL(t1.CHILD_IND,0)<1 and t1.MARTL_STATUS_CD IN('S','B') THEN 1
              ELSE 0 END) AS "IS", 
      /* MC */
        (CASE WHEN t1.AGE_CD='1' and t1.INCRM_AGE>35  and t1.INCRM_AGE<45 and NVL(t1.CHILD_IND,0)<1 and t1.MARTL_STATUS_CD IN('M','A') THEN 1
           WHEN t1.PCYC_CD IN('15','19','24','37') THEN 1
           WHEN t1.Age_yrs>35 and NVL(t1.Age_yrs,0)<45 and NVL(t1.CHILD_IND,0)<1 and t1.MARTL_STATUS_CD IN('M','A') THEN 1
           ELSE 0 END) AS MC, 
      /* PC */
        (CASE WHEN t1.AGE_CD='1' and t1.INCRM_AGE>44  and t1.INCRM_AGE<65 and NVL(t1.CHILD_IND,0)<1 and t1.MARTL_STATUS_CD IN('M','A') THEN 1
           WHEN t1.PCYC_CD IN('03','05','08','10','12','14','17','21','22','29','31') THEN 1
           WHEN t1.Age_yrs>44 and NVL(t1.Age_yrs,0)<65 and NVL(t1.CHILD_IND,0)<1 and t1.MARTL_STATUS_CD IN('M','A') THEN 1
           ELSE 0 END) AS PC, 
      /* GY */
        (CASE WHEN t1.AGE_CD='1' and t1.INCRM_AGE>64 THEN 1
              WHEN t1.PCYC_CD IN('02','04','06','11','13','16','18','20','26','27','28','38','42','53') THEN 1
              WHEN t1.Age_yrs>64 THEN 1
              ELSE 0 END) AS GY, 
      /* PI */
        (CASE WHEN t1.PCYC_CD IN('01') THEN 1
              ELSE 0 END) AS PI
  FROM STEP9_Demos_&&monthid t1;

--Since IS is a keyword, we have to use Double Quotes "" to refer to the variable
--We calculate the HH_LIFESTAGE
CREATE TABLE STEP11_Demos_&&monthid AS 
SELECT t1.*, 
      /* HH_LIFESTAGE */
        (CASE WHEN t1.PI=1 THEN '01. Pinnacle'
              WHEN t1.GY=1 THEN '02. Golden Years'
              WHEN t1.PC=1 THEN '03. Pre-Retirement Couples'
              WHEN t1.MC=1 THEN '04. Mid Life Couples'
              WHEN t1."IS"=1 THEN '05. Independent Singles'
              WHEN t1.FO=1 THEN '06. Family Life - Older Kids'
              WHEN t1.FY=1 THEN '07. Family Life - Younger Kids'
              WHEN t1.YP=1 THEN '08. Young Professionals'
              WHEN t1.YW=1 THEN '09. Young Workers'
              WHEN t1.YU=1 THEN '10. Young Student or Unemployed'
              ELSE '11. Unknown' END) AS HH_LIFESTAGE
  FROM STEP10_Demos_&&monthid t1;

--Join to pull some fields from TENURE1
CREATE TABLE STEP12_Demos_&&monthid AS 
SELECT t1.*, 
      t2.CALC_CUST_OPEN_DT, 
      t2.CALC_CUST_CLOS_DT, 
      t2.OPEN_MTH_ID, 
      t2.DT AS DT1, 
      t2.TENURE_MONTHS, 
      t2.TENURE_MTHS_FINAL
  FROM STEP11_Demos_&&monthid t1
       LEFT JOIN TENURE1_&&monthid t2 ON (t1.CUST_ID = t2.CUST_ID);

--CREATE TABLE JIM.OCT18_DEMOS_ AS (SAS Name)
CREATE TABLE &&monthid._DEMOS_MF AS 
SELECT t1.*, 
      t2.ACTIVE_BILLPAY_30DAY, 
      t2.ACTIVE_BILLPAY_90DAY, 
      t2.BILLPAY3OF3, 
      t2.ACTIVE_MOBILE_30DAY, 
      t2.ACTIVE_MOBILE_90DAY, 
      t2.MOBILE3OF3, 
      t2.ACTIVE_PROFILE_30DAY, 
      t2.ACTIVE_PROFILE_90DAY, 
      t2.PROFILE3OF3, 
      t3.SEGMENT
  FROM STEP12_Demos_&&monthid  t1
       INNER JOIN ONLINE_Demos_&&monthid t2 
        ON t1.DAY_ID = t2.DAY_ID AND t1.CUST_ID = t2.CUST_ID
       LEFT JOIN segment_demos_&&monthid t3 
        ON t1.CUST_ID = t3.CUST_ID;

--We pull some fields from STICKY3       
CREATE TABLE &&monthid._DEMOS_MF2 AS 
SELECT t1.*, 
      t2.RETIREMENT_IND, 
      t2.WALLET3OF3, 
      t2.DIR_DEP_1OF3, 
      t2.ACTIVE_DBT_CRD_3OF3, 
      t2.ACTIVE_DBT_CRD_30DAY
  FROM &&monthid._DEMOS_MF t1
       LEFT JOIN CI_RPT.STICKY3 t2 
        ON t1.DAY_ID = t2.DAY_ID AND t1.CUST_ID = t2.CUST_ID;

--Join to pull fields from DUNS_Demos
CREATE TABLE &&monthid._DEMOS_MF3 AS 
SELECT t1.*, 
      t2.SALES_VOL, 
      t2.SALES_V_CD, 
      t2.EES_TOTAL, 
      t2.EES_TTL_CD, 
      t2.EES_HERE, 
      t2.YR_STARTED, 
      t2.STATUS_IND, 
      t2.SUB_IND, 
      t2.MANUF_IND, 
      t2.LEGAL_STAT, 
      t2.OWNS_RENTS, 
      t2.SQ_FOOTAGE, 
      t2.SIC1, 
      t2.COTTAGE_IND, 
      t2.COMPANYTYPE, 
      t2.NAICS_CD, 
      t2.NAICS_DESC, 
      t2.SIC_8, 
      t2.SIC_6, 
      t2.SIC_4, 
      t2.SIC_2
  FROM  &&monthid._DEMOS_MF2 t1
       LEFT JOIN DUNS_Demos_&&monthid t2 
        ON t1.CUST_ID = t2.CUST_ID;

--Join to pull fields from GEO1_Demos
CREATE TABLE &&monthid._DEMOS_MF4 AS 
SELECT t1.*, 
      trim(t2.MATCH_CODE) as MATCH_CODE, 
      trim(t2.BG_CODE) as BG_CODE, 
      t2.CBSA_CODE, 
      t2.CBSA_NAME, 
      t2.CUST_NBR, 
      t2.FIPS_STATE_CD, 
      t2.STATE_NAME, 
      t2.FIPS_COUNTY_CD, 
      t2.CENSUS_TRACK_CD, 
      t2.CENSUS_BLOCK_CD, 
      t2.ZIP5_CD, 
      t2.ZIP5_PLUS_4_CD, 
      t2.FOOTPRINT
  FROM &&monthid._DEMOS_MF3 t1
       LEFT JOIN GEO1_Demos_&&monthid t2 
        ON t1.DAY_ID = t2.DAY_ID AND t1.CUST_ID = t2.CUST_ID;

--We calculate HAS_IXI and HAS_PSYCLE indicators
CREATE TABLE &&monthid._DEMOS_MF5 AS 
SELECT t1.*, 
     (CASE WHEN t1.TOT_ASSET_AMT>0 THEN 1 ELSE 0 END) AS HAS_IXI, 
     (CASE WHEN t1.PCYC_CD is not null THEN 1 ELSE 0 END) AS HAS_PSYCLE,
      t2.EXP_LN
  FROM &&monthid._DEMOS_MF4 t1
       LEFT JOIN QUERY_FOR_EPL_&&monthid t2 
        ON t1.DAY_ID = t2.DAY_ID AND t1.CUST_ID = t2.CUST_ID;

--ACH requirement  
CREATE TABLE QUERY_FOR_ACH_DATA AS 
SELECT t2.DAY_ID, 
	  t2.DIM_ACCT_KEY, 
	  t2.CUST_ID, 
	  t2.ACCT_ID, 
	  t2.ACCT_NBR, 
	  t1.ACH_STD_ENTRY_CLASS_ID, 
	  t1.ACH_TRANS_TYPE_ID, 
	  t1.EFF_ENTRY_DT, 
	  t1.TRANS_AMT
  FROM (SELECT DAY_ID, DIM_ACCT_KEY, ACCT_ID, ACCT_NBR, ACH_STD_ENTRY_CLASS_ID, ACH_TRANS_TYPE_ID, EFF_ENTRY_DT, TRANS_AMT
		FROM SDSS_OWNER.FACT_ACH_DAILY WHERE (EFF_ENTRY_DT BETWEEN add_months(to_date(&&dayid, 'YYYYMMDD'),-2) + 1 AND to_date(&&dayid,'YYYYMMDD')) 
		AND ACH_STD_ENTRY_CLASS_ID IN (636,626) AND ACH_TRANS_TYPE_ID IN (22,32)) t1
   INNER JOIN (SELECT DAY_ID, DIM_ACCT_KEY, CUST_ID, ACCT_ID, ACCT_NBR
				FROM CA_OWNER.CA_DIM_ACCT WHERE DAY_ID = &&dayid) t2 
   ON t1.ACCT_ID = t2.ACCT_ID;

--We aggregate the ACH information at customer level
CREATE TABLE FOR_ACH_DATA_AGG AS 
SELECT t1.CUST_ID, 
		COUNT(t1.ACH_TRANS_TYPE_ID) AS ACH_CREDITS, 
		SUM(t1.TRANS_AMT) AS ACH_CREDIT_DOLLARS
  FROM QUERY_FOR_ACH_DATA t1
  GROUP BY t1.CUST_ID;

--We pull the ACH fields  
CREATE TABLE &&monthid._DEMOS_MF6 AS 
SELECT t1.*, 
      t2.ACH_CREDITS, 
      t2.ACH_CREDIT_DOLLARS, 
       t1.SEGMENT AS TRANS_SEGMT
  FROM &&monthid._DEMOS_MF5 t1
       LEFT JOIN FOR_ACH_DATA_AGG t2 ON (t1.CUST_ID = t2.CUST_ID);

--We drop the columns that we don't need so that we match vs SAS output
ALTER TABLE &&monthid._DEMOS_MF6 DROP (AGE_0_TO_2_MALE_IND ,AGE_0_TO_2_FEML_IND ,AGE_0_TO_2_UNKN_GNDR_IND ,AGE_3_TO_5_MALE_IND ,AGE_3_TO_5_FEML_IND ,AGE_3_TO_5_UNKN_GNDR_IND ,AGE_6_TO_10_MALE_IND ,AGE_6_TO_10_FEML_IND ,AGE_6_TO_10_UNKN_GNDR_IND ,AGE_11_TO_15_MALE_IND ,AGE_11_TO_15_FEML_IND ,AGE_11_TO_15_UNKN_GNDR_IND ,AGE_16_TO_17_MALE_IND ,AGE_16_TO_17_FEML_IND ,AGE_16_TO_17_UNKN_GNDR_IND ,UA ,AF ,MA ,HV ,YU ,YW ,YP ,FY ,FO ,"IS" ,MC ,PC ,GY ,PI ,DT1 ,TENURE_MONTHS ,SEGMENT ,ACH_CREDITS ,ACH_CREDIT_DOLLARS);

--&&monthid._DEMOS_MF6 is the final table for the Oracle Demos Generation

---------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------TABLE VERIFICATION ORACLE VS SAS--------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------

--Comparing number of records Oracle vs SAS
select count(*) from sc05069.DEC18_DEMO;
select count(*), cust_id from sc05069.DEC18_DEMO group by cust_id order by count(*) desc;
select count(*) from &&monthid._DEMOS_MF6;
select count(*), cust_id from &&monthid._DEMOS_MF6 group by cust_id order by count(*) desc;


--We verify that the Oracle and SAS demo tables have the same information (same records)
DROP TABLE Dif_Demos_Oracle_SAS PURGE;
CREATE TABLE Dif_Demos_Oracle_SAS AS
SELECT *
FROM (
(SELECT DAY_ID ,CUST_ID ,DIM_CUST_KEY ,CUST_OPEN_FLAG ,CUST_REPORTABLE_FLAG ,LOB_CD ,CUST_TYPE ,CUST_STRUCTURAL_SEGMENT ,TOT_DPST_AMT ,TOT_LOAN_AMT ,TOT_INVST_AMT ,CLRSPND_IND ,INVST_IND ,MERCHNT_IND ,OLD_CROSS_SELL ,NEW_CROSS_SELL ,BUS_CHKG_IND ,BUS_CR_CARD_IND ,BUS_LOANS_IND ,BUS_MONEY_MKT_IND ,BUS_SVNGS_IND ,CD_IND ,CNSMR_CHKG_IND ,CNSMR_CR_CARD_IND ,CNSMR_INSTLMT_LOANS_IND ,CNSMR_MONEY_MKT_IND ,CNSMR_SVNGS_IND ,MTGE_IND ,OVRDFT_LOC_IND ,TOT_HOME_EQTY_IND ,HSHLD_ID ,DIM_HSHLD_KEY ,OCPN_CD ,EDUC_LVL ,TOT_ASSET_AMT ,TOT_DPST_AMT1 ,TOT_STK_AMT ,TOT_BOND_AMT ,TOT_MUTL_FUND_AMT ,TOT_ANNUITY_AMT ,TOT_OTH_EQTY_AMT ,AGE_CD ,INCRM_AGE ,EST_INCM_CD ,IPA_CD ,PCYC_CD ,PCYC_LIFESTAGE_GRP ,PRIZM_CD ,PRIZM_SOC_GRP ,PRIZM_LIFESTAGE_GROUP ,MARTL_STATUS_CD ,CHILD_IND ,BUS_CHKG_BAL ,BUS_CR_CARD_BAL ,BUS_LOANS_BAL ,BUS_MONEY_MKT_BAL ,BUS_SVNGS_BAL ,CD_BAL ,CNSMR_CHKG_BAL ,CNSMR_CR_CARD_BAL ,CNSMR_INSTLMT_LOANS_BAL ,CNSMR_MONEY_MKT_BAL ,CNSMR_SVNGS_BAL ,MTGE_BAL ,OVRDFT_LOC_BAL ,TOT_HOME_EQTY_BAL ,DT ,AFFLUENCE ,CALC_CUST_OPEN_DT ,CALC_CUST_CLOS_DT ,OPEN_MTH_ID ,ACTIVE_BILLPAY_30DAY ,ACTIVE_BILLPAY_90DAY ,BILLPAY3OF3 ,ACTIVE_MOBILE_30DAY ,ACTIVE_MOBILE_90DAY ,MOBILE3OF3 ,ACTIVE_PROFILE_30DAY ,ACTIVE_PROFILE_90DAY ,PROFILE3OF3 ,RETIREMENT_IND ,WALLET3OF3 ,DIR_DEP_1OF3 ,ACTIVE_DBT_CRD_3OF3 ,ACTIVE_DBT_CRD_30DAY ,SALES_VOL ,SALES_V_CD ,EES_TOTAL ,EES_TTL_CD ,EES_HERE ,YR_STARTED ,STATUS_IND ,SUB_IND ,MANUF_IND ,LEGAL_STAT ,OWNS_RENTS ,SQ_FOOTAGE ,SIC1 ,COTTAGE_IND ,COMPANYTYPE ,NAICS_CD ,NAICS_DESC ,SIC_8 ,SIC_6 ,SIC_4 ,SIC_2 ,MATCH_CODE ,BG_CODE ,CBSA_CODE ,CUST_NBR ,FIPS_STATE_CD ,STATE_NAME ,FIPS_COUNTY_CD ,CENSUS_TRACK_CD ,CENSUS_BLOCK_CD ,ZIP5_CD ,ZIP5_PLUS_4_CD ,HAS_IXI ,HAS_PSYCLE ,EXP_LN ,TRANS_SEGMT
FROM sc05069.DEC18_DEMO
minus
SELECT DAY_ID ,CUST_ID ,DIM_CUST_KEY ,CUST_OPEN_FLAG ,CUST_REPORTABLE_FLAG ,LOB_CD ,CUST_TYPE ,CUST_STRUCTURAL_SEGMENT ,TOT_DPST_AMT ,TOT_LOAN_AMT ,TOT_INVST_AMT ,CLRSPND_IND ,INVST_IND ,MERCHNT_IND ,OLD_CROSS_SELL ,NEW_CROSS_SELL ,BUS_CHKG_IND ,BUS_CR_CARD_IND ,BUS_LOANS_IND ,BUS_MONEY_MKT_IND ,BUS_SVNGS_IND ,CD_IND ,CNSMR_CHKG_IND ,CNSMR_CR_CARD_IND ,CNSMR_INSTLMT_LOANS_IND ,CNSMR_MONEY_MKT_IND ,CNSMR_SVNGS_IND ,MTGE_IND ,OVRDFT_LOC_IND ,TOT_HOME_EQTY_IND ,HSHLD_ID ,DIM_HSHLD_KEY ,OCPN_CD ,EDUC_LVL ,TOT_ASSET_AMT ,TOT_DPST_AMT1 ,TOT_STK_AMT ,TOT_BOND_AMT ,TOT_MUTL_FUND_AMT ,TOT_ANNUITY_AMT ,TOT_OTH_EQTY_AMT ,AGE_CD ,INCRM_AGE ,EST_INCM_CD ,IPA_CD ,PCYC_CD ,PCYC_LIFESTAGE_GRP ,PRIZM_CD ,PRIZM_SOC_GRP ,PRIZM_LIFESTAGE_GROUP ,MARTL_STATUS_CD ,CHILD_IND ,BUS_CHKG_BAL ,BUS_CR_CARD_BAL ,BUS_LOANS_BAL ,BUS_MONEY_MKT_BAL ,BUS_SVNGS_BAL ,CD_BAL ,CNSMR_CHKG_BAL ,CNSMR_CR_CARD_BAL ,CNSMR_INSTLMT_LOANS_BAL ,CNSMR_MONEY_MKT_BAL ,CNSMR_SVNGS_BAL ,MTGE_BAL ,OVRDFT_LOC_BAL ,TOT_HOME_EQTY_BAL ,DT ,AFFLUENCE ,CALC_CUST_OPEN_DT ,CALC_CUST_CLOS_DT ,OPEN_MTH_ID ,ACTIVE_BILLPAY_30DAY ,ACTIVE_BILLPAY_90DAY ,BILLPAY3OF3 ,ACTIVE_MOBILE_30DAY ,ACTIVE_MOBILE_90DAY ,MOBILE3OF3 ,ACTIVE_PROFILE_30DAY ,ACTIVE_PROFILE_90DAY ,PROFILE3OF3 ,RETIREMENT_IND ,WALLET3OF3 ,DIR_DEP_1OF3 ,ACTIVE_DBT_CRD_3OF3 ,ACTIVE_DBT_CRD_30DAY ,SALES_VOL ,SALES_V_CD ,EES_TOTAL ,EES_TTL_CD ,EES_HERE ,YR_STARTED ,STATUS_IND ,SUB_IND ,MANUF_IND ,LEGAL_STAT ,OWNS_RENTS ,SQ_FOOTAGE ,SIC1 ,COTTAGE_IND ,COMPANYTYPE ,NAICS_CD ,NAICS_DESC ,SIC_8 ,SIC_6 ,SIC_4 ,SIC_2 ,MATCH_CODE ,BG_CODE ,CBSA_CODE ,CUST_NBR ,FIPS_STATE_CD ,STATE_NAME ,FIPS_COUNTY_CD ,CENSUS_TRACK_CD ,CENSUS_BLOCK_CD ,ZIP5_CD ,ZIP5_PLUS_4_CD ,HAS_IXI ,HAS_PSYCLE ,EXP_LN ,TRANS_SEGMT
 FROM &&monthid._DEMOS_MF6)
UNION ALL
(SELECT DAY_ID ,CUST_ID ,DIM_CUST_KEY ,CUST_OPEN_FLAG ,CUST_REPORTABLE_FLAG ,LOB_CD ,CUST_TYPE ,CUST_STRUCTURAL_SEGMENT ,TOT_DPST_AMT ,TOT_LOAN_AMT ,TOT_INVST_AMT ,CLRSPND_IND ,INVST_IND ,MERCHNT_IND ,OLD_CROSS_SELL ,NEW_CROSS_SELL ,BUS_CHKG_IND ,BUS_CR_CARD_IND ,BUS_LOANS_IND ,BUS_MONEY_MKT_IND ,BUS_SVNGS_IND ,CD_IND ,CNSMR_CHKG_IND ,CNSMR_CR_CARD_IND ,CNSMR_INSTLMT_LOANS_IND ,CNSMR_MONEY_MKT_IND ,CNSMR_SVNGS_IND ,MTGE_IND ,OVRDFT_LOC_IND ,TOT_HOME_EQTY_IND ,HSHLD_ID ,DIM_HSHLD_KEY ,OCPN_CD ,EDUC_LVL ,TOT_ASSET_AMT ,TOT_DPST_AMT1 ,TOT_STK_AMT ,TOT_BOND_AMT ,TOT_MUTL_FUND_AMT ,TOT_ANNUITY_AMT ,TOT_OTH_EQTY_AMT ,AGE_CD ,INCRM_AGE ,EST_INCM_CD ,IPA_CD ,PCYC_CD ,PCYC_LIFESTAGE_GRP ,PRIZM_CD ,PRIZM_SOC_GRP ,PRIZM_LIFESTAGE_GROUP ,MARTL_STATUS_CD ,CHILD_IND ,BUS_CHKG_BAL ,BUS_CR_CARD_BAL ,BUS_LOANS_BAL ,BUS_MONEY_MKT_BAL ,BUS_SVNGS_BAL ,CD_BAL ,CNSMR_CHKG_BAL ,CNSMR_CR_CARD_BAL ,CNSMR_INSTLMT_LOANS_BAL ,CNSMR_MONEY_MKT_BAL ,CNSMR_SVNGS_BAL ,MTGE_BAL ,OVRDFT_LOC_BAL ,TOT_HOME_EQTY_BAL ,DT ,AFFLUENCE ,CALC_CUST_OPEN_DT ,CALC_CUST_CLOS_DT ,OPEN_MTH_ID ,ACTIVE_BILLPAY_30DAY ,ACTIVE_BILLPAY_90DAY ,BILLPAY3OF3 ,ACTIVE_MOBILE_30DAY ,ACTIVE_MOBILE_90DAY ,MOBILE3OF3 ,ACTIVE_PROFILE_30DAY ,ACTIVE_PROFILE_90DAY ,PROFILE3OF3 ,RETIREMENT_IND ,WALLET3OF3 ,DIR_DEP_1OF3 ,ACTIVE_DBT_CRD_3OF3 ,ACTIVE_DBT_CRD_30DAY ,SALES_VOL ,SALES_V_CD ,EES_TOTAL ,EES_TTL_CD ,EES_HERE ,YR_STARTED ,STATUS_IND ,SUB_IND ,MANUF_IND ,LEGAL_STAT ,OWNS_RENTS ,SQ_FOOTAGE ,SIC1 ,COTTAGE_IND ,COMPANYTYPE ,NAICS_CD ,NAICS_DESC ,SIC_8 ,SIC_6 ,SIC_4 ,SIC_2 ,MATCH_CODE ,BG_CODE ,CBSA_CODE ,CUST_NBR ,FIPS_STATE_CD ,STATE_NAME ,FIPS_COUNTY_CD ,CENSUS_TRACK_CD ,CENSUS_BLOCK_CD ,ZIP5_CD ,ZIP5_PLUS_4_CD ,HAS_IXI ,HAS_PSYCLE ,EXP_LN ,TRANS_SEGMT
FROM &&monthid._DEMOS_MF6
minus
SELECT DAY_ID ,CUST_ID ,DIM_CUST_KEY ,CUST_OPEN_FLAG ,CUST_REPORTABLE_FLAG ,LOB_CD ,CUST_TYPE ,CUST_STRUCTURAL_SEGMENT ,TOT_DPST_AMT ,TOT_LOAN_AMT ,TOT_INVST_AMT ,CLRSPND_IND ,INVST_IND ,MERCHNT_IND ,OLD_CROSS_SELL ,NEW_CROSS_SELL ,BUS_CHKG_IND ,BUS_CR_CARD_IND ,BUS_LOANS_IND ,BUS_MONEY_MKT_IND ,BUS_SVNGS_IND ,CD_IND ,CNSMR_CHKG_IND ,CNSMR_CR_CARD_IND ,CNSMR_INSTLMT_LOANS_IND ,CNSMR_MONEY_MKT_IND ,CNSMR_SVNGS_IND ,MTGE_IND ,OVRDFT_LOC_IND ,TOT_HOME_EQTY_IND ,HSHLD_ID ,DIM_HSHLD_KEY ,OCPN_CD ,EDUC_LVL ,TOT_ASSET_AMT ,TOT_DPST_AMT1 ,TOT_STK_AMT ,TOT_BOND_AMT ,TOT_MUTL_FUND_AMT ,TOT_ANNUITY_AMT ,TOT_OTH_EQTY_AMT ,AGE_CD ,INCRM_AGE ,EST_INCM_CD ,IPA_CD ,PCYC_CD ,PCYC_LIFESTAGE_GRP ,PRIZM_CD ,PRIZM_SOC_GRP ,PRIZM_LIFESTAGE_GROUP ,MARTL_STATUS_CD ,CHILD_IND ,BUS_CHKG_BAL ,BUS_CR_CARD_BAL ,BUS_LOANS_BAL ,BUS_MONEY_MKT_BAL ,BUS_SVNGS_BAL ,CD_BAL ,CNSMR_CHKG_BAL ,CNSMR_CR_CARD_BAL ,CNSMR_INSTLMT_LOANS_BAL ,CNSMR_MONEY_MKT_BAL ,CNSMR_SVNGS_BAL ,MTGE_BAL ,OVRDFT_LOC_BAL ,TOT_HOME_EQTY_BAL ,DT ,AFFLUENCE ,CALC_CUST_OPEN_DT ,CALC_CUST_CLOS_DT ,OPEN_MTH_ID ,ACTIVE_BILLPAY_30DAY ,ACTIVE_BILLPAY_90DAY ,BILLPAY3OF3 ,ACTIVE_MOBILE_30DAY ,ACTIVE_MOBILE_90DAY ,MOBILE3OF3 ,ACTIVE_PROFILE_30DAY ,ACTIVE_PROFILE_90DAY ,PROFILE3OF3 ,RETIREMENT_IND ,WALLET3OF3 ,DIR_DEP_1OF3 ,ACTIVE_DBT_CRD_3OF3 ,ACTIVE_DBT_CRD_30DAY ,SALES_VOL ,SALES_V_CD ,EES_TOTAL ,EES_TTL_CD ,EES_HERE ,YR_STARTED ,STATUS_IND ,SUB_IND ,MANUF_IND ,LEGAL_STAT ,OWNS_RENTS ,SQ_FOOTAGE ,SIC1 ,COTTAGE_IND ,COMPANYTYPE ,NAICS_CD ,NAICS_DESC ,SIC_8 ,SIC_6 ,SIC_4 ,SIC_2 ,MATCH_CODE ,BG_CODE ,CBSA_CODE ,CUST_NBR ,FIPS_STATE_CD ,STATE_NAME ,FIPS_COUNTY_CD ,CENSUS_TRACK_CD ,CENSUS_BLOCK_CD ,ZIP5_CD ,ZIP5_PLUS_4_CD ,HAS_IXI ,HAS_PSYCLE ,EXP_LN ,TRANS_SEGMT
FROM sc05069.DEC18_DEMO)
) order by CUST_ID;


/*A sample To export if any differences are detected*/
select * from Dif_Demos_Oracle_SAS 
where rownum <= 1000;



--Dropping intermediate tables
DROP TABLE ONLINE_Demos_&&monthid PURGE;
DROP TABLE segment_demos_&&monthid PURGE;
DROP TABLE EPL_Demos_&&monthid PURGE;
DROP TABLE QUERY_FOR_EPL_&&monthid PURGE;
DROP TABLE GEN_1_&&monthid PURGE;
DROP TABLE GEN_2_&&monthid PURGE;
DROP TABLE TENURE1_&&monthid PURGE;
DROP TABLE step1_Demos_&&monthid PURGE;
DROP TABLE DUNS_Demos_&&monthid PURGE;
DROP TABLE GEO1_Demos_&&monthid PURGE;
DROP TABLE STEP2_Demos_&&monthid PURGE;
DROP TABLE STEP3_Demos_&&monthid PURGE;
DROP TABLE STEP4_Demos_&&monthid PURGE;
DROP TABLE STEP5_Demos_&&monthid PURGE;
DROP TABLE STEP6_Demos_&&monthid PURGE;
DROP TABLE STEP7_Demos_&&monthid PURGE;
DROP TABLE STEP8_Demos_&&monthid PURGE;
DROP TABLE STEP9_Demos_&&monthid PURGE;
DROP TABLE STEP10_Demos_&&monthid PURGE;
DROP TABLE STEP11_Demos_&&monthid PURGE;
DROP TABLE STEP12_Demos_&&monthid PURGE;
DROP TABLE &&monthid._DEMOS_MF PURGE;
DROP TABLE &&monthid._DEMOS_MF2 PURGE;
DROP TABLE &&monthid._DEMOS_MF3 PURGE;
DROP TABLE &&monthid._DEMOS_MF4 PURGE;
DROP TABLE &&monthid._DEMOS_MF5 PURGE;
DROP TABLE QUERY_FOR_ACH_DATA PURGE;
DROP TABLE FOR_ACH_DATA_AGG PURGE;

--Final table dropping
DROP TABLE &&monthid._DEMOS_MF6 PURGE;
