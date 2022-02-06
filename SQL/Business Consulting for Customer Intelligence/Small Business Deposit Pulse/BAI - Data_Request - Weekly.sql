--Weekly execution (Friday end-of-business)
SET DEFINE ON
DEFINE dayid = 20190118


--We generate the Weekly Requirement
--We already have the Data Universe from the previous month
drop table BAI_Weekly_&&dayid purge;
create table BAI_Weekly_&&dayid as
(select 'C0037' as BANK_CODE, 'WEEKLY' as CYCLE_TYPE,
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
            then cafd.curr_bal_amt end) as NACH, --Non-Analysis Checking         
        sum(case when acct.PTYP_CD = 'DDA' AND acct.PRDT_CD_CD = '009'
            then cafd.curr_bal_amt end) as FBC,        
        sum(case when acct.PTYP_CD = 'DDA' AND acct.PRDT_CD_CD IN ('006','010','008','032','034') 
            then cafd.curr_bal_amt end) as NNC,
        sum(case when ((acct.PTYP_CD = 'DDA' AND acct.PRDT_CD_CD IN ('011','012','029','033','052')) OR
            (acct.PTYP_CD = 'SAV' AND acct.PRDT_CD_CD = '052'))
            then cafd.curr_bal_amt end) as INC,
                    
        sum(case when acct.PTYP_CD = 'DDA' AND acct.PRDT_CD_CD IN ('003','004','007','054','056')
            then cafd.curr_bal_amt end) as NAC, --Analysis Checking
            
        sum(case when acct.PTYP_CD = 'DDA' AND acct.PRDT_CD_CD = '087'
            then cafd.curr_bal_amt end) as SWP, --Commercial Sweep (On Balance Sheet)
            
        sum(null) as SWO, --We don't have Off Balance Sheet Commercial Sweeps     
            
        sum(case when acct.PTYP_CD = 'SAV' AND acct.PRDT_CD_CD IN ('069','071','074')
            then cafd.curr_bal_amt end) as BSV, --Business Savings
            --MMA = (RMA + HMA)
        sum(case when acct.PTYP_CD = 'SAV' AND acct.PRDT_CD_CD IN ('044','051','055','061','144','453')
            then cafd.curr_bal_amt end) as MMA, --Money Market
        sum(case when acct.PTYP_CD = 'SAV' AND acct.PRDT_CD_CD = '453'
            then cafd.curr_bal_amt end) as RMA,                
        sum(case when acct.PTYP_CD = 'SAV' AND acct.PRDT_CD_CD IN ('044','051','055','061','144')
            then cafd.curr_bal_amt end) as HMA,
        --For Business CDs we have to set the BUS_FLAG to 'C' whenever is null
        sum(case when acct.PTYP_CD = 'CDS' AND nvl(acct.BUS_FLAG,'C') != 'R' AND acct.RPTG_CC_CD != '01400' 
            then cafd.curr_bal_amt end) as BCD --Business CD

    FROM
        (select day_id, cust_id, acct_id, acct_typ, clos_dt, ca_dim_mktg_prdt_key, maty_dt,
        CLOS_MTH_ID, DIM_ACCT_KEY, OPEN_DT, PRDT_CD_CD, PTYP_CD, BUS_FLAG, RPTG_CC_CD  
        from ca_owner.ca_dim_acct where day_id = &&dayid) acct
    --We filter the customers that are part of the Universe
    INNER JOIN
        BAI_Data_Univ Univ
        ON acct.cust_id = Univ.cust_id
    --We need the daily balance        
    LEFT JOIN 
        (SELECT day_id, acct_id, curr_bal_amt 
        FROM ca_owner.ca_fact_acct_daily WHERE day_id = &&dayid) cafd
        ON acct.acct_id = cafd.acct_id        
    --We need the State Code
    LEFT JOIN 
        --These executions are before end of current month then we will have to take
        --the cust_geo_code table from previous month (cust_geo_code it is a monthly table)
        (SELECT day_id, cust_id, fips_state_cd FROM ci_ops.cust_geo_code 
        WHERE to_date(day_id,'YYYYMMDD') = trunc(to_date(&&dayid,'YYYYMMDD'),'MONTH') - 1) geo
        ON acct.cust_id = geo.cust_id        
    LEFT JOIN
        (SELECT distinct STATE_CODE, STATE_NAME FROM ci_ops.dim_CBSA) cbsa
        ON geo.fips_state_cd = cbsa.state_code
    LEFT JOIN
        (SELECT STATE_DESC, STATE_CD FROM ca_owner.ca_lkp_state) lkp
        --We need the Upper function because Oracle is case sensitive
        ON UPPER(cbsa.STATE_NAME) = UPPER(lkp.STATE_DESC)
    --Rollup STATE_CD because we also want a record with the sum of all states (National)      
    GROUP BY 'C0037', 'WEEKLY', rollup(lkp.STATE_CD), &&dayid
)
    ORDER BY BANK_CODE, CYCLE_TYPE, State, CYCLE_DT;


--Weekly Requirement
--select count(*) as cuenta from BAI_Weekly_&&dayid;
--select * from BAI_Weekly_&&dayid;
