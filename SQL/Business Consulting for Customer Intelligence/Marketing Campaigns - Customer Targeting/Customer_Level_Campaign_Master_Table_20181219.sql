SET DEFINE ON
DEFINE dayid = 20181130

/*******************************************************************************************************************************
** Check to see if the following tables have data for the above day_id:
**   1) ca_owner.ca_fact_acct_daily
**   2) ci_rpt.CUST_COUNTS_BETA_CUME_EXCL
**   3) ca_owner.ca_lnk_mktg_prdt_svc_catg
**   4) ca_owner.CA_FACT_ACCT_MTHLY
**   5) sdss_owner.DIM_RATE
*******************************************************************************************************************************/
SELECT * FROM ca_owner.ca_fact_acct_daily WHERE day_id = &&dayid;

-- No data for 20181130, Use 20181031
SELECT * FROM ci_rpt.CUST_COUNTS_BETA_CUME_EXCL WHERE day_id = &&dayid;

SELECT * FROM ca_owner.ca_lnk_mktg_prdt_svc_catg WHERE day_id = &&dayid;
SELECT * FROM ca_owner.CA_FACT_ACCT_MTHLY WHERE day_id = &&dayid;
SELECT * FROM sdss_owner.DIM_RATE WHERE day_id = &&dayid;


DROP TABLE CMPGN_CUST_MSTR_BT purge;
CREATE TABLE CMPGN_CUST_MSTR_BT as
SELECT demos.cust_id,
       demos.day_id,
       --acct.acct_id,
       --acct.OPEN_DT,
       --acct.CLOS_DT,
       --acct.MATY_DT,
       demos.cust_open_flag,
       demos.CUST_REPORTABLE_FLAG,
       demos.AFFLUENCE,
       demos.lob_cd,
       demos.cust_type,
       demos.cd_ind,
       demos.CNSMR_MONEY_MKT_IND,
       demos.CNSMR_CHKG_IND,
       demos.CNSMR_SVNGS_IND,

       --We take the average to keep the original value when grouping back to customer level
       avg(demos.tot_invst_amt) as tot_invst_amt,
       avg(demos.tot_dpst_amt) as tot_dpst_amt,
       avg(demos.TOT_DPST_AMT1) as TOT_DPST_AMT1,

       cust.vip_ind_cd,
       cust.cust_nbr,
       cust.calc_cust_clos_dt,
       cust.OFCR_CD,
       excl.excl_flag,
       excl.excl_name,
       excl.opt_out,
       excl.bad_phone,
       excl.DNS_CALL,
       excl.DNS_EMAIL,
       excl.WRONG_PH_NBR,
       excl.FOREIGN,
       pup.p_cnsmr_money_mkt_ind1,
       
       --prdt.SVC_CATG_CD,
       sum(cafd.curr_bal_amt) as curr_bal_amt,
       sum(cafd.curr_bal_amt_ci) as curr_bal_amt_ci,
       --cafm.mth_id,
       sum(cafm.MKT_BAL_MTH01) as MKT_BAL_MTH01,
       sum(cafm.MKT_BAL_MTH02) as MKT_BAL_MTH02,
       sum(cafm.MKT_BAL_MTH03) as MKT_BAL_MTH03,


       --We take the average to keep the original value when grouping back to customer level:
	     --Requirement for Money Market Declining Balance Campaign: CUSTOMER LEVEL VERSION
       avg(mmkt_maxbal.MMKT_BAL_12M_HIGH_AGG) as MMKT_BAL_12M_HIGH_AGG,
	     --Requirement for Deposits Declining Balance Campaign: CUSTOMER LEVEL VERSION
       avg(NVL(Dep_maxbal.DEP_BAL_12M_HIGH,0)) as DEP_BAL_12M_HIGH,
       --Requirement for Win Back CD Campaign: CUSTOMER LEVEL VERSION
       --avg(CD_history.CD_IN_PRIOR_BAL) as CD_IN_PRIOR_BAL,
       --Requirement for Win Back Money Market Campaign: CUSTOMER LEVEL VERSION
       --avg(MMA_history.MMA_IN_PRIOR_BAL) as MMA_IN_PRIOR_BAL,


       -- Let's bring in current balance for each of the 4 product types by checking the svc_catg_code of each account
       -- This is the current balance of each product at the customer level, e.g. if Bob has 2 MMKt
       -- accounts, A and B, with balances 1 and 2, then Bob's CNSMR_MMKT_CURR_BAL = 1 + 2 = 3
       sum(case when prdt.SVC_CATG_CD = 'CD_IND' THEN cafd.curr_bal_amt ELSE 0 END) AS CD_CURR_BAL,
       sum(case when prdt.SVC_CATG_CD = 'CNSMR_MONEY_MKT_IND' THEN cafd.curr_bal_amt ELSE 0 END) AS CNSMR_MMKT_CURR_BAL,
       sum(case when prdt.SVC_CATG_CD = 'CNSMR_CHKG_IND' THEN cafd.curr_bal_amt ELSE 0 END) AS CNSMR_CHKG_CURR_BAL,
       sum(case when prdt.SVC_CATG_CD = 'CNSMR_SVNGS_IND' THEN cafd.curr_bal_amt ELSE 0 END) AS CNSMR_SVNGS_CURR_BAL,

       sum(case when prdt.SVC_CATG_CD IN ('CD_IND','CNSMR_MONEY_MKT_IND','CNSMR_CHKG_IND','CNSMR_SVNGS_IND') THEN
       cafd.curr_bal_amt ELSE 0 END) AS CNSMR_DPSTS_CURR_BAL,


       sum(case when prdt.SVC_CATG_CD = 'INVST_IND' THEN cafd.curr_bal_amt ELSE 0 END) AS INVST_CURR_BAL,
       sum(case when prdt.SVC_CATG_CD = 'CNSMR_MONEY_MKT_IND' AND
                     acct.OPEN_DT >= '02-JAN-18' AND
                     acct.CLOS_DT = to_date('30-DEC-9999','DD-MON-YY')
                THEN cafd.curr_bal_amt END) AS JAN2_CNSMR_MMKT_BAL_AGG,

       -- Aggregated balance of all customer's CDs that meet the rate and maturity criteria:
       -- CD Renewal Campaign CUSTOMER LEVEL VERSION
       sum(case when prdt.SVC_CATG_CD = 'CD_IND' AND (acct.MATY_DT - to_date(&&dayid,'YYYYMMDD') BETWEEN 15 AND 45) AND
           rate.INT_RATE >= 0.75 THEN cafd.curr_bal_amt END) AS CD_CURR_BAL_AGG,
       --CD_INCL1: number of accounts that meets CD Renewal Campaign criteria for each customer: ACCOUNT LEVEL VERSION
       sum(case when prdt.SVC_CATG_CD = 'CD_IND' AND (acct.MATY_DT - to_date(&&dayid,'YYYYMMDD') BETWEEN 15 AND 45) AND
           rate.INT_RATE >= 0.75 AND cafd.curr_bal_amt > 10000 THEN 1 else 0 END) AS CD_INCL1,

       --MMkt_INCL_4 is the number of accounts that meet criteria for MMkt Declining Balance Campaign:
       -- Campaign 4 ACCOUNT LEVEL VERSION
       /*sum(case when mmkt_maxbal.MMKT_BAL_12M_HIGH_ACC = 0 then 0
				when mmkt_maxbal.MMKT_BAL_12M_HIGH_ACC - cafd.curr_bal_amt > 50000 AND
				round((cafd.curr_bal_amt/mmkt_maxbal.MMKT_BAL_12M_HIGH_ACC),2) < 0.50 then 1
				else 0 end) as MMkt_INCL_4, */

       --Deposits indicator for Deposits Declining Balances Campaign
       case when demos.CNSMR_MONEY_MKT_IND = 1 OR demos.cd_ind = 1 OR
                   demos.CNSMR_CHKG_IND = 1 OR demos.CNSMR_SVNGS_IND = 1
                   then 1 else 0 end as CNSMR_DEPOSITS_IND,

	     --CD_IN_PRIOR_ACCT is the number of accounts that meet CD historic balance criteria:
	     -- Campaign CD Win Back ACCOUNT LEVEL VERSION
		   sum(case when CD_history.CD_IN_PRIOR_BAL > 10000 then 1 else 0 end) as CD_IN_PRIOR_ACCT,

	     --MMA_IN_PRIOR_ACCT is the number of accounts that meet MMA historic balance criteria:
	     -- Campaign MMkt Win Back ACCOUNT LEVEL VERSION
		   sum(case when MMA_history.MMA_IN_PRIOR_BAL > 10000 then 1 else 0 end) as MMA_IN_PRIOR_ACCT

