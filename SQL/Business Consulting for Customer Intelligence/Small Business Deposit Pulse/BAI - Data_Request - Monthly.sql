--Monthly execution (end of month)
SET SERVEROUTPUT ON
SET DEFINE ON
DEFINE dayid = 20181231


-- First we determine the Data Universe at customer level
-- We pull all the fields needed in one table at customer level
create table BAI_Dta_Univ_prev as
(select acct.cust_id, beta.lob_cd, beta.cust_type, 
        avg(DNB.Annual_Revenue) as Annual_Revenue,
        --Indicator for customers that have real state loans
        sum(case when gl.CA_DIM_GL_ACCT_SUM_3_RPTG_KEY = 25 then 1 else 0 end) as Commer_RealSt_Ind,
        --Deposit Balance
        sum(case when acct.acct_typ = 'D' then cafm.MTD_AVG_BAL_AMT end) as Balance_Dep,
        --Loan Balance
        sum(case when acct.acct_typ = 'L' then cafm.MTD_AVG_BAL_AMT end) as Balance_Loan
        FROM
            (select day_id, cust_id, acct_id, acct_typ, clos_dt, ca_dim_mktg_prdt_key, maty_dt,
            CLOS_MTH_ID, DIM_ACCT_KEY, OPEN_DT, PRDT_CD_CD 
            from ca_owner.ca_dim_acct where day_id = &&dayid AND RPTG_CC_CD != '01400' AND
            --We take out the account products that are not part of the scope
            styp_cd NOT IN ('SIM', 'SIMG', 'MST', 'CKR', 'LSB', 'SPND', 'SIMA', 'TEC', 'PRC', 'PFA', 'PFC', 'PFM', 'COR', 'DTS', 'DUE')) acct
        LEFT JOIN 
            (SELECT day_id, acct_id, MTD_AVG_BAL_AMT, CA_DIM_GL_ACCT_RPTG_KEY 
            FROM ca_owner.CA_FACT_ACCT_MTHLY WHERE day_id = &&dayid) cafm
            ON acct.ACCT_ID = cafm.ACCT_ID
        LEFT JOIN
            (select a.CA_DIM_GL_ACCT_RPTG_KEY, d.CA_DIM_GL_ACCT_SUM_3_RPTG_KEY
            from CA_OWNER.ca_dim_gl_acct_rptg a
            left join CA_OWNER.ca_dim_gl_acct_sum_3_rptg d 
              on a.ca_dim_gl_acct_sum_3_rptg_key = d.ca_dim_gl_acct_sum_3_rptg_key
            where a.ca_dim_gl_acct_sum_1_rptg_key = 3) gl 
            ON cafm.CA_DIM_GL_ACCT_RPTG_KEY = gl.CA_DIM_GL_ACCT_RPTG_KEY
        LEFT JOIN   
            (select cust_id, hshld_id, sales_vol as Annual_Revenue from CI_OPS.DNB_DIM_MASTER
             where hshld_id is not null or cust_id is not null) DNB
             ON acct.cust_id = DNB.cust_id    
        LEFT JOIN
            (SELECT cust_id, lob_cd, cust_type FROM cust_counts_beta_cumulative 
             WHERE day_id = &&dayid) beta
             ON acct.cust_id = beta.cust_id
        GROUP BY acct.cust_id, beta.lob_cd, beta.cust_type
);


--We filter the customers that are part of the Universe based on BAI criteria
create table BAI_Dta_Univ_current as
select cust_id from BAI_Dta_Univ_prev
where (cust_type IN ('C','M') AND nvl(Annual_Revenue,0) < 10000000 AND Balance_Dep is not null AND Balance_Dep <1000000 
        AND ((Commer_RealSt_Ind = 0 AND nvl(Balance_Loan,0) < 1000000) OR (Commer_RealSt_Ind > 0 AND nvl(Balance_Loan,0) < 2000000)));

--We also need a table with all the customers that don't have a Deposit for each month
create table BAI_Not_Deposit as 
select cust_id from BAI_Dta_Univ_prev
where cust_type IN ('C','M') AND Balance_Dep is null;


