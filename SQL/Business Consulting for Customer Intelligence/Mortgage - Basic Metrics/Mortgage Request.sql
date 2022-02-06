--Let's iterate from January through October  2018

-- SOLUTION #1: There is a historical table for mortgage request that stores information  on a monthly basis.
-- This solution only inserts monthly tables once.

-- First let's check if the historical table already exists. If not then we proceed to create it
SET SERVEROUTPUT ON;

DECLARE
  error_code NUMBER;
BEGIN
EXECUTE IMMEDIATE 
    'CREATE TABLE MTG_REQ_SEP18_Marco
    (
    day_id NUMBER(9,0),
    cust_id NUMBER,
    cust_open_flag NUMBER,
    cust_active_flag NUMBER,
    cust_reportable_flag NUMBER,
    lob_cd VARCHAR2(4),
    cust_type VARCHAR2(1),
    fips_state_cd VARCHAR2(2),
    state_name VARCHAR2(25),
    home_ownshp_cd VARCHAR2(1),
    HFS_IND NUMBER,
    HFS_ACCT_CNT NUMBER,
    lendr_name_1 VARCHAR2(30),
    lendr_name_2 VARCHAR2(30),
    mtge_ind NUMBER,
    tot_home_eqty_ind NUMBER,
    clrspnd_ind NUMBER,
    invst_ind NUMBER,
    NEW_CROSS_SELL NUMBER,
    NEW_CROSS_SELL_HFS NUMBER,
    BUS_CHKG_IND NUMBER,
    bus_cr_card_ind NUMBER,
    BUS_LOANS_IND NUMBER,
    BUS_MONEY_MKT_IND NUMBER,
    BUS_SVNGS_IND NUMBER,
    CD_IND NUMBER,
    CNSMR_CHKG_IND NUMBER,
    CNSMR_CR_CARD_IND NUMBER,
    CNSMR_INSTLMT_LOANS_IND NUMBER,
    CNSMR_MONEY_MKT_IND NUMBER,
    CNSMR_SVNGS_IND NUMBER,
    OVRDFT_LOC_IND NUMBER,
    BUS_CHKG_BAL NUMBER,
    BUS_CR_CARD_BAL NUMBER,
    BUS_LOANS_BAL NUMBER,
    BUS_MONEY_MKT_BAL NUMBER,
    BUS_SVNGS_BAL NUMBER,
    CD_BAL NUMBER,
    CNSMR_CHKG_BAL NUMBER,
    CNSMR_CR_CARD_BAL NUMBER,
    CNSMR_INSTLMT_LOANS_BAL NUMBER,
    CNSMR_MONEY_MKT_BAL NUMBER,
    CNSMR_SVNGS_BAL NUMBER,
    OVRDFT_LOC_BAL NUMBER    
    )';
-- If the table already exists we display an output message accordingly
exception
when others then
error_code := SQLCODE;
 if(error_code = -955)
 then
   dbms_output.put_line('Table exists already!'); 
 else
   dbms_output.put_line('Unknown error : '||SQLERRM); 
 end if;
end;

--Now we proceed to insert the monthly information only if it is not already inserted
DECLARE 
    v_day_id NUMBER;
    Repeated_Month NUMBER;
