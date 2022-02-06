
/*Summary Provision Table using EAD final weight*/
/*Creates Cure Rates Table*/
proc sql;
	create table Cure_Rates as
	select family_code, Year, sum(Cure_Rate*EAD_actual) as cure_sum, sum(Cure_Rate*EAD_actual)/sum(EAD_actual) as Cure_Rate
	from output.stock_portf_provision
	where Calc_provision ne . /*and family_code = 'Commercial - C&I' */ and Year > 0
			and Stage_Base = 'S3' and Calc_Stage = 'S1'
	group by 1,2
;quit;

/*Creates EAD Decayment Table*/
proc sql;
	create table EAD_Decay as
	select Distinct Family_code, Year, sum(Decay_Rate*EAD_actual) as Decay_sum, sum(Decay_Rate*EAD_actual)/sum(EAD_actual) as EAD_Decay_Rate
	from output.stock_portf_provision
	where Calc_provision ne . and Year > 0
	group by 1,2
;quit;

/*Creates Transition Rates table weighted by EAD final */
proc sql;
	create table Expl_TR_Final as
	select lob_dept1 as Line_of_Business, family_code, Year, sum(Calc_EAD_Final) as sum_EAD, 
			sum((1-Transition_Rate)*Calc_EAD_Final) as Transition_Sum, sum((1-Transition_Rate)*Calc_EAD_Final)/sum(Calc_EAD_Final) as Transition_Rate 
	from output.stock_portf_provision
	where Calc_provision ne . /*and family_code = 'Commercial - C&I' */
			and Stage_Base = 'S1' and calc_stage = 'S1' and year >0
	group by 1,2,3
;quit;

/*Joins previous Transfer Rates (EAD Final), Cure Rates and Decay tables to create final table with all values*/
proc sql;
	create table output.Control_Prov_Final as
	select distinct * 
	from Expl_TR_Final TR
	left join Cure_Rates Cures
	on 	TR.Year = Cures.Year
	and TR.Family_Code = Cures.Family_Code
	left join EAD_Decay Decay
	on TR.Year = Decay.Year
	and TR.Family_Code = Decay.Family_Code
	group by TR.Line_of_Business, TR.Family_Code, TR.Year
	order by TR.Line_of_Business, TR.Family_Code, TR.Year
;quit;

/***********************************************************************************************************/

/*Summary provision table using initial EAD weight*/
/*Creates Explicit Transfer Rate Provision Table weighted by EAD actual*/
proc sql;
	create table Expl_TR_Act as
	select lob_dept1 as Line_of_Business, family_code, Year, sum(EAD_actual) as sum_EAD, 
			sum((1-Transition_Rate)*EAD_actual) as Transition_Sum, sum((1-Transition_Rate)*EAD_actual)/sum(EAD_actual) as Transition_Rate 
	from output.stock_portf_provision
	where Calc_provision ne . /*and family_code = 'Commercial - C&I' */
			and Stage_Base = 'S1' and calc_stage = 'S1' and year >0
	group by 1,2,3
;quit;

/*Joins previous 3 tables to create final table with all values*/
proc sql;
	create table output.Control_Prov_Act as
	select distinct * 
	from Expl_TR_Act TR
	left join Cure_Rates Cures
	on 	TR.Year = Cures.Year
	and TR.Family_Code = Cures.Family_Code
	left join EAD_Decay Decay
	on TR.Year = Decay.Year
	and TR.Family_Code = Decay.Family_Code
	group by TR.Line_of_Business, TR.Family_Code, TR.Year
	order by TR.Line_of_Business, TR.Family_Code, TR.Year
;quit;

/*Summary Provision using EAD from previous year*/

/*Joins stock portfolio table with itself, differed by a year*/
proc sql;
	create table EAD_prev as
	select a.lob_dept1, a.family_code, a.Year as Year_Prev, b.Year as Year_Future, a.Stage_Base, a.calc_stage, 
	a.EAD_actual, sum(a.EAD_actual) as EAD_ACTUAL_SUM, a.Calc_EAD_Final, sum(a.Calc_EAD_Final) as EAD_FINAL_SUM, a.Calc_provision, 
	a.Transition_Rate as TR_1, b.Transition_rate as TR_234
	from output.stock_portf_provision a
	left join output.stock_portf_provision b
	on 	a.lob_dept1 	= b.lob_dept1 	and
		a.family_code 	= b.family_code and
		a.year + 1 		= b.year  

	where a.Calc_provision ne . and a.Stage_Base = 'S1' and a.calc_stage = 'S3' and a.year > 0 
	and b.Calc_provision ne . and b.Stage_Base = 'S1' and b.calc_stage = 'S3' and b.year > 0
	group by 1,2,3
;quit;

/*Calculates Transition Rate for Year 1 from EAD_actual*/
proc sql;
	create table Expl_TR_1 as
	select lob_dept1 as Line_of_Business, family_code, Year_prev as Year, sum(EAD_actual) as sum_EAD, 
	sum(TR_1*EAD_actual) as Transition_Sum, 
	sum(TR_1*EAD_actual)/sum(EAD_actual) as Transition_Rate 
	from EAD_prev
	where Calc_provision ne . and Stage_Base = 'S1' and calc_stage = 'S3' and year_prev =1
	group by 1,2,3
;quit;

/*Calculates Transition Rate for years 2,3,4 from EAD from previous year*/
proc sql;
	create table Expl_TR_2 as
	select lob_dept1 as Line_of_Business, family_code, Year_future as Year, sum(Calc_EAD_Final) as sum_EAD, 
	sum(TR_234*Calc_EAD_Final) as Transition_Sum, 
	sum(TR_234*Calc_EAD_Final)/sum(Calc_EAD_Final) as Transition_Rate 
	from EAD_prev
	where Calc_provision ne . and Stage_Base = 'S1' and calc_stage = 'S3' and year_future >1
	group by 1,2,3
;quit;

data output.Summary_Prov_Prev;
set
Expl_TR_1
Expl_TR_2;

run;

proc sort data= output.Summary_Prov_Prev;
by Line_of_Business family_code Year;
run;