/
--Begin of PL/SQL Block


--Then we have to update the Data Universe based on the current month
BEGIN
    --If it is december, we will have to re-establish the universe of small business customers for the next year
    --In this case we will just take the customers from december that meet the whole criteria
    -- MMDD format
    IF substr(&&dayid,5,4) = 1231 THEN
        DBMS_OUTPUT.PUT_LINE('Re-establishing Data Universe for new year execution');
        EXECUTE IMMEDIATE 'drop table BAI_Data_Univ purge';
        EXECUTE IMMEDIATE 'create table BAI_Data_Univ as select * from BAI_Dta_Univ_current';
    --For the rest of the months we have to update our Data Universe: add new customers that meet the whole criteria
    --and remove customers that don't have a deposit account anymore
    ELSE
        DBMS_OUTPUT.PUT_LINE('Updating Data Universe');
        --We add the new customers that appear in this month 
        EXECUTE IMMEDIATE 'create table BAI_Dta_Temp_1 as select nvl(Univ.cust_id, Monthly.cust_id) as cust_id
                                from BAI_Data_Univ Univ FULL JOIN BAI_Dta_Univ_current Monthly
                                    ON Univ.cust_id = Monthly.cust_id';
        --We remove the customers that don't have a deposit anymore                            
        EXECUTE IMMEDIATE 'create table BAI_Dta_Temp_2 as select Univ.cust_id as cust_id
                                from BAI_Dta_Temp_1 Univ LEFT JOIN BAI_Not_Deposit NoDep
                                    ON Univ.cust_id = NoDep.cust_id
                                        WHERE NoDep.cust_id is null';
        --We update the Data Universe 
        EXECUTE IMMEDIATE 'drop table BAI_Data_Univ purge';
        EXECUTE IMMEDIATE 'create table BAI_Data_Univ as select cust_id from BAI_Dta_Temp_2';
        --We delete temporary tables
        EXECUTE IMMEDIATE 'drop table BAI_Dta_Temp_1 purge';
        EXECUTE IMMEDIATE 'drop table BAI_Dta_Temp_2 purge';
    END IF;
END;

--End of PL/SQL Block
/


--We drop intermediate tables
drop table BAI_Dta_Univ_prev purge;
drop table BAI_Dta_Univ_current purge;
drop table BAI_Not_Deposit purge;


-- Second, based on that Data Universe, we proceed to generate the monthly report