FROM (select cust_id, day_id, cust_open_flag, CUST_REPORTABLE_FLAG, affluence, lob_cd, cust_type,
             TOT_INVST_AMT, TOT_DPST_AMT, tot_dpst_amt1, CD_IND, CNSMR_MONEY_MKT_IND, CNSMR_CHKG_IND,
             CNSMR_SVNGS_IND
      from sc05069.NOV18_DEMO where day_id = &&dayid) demos
LEFT JOIN (SELECT vip_ind_cd, cust_nbr, cust_id, calc_cust_clos_dt, OFCR_CD FROM ca_owner.CA_DIM_CUST
           WHERE day_id = &&dayid) cust
ON  demos.cust_id = cust.cust_id
LEFT JOIN (SELECT day_id, cust_id, excl_flag, excl_name, opt_out, bad_phone, DNS_CALL, DNS_EMAIL, WRONG_PH_NBR, FOREIGN
           FROM ci_rpt.CUST_COUNTS_BETA_CUME_EXCL
           WHERE day_id = 20181031) excl
ON excl.cust_id = demos.CUST_ID
LEFT JOIN (SELECT day_id, cust_id, acct_id, acct_typ, clos_dt, ca_dim_mktg_prdt_key, maty_dt,
                CLOS_MTH_ID, DIM_ACCT_KEY, OPEN_DT
           FROM ca_owner.ca_dim_acct where day_id= &&dayid) acct
ON demos.cust_id = acct.cust_id
LEFT JOIN (SELECT day_id, CA_DIM_MKTG_PRDT_KEY, SVC_CATG_CD  FROM ca_owner.ca_lnk_mktg_prdt_svc_catg
           WHERE day_id = &&dayid AND SVC_CATG_TYP_CD = 'MIXED') prdt
ON acct.CA_DIM_MKTG_PRDT_KEY = prdt.CA_DIM_MKTG_PRDT_KEY
LEFT JOIN (SELECT day_id, acct_id, curr_bal_amt, curr_bal_amt_ci FROM ca_owner.ca_fact_acct_daily
           WHERE day_id = &&dayid) cafd
ON acct.acct_id = cafd.acct_id
LEFT JOIN (SELECT day_id, acct_id, mth_id, mkt_bal_mth01, mkt_bal_mth02, mkt_bal_mth03 FROM ca_owner.CA_FACT_ACCT_MTHLY
           WHERE day_id = &&dayid) cafm
ON acct.ACCT_ID = cafm.ACCT_ID
LEFT JOIN (SELECT day_id, acct_id, int_rate FROM sdss_owner.DIM_RATE
           WHERE INT_TYP_DESC = 'COUPON RATE' AND day_id = &&dayid) rate
ON rate.acct_id = acct.acct_id
LEFT JOIN (SELECT cust_id, day_id, p_cnsmr_money_mkt_ind1 FROM ci_rpt.ca_fact_cust_pup_scores WHERE day_id = &&dayid) pup
ON pup.cust_id = demos.cust_id