BEGIN
    FOR dy IN (select distinct day_id from sdss_owner.dim_day
                where day_id IN (20180228 
                , 20180131, 20180331, 20180430, 20180531, 20180630, 20180731
                , 20180831, 20180930))
    LOOP
        v_day_id := dy.day_id;
        
        --We want to count the number of records per month to see if a month was already inserted
        select count(*) into Repeated_Month 
            from MTG_REQ_SEP18_Marco
                where day_id = v_day_id;
                
        --If a month was already inserted(records > 0) we skip the current iteration        
        IF Repeated_Month > 0 THEN
            CONTINUE;
        END IF;
        
        --The information is inserted
        INSERT INTO MTG_REQ_SEP18_Marco(
            SELECT 
               beta.day_id, 
               beta.cust_id, 
               beta.cust_open_flag, 
               beta.cust_active_flag, 
               beta.cust_reportable_flag, 
               beta.lob_cd, 
               beta.cust_type, 
               geo.fips_state_cd, 
               cbsa.state_name, 
               hh.home_ownshp_cd, 
               CASE WHEN BETA.CUST_ID = HFS.CUST_ID THEN 1 ELSE 0 END AS HFS_IND,
               NVL(hfs_acct_cnt, 0) AS HFS_ACCT_CNT,
               acx.lendr_name_1,
               acx.lendr_name_2,
               beta.mtge_ind, 
               beta.tot_home_eqty_ind, 
               beta.clrspnd_ind, 
               beta.invst_ind, 
               beta.NEW_CROSS_SELL,
               --New definition of NEW_CROSS_SELL (BETA.CUST_ID = HFS.CUST_ID means HFS_IND = 1)
               case when BETA.CUST_ID = HFS.CUST_ID AND beta.mtge_ind = 0 THEN (beta.NEW_CROSS_SELL + 1) ELSE beta.NEW_CROSS_SELL END AS NEW_CROSS_SELL_HFS,
               beta.BUS_CHKG_IND, 
               beta.bus_cr_card_ind, 
               beta.BUS_LOANS_IND, 
               beta.BUS_MONEY_MKT_IND, 
               beta.BUS_SVNGS_IND, 
               beta.CD_IND, 
               beta.CNSMR_CHKG_IND, 
               beta.CNSMR_CR_CARD_IND, 
               beta.CNSMR_INSTLMT_LOANS_IND, 
               beta.CNSMR_MONEY_MKT_IND, 
               beta.CNSMR_SVNGS_IND, 
               beta.OVRDFT_LOC_IND,
               
               fact_mthly.BUS_CHKG_BAL,
               fact_mthly.BUS_CR_CARD_BAL,
               fact_mthly.BUS_LOANS_BAL,
               fact_mthly.BUS_MONEY_MKT_BAL,
               fact_mthly.BUS_SVNGS_BAL,
               fact_mthly.CD_BAL,
               fact_mthly.CNSMR_CHKG_BAL,
               fact_mthly.CNSMR_CR_CARD_BAL,
               fact_mthly.CNSMR_INSTLMT_LOANS_BAL,
               fact_mthly.CNSMR_MONEY_MKT_BAL,
               fact_mthly.CNSMR_SVNGS_BAL,
               fact_mthly.OVRDFT_LOC_BAL
               
        FROM 
        (SELECT day_id, cust_id, cust_open_flag, cust_reportable_flag, cust_active_flag, lob_cd, cust_type, mtge_ind, tot_home_eqty_ind,
                clrspnd_ind, invst_ind, NEW_CROSS_SELL, BUS_CHKG_IND, bus_cr_card_ind, BUS_LOANS_IND, BUS_MONEY_MKT_IND, BUS_SVNGS_IND, 
                CD_IND, CNSMR_CHKG_IND, CNSMR_CR_CARD_IND, CNSMR_INSTLMT_LOANS_IND, CNSMR_MONEY_MKT_IND, CNSMR_SVNGS_IND, OVRDFT_LOC_IND
        FROM cust_counts_beta_cumulative 
        WHERE day_id = V_DAY_ID and cust_open_flag = 1) beta
        
        LEFT JOIN 
        (SELECT day_id, cust_id, fips_state_cd FROM ci_ops.cust_geo_code WHERE day_id = V_DAY_ID) geo
        ON beta.cust_id = geo.cust_id
        
        LEFT JOIN
        (SELECT distinct STATE_CODE, STATE_NAME FROM ci_ops.dim_CBSA) cbsa
        ON geo.fips_state_cd = cbsa.state_code
        
        LEFT JOIN
        (SELECT hshld_id, cust_id FROM sdss_owner.LNK_CUST_HSHLD WHERE day_id= V_DAY_ID) hhlink
        ON beta.cust_id = hhlink.cust_id
        
        LEFT JOIN
        (SELECT hshld_id, home_ownshp_cd FROM sdss_owner.dim_hshld_demog WHERE day_id = V_DAY_ID) hh
        ON hhlink.hshld_id = hh.hshld_id
        
        LEFT JOIN
        (SELECT cust_id, lendr_name_1, lendr_name_2 FROM ca_owner.ca_dim_acx_apnd WHERE day_id = V_DAY_ID) acx
        ON beta.cust_id = acx.cust_id
        LEFT JOIN
        (SELECT day_id, cust_id, count(distinct acct_id) as hfs_acct_cnt
        FROM ca_owner.ca_dim_acct
        WHERE day_id = V_DAY_ID and
              clos_mth_id is null and
              ptyp_cd = 'MTG' and
              styp_cd = 'HFS'
        GROUP BY cust_id, day_id) hfs
        ON beta.cust_id = hfs.cust_id
        
        --We get the deposit accounts Balance requirement from CA_FACT_CUST_BAL_XSELL_MTHLY
        LEFT JOIN 
        (SELECT CUST_ID, BUS_CHKG_BAL, BUS_CR_CARD_BAL, BUS_LOANS_BAL, BUS_MONEY_MKT_BAL, BUS_SVNGS_BAL, CD_BAL, 
        CNSMR_CHKG_BAL, CNSMR_CR_CARD_BAL, CNSMR_INSTLMT_LOANS_BAL, CNSMR_MONEY_MKT_BAL, CNSMR_SVNGS_BAL,
        OVRDFT_LOC_BAL
        FROM CI_OPS.CA_FACT_CUST_BAL_XSELL_MTHLY WHERE DAY_ID = V_DAY_ID) fact_mthly
        ON beta.cust_id = fact_mthly.CUST_ID
        );     
    
        COMMIT;
    END LOOP;
