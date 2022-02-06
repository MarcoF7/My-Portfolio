
/*Engine Table with LOB*/
proc sql;
create table Engine_Complete as
select Eng.*, ifrs.lob_dept1 as lob_dept1
from &ENGINE. Eng
LEFT JOIN &master_alll. ifrs 
ON Eng.CMCO_COD_CCONTR = ifrs.CMCO_COD_CCONTR
WHERE Eng.CMCO_IMP_PROV_FINAL <= 100000000000000;
quit;

/*Generate Parametric Table: EAD Evolution*/
PROC SQL;
   CREATE TABLE output.EAD_Evolution AS 
   SELECT "" as lob_dept1,
		  Family_Code,
   		  year,           
		  sum(EAD)/sum(CMCO_IMP_EAD_ACTUAL) as EAD_Decay
      FROM Engine_Complete
	  where DEFAULT_FLAG_FINAL NE "1" AND year <= 4 /*Performing accounts and up to 4 years projection*/
      GROUP BY 1,2,3
	  Having EAD_Decay NE .
;QUIT;