--Maximum Balance of the last 12 months for Money Market: CUSTOMER LEVEL VERSION - MMkt Declining Balance Campaign
LEFT JOIN (select cust_id, max(total_cust_bal_amt) as MMKT_BAL_12M_HIGH_AGG from
            (
            select cust2.cust_id, mnth2.day_id, sum(curr_bal_amt_ci) as total_cust_bal_amt
            FROM
                (SELECT cust_id FROM sc05069.NOV18_DEMO WHERE day_id = &&dayid) cust2
                INNER JOIN
                (SELECT day_id, cust_id, acct_id, ca_dim_mktg_prdt_key
                FROM ca_owner.ca_dim_acct where day_id= &&dayid AND OPEN_DT >= '02-JAN-18' AND
                      CLOS_DT = to_date('30-DEC-9999','DD-MON-YY')) acct2
                ON cust2.cust_id = acct2.cust_id
                INNER JOIN
                (SELECT day_id, CA_DIM_MKTG_PRDT_KEY  FROM ca_owner.ca_lnk_mktg_prdt_svc_catg
                WHERE day_id = &&dayid AND SVC_CATG_TYP_CD = 'MIXED' AND svc_catg_cd IN ('CNSMR_MONEY_MKT_IND')) prdt2
                ON acct2.CA_DIM_MKTG_PRDT_KEY = prdt2.CA_DIM_MKTG_PRDT_KEY
                LEFT JOIN (SELECT day_id, curr_bal_amt_ci, acct_id FROM ca_owner.ca_fact_acct_mthly
                    where to_date(day_id, 'YYYY-MM-DD') between add_months(to_date(&&dayid, 'YYYY-MM-DD'), -12) and to_date(&&dayid, 'YYYY-MM-DD')) mnth2
                    ON acct2.acct_id = mnth2.acct_id
                        GROUP BY cust2.cust_id, mnth2.day_id
            ) tot GROUP BY cust_id
          ) mmkt_maxbal
          ON demos.cust_id = mmkt_maxbal.cust_id


--Maximum Balance of the last 12 months for Money Market: ACCOUNT LEVEL VERSION - MMkt Declining Balance Campaign
/*LEFT JOIN (select acct_id, max(total_cust_bal_amt) as MMKT_BAL_12M_HIGH_ACC from
            (
            select acct2.acct_id, mnth2.day_id, sum(curr_bal_amt_ci) as total_cust_bal_amt
            FROM
                (SELECT cust_id FROM sc05069.NOV18_DEMO WHERE day_id = &&dayid) cust2
                INNER JOIN
                (SELECT day_id, cust_id, acct_id, ca_dim_mktg_prdt_key
                FROM ca_owner.ca_dim_acct where day_id= &&dayid AND OPEN_DT >= '02-JAN-18' AND
                      CLOS_DT = to_date('30-DEC-9999','DD-MON-YY')) acct2
                ON cust2.cust_id = acct2.cust_id
                INNER JOIN
                (SELECT day_id, CA_DIM_MKTG_PRDT_KEY  FROM ca_owner.ca_lnk_mktg_prdt_svc_catg
                WHERE day_id = &&dayid AND SVC_CATG_TYP_CD = 'MIXED' AND svc_catg_cd IN ('CNSMR_MONEY_MKT_IND')) prdt2
                ON acct2.CA_DIM_MKTG_PRDT_KEY = prdt2.CA_DIM_MKTG_PRDT_KEY
                LEFT JOIN (SELECT day_id, curr_bal_amt_ci, acct_id FROM ca_owner.ca_fact_acct_mthly
                    where to_date(day_id, 'YYYY-MM-DD') between add_months(to_date(&&dayid, 'YYYY-MM-DD'), -12) and to_date(&&dayid, 'YYYY-MM-DD')) mnth2
                    ON acct2.acct_id = mnth2.acct_id
                        GROUP BY acct2.acct_id, mnth2.day_id
            ) tot GROUP BY acct_id
          ) mmkt_maxbal
          ON acct.acct_id = mmkt_maxbal.acct_id */

--Maximum Balance of the last 12 months for Deposits (DDA, SAV, MMA, CD) - Deposits Declining Balance Campaign
LEFT JOIN (select cust_id, max(total_cust_bal_amt) as DEP_BAL_12M_HIGH from
            (
            select cust3.cust_id, mnth3.day_id, sum(curr_bal_amt_ci) as total_cust_bal_amt
            FROM
                (SELECT cust_id FROM sc05069.NOV18_DEMO WHERE day_id = &&dayid) cust3
                LEFT JOIN
                (SELECT day_id, cust_id, acct_id, ca_dim_mktg_prdt_key
                FROM ca_owner.ca_dim_acct where day_id= &&dayid) acct3
                ON cust3.cust_id = acct3.cust_id
                INNER JOIN
                (SELECT day_id, CA_DIM_MKTG_PRDT_KEY  FROM ca_owner.ca_lnk_mktg_prdt_svc_catg
                WHERE day_id = &&dayid AND SVC_CATG_TYP_CD = 'MIXED' AND
                svc_catg_cd IN ('CNSMR_CHKG_IND','CNSMR_MONEY_MKT_IND','CD_IND','CNSMR_SVNGS_IND')) prdt3
                ON acct3.CA_DIM_MKTG_PRDT_KEY = prdt3.CA_DIM_MKTG_PRDT_KEY
                LEFT JOIN (SELECT day_id, curr_bal_amt_ci, acct_id FROM ca_owner.ca_fact_acct_mthly
                    where to_date(day_id, 'YYYY-MM-DD') between add_months(to_date(&&dayid, 'YYYY-MM-DD'), -12) and to_date(&&dayid, 'YYYY-MM-DD')) mnth3
                    ON acct3.acct_id = mnth3.acct_id
                        GROUP BY cust3.cust_id, mnth3.day_id
            ) tot GROUP BY cust_id
          ) Dep_maxbal
          ON demos.cust_id = Dep_maxbal.cust_id