END;
--End SOLUTION #1




select day_id, count(*) as cuenta
    from MTG_REQ_SEP18_Marco
        group by day_id;


select DAY_ID, CUST_ID, count(*) as cuenta
    from CI_OPS.CA_FACT_CUST_BAL_XSELL_MTHLY 
        where DAY_ID = 20180930
            group by DAY_ID, CUST_ID
                having count(*) > 1;



drop table MTG_REQ_SEP18_Marco2;


/*SOLUTION #2: Full Insert Into Method*/
-- First let's create the Template table
CREATE TABLE MTG_REQ_SEP18_Marco
(
day_id NUMBER(9,0),
cust_id NUMBER,
cust_open_flag NUMBER,
cust_active_flag NUMBER,
cust_reportable_flag NUMBER,
lob_cd VARCHAR2(4),
cust_type VARCHAR2(1),
fips_state_cd VARCHAR2(2),
state_name VARCHAR2(25),
home_ownshp_cd VARCHAR2(1),
HFS_IND NUMBER,
HFS_ACCT_CNT NUMBER,
lendr_name_1 VARCHAR2(30),
lendr_name_2 VARCHAR2(30),
mtge_ind NUMBER,
tot_home_eqty_ind NUMBER,
clrspnd_ind NUMBER,
invst_ind NUMBER,
NEW_CROSS_SELL NUMBER,
NEW_CROSS_SELL_HFS NUMBER,
BUS_CHKG_IND NUMBER,
bus_cr_card_ind NUMBER,
BUS_LOANS_IND NUMBER,
BUS_MONEY_MKT_IND NUMBER,
BUS_SVNGS_IND NUMBER,
CD_IND NUMBER,
CNSMR_CHKG_IND NUMBER,
CNSMR_CR_CARD_IND NUMBER,
CNSMR_INSTLMT_LOANS_IND NUMBER,
CNSMR_MONEY_MKT_IND NUMBER,
CNSMR_SVNGS_IND NUMBER,
OVRDFT_LOC_IND NUMBER,
BUS_CHKG_BAL NUMBER,
BUS_CR_CARD_BAL NUMBER,
BUS_LOANS_BAL NUMBER,
BUS_MONEY_MKT_BAL NUMBER,
BUS_SVNGS_BAL NUMBER,
CD_BAL NUMBER,
CNSMR_CHKG_BAL NUMBER,
CNSMR_CR_CARD_BAL NUMBER,
CNSMR_INSTLMT_LOANS_BAL NUMBER,
CNSMR_MONEY_MKT_BAL NUMBER,
CNSMR_SVNGS_BAL NUMBER,
OVRDFT_LOC_BAL NUMBER    
);

--Here all months are inserted one by one on every execution
--So if in the future some past table is edited, this method will take that into account for the result
DECLARE 
    v_day_id NUMBER;