--Monthly Requirement
drop table BAI_Monthly_&&dayid purge;
create table BAI_Monthly_&&dayid as
(select 'C0037' as BANK_CODE, 'MONTHLY' as CYCLE_TYPE,
        --We need the report at State level 
        --'XX' when state not known and 'NATL' for the sum of all States 
        --grouping_id = 1 tells us when we are in the summary record
        case when grouping_id(lkp.STATE_CD) = 1 then 'NATL' else nvl(lkp.STATE_CD,'XX') end as STATE,
        &&dayid as CYCLE_DT,

        --BAI Product Classification
            --NACH = (FBC + NNC + INC)
        sum(case when (
            (acct.PTYP_CD = 'DDA' AND acct.PRDT_CD_CD IN ('009','006','010','008','032','034','011','012','029','033','052'))
            OR (acct.PTYP_CD = 'SAV' AND acct.PRDT_CD_CD = '052'))
            then cafm.MTD_AVG_BAL_AMT end) as NACH, --Non-Analysis Checking         
        sum(case when acct.PTYP_CD = 'DDA' AND acct.PRDT_CD_CD = '009'
            then cafm.MTD_AVG_BAL_AMT end) as FBC,        
        sum(case when acct.PTYP_CD = 'DDA' AND acct.PRDT_CD_CD IN ('006','010','008','032','034') 
            then cafm.MTD_AVG_BAL_AMT end) as NNC,
        sum(case when ((acct.PTYP_CD = 'DDA' AND acct.PRDT_CD_CD IN ('011','012','029','033','052')) OR
            (acct.PTYP_CD = 'SAV' AND acct.PRDT_CD_CD = '052'))
            then cafm.MTD_AVG_BAL_AMT end) as INC,
                    
        sum(case when acct.PTYP_CD = 'DDA' AND acct.PRDT_CD_CD IN ('003','004','007','054','056')
            then cafm.MTD_AVG_BAL_AMT end) as NAC, --Analysis Checking
            
        sum(case when acct.PTYP_CD = 'DDA' AND acct.PRDT_CD_CD = '087'
            then cafm.MTD_AVG_BAL_AMT end) as SWP, --Commercial Sweep (On Balance Sheet)
            
        sum(null) as SWO, --We don't have Off Balance Sheet Commercial Sweeps     
            
        sum(case when acct.PTYP_CD = 'SAV' AND acct.PRDT_CD_CD IN ('069','071','074')
            then cafm.MTD_AVG_BAL_AMT end) as BSV, --Business Savings
            
            --MMA = (RMA + HMA)
        sum(case when acct.PTYP_CD = 'SAV' AND acct.PRDT_CD_CD IN ('044','051','055','061','144','453')
            then cafm.MTD_AVG_BAL_AMT end) as MMA, --Money Market
        sum(case when acct.PTYP_CD = 'SAV' AND acct.PRDT_CD_CD = '453'
            then cafm.MTD_AVG_BAL_AMT end) as RMA,                
        sum(case when acct.PTYP_CD = 'SAV' AND acct.PRDT_CD_CD IN ('044','051','055','061','144')
            then cafm.MTD_AVG_BAL_AMT end) as HMA,
        
        sum(case when acct.PTYP_CD = 'CDS' AND nvl(acct.BUS_FLAG,'C') != 'R' AND acct.RPTG_CC_CD != '01400' 
            then cafm.MTD_AVG_BAL_AMT end) as BCD, --Business CD

        --Total number of checking that are on hand as of month end (open acounts only)
            --Total
        sum(case when (
            ((acct.PTYP_CD = 'DDA' AND acct.PRDT_CD_CD IN 
            ('009','006','010','008','032','034','011','012','029','033','052','003','004','007','054','056'))
            OR (acct.PTYP_CD = 'SAV' AND acct.PRDT_CD_CD = '052')) AND acct.CLOS_DT = to_date('30-DEC-9999','DD-MON-YY'))
            then 1 else 0 end) as TOTAL_CKG_ACCTS,
            --Non-analysis checking
        sum(case when (
            ((acct.PTYP_CD = 'DDA' AND acct.PRDT_CD_CD IN ('009','006','010','008','032','034','011','012','029','033','052'))
            OR (acct.PTYP_CD = 'SAV' AND acct.PRDT_CD_CD = '052')) AND acct.CLOS_DT = to_date('30-DEC-9999','DD-MON-YY')) 
            then 1 else 0 end) as TOTAL_NACH_CKG_ACCTS,
            --Analysis checking
        sum(case when acct.PTYP_CD = 'DDA' AND acct.PRDT_CD_CD IN ('003','004','007','054','056') 
            AND acct.CLOS_DT = to_date('30-DEC-9999','DD-MON-YY')
            then 1 else 0 end) as TOTAL_NAC_CKG_ACCTS,

        --Total number of checking accounts that were opened during this month
            --Total
        sum(case when (
            ((acct.PTYP_CD = 'DDA' AND acct.PRDT_CD_CD IN 
            ('009','006','010','008','032','034','011','012','029','033','052','003','004','007','054','056'))
            OR (acct.PTYP_CD = 'SAV' AND acct.PRDT_CD_CD = '052')) 
            AND extract(year from acct.open_dt) = substr(&&dayid,1,4) AND extract(month from acct.open_dt) = substr(&&dayid,5,2))
            then 1 else 0 end) as NEW_CKG_ACCTS,         
            --Non-analysis checking
        sum(case when (
            ((acct.PTYP_CD = 'DDA' AND acct.PRDT_CD_CD IN ('009','006','010','008','032','034','011','012','029','033','052'))
            OR (acct.PTYP_CD = 'SAV' AND acct.PRDT_CD_CD = '052')) 
            AND extract(year from acct.open_dt) = substr(&&dayid,1,4) AND extract(month from acct.open_dt) = substr(&&dayid,5,2)) 
            then 1 else 0 end) as NEW_NACH_CKG_ACCTS,
            --Analysis checking
        sum(case when acct.PTYP_CD = 'DDA' AND acct.PRDT_CD_CD IN ('003','004','007','054','056') 
            AND extract(year from acct.open_dt) = substr(&&dayid,1,4) AND extract(month from acct.open_dt) = substr(&&dayid,5,2)
            then 1 else 0 end) as NEW_NAC_CKG_ACCTS,

        --Total number of checking accounts that were closed in the month
            --Total
        sum(case when (
            ((acct.PTYP_CD = 'DDA' AND acct.PRDT_CD_CD IN 
            ('009','006','010','008','032','034','011','012','029','033','052','003','004','007','054','056'))
            OR (acct.PTYP_CD = 'SAV' AND acct.PRDT_CD_CD = '052')) 
            AND extract(year from acct.clos_dt) = substr(&&dayid,1,4) AND extract(month from acct.clos_dt) = substr(&&dayid,5,2))
            then 1 else 0 end) as CLOSED_CKG_ACCTS,          
            --Non-analysis checking
        sum(case when (
            ((acct.PTYP_CD = 'DDA' AND acct.PRDT_CD_CD IN ('009','006','010','008','032','034','011','012','029','033','052'))
            OR (acct.PTYP_CD = 'SAV' AND acct.PRDT_CD_CD = '052')) 
            AND extract(year from acct.clos_dt) = substr(&&dayid,1,4) AND extract(month from acct.clos_dt) = substr(&&dayid,5,2)) 
            then 1 else 0 end) as CLOSED_NACH_CKG_ACCTS,
            --Analysis checking
        sum(case when acct.PTYP_CD = 'DDA' AND acct.PRDT_CD_CD IN ('003','004','007','054','056') 
            AND extract(year from acct.clos_dt) = substr(&&dayid,1,4) AND extract(month from acct.clos_dt) = substr(&&dayid,5,2)
            then 1 else 0 end) as CLOSED_NAC_CKG_ACCTS
 
    FROM
        (select day_id, cust_id, acct_id, acct_typ, clos_dt, ca_dim_mktg_prdt_key, maty_dt,
        CLOS_MTH_ID, DIM_ACCT_KEY, OPEN_DT, PRDT_CD_CD, PTYP_CD, BUS_FLAG, RPTG_CC_CD  
        from ca_owner.ca_dim_acct where day_id = &&dayid) acct
    --We filter the customers that are part of the Universe
    INNER JOIN
        BAI_Data_Univ Univ
        ON acct.cust_id = Univ.cust_id
    --We need the average monthly balance
    LEFT JOIN 
        (SELECT acct_id, MTD_AVG_BAL_AMT 
        FROM ca_owner.CA_FACT_ACCT_MTHLY WHERE day_id = &&dayid) cafm
        ON acct.ACCT_ID = cafm.ACCT_ID  
    --We need the State Code
    LEFT JOIN 
        (SELECT day_id, cust_id, fips_state_cd FROM ci_ops.cust_geo_code WHERE day_id = &&dayid) geo
        ON acct.cust_id = geo.cust_id
    LEFT JOIN
        (SELECT distinct STATE_CODE, STATE_NAME FROM ci_ops.dim_CBSA) cbsa
        ON geo.fips_state_cd = cbsa.state_code
    LEFT JOIN
        (SELECT STATE_DESC, STATE_CD FROM ca_owner.ca_lkp_state) lkp
        --We need the Upper function because Oracle is case sensitive
        ON UPPER(cbsa.STATE_NAME) = UPPER(lkp.STATE_DESC)
    --Rollup STATE_CD because we also want a record with the sum of all states (National)      
    GROUP BY 'C0037', 'MONTHLY', rollup(lkp.STATE_CD), &&dayid
)
    ORDER BY BANK_CODE, CYCLE_TYPE, State, CYCLE_DT;



--Monthly Requirement
--select count(*) as cuenta from BAI_Monthly_&&dayid;
--select * from BAI_Monthly_&&dayid;