--CD in prior (10-18, 23-26) months: CD Win Back Campaign - CUSTOMER LEVEL VERSION
/*
LEFT JOIN(
select cust_id, sum(CD_IN_PRIOR_BAL) as CD_IN_PRIOR_BAL from
	(select acct4.cust_id, ACCT4.acct_id, max(cafm4.MKT_BAL_MTH01) as CD_IN_PRIOR_BAL
	  FROM (Select cust_id, acct_id, day_id, clos_mth_id, open_mth_id, CA_DIM_MKTG_PRDT_KEY, clos_dt
      from ca_owner.ca_dim_acct
      where day_id = &&dayid
        AND (clos_dt between add_months(to_date(&&dayid, 'YYYYMMDD'), -18) and add_months(to_date(&&dayid, 'YYYYMMDD'), -10)  or
             clos_dt between add_months(to_date(&&dayid, 'YYYYMMDD'), -26) and add_months(to_date(&&dayid, 'YYYYMMDD'), -23))) acct4
       inner JOIN (SELECT day_id, CA_DIM_MKTG_PRDT_KEY, SVC_CATG_CD
                   FROM ca_owner.ca_lnk_mktg_prdt_svc_catg
                   WHERE day_id = &&dayid
                     AND SVC_CATG_TYP_CD = 'MIXED'
                     AND svc_catg_cd = 'CD_IND') prdt4 ON prdt4.CA_DIM_MKTG_PRDT_KEY = acct4.CA_DIM_MKTG_PRDT_KEY
       LEFT JOIN (SELECT MKT_BAL,
                         MKT_BAL_MTH01,
                         MKT_BAL_MTH02,
                         MKT_BAL_MTH03,
                         acct_id,
                         day_id,
                         mth_id
                  FROM ca_owner.CA_FACT_ACCT_MTHLY
				  where to_date(day_id, 'YYYY-MM-DD') between add_months(to_date(&&dayid, 'YYYY-MM-DD'), -18) and add_months(to_date(&&dayid, 'YYYY-MM-DD'),-10) or
						to_date(day_id, 'YYYY-MM-DD') between add_months(to_date(&&dayid, 'YYYY-MM-DD'), -26) and add_months(to_date(&&dayid, 'YYYY-MM-DD'),-23)
				  ) cafm4
         On acct4.acct_id = cafm4.acct_id
         GROUP BY acct4.cust_id, ACCT4.acct_id
		)GROUP BY cust_id
        ) CD_history
            ON demos.cust_id = CD_history.cust_id
*/

--CD in prior (10-18, 23-26) months: CD Win Back Campaign - ACCOUNT LEVEL VERSION
LEFT JOIN(
select acct_id, sum(CD_IN_PRIOR_BAL) as CD_IN_PRIOR_BAL from
	(select acct4.cust_id, ACCT4.acct_id, max(cafm4.MKT_BAL_MTH01) as CD_IN_PRIOR_BAL
	  FROM
	    (Select cust_id, acct_id, day_id, clos_mth_id, open_mth_id, CA_DIM_MKTG_PRDT_KEY, clos_dt
      from ca_owner.ca_dim_acct
      where day_id = &&dayid
        AND (clos_dt between add_months(to_date(&&dayid, 'YYYYMMDD'), -18) and add_months(to_date(&&dayid, 'YYYYMMDD'), -10)  or
             clos_dt between add_months(to_date(&&dayid, 'YYYYMMDD'), -26) and add_months(to_date(&&dayid, 'YYYYMMDD'), -23))) acct4
       inner JOIN (SELECT day_id, CA_DIM_MKTG_PRDT_KEY, SVC_CATG_CD
                   FROM ca_owner.ca_lnk_mktg_prdt_svc_catg
                   WHERE day_id = &&dayid
                     AND SVC_CATG_TYP_CD = 'MIXED'
                     AND svc_catg_cd = 'CD_IND') prdt4 ON prdt4.CA_DIM_MKTG_PRDT_KEY = acct4.CA_DIM_MKTG_PRDT_KEY
       LEFT JOIN (SELECT MKT_BAL_MTH01,
                         acct_id,
                         day_id,
                         mth_id
                  FROM ca_owner.CA_FACT_ACCT_MTHLY
				  where to_date(day_id, 'YYYY-MM-DD') between add_months(to_date(&&dayid, 'YYYY-MM-DD'), -18) and add_months(to_date(&&dayid, 'YYYY-MM-DD'),-10) or
						to_date(day_id, 'YYYY-MM-DD') between add_months(to_date(&&dayid, 'YYYY-MM-DD'), -26) and add_months(to_date(&&dayid, 'YYYY-MM-DD'),-23)
				  ) cafm4
         On acct4.acct_id = cafm4.acct_id
         GROUP BY acct4.cust_id, ACCT4.acct_id
		)GROUP BY acct_id
        ) CD_history
            ON acct.acct_id = CD_history.acct_id

