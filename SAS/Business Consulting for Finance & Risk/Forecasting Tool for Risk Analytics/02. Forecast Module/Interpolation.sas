

/*output.Stock_Portf_Provision
AUTOMATE THE Date_Year4 macro variable
*/


data test_prev;
	format _year z4.0;
	format _month z2.0;
	format _day z2.0;
	format _date mmddyy10.;
	format _date_begin_nxt mmddyy10.;
	format _date_end mmddyy10.;
	format _date_end_format 8.;

	format _date_final mmddyy10.;
	format _date_final_format 8.;

	_year = input(substr(left(&DAY),1,4),4.);
	_month = input(substr(left(&DAY),5,2),2.);
	_day = input(substr(left(&DAY),7,2),2.);
	_date = mdy(_month, _day, _year);
	call symput('Date_Year0',_date); /*batch in date format*/

	_date_begin_nxt = intnx("Day",_date,1);
	_date_end = intnx("Month",_date_begin_nxt,0,"E");

	_date_end_format = input(cats(
	substr(put(_date_end, mmddyy10.),7,4),
	substr(put(_date_end, mmddyy10.),1,2),
	substr(put(_date_end, mmddyy10.),4,2)
	),$8.);
	call symput('_date_end_format', _date_end_format); /*Next Month*/

	_date_final = intnx("Year",_date,4,"Sameday");

	_date_final_format = input(cats(
	substr(put(_date_final, mmddyy10.),7,4),
	substr(put(_date_final, mmddyy10.),1,2),
	substr(put(_date_final, mmddyy10.),4,2)
	),$8.);
	call symput('_date_final_format', _date_final_format); /*Final Projection Date*/
	call symput('Date_Year4',_date_final);
run;

%put Date_Year0 = &Date_Year0.;
%put Date_Year4 = &Date_Year4.;


DATA years_iter;
	format date mmddyy10.;
    DO date = &Date_Year0. TO &Date_Year4.;
		OUTPUT; 
    END;
RUN;

data years_iter_nxt_dy;
set years_iter;
	format date_next_day mmddyy10.;
	date_next_day = intnx("day",date, 1);
	day_next_day = day(date_next_day);
run;

data years_iter_format;
set years_iter_nxt_dy;
	format date_format 8.;
	date_format = input(cats(
	substr(put(date, mmddyy10.),7,4),
	substr(put(date, mmddyy10.),1,2),
	substr(put(date, mmddyy10.),4,2)
	),$8.);
	date_format_Lag = lag(date_format);
	where day_next_day = 1;
run;

proc sql;
	select cats("'", date_format, "'n") into: Batch_IDs
	separated by " "
	from years_iter_format;
quit;

%put &Batch_IDs.;



proc sql;
create table Summary_for_transp as
select lob_dept1, Family_Code, Stage_Base, DAY_ID_PY, 
sum(Calc_EAD_Final) as Calc_EAD_Final,
sum(Calc_Provision) as Calc_Provision
from output.Stock_Portf_Provision
group by 1,2,3,4;
quit;

proc transpose 
data=Summary_for_transp
out=Portfolio_Transposed
name=Balance;
by lob_dept1 Family_Code Stage_Base;
id DAY_ID_PY;
run;

proc contents data=Portfolio_Transposed out=Trans_name noprint;
run;

proc sql;
create table Trans_name_Numer as
select Name as Orig_Name, strip(Name) as Name
from Trans_name
where type = 1;
quit;

proc sql;
select cat("'",trim(Orig_Name), "'n = '", strip(Orig_Name), "'n") into: Rename_Trans
separated by " "
from Trans_name_Numer;	
quit;

proc sort data=Trans_name_Numer out=Trans_name_Order(drop=Orig_Name);
by Name;
run;

data Trans_name_Lag(where=(Name_past ne ""));
set Trans_name_Order;
Name_past = Lag(Name);
run;

data Trans_name_Count;
set Trans_name_Lag;
i = monotonic();
run;

proc sql;
select cats("Diff", i) into: Diff_Trans
separated by " "
from Trans_name_Count;
quit;


proc sql;
select cats("Diff", i, "=('", Name, "'n-'", Name_past,"'n)/12") into: Subst_Trans
separated by ";"
from Trans_name_Count;
quit;

