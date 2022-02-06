/*
KPI4. CHECK COLLECTION
CREATION OF A TABLE TO SHOW THE NUMBER OF CHECK COLLECTIONS AND TOTAL AMOUNT BROKEN OUT BY:
  - BATCH_MONTH.         MONTH AT WHICH THE TRANSACTIONS WERE REPORTED
  - ACCOUNTS.            ACCOUNT ID ASSOCIATED TO THE TRANSACTIONS 
  - PRODUCT_NAME.        DESCRIPTION OF THE PRODUCT TIED TO THE TRANSACTION
  - SUBPRODUCT_NAME.     DESCRIPTION OF THE SUBPRODUCT TIED TO THE TRANSACTION
  - LOB                  LINE OF BUSINESS (RETAIL, SMEs?)
  - CHANNEL_DESCRIPTION  CHANNEL AT WHICH THE TRANSACTION WAS PERFORMED
  - CURRENCY             ORIGINAL CURRENCY USED IN TRANSACTION
  - DEBITCREDITFLAG      CREDIT/DEBIT FLAG
  - COST_CENTER          COST CENTER TIED TO THE TRANSACTION
*/

CREATE TABLE CHECK_COLLECTION AS
SELECT * FROM (
SELECT 
	MONTH(T1.DAT ACCT)            AS BATCH_MONTH,
	'CHECK COLLECTION'            AS ITEM,
	T1.ACC                        AS ACCOUNTS,                                                                                              -- CONFIRM ACCOUNT LEVEL (COMMERCIAL WAS AT CLIENT LEVEL)
	T3.DES_CODE                   AS PRODUCT_NAME, /*MARCO: Should be _DES_CODE*/                                                                                          -- MANUEL FONSECA. PRODUCT DESCRIPTION - MISSING FILTER FOR CONSUMER
	T3.SDE_CODE                   AS SUBPRODUCT_NAME, /*MARCO: Should be _SDE_CODE*/                                                                        
	CASE WHEN T5.CONSUMER_FLAG = 'Y' THEN 'CONSUMER'
		   ELSE 'RETAIL SME' END    AS LOB,                                                                                                   
	SUM(T1.AMOUNT)                AS AMOUNT,
	T6.HOLDING_CHANNEL_DESC       AS CHANNEL_DESCRIPTION,                                                                                  -- PENDING MANUEL FONSECA TO SEND US MATCH OF T304 WITH HOLDING TABLE. UNDER CONFIRMATION. EXCLUDE "SIMPLE" IN TABLE WITH FINAL UNIVERSE
	COUNT(T1.NUM OPERATION)       AS UNITS(#TRANSACTIONS),                                                                                  -- COUNTING EVERY TRANSACTION WOULD BE THE SAME AS COUNTING THE NUMBER OF OPERATIONS
	T1.OCC                        AS CURRENCY,
  'CREDIT'                      AS DEBITCREDITFLAG, 
  T4.COSTCENTER                 AS COST_CENTER                                                                             
  
-- BGDT071. TABLE WITH  THE TRANSACTIONS DETAILS:
FROM BGDT071 T1 

-- BGDT919. TABLE WITH "CODE" AND "TRANCODE" DESCRIPTIONS:
INNER JOIN BGDT919 T2
	  ON T1.CODE = T2.CODE AND T1.TRANCODE = T2.TRANCODE
    WHERE T2.DLCA = 'Y' AND T2.SRC SYS IN ('0','4','5','6'), /*MARCO: DLCA should be FLGUPDDLCA; SRC SYS should be SRCSYS*/
					
-- WPDT003. TABLE WITH PRODUCTS AND SUBPRODUCTS CATEGORIES:
  LEFT JOIN WPDT003 T3 
	  ON T1.COD PRODUCT = T3.COD PRODUCT AND T1.COD SPROD = T3.COD SUBPRODUCT /*MARCO: T3.COD PRODUCT should be T3._COD_PRODUCT; T3.COD SUBPRODUCT should be T3._CODE*/                                          
    --WHERE T1.COD PRODUCT IN ('X','Y','Z') 																	                                                            -- CONFIRM VALUES OF PRODUCT                                                     														
		--AND T1.COD SPROD IN ('A','B','C'),																	                                                                -- CONFIRM VALUES OF SUBPRODUCT

-- BGDT006. CROSS-TABLE TO GET "SYSTEM TYPE" TO LINK WITH THE T812 TO GET CONSUMER/NON CONSUMER FLAG:	
  LEFT JOIN BGDT006 T4  
	  ON T1.ENT = T4.ENT AND T1.CEN REG = T4.CEN REG AND T1.ACC = T4.ACC /*MARCO: T4.CEN REG should be T4.CENREG*/

-- T812. TABLE WITH CONSUMER/NON CONSUMER FLAG:	 
  LEFT JOIN T812 T5
	  ON T4.SYSTEM_TYPE = T5.KEY TABLE, /*MARCO: T4.SYSTEM_TYPE should be T4.SYSTEMTYPE*/                                                                                                    -- CONFIRM SYSTEM TYPE
 
-- T304. TABLE WITH CHANNEL TYPE:
  LEFT JOIN T304 T6                                                                                                                      -- PENDING MANUEL FONSECA TO SEND US MATCH OF T304 WITH HOLDING TABLE. UNDER CONFIRMATION. EXCLUDE "SIMPLE" IN TABLE WITH FINAL UNIVERSE
	   	ON  T1.FLGFREE1 = T6.KEY_HOLDING_CHANNEL /*MARCO: It should be FLG FREE1*/

-- REQUIRED CRITERIA TO IDENTIFY CASH DEPOSIT TRANSACTIONS:
WHERE T1.DAT ACCT BETWEEN 2018-10-01 AND 2018-10-31
    AND ((T1.CODE IN ('425') AND T1.TRANCODE IN ('0021','0756'))
    OR (T1.CODE IN ('426') AND T1.TRANCODE IN ('0029','0684'))
    OR (T1.CODE IN ('427') AND T1.TRANCODE IN ('0030','0874'))
    OR (T1.CODE IN ('428') AND T1.TRANCODE IN ('0035'))
    OR (T1.CODE IN ('528') AND T1.TRANCODE IN ('0735'))
    OR (T1.CODE IN ('D67') AND T1.TRANCODE IN ('0738'))) 
    AND T1.COD PRODUCT= "02"                                                                                                              -- '02' REFERS TO FREQUENT TRANSACTION ACCOUNTS (DDA, CHECKING ACCOUNTS, MONEY MARKET ACCOUNTS)                                                                                                         )
    AND T1.CREDEB = 'D' /*MARCO: It should be FLG CREDEB*/
    AND T1.CHECK != 0
    AND NOT ((LEN(T1.CHECK) = 6) AND (SUBSTR(T1.CHECK,1,2) = '90'))                                                                       -- EXCLUDING THE BILL PAY CHECKS
    AND ((T5.CONSUMER_FLAG = 'Y') OR (T5.CONSUMER_FLAG = 'N' AND (T1.COD SPROD IN ('0008','0009','0012','0029', '0044','0071','0144'))
    AND (T4.COSTCENTER IN (SELECT COST_CENTER FROM RETAIL_BRANCH_REPORT T7)))) /*MARCO: COST_CENTER should be Cost Center*/                                                          -- AMANDA HARDEN INDICATED THESE SUBPRODUCT CODES BELONG TO SMEs. LOGIC TO SEGMENT CONSUMER/NON CONSUMER TRANSACTIONS: (BGDT071 ACC+NUMOPERATION => BGDT006 | BGDT006 SYSTEM_TYPE => T812)
)
GROUP BY BATCH_MONTH, LOB, CHANNEL_DESCRIPTION, COST_CENTER, PRODUCT_NAME, SUBPRODUCT_NAME, ACCOUNTS, DEBITCREDITFLAG, CURRENCY
;