--MMA in prior 4-24 months: MMkt Win Back Campaign - CUSTOMER LEVEL VERSION
/*
LEFT JOIN(
select cust_id, sum(MMA_IN_PRIOR_BAL) as MMA_IN_PRIOR_BAL from
(select acct6.cust_id, acct6.acct_id, max(cafm6.MKT_BAL_MTH01) as MMA_IN_PRIOR_BAL
FROM (Select cust_id, acct_id, day_id, clos_mth_id, open_mth_id, CA_DIM_MKTG_PRDT_KEY, clos_dt
      from ca_owner.ca_dim_acct
      where day_id = &&dayid
        AND (clos_dt between add_months(to_date(&&dayid, 'YYYYMMDD'), -24) and add_months(to_date(&&dayid, 'YYYYMMDD'), -4))
        ) acct6
       inner JOIN (SELECT day_id, CA_DIM_MKTG_PRDT_KEY, SVC_CATG_CD
                   FROM ca_owner.ca_lnk_mktg_prdt_svc_catg
                   WHERE day_id = &&dayid
                     AND SVC_CATG_TYP_CD = 'MIXED'
                     AND svc_catg_cd = 'CNSMR_MONEY_MKT_IND') prdt6 ON prdt6.CA_DIM_MKTG_PRDT_KEY = acct6.CA_DIM_MKTG_PRDT_KEY
       LEFT JOIN (SELECT MKT_BAL,
                         MKT_BAL_MTH01,
                         MKT_BAL_MTH02,
                         MKT_BAL_MTH03,
                         acct_id,
                         day_id,
                         mth_id
                  FROM ca_owner.CA_FACT_ACCT_MTHLY
				  where to_date(day_id, 'YYYY-MM-DD') between add_months(to_date(&&dayid, 'YYYY-MM-DD'), -24) and add_months(to_date(&&dayid, 'YYYY-MM-DD'),-4)
				  ) cafm6
         On acct6.acct_id = cafm6.acct_id
            GROUP BY acct6.cust_id, acct6.acct_id
		)	GROUP BY cust_id
        ) MMA_history
            ON demos.cust_id = MMA_history.cust_id
*/
--MMA in prior 4-24 months: MMkt Declining Balance Campaign - ACCOUNT LEVEL VERSION
LEFT JOIN(
select acct_id, sum(MMA_IN_PRIOR_BAL) as MMA_IN_PRIOR_BAL from
(select acct6.cust_id, acct6.acct_id, max(cafm6.MKT_BAL_MTH01) as MMA_IN_PRIOR_BAL
FROM (Select cust_id, acct_id, day_id, clos_mth_id, open_mth_id, CA_DIM_MKTG_PRDT_KEY, clos_dt
      from ca_owner.ca_dim_acct
      where day_id = &&dayid
        AND (clos_dt between add_months(to_date(&&dayid, 'YYYYMMDD'), -24) and add_months(to_date(&&dayid, 'YYYYMMDD'), -4))
        ) acct6
       inner JOIN (SELECT day_id, CA_DIM_MKTG_PRDT_KEY, SVC_CATG_CD
                   FROM ca_owner.ca_lnk_mktg_prdt_svc_catg
                   WHERE day_id = &&dayid
                     AND SVC_CATG_TYP_CD = 'MIXED'
                     AND svc_catg_cd = 'CNSMR_MONEY_MKT_IND') prdt6 ON prdt6.CA_DIM_MKTG_PRDT_KEY = acct6.CA_DIM_MKTG_PRDT_KEY
       LEFT JOIN (SELECT MKT_BAL_MTH01,
                         acct_id,
                         day_id,
                         mth_id
                  FROM ca_owner.CA_FACT_ACCT_MTHLY
				  where to_date(day_id, 'YYYY-MM-DD') between add_months(to_date(&&dayid, 'YYYY-MM-DD'), -24) and add_months(to_date(&&dayid, 'YYYY-MM-DD'),-4)
				  ) cafm6
         On acct6.acct_id = cafm6.acct_id
            GROUP BY acct6.cust_id, acct6.acct_id
		)	GROUP BY acct_id
        ) MMA_history
            ON acct.acct_id = MMA_history.acct_id

GROUP BY   demos.cust_id,
           demos.day_id,
           demos.cust_open_flag,
           demos.CUST_REPORTABLE_FLAG,
           demos.AFFLUENCE,
           demos.lob_cd,
           demos.cust_type,
           demos.cd_ind,
           demos.CNSMR_MONEY_MKT_IND,
           demos.CNSMR_CHKG_IND,
           demos.CNSMR_SVNGS_IND,
           case when demos.CNSMR_MONEY_MKT_IND = 1 OR demos.cd_ind = 1 OR
               demos.CNSMR_CHKG_IND = 1 OR demos.CNSMR_SVNGS_IND = 1
               then 1 else 0 end,
           cust.vip_ind_cd,
           cust.cust_nbr,
           cust.calc_cust_clos_dt,
           cust.OFCR_CD,
           excl.excl_flag,
           excl.excl_name,
           excl.opt_out,
           excl.bad_phone,
           excl.DNS_CALL,
           excl.DNS_EMAIL,
           excl.WRONG_PH_NBR,
           excl.FOREIGN,
           pup.p_cnsmr_money_mkt_ind1
;
commit;

 


select * from CMPGN_CUST_MSTR_BT where rownum < 1000;