data Portfolio_Trans_Rename(rename=(&Rename_Trans.));
set Portfolio_Transposed;
run;

data Portfolio_Trans_Diff; 
set Portfolio_Trans_Rename;
&Subst_Trans.;
run;

/*Calculating Interpolation*/
data Portfolio_Trans_Interpolat(drop=i j &Diff_Trans.);
set Portfolio_Trans_Diff;
	array Diff{*} &Diff_Trans.;
	array Batch_ID {*} &Batch_IDs.;

	do i=1 to Dim(Diff);
		/*To 11 to not go out of index in last iteration and to not overwrite the yearly values*/
		do j=1 to 11; 
			Batch_ID(12*(i-1) + j + 1) = Batch_ID(12*(i-1) + j) + Diff(i); /*Interpolation*/
		end;
	end;
run;


proc contents data=Portfolio_Trans_Interpolat out=Final_Fields noprint;
run;

proc sql noprint;
select NAME into: Fields_Fnl_Str
separated by " "
from Final_Fields
where Type = 2
order by varnum;
quit;

proc sql noprint;
select cats("'", NAME, "'n") into: Fields_Fnl_Num
separated by " "
from Final_Fields
where Type = 1
order by NAME;
quit;

/*Ordering final table*/
data Output.Portf_Trans_Interpolat_Final;
format &Fields_Fnl_Str. &Fields_Fnl_Num.;
set Portfolio_Trans_Interpolat;
run;

/*Adding Additional Monthly Variables*/
/*Creates table with only EAD final values*/
proc sql;
	create table interpolation_EAD_final as
	select * 
	from Output.Portf_Trans_Interpolat_Final
	where Balance = 'Calc_EAD_Final'
;quit;

/*Creates table with only Provision values*/
proc sql;
	create table interpolation_prov as
	select * 
	from Output.Portf_Trans_Interpolat_Final
	where Balance = 'Calc_Provision'
;quit;

/*Joins prior two tables
Duplicates variables for use in excel filtering
Creates Transfer Rate variable at each monthly iteration*/
proc sql;
	create table Output.TR_Interpolat as
	select EAD.LOB_dept1, EAD.LOB_dept1 as Line_of_Business, EAD.Family_Code, EAD.Family_Code as Family_Code_2, EAD.Stage_Base, EAD.Stage_Base as Stage_2,
				Prov.'20190531'n/EAD.'20190531'n as TR_20190531,
				Prov.'20190630'n/EAD.'20190630'n as TR_20190630,
				Prov.'20190731'n/EAD.'20190731'n as TR_20190731,
				Prov.'20190831'n/EAD.'20190831'n as TR_20190831,
				Prov.'20190930'n/EAD.'20190930'n as TR_20190930,
				Prov.'20191031'n/EAD.'20191031'n as TR_20191031,
				Prov.'20191130'n/EAD.'20191130'n as TR_20191130,
				Prov.'20191231'n/EAD.'20191231'n as TR_20191231,
				Prov.'20200131'n/EAD.'20200131'n as TR_20200131,
				Prov.'20200229'n/EAD.'20200229'n as TR_20200229,
				Prov.'20200331'n/EAD.'20200331'n as TR_20200331,
				Prov.'20200430'n/EAD.'20200430'n as TR_20200430,
				Prov.'20200531'n/EAD.'20200531'n as TR_20200531,
				Prov.'20200630'n/EAD.'20200630'n as TR_20200630,
				Prov.'20200731'n/EAD.'20200731'n as TR_20200731,
				Prov.'20200831'n/EAD.'20200831'n as TR_20200831,
				Prov.'20200930'n/EAD.'20200930'n as TR_20200930,
				Prov.'20201031'n/EAD.'20201031'n as TR_20201031,
				Prov.'20201130'n/EAD.'20201130'n as TR_20201130,
				Prov.'20201231'n/EAD.'20201231'n as TR_20201231,
				Prov.'20210131'n/EAD.'20210131'n as TR_20210131,
				Prov.'20210228'n/EAD.'20210228'n as TR_20210228,
				Prov.'20210331'n/EAD.'20210331'n as TR_20210331,
				Prov.'20210430'n/EAD.'20210430'n as TR_20210430,
				Prov.'20210531'n/EAD.'20210531'n as TR_20210531,
				Prov.'20210630'n/EAD.'20210630'n as TR_20210630,
				Prov.'20210731'n/EAD.'20210731'n as TR_20210731,
				Prov.'20210831'n/EAD.'20210831'n as TR_20210831,
				Prov.'20210930'n/EAD.'20210930'n as TR_20210930,
				Prov.'20211031'n/EAD.'20211031'n as TR_20211031,
				Prov.'20211130'n/EAD.'20211130'n as TR_20211130,
				Prov.'20211231'n/EAD.'20211231'n as TR_20211231,
				Prov.'20220131'n/EAD.'20220131'n as TR_20220131,
				Prov.'20220228'n/EAD.'20220228'n as TR_20220228,
				Prov.'20220331'n/EAD.'20220331'n as TR_20220331,
				Prov.'20220430'n/EAD.'20220430'n as TR_20220430,
				Prov.'20220531'n/EAD.'20220531'n as TR_20220531,
				Prov.'20220630'n/EAD.'20220630'n as TR_20220630,
				Prov.'20220731'n/EAD.'20220731'n as TR_20220731,
				Prov.'20220831'n/EAD.'20220831'n as TR_20220831,
				Prov.'20220930'n/EAD.'20220930'n as TR_20220930,
				Prov.'20221031'n/EAD.'20221031'n as TR_20221031,
				Prov.'20221130'n/EAD.'20221130'n as TR_20221130,
				Prov.'20221231'n/EAD.'20221231'n as TR_20221231,
				Prov.'20230131'n/EAD.'20230131'n as TR_20230131,
				Prov.'20230228'n/EAD.'20230228'n as TR_20230228,
				Prov.'20230331'n/EAD.'20230331'n as TR_20230331,
				Prov.'20230430'n/EAD.'20230430'n as TR_20230430

	from interpolation_EAD_final EAD
	left join interpolation_prov Prov
	on 	EAD.lob_dept1 = Prov.lob_dept1 and
		EAD.Family_Code = prov.Family_Code and
		EAD.Stage_Base = Prov.Stage_Base
	group by EAD.lob_dept1, EAD.Family_Code, EAD.Stage_Base
	order by EAD.lob_dept1, EAD.Family_Code, EAD.Stage_Base