BEGIN
    FOR dy IN (select distinct day_id from sdss_owner.dim_day
                where day_id IN (
                
                --20180131, 20180228, 20180331, 20180430, 20180531, 20180630, 20180731, 20180831, 
                
                20180930
                
                ))
    LOOP
        v_day_id := dy.day_id;
        
        INSERT INTO MTG_REQ_SEP18_Marco(
            SELECT 
               beta.day_id, 
               beta.cust_id, 
               beta.cust_open_flag, 
               beta.cust_active_flag, 
               beta.cust_reportable_flag, 
               beta.lob_cd, 
               beta.cust_type, 
               geo.fips_state_cd, 
               cbsa.state_name, 
               hh.home_ownshp_cd, 
               CASE WHEN BETA.CUST_ID = HFS.CUST_ID THEN 1 ELSE 0 END AS HFS_IND,
               NVL(hfs_acct_cnt, 0) AS HFS_ACCT_CNT,
               acx.lendr_name_1,
               acx.lendr_name_2,
               beta.mtge_ind, 
               beta.tot_home_eqty_ind, 
               beta.clrspnd_ind, 
               beta.invst_ind, 
               beta.NEW_CROSS_SELL,
               --New definition of NEW_CROSS_SELL (BETA.CUST_ID = HFS.CUST_ID means HFS_IND = 1)
               case when BETA.CUST_ID = HFS.CUST_ID AND beta.mtge_ind = 0 THEN (beta.NEW_CROSS_SELL + 1) ELSE beta.NEW_CROSS_SELL END AS NEW_CROSS_SELL_HFS,
               beta.BUS_CHKG_IND, 
               beta.bus_cr_card_ind, 
               beta.BUS_LOANS_IND, 
               beta.BUS_MONEY_MKT_IND, 
               beta.BUS_SVNGS_IND, 
               beta.CD_IND, 
               beta.CNSMR_CHKG_IND, 
               beta.CNSMR_CR_CARD_IND, 
               beta.CNSMR_INSTLMT_LOANS_IND, 
               beta.CNSMR_MONEY_MKT_IND, 
               beta.CNSMR_SVNGS_IND, 
               beta.OVRDFT_LOC_IND,
               
               fact_mthly.BUS_CHKG_BAL,
               fact_mthly.BUS_CR_CARD_BAL,
               fact_mthly.BUS_LOANS_BAL,
               fact_mthly.BUS_MONEY_MKT_BAL,
               fact_mthly.BUS_SVNGS_BAL,
               fact_mthly.CD_BAL,
               fact_mthly.CNSMR_CHKG_BAL,
               fact_mthly.CNSMR_CR_CARD_BAL,
               fact_mthly.CNSMR_INSTLMT_LOANS_BAL,
               fact_mthly.CNSMR_MONEY_MKT_BAL,
               fact_mthly.CNSMR_SVNGS_BAL,
               fact_mthly.OVRDFT_LOC_BAL
               
        FROM 
        (SELECT day_id, cust_id, cust_open_flag, cust_reportable_flag, cust_active_flag, lob_cd, cust_type, mtge_ind, tot_home_eqty_ind,
                clrspnd_ind, invst_ind, NEW_CROSS_SELL, BUS_CHKG_IND, bus_cr_card_ind, BUS_LOANS_IND, BUS_MONEY_MKT_IND, BUS_SVNGS_IND, 
                CD_IND, CNSMR_CHKG_IND, CNSMR_CR_CARD_IND, CNSMR_INSTLMT_LOANS_IND, CNSMR_MONEY_MKT_IND, CNSMR_SVNGS_IND, OVRDFT_LOC_IND
        FROM cust_counts_beta_cumulative 
        WHERE day_id = V_DAY_ID and cust_open_flag = 1) beta
        
        LEFT JOIN 
        (SELECT day_id, cust_id, fips_state_cd FROM ci_ops.cust_geo_code WHERE day_id = V_DAY_ID) geo
        ON beta.cust_id = geo.cust_id
        
        LEFT JOIN
        (SELECT distinct STATE_CODE, STATE_NAME FROM ci_ops.dim_CBSA) cbsa
        ON geo.fips_state_cd = cbsa.state_code
        
        LEFT JOIN
        (SELECT hshld_id, cust_id FROM sdss_owner.LNK_CUST_HSHLD WHERE day_id= V_DAY_ID) hhlink
        ON beta.cust_id = hhlink.cust_id
        
        LEFT JOIN
        (SELECT hshld_id, home_ownshp_cd FROM sdss_owner.dim_hshld_demog WHERE day_id = V_DAY_ID) hh
        ON hhlink.hshld_id = hh.hshld_id
        
        LEFT JOIN
        (SELECT cust_id, lendr_name_1, lendr_name_2 FROM ca_owner.ca_dim_acx_apnd WHERE day_id = V_DAY_ID) acx
        ON beta.cust_id = acx.cust_id
        LEFT JOIN
        (SELECT day_id, cust_id, count(distinct acct_id) as hfs_acct_cnt
        FROM ca_owner.ca_dim_acct
        WHERE day_id = V_DAY_ID and
              clos_mth_id is null and
              ptyp_cd = 'MTG' and
              styp_cd = 'HFS'
        GROUP BY cust_id, day_id) hfs
        ON beta.cust_id = hfs.cust_id
        
        --We get the deposit accounts Balance requirement from CA_FACT_CUST_BAL_XSELL_MTHLY
        LEFT JOIN 
        (SELECT CUST_ID, BUS_CHKG_BAL, BUS_CR_CARD_BAL, BUS_LOANS_BAL, BUS_MONEY_MKT_BAL, BUS_SVNGS_BAL, CD_BAL, 
        CNSMR_CHKG_BAL, CNSMR_CR_CARD_BAL, CNSMR_INSTLMT_LOANS_BAL, CNSMR_MONEY_MKT_BAL, CNSMR_SVNGS_BAL,
        OVRDFT_LOC_BAL
        FROM CI_OPS.CA_FACT_CUST_BAL_XSELL_MTHLY WHERE DAY_ID = V_DAY_ID) fact_mthly
        ON beta.cust_id = fact_mthly.CUST_ID
        );          
            
        COMMIT;
    END LOOP;