-- Verifying number of rows:
SELECT count(*) from  sc05069.NOV18_DEMO;
-- 2908411
SELECT count(*) from CMPGN_CUST_MSTR_BT;
-- 2908411

 
--We create the flags for each campaign
drop table CMPGN_CUST_MSTR_BT2 purge;
create table CMPGN_CUST_MSTR_BT2 as
select t1.*,
        --Campaign CD Renewal Flag - Customer Level version
        --case when t1.CD_CURR_BAL_AGG >= 10000 then 1 else 0 end as Camp_CD_Ren_Flag,
		    --Campaign CD Renewal Flag - Account Level version
        case when t1.CD_INCL1 > 0 then 1 else 0 end as Camp_CD_Ren_Flag,


		    -- Campaign MM Rate Increase and Balance Acquisition:
		    -- Placeholder until specs are finalized


        --Campaign PPB Retention Flag
        case when t1.vip_ind_cd = 'K2' AND (t1.CNSMR_DPSTS_CURR_BAL + t1.INVST_CURR_BAL < 100000) then 1
             else 0 end as Camp_PPB_RET_Flag,


        --Campaign MMkt Declining Balance Flag - Customer Level version
        case when t1.JAN2_CNSMR_MMKT_BAL_AGG is null then 0
             when t1.MMKT_BAL_12M_HIGH_AGG = 0 then 0
			       when t1.MMKT_BAL_12M_HIGH_AGG - t1.JAN2_CNSMR_MMKT_BAL_AGG > 50000 AND
             round((t1.JAN2_CNSMR_MMKT_BAL_AGG/t1.MMKT_BAL_12M_HIGH_AGG), 3) < 0.50 then 1
             else 0 end as Camp_MM_DEC_BAL_Flag,
        --Campaign MMkt Declining Balance Flag - Account Level version
        /*case when t1.MMkt_INCL_4 > 0 then 1
                else 0 end as Camp_MM_DEC_BAL_Flag,
        */



        --Campaign Deposits Declining Balance Flag
        case when t1.DEP_BAL_12M_HIGH = 0 then 0
			       when /*t1.CNSMR_DEPOSITS_IND = 1 AND */
			            t1.DEP_BAL_12M_HIGH - (t1.CNSMR_DPSTS_CURR_BAL) > 50000 AND
			            round((t1.CNSMR_DPSTS_CURR_BAL/t1.DEP_BAL_12M_HIGH), 3) < 0.50
			            then 1 else 0 end as Camp_DEP_DEC_BAL_Flag,



        --Campaign Aff/Ultra Aff Potential PPB Flag
        case when t1.AFFLUENCE in ('A. Ultra Affluent', 'B. Affluent') AND t1.CNSMR_DPSTS_CURR_BAL <= 25000 AND
                    t1.TOT_DPST_AMT1 >= 125000 AND t1.vip_ind_cd != 'K2' then 1
                    else 0 end as Camp_PPB_POT_Flag,


				--Campaign AFF/Ultra Aff High Propensity Money Market Flag (with propensity rule)
				case when t1.CNSMR_DPSTS_CURR_BAL > 25000 AND
				          t1.TOT_DPST_AMT1 - t1.CNSMR_DPSTS_CURR_BAL > 50000 AND
				          round(t1.CNSMR_DPSTS_CURR_BAL/t1.TOT_DPST_AMT1, 3) < 0.50 AND
				          t1.CNSMR_MMKT_CURR_BAL < 20000 AND
				          t1.AFFLUENCE in ('A. Ultra Affluent', 'B. Affluent') AND
				          t1.p_cnsmr_money_mkt_ind1 > 0.5 then 1
				          else 0 end as CAMP_HIGH_MMKT_PROP_FLAG1,

				--Campaign AFF/Ultra Aff High Propensity Money Market Flag (without propensity rule)
				case when t1.CNSMR_DPSTS_CURR_BAL > 25000 AND
				          t1.TOT_DPST_AMT1 - t1.CNSMR_DPSTS_CURR_BAL > 50000 AND
				          round(t1.CNSMR_DPSTS_CURR_BAL/t1.TOT_DPST_AMT1, 3) < 0.50 AND
				          t1.CNSMR_MMKT_CURR_BAL < 20000 AND
				          t1.AFFLUENCE in ('A. Ultra Affluent', 'B. Affluent') /* AND
				          t1.p_cnsmr_money_mkt_ind1 > 0.5 */ then 1
				          else 0 end as CAMP_HIGH_MMKT_PROP_FLAG2,
				--Campaign Lending only Relationship Aff/Ultra Aff: Affluent no deposits, MMkt Acquisition
        /***************************************************************************************************************
         **       Need to know how to determine lending only Relationship
         **************************************************************************************************************/



        --Campaign PPB Acquisition
        case when (t1.CNSMR_DPSTS_CURR_BAL between 50000 AND 99000)
                   AND t1.vip_ind_cd != 'K2' then 1
                   else 0 end as Camp_PPB_ACQ_Flag,



        --Campaign Win Back CD Flag - Customer Level version
		    /*case when t1.cd_ind = 0 AND t1.CD_IN_PRIOR_BAL >= 10000 AND
                (t1.CNSMR_CHKG_CURR_BAL + t1.CNSMR_SVNGS_CURR_BAL + t1.CNSMR_MMKT_CURR_BAL < 25000) then 1 
                else 0 end as Camp_CD_WB_Flag,
	     	*/
		    --Campaign CD Win Back Flag - Account Level version
	    	case when t1.cd_ind = 0 AND t1.CD_IN_PRIOR_ACCT > 0 AND
                (t1.CNSMR_CHKG_CURR_BAL + t1.CNSMR_SVNGS_CURR_BAL + t1.CNSMR_MMKT_CURR_BAL < 25000) then 1 
                else 0 end as Camp_CD_WB_Flag,
					



        --Campaign MMkt Win Back Flag - Customer Level version
		    /*case when t1.CNSMR_MONEY_MKT_IND = 0 AND t1.MMA_IN_PRIOR_BAL >= 10000 AND
                (t1.CNSMR_DPSTS_CURR_BAL < 25000) then 1
                else 0 end as Camp_MM_WB_Flag
		    */
        --Campaign MMkt Win Back Flag - Account Level version
        case when t1.CNSMR_MONEY_MKT_IND = 0 AND t1.MMA_IN_PRIOR_ACCT > 0 AND 
                (t1.CNSMR_DPSTS_CURR_BAL < 25000) then 1
                else 0 end as Camp_MM_WB_Flag,


        --Campaign Remaining (Low Value Mass Mkt, HV Mass Mkt, Mass Affluent) High Propensity MMkt Campaign
        case when t1.CNSMR_DPSTS_CURR_BAL < 25000 AND
                  t1.TOT_DPST_AMT1 - t1.CNSMR_DPSTS_CURR_BAL > 50000 AND
                  t1.p_cnsmr_money_mkt_ind1 > 0.5 AND
                  t1.AFFLUENCE not in ('A. Ultra Affluent', 'B. Affluent') then 1
                  else 0 end as CAMP_LB_MMKT_PROP_FLAG

    from CMPGN_CUST_MSTR_BT t1;
commit;

-- 2908411
select count(*) from CMPGN_CUST_MSTR_BT2;


select * from CMPGN_CUST_MSTR_BT2 where rownum < 1000;

--Test table

drop table test_MF purge;
select * from test_MF 
where cust_id = 68858201;


--create table test_MF as

--End test table



