
/*Engine Table with LOB*/
proc sql;
create table Engine_Complete as
select Eng.*, ifrs.lob_dept1 as lob_dept1
from &ENGINE. Eng
LEFT JOIN &master_alll. ifrs 
ON Eng.CMCO_COD_CCONTR = ifrs.CMCO_COD_CCONTR
WHERE Eng.CMCO_IMP_PROV_FINAL <= 100000000000000;
quit;

/*Generate Parametric Tables: Expected Loss for non-default and for default accounts*/

/*Calculates EL for non-default accounts based on the PD Driver*/

/*Base Table for Expected Loss for non-default calculation*/
PROC SQL;
  	CREATE TABLE Expected_Loss_Base AS 
  	SELECT CMCO_FEC_DATOS as DAY_ID,
  	lob_dept1,
  	Family_Code,
  	Driver_PD,
	year, 
  	ceil(CMCO_PLZ_RESID) as PLZ_RESID,
	sum(CMCO_IMP_EAD_ACTUAL) as Sum_EAD,
	sum(EL) as Sum_EL
    FROM Engine_Complete
	where DEFAULT_FLAG_FINAL NE "1" 
    GROUP BY 1,2,3,4,5,6
 	Having sum_EL NE .
 	order by 1,2,3,4,5,6
;QUIT;

/*Joins prior table with itself in order to calculate EL off of later years in the contract*/
PROC SQL;
  	CREATE TABLE Output.Expected_Loss_s1 (drop=EL_A EL_B) AS 
  	SELECT
  	a.lob_dept1,
  	a.Family_Code,
  	a.Driver_PD,
	a.PLZ_RESID,
 	a.year, 
	a.sum_EAD,
	a.Sum_EL as EL_A,
	sum(b.Sum_EL) as EL_B,
 	sum(b.Sum_EL)/a.sum_EAD AS Expected_Loss
    FROM Expected_Loss_Base a
	left join Expected_Loss_Base b
	on 	a.lob_dept1 	= b.lob_dept1 	and
		a.Family_Code 	= b.Family_Code and
		a.Driver_PD 	= b.Driver_PD 	and
		a.PLZ_RESID 	= b.PLZ_RESID 	and
		b.year 			> a.year 
 	where a.year <= 4 /*Up to 4 years projection*/
	AND   a.year < a.PLZ_RESID /*We can't project in the last year*/
    GROUP BY 1,2,3,4,5,6,7
 	order by 1,2,3,4,5,6,7
;QUIT;


/*Calculates EL for default accounts based on the LGD Driver*/
proc sql;
create table Output.Expected_Loss_s3 as
select distinct "" as lob_dept1, Family_Code, 
LGD_Driver as Driver_LGD, year_to as year, LGD as Expected_Loss
from Output.LGD_Driver
where year_to <= 4
order by 1,2,3,4;
quit;