END;
--End SOLUTION #2

select * from MTG_REQ_SEP18_Marco;


select * from CI_OPS.CA_FACT_CUST_BAL_XSELL_MTHLY where day_id = 20180930;


-- The next Step is to aggregate the information and perform some calculations required for the Mortgage request
CREATE TABLE MTG_REQ_SEP18_Marco2 AS 
SELECT t1.DAY_ID, 
      t1.CUST_OPEN_FLAG, 
      t1.CUST_ACTIVE_FLAG, 
      t1.CUST_REPORTABLE_FLAG,
      case when t1.CUST_REPORTABLE_FLAG = 1 OR t1.HFS_IND = 1 then 1 else 0 end as New_Reportable_Flag,
      case when t1.CUST_ACTIVE_FLAG = 1 OR t1.HFS_IND = 1 then 1 else 0 end as New_Active_Flag,
      t1.LOB_CD, 
      t1.CUST_TYPE, 
      t1.FIPS_STATE_CD, 
      t1.STATE_NAME, 
      t1.HOME_OWNSHP_CD,
      
      case when t1.HOME_OWNSHP_CD = 'O' then 'O' 
            when t1.MTGE_IND = 1 then 'O'
            when t1.TOT_HOME_EQTY_IND = 1 then 'O'
            when t1.HFS_IND = 1 then 'O'
            else t1.HOME_OWNSHP_CD end as NEW_HOME_OWNSHP_CD,
        
      case when t1.LENDR_NAME_1 is NOT NULL then 1 else 0 end as LENDR_NAME_1,
      case when t1.lendr_name_2 is NOT NULL then 1 else 0 end as lendr_name_2,
      case when t1.MTGE_IND = 1 OR t1.HFS_IND = 1 OR t1.LENDR_NAME_1 IS NOT NULL then 1 else 0 end as Has_Mortgage_Any,
      t1.HFS_IND, 
      t1.MTGE_IND, 
      case when t1.HFS_IND = 1 OR t1.MTGE_IND = 1 then 1 else 0 end as Has_HFS_or_BBVA_Mtg,
      t1.TOT_HOME_EQTY_IND, 
      
        (COUNT(t1.CUST_ID)) AS COUNT_of_CUST_ID, 
        (SUM(t1.HFS_ACCT_CNT)) AS SUM_of_HFS_ACCT_CNT, 
        (SUM(t1.HFS_IND)) AS SUM_of_HFS_IND, 
        (SUM(t1.MTGE_IND)) AS SUM_of_MTGE_IND, 
        (SUM(t1.TOT_HOME_EQTY_IND)) AS SUM_of_TOT_HOME_EQTY_IND, 
        (SUM(t1.CLRSPND_IND)) AS SUM_of_CLRSPND_IND, 
        (SUM(t1.INVST_IND)) AS SUM_of_INVST_IND, 
        
        (SUM(t1.NEW_CROSS_SELL)) AS SUM_of_NEW_CROSS_SELL,
        (SUM(t1.NEW_CROSS_SELL_HFS)) AS SUM_of_NEW_CROSS_SELL_HFS,
        
        (SUM(t1.BUS_CHKG_IND)) AS SUM_of_BUS_CHKG_IND, 
        (SUM(t1.BUS_CR_CARD_IND)) AS SUM_of_BUS_CR_CARD_IND, 
        (SUM(t1.BUS_LOANS_IND)) AS SUM_of_BUS_LOANS_IND, 
        (SUM(t1.BUS_MONEY_MKT_IND)) AS SUM_of_BUS_MONEY_MKT_IND, 
        (SUM(t1.BUS_SVNGS_IND)) AS SUM_of_BUS_SVNGS_IND, 
        (SUM(t1.CD_IND)) AS SUM_of_CD_IND, 
        (SUM(t1.CNSMR_CHKG_IND)) AS SUM_of_CNSMR_CHKG_IND, 
        (SUM(t1.CNSMR_CR_CARD_IND)) AS SUM_of_CNSMR_CR_CARD_IND, 
        (SUM(t1.CNSMR_INSTLMT_LOANS_IND)) AS SUM_of_CNSMR_INSTLMT_LOANS_IND, 
        (SUM(t1.CNSMR_MONEY_MKT_IND)) AS SUM_of_CNSMR_MONEY_MKT_IND, 
        (SUM(t1.CNSMR_SVNGS_IND)) AS SUM_of_CNSMR_SVNGS_IND, 
        (SUM(t1.OVRDFT_LOC_IND)) AS SUM_of_OVRDFT_LOC_IND,
        
        --Balances
        SUM(t1.BUS_CHKG_BAL) AS SUM_BUS_CHKG_BAL,
        SUM(t1.BUS_CR_CARD_BAL) AS SUM_BUS_CR_CARD_BAL,
        SUM(t1.BUS_LOANS_BAL) AS SUM_BUS_LOANS_BAL,
        SUM(t1.BUS_MONEY_MKT_BAL) AS SUM_BUS_MONEY_MKT_BAL,
        SUM(t1.BUS_SVNGS_BAL) AS SUM_BUS_SVNGS_BAL,
        SUM(t1.CD_BAL) AS SUM_CD_BAL,
        SUM(t1.CNSMR_CHKG_BAL) AS SUM_CNSMR_CHKG_BAL,
        SUM(t1.CNSMR_CR_CARD_BAL) AS SUM_CNSMR_CR_CARD_BAL,
        SUM(t1.CNSMR_INSTLMT_LOANS_BAL) AS SUM_CNSMR_INSTLMT_LOANS_BAL,
        SUM(t1.CNSMR_MONEY_MKT_BAL) AS SUM_CNSMR_MONEY_MKT_BAL,
        SUM(t1.CNSMR_SVNGS_BAL) AS SUM_CNSMR_SVNGS_BAL,
        SUM(t1.OVRDFT_LOC_BAL) AS SUM_OVRDFT_LOC_BAL        
        
                
      FROM MTG_REQ_SEP18_Marco t1
      
          GROUP BY t1.DAY_ID, t1.CUST_OPEN_FLAG, t1.CUST_ACTIVE_FLAG, t1.CUST_REPORTABLE_FLAG, 
          case when t1.CUST_REPORTABLE_FLAG = 1 OR t1.HFS_IND = 1 then 1 else 0 end,
          case when t1.CUST_ACTIVE_FLAG = 1 OR t1.HFS_IND = 1 then 1 else 0 end,
          t1.LOB_CD, t1.CUST_TYPE, 
          t1.FIPS_STATE_CD, t1.STATE_NAME, t1.HOME_OWNSHP_CD, 
          case when t1.HOME_OWNSHP_CD = 'O' then 'O' 
          when t1.MTGE_IND = 1 then 'O'
          when t1.TOT_HOME_EQTY_IND = 1 then 'O'
          when t1.HFS_IND = 1 then 'O'
          else t1.HOME_OWNSHP_CD end,
          case when t1.LENDR_NAME_1 is NOT NULL then 1 else 0 end, 
          case when t1.lendr_name_2 is NOT NULL then 1 else 0 end,
          case when t1.MTGE_IND = 1 OR t1.HFS_IND = 1 OR t1.LENDR_NAME_1 IS NOT NULL then 1 else 0 end,
          t1.HFS_IND, t1.MTGE_IND,
          case when t1.HFS_IND = 1 OR t1.MTGE_IND = 1 then 1 else 0 end,  
          t1.TOT_HOME_EQTY_IND;


select * from MTG_REQ_SEP18_Marco2;