-- Campaign totals
SELECT sum(Camp_CD_Ren_Flag),
       sum(Camp_PPB_RET_Flag),
       sum(Camp_MM_DEC_BAL_Flag),
       sum(Camp_DEP_DEC_BAL_Flag),
       sum(Camp_PPB_POT_Flag), 
       sum(CAMP_HIGH_MMKT_PROP_FLAG1), 
       sum(CAMP_HIGH_MMKT_PROP_FLAG2), 
       sum(Camp_PPB_ACQ_Flag),
       sum(Camp_CD_WB_Flag),
       sum(Camp_MM_WB_Flag), 
       sum(CAMP_LB_MMKT_PROP_FLAG)
FROM CMPGN_CUST_MSTR_BT2;


-- Campaign Totals - Exclusions
SELECT sum(Camp_CD_Ren_Flag),
       sum(Camp_PPB_RET_Flag),
       sum(Camp_MM_DEC_BAL_Flag),
       sum(Camp_DEP_DEC_BAL_Flag),
       sum(Camp_PPB_POT_Flag), 
       sum(CAMP_HIGH_MMKT_PROP_FLAG1), 
       sum(CAMP_HIGH_MMKT_PROP_FLAG2), 
       sum(Camp_PPB_ACQ_Flag),
       sum(Camp_CD_WB_Flag),
       sum(Camp_MM_WB_Flag), 
       sum(CAMP_LB_MMKT_PROP_FLAG),
       EXCL_FLAG,
       EXCL_NAME,
       OPT_OUT,
       BAD_PHONE,
       DNS_CALL,
       DNS_EMAIL,
       WRONG_PH_NBR,
       FOREIGN 
FROM CMPGN_CUST_MSTR_BT2
GROUP BY EXCL_FLAG, EXCL_NAME, OPT_OUT, BAD_PHONE, DNS_CALL, DNS_EMAIL, WRONG_PH_NBR, FOREIGN
ORDER by EXCL_FLAG, EXCL_NAME, OPT_OUT, BAD_PHONE, DNS_CALL, DNS_EMAIL, WRONG_PH_NBR, FOREIGN;



--Create a summary table
SELECT DAY_ID,
       CUST_OPEN_FLAG,
       CUST_REPORTABLE_FLAG,
       AFFLUENCE,
       VIP_IND_CD,
       LOB_CD,
       CUST_TYPE,
       EXCL_FLAG,
       EXCL_NAME,
       OPT_OUT,
       BAD_PHONE,
       DNS_CALL,
       DNS_EMAIL,
       WRONG_PH_NBR,
       FOREIGN,
       CD_IND,
       CNSMR_MONEY_MKT_IND,
       CNSMR_CHKG_IND,
       CNSMR_SVNGS_IND,
       CNSMR_DEPOSITS_IND,
       CAMP_CD_REN_FLAG,
       CAMP_PPB_RET_FLAG,
       CAMP_MM_DEC_BAL_FLAG,
       CAMP_DEP_DEC_BAL_FLAG,
       CAMP_PPB_POT_FLAG,
       CAMP_HIGH_MMKT_PROP_FLAG1,
       CAMP_HIGH_MMKT_PROP_FLAG2,
       CAMP_PPB_ACQ_FLAG,
       CAMP_CD_WB_FLAG,
       CAMP_MM_WB_FLAG,
       CAMP_LB_MMKT_PROP_FLAG,
       count(CUST_ID),
       sum(TOT_INVST_AMT),
       sum(TOT_DPST_AMT),
       sum(TOT_DPST_AMT1),
       sum(CURR_BAL_AMT),
       sum(CURR_BAL_AMT_CI),
       sum(MKT_BAL_MTH01),
       sum(MKT_BAL_MTH02),
       sum(MKT_BAL_MTH03),
       sum(MMKT_BAL_12M_HIGH_AGG),
       sum(DEP_BAL_12M_HIGH),
       sum(CD_CURR_BAL),
       sum(CNSMR_MMKT_CURR_BAL),
       sum(CNSMR_CHKG_CURR_BAL),
       sum(CNSMR_SVNGS_CURR_BAL),
       sum(CNSMR_DPSTS_CURR_BAL),
       sum(INVST_CURR_BAL),
       sum(JAN2_CNSMR_MMKT_BAL_AGG),
       sum(CD_CURR_BAL_AGG),
       sum(CD_INCL1),
       sum(CD_IN_PRIOR_ACCT),
       sum(MMA_IN_PRIOR_ACCT),
       sum(CAMP_CD_REN_FLAG),
       sum(CAMP_PPB_RET_FLAG),
       sum(CAMP_MM_DEC_BAL_FLAG),
       sum(CAMP_DEP_DEC_BAL_FLAG),
       sum(CAMP_PPB_POT_FLAG),
       sum(CAMP_HIGH_MMKT_PROP_FLAG1),
       sum(CAMP_HIGH_MMKT_PROP_FLAG2),
       sum(CAMP_PPB_ACQ_FLAG),
       sum(CAMP_CD_WB_FLAG),
       sum(CAMP_MM_WB_FLAG),
       sum(CAMP_LB_MMKT_PROP_FLAG)
FROM ci_rpt.CMPGN_CUST_MSTR_BT2
GROUP BY DAY_ID,
       CUST_OPEN_FLAG,
       CUST_REPORTABLE_FLAG,
       AFFLUENCE,
       VIP_IND_CD,
       LOB_CD,
       CUST_TYPE,
       EXCL_FLAG,
       EXCL_NAME,
       OPT_OUT,
       BAD_PHONE,
       DNS_CALL,
       DNS_EMAIL,
       WRONG_PH_NBR,
       FOREIGN,
       CD_IND,
       CNSMR_MONEY_MKT_IND,
       CNSMR_CHKG_IND,
       CNSMR_SVNGS_IND,
       CNSMR_DEPOSITS_IND,
       CAMP_CD_REN_FLAG,
       CAMP_PPB_RET_FLAG,
       CAMP_MM_DEC_BAL_FLAG,
       CAMP_DEP_DEC_BAL_FLAG,
       CAMP_PPB_POT_FLAG,
       CAMP_HIGH_MMKT_PROP_FLAG1,
       CAMP_HIGH_MMKT_PROP_FLAG2,
       CAMP_PPB_ACQ_FLAG,
       CAMP_CD_WB_FLAG,
       CAMP_MM_WB_FLAG,
       CAMP_LB_MMKT_PROP_FLAG;
