;quit;

/*Adds cure rate value to prior table*/
proc sql;
	create table output.Monthly_Rates as
	select TR.*, Control.Cure_Rate 
	from Output.TR_Interpolat TR
	left join output.Control_Prov_Final Control
	on 	TR.lob_dept1 		= Control.Line_of_Business and
		TR.Family_Code 		= Control.Family_Code
	where Control.year = 1
	group by TR.lob_dept1, TR.Line_of_Business, TR.Family_Code, TR.Family_Code_2, TR.Stage_Base, TR.Stage_2
;quit;



/*
DAY_ID
lob_dept1
Family_Code
Stage_Base
Driver_PD
Driver_LGD
PLZ_RESID
Year
DAY_ID_PY
YTM_PY
EAD_actual
Provision_Actual
Pctg_Future_PD_Driver
Future_PD_Driver
Transition_Rate
Calc_Stage
EAD_Post_Tran
Cure_Rate
EAD_Post_Cure
Decay_Rate
Charge_Off_Rate
Calc_EAD_Final
Calc_EL_rate
Calc_Provision
*/




/*Test transpose*/
data test(drop=/*DAY_ID_PY*/ Year YTM_PY EAD_actual Provision_Actual Pctg_Future_PD_Driver
Future_PD_Driver Transition_Rate Calc_Stage EAD_Post_Tran Cure_Rate EAD_Post_Cure
Decay_Rate Charge_Off_Rate Calc_EL_rate);
set output.Stock_Portf_Provision;
	where lob_dept1 = "COMMERCIAL BANKING AND WMG CONSOLIDATION" AND Stage_Base = "S1"
			AND Driver_PD = "B+" AND PLZ_RESID = 3 AND Calc_Stage = "S1";
run;

proc transpose data=test
			   out=test_trans
			   name=Balance;
		by DAY_ID lob_dept1 Family_Code Stage_Base Driver_PD Driver_LGD plz_resid;
		id DAY_ID_PY /*year*/;
run;


proc contents data=output.Stock_Portf_Provision out=test_fields noprint;
run;

proc sort data=test_fields;
by varnum;
run;
/*Test transpose*/