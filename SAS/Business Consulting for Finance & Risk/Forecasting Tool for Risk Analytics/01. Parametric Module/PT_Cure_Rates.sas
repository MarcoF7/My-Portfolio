/*Creating the Cure Rates Parametric Table*/

/*Pulls needed variables from Database Parameters*/
proc sql;
	create table RKA.Cure_Rates_1 as
	select distinct account_final_MIS, BATCH_ID, Product_Final_Facility, default_flag_1pct_facility, 
	input((substr(Put(BATCH_ID, 8.),1, 4)),4.) as Cohort_Orig, total_commitment_facility 
	from ALLPROD.Database_Parameters
;quit;

/*Joins Cure_Rates_1 to itself, deferring by a year, to later determine cures*/
proc sql;
	create table RKA.Cure_Rates_Final as
	select distinct CR1.* ,  CR2.Cohort_Orig as Cohort_Future, CR2.default_flag_1pct_facility as Default_Future
	from RKA.Cure_Rates_1 CR1
	left join RKA.Cure_Rates_1 CR2
	on 	CR1.account_final_MIS 	= CR2.account_final_MIS and
		CR1.Cohort_Orig +1 		= CR2.Cohort_Orig
	where CR2.Cohort_Orig ne .
;quit;

/*Adds additional variable, cure_flag, which has a value of 1 when a cure has occured*/
proc sql;
	create table Cure_Rates_Flag as
	select distinct account_final_MIS, Product_Final_Facility, default_flag_1pct_facility, 
			Cohort_Orig, total_commitment_facility, 
			case 		when default_flag_1pct_facility = 1 and Default_Future = 0 
						then 1
						else 0 end as cure_flag
	from RKA.Cure_Rates_Final
;quit;

/*Creates aux variable in order to sum total commitment that cured*/
proc sql;
	create table total_com_aux as
	select *, case when  cure_flag = 1 then total_commitment_facility else 0 end as total_Com_Aux
	from Cure_Rates_Flag 
;quit;

/*Sums the number of cured accounts and the total commitment cured for each product and year*/
proc sql;
   	create table Cure_Rates_Final_Count AS 
   	select *, sum(cure_flag) as Cure_Flag_Sum,
			  sum(total_Com_Aux) as Commit_Sum_Cured
   	from total_com_aux
	where default_flag_1pct_facility = 1 
   	group by Product_Final_Facility, Cohort_Orig
   	order by Product_Final_Facility, Cohort_Orig
;quit;

/*Sums the number of default accounts in each product and year*/
proc sql;
   	create table Cure_Rates_Final_Sum AS 
   	select *, Count(*) as num_of_accounts, sum(total_commitment_facility) as Commit_Sum_All
    from Cure_Rates_Final_Count
    group by Product_Final_Facility, Cohort_Orig
	order by Product_Final_Facility, Cohort_Orig 
;quit;

/*Calculates the percentage of cures out of the total default accounts from the same product and year*/
proc sql;
	create table Cure_Rates_in as
	select distinct Count.Product_Final_Facility, Count.Cohort_Orig, Count.Cure_flag_sum / Sum.num_of_accounts as Cure_Rate_Perc,
			Count.Commit_Sum_Cured, Count.Commit_Sum_Cured / Sum.Commit_Sum_All as Commit_Perc
	from Cure_Rates_Final_Count Count
	left join Cure_Rates_Final_Sum Sum
	on 	Count.account_final_MIS 		= Sum.account_final_MIS			and
		Count.Product_Final_Facility 	= Sum.Product_Final_Facility	and
		Count.Cohort_Orig				= Sum.Cohort_Orig
	group by 1,2
	
;quit;


proc sql;
	create table Output.Cure_Rates as 
	select "" as lob_dept1, Product_Final_Facility as Family_Code, 
			1 as Year, 'S3 to S1' as Transition,  
			avg(Commit_Perc) as Cure_Rate /*,avg(Cure_Rate_Perc) as Cure_Rate_Num*/
	from  Cure_Rates_in
	group by 1,2,3,4
;quit;