select count(*) from (
(select cust_id, day_id, TOT_DPST_AMT, TOT_INVST_AMT from sc05069.NOV18_DEMO where TOT_DPST_AMT + TOT_INVST_AMT < 100000 and cust_type in ('R', 'N')) oct
INNER JOIN (SELECT cust_id, VIP_IND_CD FROM ca_owner.CA_DIM_CUST where VIP_IND_CD = 'K2' and day_id = 20181031) dim
ON oct.CUST_ID = dim.CUST_ID
);



-- Number of target consumers that deposits != TOT_DPST_AMT
select count(*) from (
select cust_id, cust_type, lob_cd, cust_open_flag, cust_reportable_flag,
       CD_CURR_BAL + CNSMR_CHKG_CURR_BAL + CNSMR_SVNGS_CURR_BAL + CNSMR_MMKT_CURR_BAL as deposits,
       TOT_DPST_AMT,
       INVST_CURR_BAL,
       tot_invst_amt
FROM CMPGN_CUST_MSTR_BT2
WHERE CD_CURR_BAL + CNSMR_CHKG_CURR_BAL + CNSMR_SVNGS_CURR_BAL + CNSMR_MMKT_CURR_BAL != tot_dpst_amt
       AND cust_type in ('R', 'N') and lob_cd in ('RET', 'WMG', 'CSME') and cust_reportable_flag = 1
)
;


-- Looks at accounts attached to those customers to investigate why the deposit totals are not matching
SELECT demos.cust_id, demos.cust_type, demos.lob_cd, demos.cust_open_flag, demos.cust_reportable_flag,
       demos.CD_CURR_BAL, demos.CNSMR_CHKG_CURR_BAL, demos.CNSMR_SVNGS_CURR_BAL, demos.CNSMR_MMKT_CURR_BAL, demos.deposits,
       demos.TOT_DPST_AMT, demos.INVST_CURR_BAL, demos.tot_invst_amt, acct.acct_id, acct.acct_typ, acct.clos_dt,
       prdt.SVC_CATG_CD, acct.ptyp_cd, acct.styp_cd, cafd.curr_bal_amt, cafd.curr_bal_amt_ci
FROM
(select cust_id, cust_type, lob_cd, cust_open_flag, cust_reportable_flag, CD_CURR_BAL, CNSMR_CHKG_CURR_BAL, CNSMR_SVNGS_CURR_BAL,
       CNSMR_MMKT_CURR_BAL,
       CD_CURR_BAL + CNSMR_CHKG_CURR_BAL + CNSMR_SVNGS_CURR_BAL + CNSMR_MMKT_CURR_BAL as deposits,
       TOT_DPST_AMT,
       INVST_CURR_BAL,
       tot_invst_amt
FROM CMPGN_CUST_MSTR_BT2) demos
LEFT JOIN (SELECT day_id, cust_id, acct_id, acct_typ, clos_dt, ca_dim_mktg_prdt_key, ptyp_cd, styp_cd,
                CLOS_MTH_ID, DIM_ACCT_KEY, OPEN_DT
           FROM ca_owner.ca_dim_acct where day_id= 20181031) acct
ON demos.cust_id = acct.cust_id
LEFT JOIN (SELECT day_id, CA_DIM_MKTG_PRDT_KEY, SVC_CATG_CD  FROM ca_owner.ca_lnk_mktg_prdt_svc_catg
           WHERE day_id = 20181031 AND SVC_CATG_TYP_CD = 'MIXED') prdt
ON acct.CA_DIM_MKTG_PRDT_KEY = prdt.CA_DIM_MKTG_PRDT_KEY
LEFT JOIN (SELECT day_id, acct_id, curr_bal_amt, curr_bal_amt_ci FROM ca_owner.ca_fact_acct_daily
           WHERE day_id = 20181031) cafd
ON acct.acct_id = cafd.acct_id
WHERE demos.deposits != demos.tot_dpst_amt
       AND demos.cust_type in ('R', 'N') and demos.lob_cd in ('RET', 'WMG', 'CSME') and demos.cust_reportable_flag = 1
ORDER BY demos.cust_id
;
-- Conclusion is that TOT_DPST_AMT includes some SVC_CATG_CD = 'RETIREMENT_IND' products

SELECT count(*)
FROM
(SELECT cust_id, tot_dpst_amt, tot_dpst_amt1 FROM sc05069.NOV18_DEMO) demos
INNER Join (SELECT cust_id, vip_ind_cd, day_id FROM ca_owner.ca_dim_cust where day_id = 20181031 and vip_ind_cd != 'K2') dim
ON demos.cust_id = dim.cust_id
WHERE demos.tot_dpst_amt <= 25000 and demos.tot_dpst_amt1 >= 125000;




select distinct affluence from sc05069.NOV18_DEMO;


select * from CMPGN_CUST_MSTR_BT where CD_INCL1 != 0;


(SELECT day_id, acct_id, curr_bal_amt, curr_bal_amt_ci FROM ca_owner.ca_fact_acct_daily
           WHERE day_id = 20181031)
           
           
           
SELECT day_id, cust_id, excl_flag, excl_name, opt_out, bad_phone, DNS_CALL, DNS_EMAIL, WRONG_PH_NBR, FOREIGN
           FROM ci_rpt.CUST_COUNTS_BETA_CUME_EXCL WHERE day_id = 20181031;
           
SELECT distinct day_id from CUST_COUNTS_BETA_CUME_EXCL order by day_id;
