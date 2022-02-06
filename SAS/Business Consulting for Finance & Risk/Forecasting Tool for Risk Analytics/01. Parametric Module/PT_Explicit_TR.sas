
/*Engine Table with LOB*/
proc sql;
create table Engine_Complete as
select Eng.*, ifrs.lob_dept1 as lob_dept1
from &ENGINE. Eng
LEFT JOIN &master_alll. ifrs 
ON Eng.CMCO_COD_CCONTR = ifrs.CMCO_COD_CCONTR
WHERE Eng.CMCO_IMP_PROV_FINAL <= 100000000000000;
quit;

/*Generate Parametric Table: Explicit Transfer Rate*/
PROC SQL;
   CREATE TABLE output.Explicit_TR AS 
   SELECT lob_dept1,
		  Family_Code,
		  Driver_PD,
		  'S1 to S3' as Transition,
   		  year,           
          SUM(PD*CMCO_IMP_EAD_ACTUAL)/sum(CMCO_IMP_EAD_ACTUAL) AS Transition_Rate 
      FROM Engine_Complete
	  where DEFAULT_FLAG_FINAL NE "1" AND year <= 4 /*Performing accounts and up to 4 years projection*/
      GROUP BY 1,2,3,4,5
	  Having Transition_Rate NE .
;QUIT;