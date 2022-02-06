

/*Creates separate tables for each portfolio*/

/*Commercial - Construction Commercial / Residential*/
proc sql;
	create table RKA.Commercial_Construction as
		select 	account_final_MIS,			BATCH_ID,					Product_Final_Facility,			bureau_score_facility,		Rating_RADB_Facility, 		
				sbrps_score_facility, 		Pcards_Flag_EC_facility, 	SB_product_type_facility, 	 	PRODUCT_GROUP_EC_facility,	orig_term_final_facility,
				pct_utilization_facility,	DTI_PTI_FACILITY,			Renegotiated_Flag_BdE_Facility, months_on_books_facility,	Final_State_Facility,
				ORIG_BAL_facility,			FIXED_VAR_TMP_EC_facility,	GLdesc_facility,				LTV_facility, 				WL_Level_facility,	
				COSTCTR_NAME_EC_facility,	CUSTOMER_FLAG_EC_facility,	Secured_Indicator_Facility,		TSYS_PRODUCT_EC_facility,	'' as State,
				DPD_Facility,				PDUE_Group_Facility,		PDUE_Days_Facility,				Status_Rollup_Final,		CC_Activity_Flag_facility,	
				curr_CLTV_HE_facility,		prosper_rating_facility,	total_commitment_facility
		from ALLPROD.Database_Parameters
				where 	(product_final_facility 	= 		"Commercial - Construction Commercial"
				or 		product_final_facility 		= 		"Commercial - Construction Residential")
				and 	tran_status_final 			not = 	"CLS" 
				and 	tran_status_final 			not = 	"CGO"
				and 	default_flag_1pct_facility	not = 	1
;quit;

/*Commercial - CRE */
proc sql;
	create table RKA.Commercial_CRE as
		select 	account_final_MIS,			BATCH_ID,					Product_Final_Facility,			bureau_score_facility,		Rating_RADB_Facility, 		
				sbrps_score_facility, 		Pcards_Flag_EC_facility, 	SB_product_type_facility, 	 	PRODUCT_GROUP_EC_facility,	orig_term_final_facility,
				pct_utilization_facility,	DTI_PTI_FACILITY,			Renegotiated_Flag_BdE_Facility, months_on_books_facility,	Final_State_Facility,
				ORIG_BAL_facility,			FIXED_VAR_TMP_EC_facility,	GLdesc_facility,				LTV_facility, 				WL_Level_facility,	
				COSTCTR_NAME_EC_facility,	CUSTOMER_FLAG_EC_facility,	Secured_Indicator_Facility,		TSYS_PRODUCT_EC_facility,	'' as State,
				DPD_Facility,				PDUE_Group_Facility,		PDUE_Days_Facility,				Status_Rollup_Final,		CC_Activity_Flag_facility,
				curr_CLTV_HE_facility,		prosper_rating_facility,	total_commitment_facility 
			from ALLPROD.DATABASE_PARAMETERS
				where 	product_final_facility 		= 		"Commercial - CRE"
				and 	tran_status_final 			not = 	"CLS" 
				and 	tran_status_final 			not = 	"CGO"
				and 	default_flag_1pct_facility	not = 	1
;quit;

/*Commercial - C&I*/
proc sql;
	create table RKA.Commercial_CI as
		select 	account_final_MIS,			BATCH_ID,					Product_Final_Facility,			bureau_score_facility,		Rating_RADB_Facility, 		
				sbrps_score_facility, 		Pcards_Flag_EC_facility, 	SB_product_type_facility, 	 	PRODUCT_GROUP_EC_facility,	orig_term_final_facility,
				pct_utilization_facility,	DTI_PTI_FACILITY,			Renegotiated_Flag_BdE_Facility, months_on_books_facility,	Final_State_Facility,
				ORIG_BAL_facility,			FIXED_VAR_TMP_EC_facility,	GLdesc_facility,				LTV_facility, 				WL_Level_facility,	
				COSTCTR_NAME_EC_facility,	CUSTOMER_FLAG_EC_facility,	Secured_Indicator_Facility,		TSYS_PRODUCT_EC_facility,	'' as State,
				DPD_Facility,				PDUE_Group_Facility,		PDUE_Days_Facility,				Status_Rollup_Final,		CC_Activity_Flag_facility,
				curr_CLTV_HE_facility,		prosper_rating_facility,	total_commitment_facility 
			/*from ALLPROD.DATABASE_PARAMETERS*/
			from paramest.Database_Parameters
				where 	product_final_facility 		= 		"Commercial - C&I"
				and 	tran_status_final 			not = 	"CLS" 
				and 	tran_status_final 			not = 	"CGO"
				and 	default_flag_1pct_facility	not = 	1
;quit;

/*Commercial - Credit Card*/
proc sql;
	create table RKA.Commercial_Credit_Card as
		select  account_final_MIS,			BATCH_ID,					Product_Final_Facility,			bureau_score_facility,		Rating_RADB_Facility, 		
				sbrps_score_facility, 		Pcards_Flag_EC_facility, 	SB_product_type_facility, 	 	PRODUCT_GROUP_EC_facility,	orig_term_final_facility,
				pct_utilization_facility,	DTI_PTI_FACILITY,			Renegotiated_Flag_BdE_Facility, months_on_books_facility,	Final_State_Facility,
				ORIG_BAL_facility,			FIXED_VAR_TMP_EC_facility,	GLdesc_facility,				LTV_facility, 				WL_Level_facility,	
				COSTCTR_NAME_EC_facility,	CUSTOMER_FLAG_EC_facility,	Secured_Indicator_Facility,		TSYS_PRODUCT_EC_facility,	'' as State,
				DPD_Facility,				PDUE_Group_Facility,		PDUE_Days_Facility,				Status_Rollup_Final,		CC_Activity_Flag_facility,
				curr_CLTV_HE_facility,		prosper_rating_facility,	total_commitment_facility
		/*	from AllPROD.Database_Parameters*/
			from paramest.Database_Parameters
				where product_final_facility 		= 		"Commercial - Credit Card"
				and 	tran_status_final 			not = 	"CLS" 
				and 	tran_status_final 			not = 	"CGO"
				and 	default_flag_1pct_facility	not = 	1
;quit;

/*Retail - Consumer Direct */
proc sql;
	create table RKA.Retail_Consumer_Direct as
		select  account_final_MIS,			BATCH_ID,					Product_Final_Facility,			bureau_score_facility,		Rating_RADB_Facility, 		
				sbrps_score_facility, 		Pcards_Flag_EC_facility, 	SB_product_type_facility, 	 	PRODUCT_GROUP_EC_facility,	orig_term_final_facility,
				pct_utilization_facility,	DTI_PTI_FACILITY,			Renegotiated_Flag_BdE_Facility, months_on_books_facility,	final_state_facility,
				ORIG_BAL_facility,			FIXED_VAR_TMP_EC_facility,	GLdesc_facility,				LTV_facility, 				WL_Level_facility,
				COSTCTR_NAME_EC_facility,	CUSTOMER_FLAG_EC_facility,	Secured_Indicator_Facility,		TSYS_PRODUCT_EC_facility,	CC_Activity_Flag_facility,
				DPD_Facility,				PDUE_Group_Facility,		PDUE_Days_Facility,				Status_Rollup_Final,		curr_CLTV_HE_facility, 		
				prosper_rating_facility,	total_commitment_facility,
				case when Secured_Indicator_Facility= 'UNSECURED' 
				then case 	when Final_State_Facility='CA' and COSTCTR_NAME_EC_facility='LYNWOOD CA BNKG CTR'    then 'FP-CA-LYN'
							when Final_State_Facility='CA' and COSTCTR_NAME_EC_facility not ='LYNWOOD CA BNKG CTR' then 'FP-CA-OTH'
							when Final_State_Facility in ('AZ','CO','NM','TX','AL','FL') then 'FP-nonCA'
							else 'out-of-FP' end end as State
			from paramest.Database_Parameters	
		/*	from AllPROD.Database_Parameters*/
				where 	product_final_facility 		= 		"Retail - Consumer Direct"
				and 	tran_status_final 			not = 	"CLS" 
				and 	tran_status_final 			not = 	"CGO"
				and 	default_flag_1pct_facility	not = 	1
;quit;

/*Retail - Credit Card*/
proc sql;
	create table RKA.Retail_Credit_Card as
		select  account_final_MIS,			BATCH_ID,					Product_Final_Facility,			bureau_score_facility,		Rating_RADB_Facility, 		
				sbrps_score_facility, 		Pcards_Flag_EC_facility, 	SB_product_type_facility, 	 	PRODUCT_GROUP_EC_facility,	orig_term_final_facility,
				pct_utilization_facility,	DTI_PTI_FACILITY,			Renegotiated_Flag_BdE_Facility, months_on_books_facility,	Final_State_Facility,
				ORIG_BAL_facility,			FIXED_VAR_TMP_EC_facility,	GLdesc_facility,				LTV_facility, 				WL_Level_facility,	
				COSTCTR_NAME_EC_facility,	CUSTOMER_FLAG_EC_facility,	Secured_Indicator_Facility,		TSYS_PRODUCT_EC_facility,	'' as State,
				DPD_Facility,				PDUE_Group_Facility,		PDUE_Days_Facility,				Status_Rollup_Final,		CC_Activity_Flag_facility,
				curr_CLTV_HE_facility,		prosper_rating_facility,	total_commitment_facility
			from AllPROD.Database_Parameters
				where product_final_facility 		= 		"Retail - Credit Card"
				and 	tran_status_final 			not = 	"CLS" 
				and 	tran_status_final 			not = 	"CGO"
				and 	default_flag_1pct_facility	not = 	1
;quit;

/*Retail - DFS*/
proc sql;
	create table RKA.Retail_DFS as
		select  account_final_MIS,			BATCH_ID,					Product_Final_Facility,			bureau_score_facility,		Rating_RADB_Facility, 		
				sbrps_score_facility, 		Pcards_Flag_EC_facility, 	SB_product_type_facility, 	 	PRODUCT_GROUP_EC_facility,	orig_term_final_facility,
				pct_utilization_facility,	DTI_PTI_FACILITY,			Renegotiated_Flag_BdE_Facility, months_on_books_facility,	Final_State_Facility,
				ORIG_BAL_facility,			FIXED_VAR_TMP_EC_facility,	GLdesc_facility,				LTV_facility, 				WL_Level_facility,	
				COSTCTR_NAME_EC_facility,	CUSTOMER_FLAG_EC_facility,	Secured_Indicator_Facility,		TSYS_PRODUCT_EC_facility,	'' as State,
				DPD_Facility,				PDUE_Group_Facility,		PDUE_Days_Facility,				Status_Rollup_Final,		CC_Activity_Flag_facility,
				curr_CLTV_HE_facility,		prosper_rating_facility,	total_commitment_facility
		/*	from AllPROD.Database_Parameters*/
			from paramest.Database_Parameters
				where product_final_facility 		= 		"Retail - DFS"
				and 	tran_status_final 			not = 	"CLS" 
				and 	tran_status_final 			not = 	"CGO"
				and 	default_flag_1pct_facility	not = 	1
;quit;

/*Retail - HELOAN*/
proc sql;
	create table RKA.Retail_HELOAN as
		select  account_final_MIS,			BATCH_ID,					Product_Final_Facility,			bureau_score_facility,		Rating_RADB_Facility, 		
				sbrps_score_facility, 		Pcards_Flag_EC_facility, 	SB_product_type_facility, 	 	PRODUCT_GROUP_EC_facility,	orig_term_final_facility,
				pct_utilization_facility,	DTI_PTI_FACILITY,			Renegotiated_Flag_BdE_Facility, months_on_books_facility,	Final_State_Facility,
				ORIG_BAL_facility,			FIXED_VAR_TMP_EC_facility,	GLdesc_facility,				LTV_facility, 				WL_Level_facility,	
				COSTCTR_NAME_EC_facility,	CUSTOMER_FLAG_EC_facility,	Secured_Indicator_Facility,		TSYS_PRODUCT_EC_facility,	'' as State,
				DPD_Facility,				PDUE_Group_Facility,		PDUE_Days_Facility,				Status_Rollup_Final,		CC_Activity_Flag_facility,
				curr_CLTV_HE_facility,		prosper_rating_facility,	total_commitment_facility
		/*	from AllPROD.Database_Parameters*/
			from paramest.Database_Parameters
				where product_final_facility 		= 		"Retail - HELOAN"
				and 	tran_status_final 			not = 	"CLS" 
				and 	tran_status_final 			not = 	"CGO"
				and 	default_flag_1pct_facility	not = 	1
;quit;

/*Retail - HELOC*/
proc sql;
	create table RKA.Retail_HELOC as
		select  account_final_MIS,			BATCH_ID,					Product_Final_Facility,			bureau_score_facility,		Rating_RADB_Facility, 		
				sbrps_score_facility, 		Pcards_Flag_EC_facility, 	SB_product_type_facility, 	 	PRODUCT_GROUP_EC_facility,	orig_term_final_facility,
				pct_utilization_facility,	DTI_PTI_FACILITY,			Renegotiated_Flag_BdE_Facility, months_on_books_facility,	Final_State_Facility,
				ORIG_BAL_facility,			FIXED_VAR_TMP_EC_facility,	GLdesc_facility,				LTV_facility, 				WL_Level_facility,	
				COSTCTR_NAME_EC_facility,	CUSTOMER_FLAG_EC_facility,	Secured_Indicator_Facility,		TSYS_PRODUCT_EC_facility,	'' as State,
				DPD_Facility,				PDUE_Group_Facility,		PDUE_Days_Facility,				Status_Rollup_Final,		CC_Activity_Flag_facility,
				curr_CLTV_HE_facility,		prosper_rating_facility,	total_commitment_facility
		/*	from AllPROD.Database_Parameters*/
			from paramest.Database_Parameters
				where product_final_facility 		= 		"Retail - HELOC"
				and 	tran_status_final 			not = 	"CLS" 
				and 	tran_status_final 			not = 	"CGO"
				and 	default_flag_1pct_facility	not = 	1
;quit;

/*Retail - Mortgages*/
proc sql;
	create table RKA.Retail_Mortgages as
		select  account_final_MIS,			BATCH_ID,					Product_Final_Facility,			bureau_score_facility,		Rating_RADB_Facility, 		
				sbrps_score_facility, 		Pcards_Flag_EC_facility, 	SB_product_type_facility, 	 	PRODUCT_GROUP_EC_facility,	orig_term_final_facility,
				pct_utilization_facility,	DTI_PTI_FACILITY,			Renegotiated_Flag_BdE_Facility, months_on_books_facility,	Final_State_Facility,
				ORIG_BAL_facility,			FIXED_VAR_TMP_EC_facility,	GLdesc_facility,				LTV_facility, 				WL_Level_facility,	
				COSTCTR_NAME_EC_facility,	CUSTOMER_FLAG_EC_facility,	Secured_Indicator_Facility,		TSYS_PRODUCT_EC_facility,	'' as State,
				DPD_Facility,				PDUE_Group_Facility,		PDUE_Days_Facility,				Status_Rollup_Final,		CC_Activity_Flag_facility,
				curr_CLTV_HE_facility,		prosper_rating_facility,	total_commitment_facility
		/*	from AllPROD.Database_Parameters*/
			from paramest.Database_Parameters
				where product_final_facility 		= 		"Retail - Mortgages"
				and 	tran_status_final 			not = 	"CLS" 
				and 	tran_status_final 			not = 	"CGO"
				and 	default_flag_1pct_facility	not = 	1
;quit;

/*Retail - Other*/
proc sql;
	create table RKA.Retail_Other as
		select  account_final_MIS,			BATCH_ID,					Product_Final_Facility,			bureau_score_facility,		Rating_RADB_Facility, 		
				sbrps_score_facility, 		Pcards_Flag_EC_facility, 	SB_product_type_facility, 	 	PRODUCT_GROUP_EC_facility,	orig_term_final_facility,
				pct_utilization_facility,	DTI_PTI_FACILITY,			Renegotiated_Flag_BdE_Facility, months_on_books_facility,	Final_State_Facility,
				ORIG_BAL_facility,			FIXED_VAR_TMP_EC_facility,	GLdesc_facility,				LTV_facility, 				WL_Level_facility,	
				COSTCTR_NAME_EC_facility,	CUSTOMER_FLAG_EC_facility,	Secured_Indicator_Facility,		TSYS_PRODUCT_EC_facility,	'' as State,
				DPD_Facility,				PDUE_Group_Facility,		PDUE_Days_Facility,				Status_Rollup_Final,		CC_Activity_Flag_facility,
				curr_CLTV_HE_facility,		prosper_rating_facility,	total_commitment_facility
		/*	from AllPROD.Database_Parameters*/
			from paramest.Database_Parameters
				where product_final_facility 		= 		"Retail - Other"
				and 	tran_status_final 			not = 	"CLS" 
				and 	tran_status_final 			not = 	"CGO"
				and 	default_flag_1pct_facility	not = 	1
;quit;

/*Retail - Prosper*/
proc sql;
	create table RKA.Retail_Prosper as
		select  account_final_MIS,			BATCH_ID,					Product_Final_Facility,			bureau_score_facility,		Rating_RADB_Facility, 		
				sbrps_score_facility, 		Pcards_Flag_EC_facility, 	SB_product_type_facility, 	 	PRODUCT_GROUP_EC_facility,	orig_term_final_facility,
				pct_utilization_facility,	DTI_PTI_FACILITY,			Renegotiated_Flag_BdE_Facility, months_on_books_facility,	Final_State_Facility,
				ORIG_BAL_facility,			FIXED_VAR_TMP_EC_facility,	GLdesc_facility,				LTV_facility, 				WL_Level_facility,	
				COSTCTR_NAME_EC_facility,	CUSTOMER_FLAG_EC_facility,	Secured_Indicator_Facility,		TSYS_PRODUCT_EC_facility,	'' as State,
				DPD_Facility,				PDUE_Group_Facility,		PDUE_Days_Facility,				Status_Rollup_Final,		CC_Activity_Flag_facility,
				curr_CLTV_HE_facility,		prosper_rating_facility,	total_commitment_facility
		/*	from AllPROD.Database_Parameters*/
			from paramest.Database_Parameters
				where product_final_facility 		= 		"Retail - Prosper"
				and 	tran_status_final 			not = 	"CLS" 
				and 	tran_status_final 			not = 	"CGO"
				and 	default_flag_1pct_facility	not = 	1
;quit;

/*SB - CF&A Secured*/
proc sql;
	create table RKA.SB_CFA_Secured as
		select  account_final_MIS,			BATCH_ID,					Product_Final_Facility,			bureau_score_facility,		Rating_RADB_Facility, 		
				sbrps_score_facility, 		Pcards_Flag_EC_facility, 	SB_product_type_facility, 	 	PRODUCT_GROUP_EC_facility,	orig_term_final_facility,
				pct_utilization_facility,	DTI_PTI_FACILITY,			Renegotiated_Flag_BdE_Facility, months_on_books_facility,	Final_State_Facility,
				ORIG_BAL_facility,			FIXED_VAR_TMP_EC_facility,	GLdesc_facility,				LTV_facility, 				WL_Level_facility,	
				COSTCTR_NAME_EC_facility,	CUSTOMER_FLAG_EC_facility,	Secured_Indicator_Facility,		TSYS_PRODUCT_EC_facility,	'' as State,
				DPD_Facility,				PDUE_Group_Facility,		PDUE_Days_Facility,				Status_Rollup_Final,		CC_Activity_Flag_facility,
				curr_CLTV_HE_facility,		prosper_rating_facility,	total_commitment_facility
		/*	from AllPROD.Database_Parameters*/
			from paramest.Database_Parameters
				where product_final_facility 		= 		"SB - CF&A Secured"
				and 	tran_status_final 			not = 	"CLS" 
				and 	tran_status_final 			not = 	"CGO"
				and 	default_flag_1pct_facility	not = 	1
;quit;

/*SB - CF&A Unsecured*/
proc sql;
	create table RKA.SB_CFA_Unsecured as
		select  account_final_MIS,			BATCH_ID,					Product_Final_Facility,			bureau_score_facility,		Rating_RADB_Facility, 		
				sbrps_score_facility, 		Pcards_Flag_EC_facility, 	SB_product_type_facility, 	 	PRODUCT_GROUP_EC_facility,	orig_term_final_facility,
				pct_utilization_facility,	DTI_PTI_FACILITY,			Renegotiated_Flag_BdE_Facility, months_on_books_facility,	Final_State_Facility,
				ORIG_BAL_facility,			FIXED_VAR_TMP_EC_facility,	GLdesc_facility,				LTV_facility, 				WL_Level_facility,	
				COSTCTR_NAME_EC_facility,	CUSTOMER_FLAG_EC_facility,	Secured_Indicator_Facility,		TSYS_PRODUCT_EC_facility,	'' as State,
				DPD_Facility,				PDUE_Group_Facility,		PDUE_Days_Facility,				Status_Rollup_Final,		CC_Activity_Flag_facility,
				curr_CLTV_HE_facility,		prosper_rating_facility,	total_commitment_facility
			/*from AllPROD.Database_Parameters*/
			from paramest.Database_Parameters
				where product_final_facility 		= 		"SB - CF&A Unsecured"
				and 	tran_status_final 			not = 	"CLS" 
				and 	tran_status_final 			not = 	"CGO"
				and 	default_flag_1pct_facility	not = 	1
;quit;

/*SB - CRE*/
proc sql;
	create table RKA.SB_CRE as
		select  account_final_MIS,			BATCH_ID,					Product_Final_Facility,			bureau_score_facility,		Rating_RADB_Facility, 		
				sbrps_score_facility, 		Pcards_Flag_EC_facility, 	SB_product_type_facility, 	 	PRODUCT_GROUP_EC_facility,	orig_term_final_facility,
				pct_utilization_facility,	DTI_PTI_FACILITY,			Renegotiated_Flag_BdE_Facility, months_on_books_facility,	Final_State_Facility,
				ORIG_BAL_facility,			FIXED_VAR_TMP_EC_facility,	GLdesc_facility,				LTV_facility, 				WL_Level_facility,	
				COSTCTR_NAME_EC_facility,	CUSTOMER_FLAG_EC_facility,	Secured_Indicator_Facility,		TSYS_PRODUCT_EC_facility,	'' as State,
				DPD_Facility,				PDUE_Group_Facility,		PDUE_Days_Facility,				Status_Rollup_Final,		CC_Activity_Flag_facility,
				curr_CLTV_HE_facility,		prosper_rating_facility,	total_commitment_facility
			/*from AllPROD.Database_Parameters*/
			from paramest.Database_Parameters
				where product_final_facility 		= 		"SB - CRE"
				and 	tran_status_final 			not = 	"CLS" 
				and 	tran_status_final 			not = 	"CGO"
				and 	default_flag_1pct_facility	not = 	1
;quit;	

/*SB - Construction Commercial*/
proc sql;
	create table RKA.SB_Construction_Commercial as
		select  account_final_MIS,			BATCH_ID,					Product_Final_Facility,			bureau_score_facility,		Rating_RADB_Facility, 		
				sbrps_score_facility, 		Pcards_Flag_EC_facility, 	SB_product_type_facility, 	 	PRODUCT_GROUP_EC_facility,	orig_term_final_facility,
				pct_utilization_facility,	DTI_PTI_FACILITY,			Renegotiated_Flag_BdE_Facility, months_on_books_facility,	Final_State_Facility,
				ORIG_BAL_facility,			FIXED_VAR_TMP_EC_facility,	GLdesc_facility,				LTV_facility, 				WL_Level_facility,	
				COSTCTR_NAME_EC_facility,	CUSTOMER_FLAG_EC_facility,	Secured_Indicator_Facility,		TSYS_PRODUCT_EC_facility,	'' as State,
				DPD_Facility,				PDUE_Group_Facility,		PDUE_Days_Facility,				Status_Rollup_Final,		CC_Activity_Flag_facility,
				curr_CLTV_HE_facility,		prosper_rating_facility,	total_commitment_facility
			/*from AllPROD.Database_Parameters*/
			from paramest.Database_Parameters
				where product_final_facility 		= 		"SB - Construction Commercial"
				and 	tran_status_final 			not = 	"CLS" 
				and 	tran_status_final 			not = 	"CGO"
				and 	default_flag_1pct_facility	not = 	1
;quit;

/*creates random sample for testing*/
/*proc surveyselect data = RKA.Retail_dfs
method=srs	n=100000	out= Retail_dfs_Sample;
run;
*/

/*Macro to generate all tables for portfolio*/
%macro PD_Driver_Assign(Portfolio);

/*Allows for proper DPD joining by creating a DPD auxilary variable and
creates auxilary rating variable that combines all ratings into one column*/
proc sql;
create table DPD_Rating_Aux as
	select *,
			(case 	when prosper_rating_facility	not = "N/A" then prosper_rating_facility
					when Rating_RADB_Facility 		not = ""
					and  Rating_RADB_Facility   	not = "N/A"	then Rating_RADB_Facility
					when bureau_score_facility 		not = . 	then put(bureau_score_facility, 20.)
					when sbrps_score_facility		not = . 	then put(sbrps_score_facility, 20.)
					else "Missing Rating"
			end) as Rating_Aux,

			(case 	when Status_Rollup_Final = 'NOTPD' then 0
					/*when product_final_facility = 'Retail - Credit Card' then
							case 	when status_rollup_final = 'PD001' then 10
									when status_rollup_final = 'PD030' then 40
									when status_rollup_final in ('PD060', 'PD090', 'PD120', 'PD150') then 80
							end*/
					else PDUE_days_Facility
			end) as DPD_Facility_Aux

	from &Portfolio.
;quit;

/*Joins each portfolio with the PD_Driver table*/
proc sql;
create table &Portfolio._PD as
select Port.*, PD.PD_Driver
from DPD_Rating_Aux as Port
left join Output.PD_Driver as PD
on 
case	
when 	Port.Product_Final_Facility in ("Commercial - Construction Commercial", 
										"Commercial - Construction Residential")   			and
		PD.aggregation_key in 			( 2 )					then

		case		when 	Port.DPD_Facility_Aux 	> 0 and PD.Past_Due_Days_From > 0 then
							Port.DPD_Facility_Aux 	>=  PD.Past_Due_Days_From	and
							Port.DPD_Facility_Aux	<	PD.Past_Due_Days_To	

					when  	Port.DPD_Facility_Aux in (., 0) and Port.Rating_Aux not = "Missing Rating" and input(Strip(Port.Rating_Aux),3.) <24 then
							input((substr(Port.Rating_Aux, 1, 2)),2.) 	= 	PD.Grade_Of_Tool_From 
					
					when 	Port.DPD_Facility_Aux in (., 0) and (Port.Rating_Aux = "Missing Rating"  or input(strip(Port.Rating_Aux),3.)>=24) and PD.Grade_Of_Tool_To = 1 then
							PD.Grade_Of_Tool_From < 0

		end

when 	Port.Product_Final_Facility in ("Commercial - C&I")    			and
		PD.aggregation_key in 			(1)		then

		case		when 	Port.WL_Level_facility not in ( "03.No WL" , "") then
							PD.Watch_List in ('1', '2') and
							substr(Port.WL_Level_facility, 2, 1) = PD.Watch_List

					when 	Port.WL_Level_facility = "03.No WL" and Port.DPD_Facility_Aux 	> 0 and PD.Past_Due_Days_From > 0  then
							Port.DPD_Facility_Aux 	>=  PD.Past_Due_Days_From	and
							Port.DPD_Facility_Aux	<	PD.Past_Due_Days_To		and
							PD.Watch_List not in ('1', '2')	

					when  	Port.DPD_Facility_Aux in (., 0) and Port.WL_Level_facility = "03.No WL" and
							Port.Rating_Aux not = "Missing Rating" and input(Strip(Port.Rating_Aux),3.) <24 then
							input((substr(Port.Rating_Aux, 1, 2)),2.) 	= 	PD.Grade_Of_Tool_From and
							PD.Watch_List not in ('1', '2') 
					
					when 	Port.DPD_Facility_Aux in (., 0) and Port.WL_Level_facility = "03.No WL" and 
							(Port.Rating_Aux = "Missing Rating" or input(strip(Port.Rating_Aux),3.)>=24) and PD.Grade_Of_Tool_To = 1 then
							PD.Grade_Of_Tool_From < 0 and
							PD.Watch_List not in ('1', '2')

		end


when 	Port.Product_Final_Facility in ("Commercial - CRE")     			and
		PD.aggregation_key in 			(4)		then

		case		when 	Port.WL_Level_facility not in ( "03.No WL" , "") then
							PD.Watch_List in ('1', '2') and
							substr(Port.WL_Level_facility, 2, 1) = PD.Watch_List

					when 	Port.DPD_Facility_Aux 	> 0 and PD.Past_Due_Days_From > 0 and Port.WL_Level_facility = "03.No WL" then
							Port.DPD_Facility_Aux 	>=  PD.Past_Due_Days_From	and
							Port.DPD_Facility_Aux	<	PD.Past_Due_Days_To		and
							PD.Watch_List not in ('1', '2')	

					when  	Port.DPD_Facility_Aux in (., 0) and Port.WL_Level_facility = "03.No WL" and 
							Port.Rating_Aux not = "Missing Rating" and input(Strip(Port.Rating_Aux),3.) <24 then
							input((substr(Port.Rating_Aux, 1, 2)),2.) 	= 	PD.Grade_Of_Tool_From and
							PD.Watch_List not in ('1', '2')
					
					when 	Port.DPD_Facility_Aux in (., 0) and Port.WL_Level_facility = "03.No WL" and 
							(Port.Rating_Aux = "Missing Rating" or input(strip(Port.Rating_Aux),3.)>=24) and PD.Grade_Of_Tool_To = 1 then
							PD.Grade_Of_Tool_From < 0 and
							PD.Watch_List not in ('1', '2')

		end

when 	Port.Product_Final_Facility in ("Commercial - Credit Card" ) 			and
	 	PD.aggregation_key in 			( 5 )									then

		case 		when 	Port.DPD_Facility_Aux 	> 0 and PD.Past_Due_Days_From > 0 then
							Port.DPD_Facility_Aux 	>=  PD.Past_Due_Days_From	and
							Port.DPD_Facility_Aux	<	PD.Past_Due_Days_To	

					when 	Port.Pcards_Flag_EC_facility = 'SmallBusines Cards' then
							PD.Subproduct = '05-SBCD' and
								case 	when 	Port.DPD_Facility_Aux in (., 0) and Port.Rating_Aux not = "Missing Rating" then
												PD.Grade_Of_Tool_From <= input(strip(Port.Rating_Aux),3.) 	< PD.Grade_Of_Tool_To
										when 	Port.DPD_Facility_Aux in (., 0) and Port.Rating_Aux = "Missing Rating" and PD.Grade_Of_Tool_To = 300 then
												PD.Grade_Of_Tool_From < 0	
								end 

					else		case	when  	Port.DPD_Facility_Aux in (., 0) and Port.Rating_Aux not = "Missing Rating" and input(Strip(Port.Rating_Aux),3.) <24 then
												input((substr(Port.Rating_Aux, 1, 2)),2.) 	= 	PD.Grade_Of_Tool_From 

										when 	Port.DPD_Facility_Aux in (., 0) and (Port.Rating_Aux = "Missing Rating" or input(strip(Port.Rating_Aux),3.)>=24) and PD.Grade_Of_Tool_To = 1 then
												PD.Grade_Of_Tool_From < 0
								 end
		end

when 	Port.Product_Final_Facility in 	("Retail - Consumer Direct" ) 		and
		PD.aggregation_key in 		    (6, 7 )								then

		case when 	PRODUCT_GROUP_EC_facility = 'CD-Secured' then
					aggregation_key = 6 and
				case 		when 	Port.DPD_Facility_Aux 	> 0 and PD.Past_Due_Days_From > 0 then
									Port.DPD_Facility_Aux 	>=  PD.Past_Due_Days_From	and
									Port.DPD_Facility_Aux	<	PD.Past_Due_Days_To	

							when	Port.DPD_Facility_Aux in ( ., 0) and PD.Past_Due_Days_From in (0,.) then
								 	case 	when 	Port.Rating_Aux not = "Missing Rating" then
													PD.Grade_Of_Tool_From <= input(strip(Port.Rating_Aux),3.) < PD.Grade_Of_Tool_To 

											when 	Port.Rating_Aux = "Missing Rating" and PD.Grade_Of_Tool_To = 300 then
													PD.Grade_Of_Tool_From < 0
									end
				end

		else 		aggregation_key = 7 and
				case 		when 	Port.DPD_Facility_Aux 	> 0 and PD.Past_Due_Days_From > 0 then
									Port.DPD_Facility_Aux 	>=  PD.Past_Due_Days_From	and
									Port.DPD_Facility_Aux	<	PD.Past_Due_Days_To	

							when	Port.DPD_Facility_Aux in ( ., 0) and PD.Past_Due_Days_From in (0,.) then
									case 	when Port.CUSTOMER_FLAG_EC_facility = "CUSTOMER" and Port.State='FP-CA-OTH'
												then PD.subproduct_desc = "EPL, Customer, Footprint CA"
											when Port.CUSTOMER_FLAG_EC_facility = "CUSTOMER" and Port.COSTCTR_NAME_EC_facility = "LYNWOOD CA BNKG CTR"
												then PD.subproduct_desc = "EPL, Customer, Lynwood Cost Center"
											when Port.CUSTOMER_FLAG_EC_facility = "CUSTOMER" and Port.State='FP-nonCA'
												then PD.subproduct_desc = "EPL, Customer, Footprint Non_CA"
											when Port.CUSTOMER_FLAG_EC_facility = "CUSTOMER" and Port.State='out-of-FP'
												then PD.subproduct_desc = "EPL, Customer, Out of Footprint"
											when Port.CUSTOMER_FLAG_EC_facility = "PROSPECT" and Port.State='FP-CA-OTH'
												then PD.subproduct_desc = "EPL, Prospect, Footprint CA"
											when Port.CUSTOMER_FLAG_EC_facility = "PROSPECT" and Port.COSTCTR_NAME_EC_facility = "LYNWOOD CA BNKG CTR"
												then PD.subproduct_desc = "EPL, Prospect, Lynwood Cost Center"
											when Port.CUSTOMER_FLAG_EC_facility = "PROSPECT" and Port.State='FP-nonCA'
												then PD.subproduct_desc = "EPL, Prospect, Footprint Non_CA"
											when Port.CUSTOMER_FLAG_EC_facility = "PROSPECT" and Port.State='out-of-FP'
												then PD.subproduct_desc = "EPL, Prospect, Out of Footprint"
											when Port.CUSTOMER_FLAG_EC_facility = ""	
												then PD.subproduct_desc = "" and
													case 	when 	Port.Rating_Aux not = "Missing Rating" then
																	PD.Grade_Of_Tool_From <= input(strip(Port.Rating_Aux),3.) < PD.Grade_Of_Tool_To 

															when 	Port.Rating_Aux = "Missing Rating" and PD.Grade_Of_Tool_To = 300 then
																	PD.Grade_Of_Tool_From < 0
													end
									end
						and  			case 	when 	Port.Rating_Aux not = "Missing Rating" then
														PD.Grade_Of_Tool_From <= input(strip(Port.Rating_Aux),3.) < PD.Grade_Of_Tool_To 

												when 	Port.Rating_Aux = "Missing Rating" and PD.Grade_Of_Tool_To = 300 then
														PD.Grade_Of_Tool_From < 0
										end
				end
			
		end

when 	Port.Product_Final_Facility  in 	("Retail - Credit Card" ) 				and
		PD.aggregation_key in 			 	( 8 )									then
	
		case		when 	Port.DPD_Facility_Aux 	> 0 and PD.Past_Due_Days_From > 0 then
							Port.DPD_Facility_Aux 		>=  PD.Past_Due_Days_From	and
							Port.DPD_Facility_Aux		<	PD.Past_Due_Days_To		and
							Upcase(PD.aux_Cards_inact) 	= 'ACTIVE'					and
								case when 	Port.TSYS_PRODUCT_EC_facility='NBA_AMEX' 	then
											PD.Subproduct = '08-NBMX'
											else PD.Subproduct ne '08-NBMX'
								end	
						
					when 	Port.DPD_Facility_Aux in ( ., 0) and PD.Past_Due_Days_From in (0,.) then
						case 	when	Port.CC_Activity_Flag_facility 	= 'ACTIVE'	then
										Port.CC_Activity_Flag_facility 	=	Upcase(PD.aux_Cards_inact)	and
											case when 	Port.TSYS_PRODUCT_EC_facility='NBA_AMEX' then
														PD.Subproduct = '08-NBMX' and
														case 	when 	Port.Rating_Aux not = "Missing Rating" then
																		PD.Grade_Of_Tool_From <= input(strip(Port.Rating_Aux),3.) 	< PD.Grade_Of_Tool_To
																when 	Port.Rating_Aux = "Missing Rating" and PD.Grade_Of_Tool_To = 300 then
																		PD.Grade_Of_Tool_From < 0
														end
												else	Port.pct_utilization_facility 	>= 	PD.Percentage_Use_From		and
														Port.pct_utilization_facility 	< 	PD.Percentage_Use_To		and
														PD.Subproduct ne '08-NBMX'  and
															case 	when 	Port.Rating_Aux not = "Missing Rating" then
																		PD.Grade_Of_Tool_From <= input(strip(Port.Rating_Aux),3.) 	< PD.Grade_Of_Tool_To
																when 	Port.Rating_Aux = "Missing Rating" and PD.Grade_Of_Tool_To = 300 then
																		PD.Grade_Of_Tool_From < 0	
														end	
											end
								when	Port.CC_Activity_Flag_facility 	= 'INACTIVE' then
										Port.CC_Activity_Flag_facility 	=	Upcase(PD.aux_Cards_inact) and
									case 	when 	Port.TSYS_PRODUCT_EC_facility in ('OLD_OTHER','CHARGE_HIGH_END','OPTIMIZER_SECURED','VISA_SIGNATURE','WMG')     then 
													PD.Subproduct = '08-GRP1' 	and
														case 	when 	Port.Rating_Aux not = "Missing Rating" then
																		PD.Grade_Of_Tool_From <= input(strip(Port.Rating_Aux),3.) 	< PD.Grade_Of_Tool_To
																when 	Port.Rating_Aux = "Missing Rating" and PD.Grade_Of_Tool_To = 300 then
																		PD.Grade_Of_Tool_From < 0	
														end	
											when 	Port.TSYS_PRODUCT_EC_facility =   'PLATINUM' then
													PD.subproduct = '08-GRP2' and
														case 	when 	Port.Rating_Aux not = "Missing Rating" then
																		PD.Grade_Of_Tool_From <= input(strip(Port.Rating_Aux),3.) 	< PD.Grade_Of_Tool_To
																when 	Port.Rating_Aux = "Missing Rating" and PD.Grade_Of_Tool_To = 300 then
																		PD.Grade_Of_Tool_From < 0	
														end	
											when 	Port.TSYS_PRODUCT_EC_facility in ('UNKNOWN','CLEAR_POINTS','PLC','SELECT') or missing(Port.TSYS_PRODUCT_EC_facility) then
													PD.subproduct = '08-GRP3' and
														case 	when 	Port.Rating_Aux not = "Missing Rating" then
																		PD.Grade_Of_Tool_From <= input(strip(Port.Rating_Aux),3.) 	< PD.Grade_Of_Tool_To
																when 	Port.Rating_Aux = "Missing Rating" and PD.Grade_Of_Tool_To = 300 then
																		PD.Grade_Of_Tool_From < 0	
														end	
											when 	Port.TSYS_PRODUCT_EC_facility =   'CHARGE_LOW_END'  then
													PD.Subproduct = '08-GRP4' and
														case 	when 	Port.Rating_Aux not = "Missing Rating" then
																		PD.Grade_Of_Tool_From <= input(strip(Port.Rating_Aux),3.) 	< PD.Grade_Of_Tool_To
																when 	Port.Rating_Aux = "Missing Rating" and PD.Grade_Of_Tool_To = 300 then
																		PD.Grade_Of_Tool_From < 0	
														end	
											when	Port.TSYS_PRODUCT_EC_facility='NBA_AMEX' then
													PD.Subproduct = '08-NBMX' 
									end
						end
		end

when 	Port.Product_Final_Facility in 	("Retail - DFS" ) 						and
			 PD.aggregation_key in 		( 9 )									then

		case	 	when 	Port.DPD_Facility_Aux 	> 0 and PD.Past_Due_Days_From > 0 then
							Port.DPD_Facility_Aux 	>=  PD.Past_Due_Days_From	and
							Port.DPD_Facility_Aux	<	PD.Past_Due_Days_To	

					when 	Port.DPD_Facility_Aux in (., 0) and PD.Past_Due_Days_From in (0,.) then
						case when 0 <= Port.LTV_facility < 1 and PD.Orig_LTV_To <900	then
										Port.LTV_facility 					>= 	PD.Orig_LTV_From			and
										Port.LTV_facility 					< 	PD.Orig_LTV_To				and
										Port.orig_term_final_facility /12 	>= 	PD.Original_Period_From		and
										Port.orig_term_final_facility /12	< 	PD.Original_Period_To		and
											case 	when 	Port.DPD_Facility_Aux in (., 0) and Port.Rating_Aux not = "Missing Rating" then
															PD.Grade_Of_Tool_From <= input(strip(Port.Rating_Aux),3.) 	< PD.Grade_Of_Tool_To
													when 	Port.DPD_Facility_Aux in (., 0) and Port.Rating_Aux = "Missing Rating" and PD.Grade_Of_Tool_To = 300 then
															PD.Grade_Of_Tool_From < 0	
											end	

								 when Port.LTV_facility >= 1 and PD.Orig_LTV_From ne 0 then
										Port.LTV_facility 					>= 	PD.Orig_LTV_From			and
										Port.LTV_facility 					< 	PD.Orig_LTV_To				and
											case 	when 	Port.DTI_PTI_Facility = . then
															PD.PTI_From = 8
											else 			Port.DTI_PTI_Facility 			>= 	PD.PTI_From	and
															Port.DTI_PTI_Facility 			< 	PD.PTI_To 					
											end

									and		case 	when 	Port.Rating_Aux not = "Missing Rating" then
															PD.Grade_Of_Tool_From <= input(strip(Port.Rating_Aux),3.) 	< PD.Grade_Of_Tool_To
													when 	Port.Rating_Aux = "Missing Rating" and PD.Grade_Of_Tool_To = 300 then
															PD.Grade_Of_Tool_From < 0	
											end	
							end
		 end

when 	Port.Product_Final_Facility in 	("Retail - HELOAN") 					and
			 PD.aggregation_key in 		( 10 )									then

		case	when 	Port.DPD_Facility_Aux 	> 0 and PD.Past_Due_Days_From > 0 then
						Port.DPD_Facility_Aux 	>=  PD.Past_Due_Days_From	and
						Port.DPD_Facility_Aux	<	PD.Past_Due_Days_To

				when 	Port.DPD_Facility_Aux in (., 0) and PD.Past_Due_Days_From in (0,.) then
						case 	when 	Port.Renegotiated_Flag_BdE_Facility = 1			then
										Refinanced_Indicator = 'S'

								when 	0 <= Port.curr_CLTV_HE_facility < .85 and PD.Orig_LTV_To <900	then
										Port.curr_CLTV_HE_facility 					>= 	PD.Orig_LTV_From			and
										Port.curr_CLTV_HE_facility 					< 	PD.Orig_LTV_To				and
											case	when 	Port.Rating_Aux not = "Missing Rating" then
															PD.Grade_Of_Tool_From <= input(strip(Port.Rating_Aux),3.) 	< PD.Grade_Of_Tool_To
													when 	Port.Rating_Aux = "Missing Rating" and PD.Grade_Of_Tool_To = 300 then
															PD.Grade_Of_Tool_From < 0	
											end

								when 	Port.curr_CLTV_HE_facility = . then
										PD.Orig_LTV_From = .85 and
											case	when 	Port.Rating_Aux not = "Missing Rating" then
																PD.Grade_Of_Tool_From <= input(strip(Port.Rating_Aux),3.) 	< PD.Grade_Of_Tool_To
														when 	Port.Rating_Aux = "Missing Rating" and PD.Grade_Of_Tool_To = 300 then
																PD.Grade_Of_Tool_From < 0	
											end	

								when 	Port.curr_CLTV_HE_facility >= .85 and PD.Orig_LTV_From ne 0 then
										Port.curr_CLTV_HE_facility 					>= 	PD.Orig_LTV_From			and
										Port.curr_CLTV_HE_facility 					< 	PD.Orig_LTV_To				and
										 	case	when 	Port.Rating_Aux not = "Missing Rating" then
															PD.Grade_Of_Tool_From <= input(strip(Port.Rating_Aux),3.) 	< PD.Grade_Of_Tool_To
													when 	Port.Rating_Aux = "Missing Rating" and PD.Grade_Of_Tool_To = 300 then
															PD.Grade_Of_Tool_From < 0	
											end	
					end
		end

when 	Port.Product_Final_Facility in 	("Retail - HELOC") 					and
				PD.aggregation_key in 	( 11 )								then

		case		when 	Port.DPD_Facility_Aux 	> 0 and PD.Past_Due_Days_From > 0 then
							Port.DPD_Facility_Aux 	>=  PD.Past_Due_Days_From	and
							Port.DPD_Facility_Aux	<	PD.Past_Due_Days_To

					
				when 	Port.DPD_Facility_Aux in (., 0) and PD.Past_Due_Days_From in (0,.) then
						case 	when 	0 <= Port.curr_CLTV_HE_facility < .8 and PD.Orig_LTV_To <900	then
										Port.curr_CLTV_HE_facility 					>= 	PD.Orig_LTV_From			and
										Port.curr_CLTV_HE_facility 					< 	PD.Orig_LTV_To				and
											case	when 	Port.Rating_Aux not = "Missing Rating" then
															PD.Grade_Of_Tool_From <= input(strip(Port.Rating_Aux),3.) 	< PD.Grade_Of_Tool_To
													when 	Port.Rating_Aux = "Missing Rating" and PD.Grade_Of_Tool_To = 300 then
															PD.Grade_Of_Tool_From < 0	
											end

								when	Port.curr_CLTV_HE_facility = . then
										PD.Aux_Orig_LTV_From_To = 'Missing LTV'  and
												case	when 	Port.Rating_Aux not = "Missing Rating" then
																PD.Grade_Of_Tool_From <= input(strip(Port.Rating_Aux),3.) 	< PD.Grade_Of_Tool_To
														when 	Port.Rating_Aux = "Missing Rating" and PD.Grade_Of_Tool_To = 300 then
																PD.Grade_Of_Tool_From < 0	
											end	

								when 	Port.curr_CLTV_HE_facility >= .8 and PD.Orig_LTV_From ne 0 then
										Port.curr_CLTV_HE_facility 					>= 	PD.Orig_LTV_From			and
										Port.curr_CLTV_HE_facility 					< 	PD.Orig_LTV_To				and
										 	case	when 	Port.Rating_Aux not = "Missing Rating" then
															PD.Grade_Of_Tool_From <= input(strip(Port.Rating_Aux),3.) 	< PD.Grade_Of_Tool_To
													when 	Port.Rating_Aux = "Missing Rating" and PD.Grade_Of_Tool_To = 300 then
															PD.Grade_Of_Tool_From < 0	
											end	
					end
		end

when 	Port.Product_Final_Facility in 	("Retail - Mortgages") 				and
			 PD.aggregation_key in 		( 12 )								then

		case	when 	Port.DPD_Facility_Aux 	> 0 and PD.Past_Due_Days_From > 0 then
						Port.DPD_Facility_Aux 	>=  PD.Past_Due_Days_From	and
						Port.DPD_Facility_Aux	<	PD.Past_Due_Days_To	

				when 	Port.DPD_Facility_Aux in (., 0) and PD.Past_Due_Days_From in (0,.) then
						case 	when 	Port.Renegotiated_Flag_BdE_Facility = 1			then
										Refinanced_Indicator = 'S'

				 	   			else	case	when  	Port.PRODUCT_GROUP_EC_Facility in ('PA PROGRAM', 'STANDARD')	then
													Port.PRODUCT_GROUP_EC_Facility 		= 	Upcase(PD.Subproduct_Desc) 			and
														case 	when  	Port.Fixed_Var_TMP_EC_Facility = 'FIXED' then
																		Port.Fixed_Var_TMP_EC_Facility		=	Upcase(Substr(PD.Aux_Int_Rate_Type,1,5))	
																else	PD.Aux_Int_Rate_Type = ''
														end
												and		case 	when 	Port.Rating_Aux not = "Missing Rating" then
																		PD.Grade_Of_Tool_From <= input(strip(Port.Rating_Aux),3.) 	< PD.Grade_Of_Tool_To
																when 	Port.Rating_Aux = "Missing Rating" and PD.Grade_Of_Tool_To = 300 then
																		PD.Grade_Of_Tool_From < 0	
														end

												when 	Port.PRODUCT_GROUP_EC_Facility in ('CRA', 'EMPLOYEE') then
														Port.PRODUCT_GROUP_EC_Facility	= 	Upcase(PD.Subproduct_Desc) 			and
														case 	when 	Port.Rating_Aux not = "Missing Rating" then
																		PD.Grade_Of_Tool_From <= input(strip(Port.Rating_Aux),3.) 	< PD.Grade_Of_Tool_To
																when 	Port.Rating_Aux = "Missing Rating" and PD.Grade_Of_Tool_To = 300 then
																		PD.Grade_Of_Tool_From < 0	
														end

												when 	Port.PRODUCT_GROUP_EC_Facility in ('FOREIGN NATIONAL') then
														Port.PRODUCT_GROUP_EC_Facility 		= 	Upcase(PD.Subproduct_Desc) 			and
														case 	when 	Port.Final_State_Facility in ('FL', 'TX') then 
																		Port.Final_State_Facility 	= 	PD.aux_State	
																else	PD.aux_State = ''
														end
														and			case 	when 	Port.Rating_Aux not = "Missing Rating" then
																		PD.Grade_Of_Tool_From <= input(strip(Port.Rating_Aux),3.) 	< PD.Grade_Of_Tool_To
																when 	Port.Rating_Aux = "Missing Rating" and PD.Grade_Of_Tool_To = 300 then
																		PD.Grade_Of_Tool_From < 0	
														end	 

												when    PD.Aux_Int_Rate_Type = '' and
														UPCASE(PD.Subproduct_Desc) not in ('CRA', 'EMPLOYEE','PA PROGRAM', 'STANDARD', 'FOREIGN NATIONAL') then
														PD.Subproduct_Desc = '' and
														Refinanced_Indicator in ('N', '*') and
														case 	when 	Port.Rating_Aux not = "Missing Rating" then
																		PD.Grade_Of_Tool_From <= input(strip(Port.Rating_Aux),3.) 	< PD.Grade_Of_Tool_To
																when 	Port.Rating_Aux = "Missing Rating" and PD.Grade_Of_Tool_To = 300 then
																		PD.Grade_Of_Tool_From < 0	
														end
										end
						end
		end

when 	Port.Product_Final_Facility in 	("Retail - Other" ) 					and
			 PD.aggregation_key in 		( 13 )									then

		case	 when 	Port.DPD_Facility_Aux 	> 0 and PD.Past_Due_Days_From > 0 then
						Port.DPD_Facility_Aux 	>=  PD.Past_Due_Days_From	and
						Port.DPD_Facility_Aux	<	PD.Past_Due_Days_To	

				when  	Port.DPD_Facility_Aux in (., 0)  and PD.Past_Due_Days_From in (0,.) then
					case 	when 	substr(Port.GLdesc_Facility,1,9) = 'OVERDRAFT' then
									substr(Port.GLdesc_Facility,1,9)	= 	Upcase(PD.Subproduct_Desc)	and
								case 	when 	Port.Months_on_Books_Facility ne . then
												Port.Months_on_Books_Facility /12 	>= 	PD.Elapsed_Period_From 		and
												Port.Months_on_Books_Facility /12	<	PD.Elapsed_Period_To
										else	PD.Elap_Period_From_To = 'Missing MOB'
								end	
					
							else  	Subproduct_Desc = '' and
									case 	when 	Port.Months_on_Books_Facility ne . then
													Port.Months_on_Books_Facility /12 	>= 	PD.Elapsed_Period_From 		and
													Port.Months_on_Books_Facility /12	<	PD.Elapsed_Period_To
											else	PD.Elap_Period_From_To = 'Missing MOB'
									end	
							and		case 	when 	Port.Rating_Aux not = "Missing Rating" then
													PD.Grade_Of_Tool_From <= input(strip(Port.Rating_Aux),3.) 	< PD.Grade_Of_Tool_To
											when 	Port.Rating_Aux = "Missing Rating" and PD.Grade_Of_Tool_To = 300 then
													PD.Grade_Of_Tool_From < 0	
								end
					end
		end

when 	Port.Product_Final_Facility in 	( "Retail - Prosper" )				and
		PD.aggregation_key in 			( 14 )								then

		case	 when 	Port.DPD_Facility_Aux 	> 0 and PD.Past_Due_Days_From > 0 then
						Port.DPD_Facility_Aux 	>=  PD.Past_Due_Days_From	and
						Port.DPD_Facility_Aux	<	PD.Past_Due_Days_To	

				when 	Port.DPD_Facility_Aux in (., 0) and PD.Past_Due_Days_From in (0,.) then
						Port.orig_term_final_facility/12 		>= 	PD.Original_Period_From		and
						Port.orig_term_final_facility/12		< 	PD.Original_Period_To		and
						Port.Months_on_Books_Facility/12 		>= 	PD.Elapsed_Period_From 		and
						Port.Months_on_Books_Facility/12 		<	PD.Elapsed_Period_To		and
						case 	when 	Port.orig_term_final_facility = 36 then
								case 	when 	Port.Rating_Aux = "AA" then
												Grade_Of_Tool_From = 1 AND Grade_Of_Tool_To = 2
										when 	Port.Rating_Aux = "A" then
												Grade_Of_Tool_From = 2 AND Grade_Of_Tool_To = 3
										when 	Port.Rating_Aux = "B" then
												Grade_Of_Tool_From = 3 AND Grade_Of_Tool_To = 4
										when 	Port.Rating_Aux = "C" then
												Grade_Of_Tool_From = 4 
										else	PD.Grade_Of_Tool_From < 0
								end
						 		when	Port.orig_term_final_facility = 60 then
						 		case 	when 	Port.Rating_Aux in ("AA", "A") then
												Grade_Of_Tool_From = 1 AND Grade_Of_Tool_To = 3
										when 	Port.Rating_Aux = "B" then
												Grade_Of_Tool_From = 3 AND Grade_Of_Tool_To = 4
										when 	Port.Rating_Aux = "C" then
												Grade_Of_Tool_From = 4 
										else	PD.Grade_Of_Tool_From < 0
								end
						end
		end

when Port.Product_Final_Facility in 	("SB - CF&A Secured") 			and
	 PD.aggregation_key in 				( 15 )							then

		case	 	when 	Port.DPD_Facility_Aux 	> 0 and PD.Past_Due_Days_From > 0 then
							Port.DPD_Facility_Aux 	>=  PD.Past_Due_Days_From	and
							Port.DPD_Facility_Aux	<	PD.Past_Due_Days_To	

					when 	Port.DPD_Facility_Aux in (., 0) and PD.Past_Due_Days_From in (0, .) then
							case 	when 	Port.SB_Product_Type_Facility = 'SBA Dallas' 	then
											Substr(Port.SB_Product_Type_Facility, 1,3)	=	PD.Subproduct_Desc

									when 	Substr(Port.SB_Product_Type_Facility,1,4) = 'RLOC'	then
											Substr(Port.SB_Product_Type_Facility,1,4)	=	PD.Subproduct_Desc	and	
											case 	when 	Port.Rating_Aux not = "Missing Rating" then
															PD.Grade_Of_Tool_From <= Input(Strip(Port.Rating_Aux), 3.)	<	PD.Grade_Of_Tool_To 
													when 	Port.Rating_Aux = "Missing Rating" and PD.Grade_Of_Tool_To = 1 then
															PD.Grade_Of_Tool_From < 0	
											end
									when 	PD.Subproduct_Desc not in ('SBA', 'RLOC') then
											PD.Subproduct_Desc = '' and
											case 	when 	Port.Rating_Aux not = "Missing Rating" then
															PD.Grade_Of_Tool_From <= Input(Strip(Port.Rating_Aux), 3.)	<	PD.Grade_Of_Tool_To
													when 	Port.Rating_Aux = "Missing Rating" and PD.Grade_Of_Tool_To = 1 then
															PD.Grade_Of_Tool_From < 0	
											end
							end
		end
when Port.Product_Final_Facility in 	("SB - CF&A Unsecured") 		and
	 PD.aggregation_key in 				( 16 )							then

		case	 	when 	Port.DPD_Facility_Aux 	> 0 and PD.Past_Due_Days_From > 0 then
							Port.DPD_Facility_Aux 	>=  PD.Past_Due_Days_From	and
							Port.DPD_Facility_Aux	<	PD.Past_Due_Days_To	

					when 	Port.DPD_Facility_Aux in (., 0)  and PD.Past_Due_Days_From in (0, .) then
							case 	when 	Port.SB_Product_Type_Facility = 'CLOC' 	then
											PD.Subproduct_Desc = 'CLOC' and 
											case 	when 	Port.Rating_Aux not = "Missing Rating" then
															PD.Grade_Of_Tool_From <= Input(Strip(Port.Rating_Aux), 3.)	<	PD.Grade_Of_Tool_To 
													when 	Port.Rating_Aux = "Missing Rating" and PD.Grade_Of_Tool_To = 1 then
															PD.Grade_Of_Tool_From < 0	
											end
									when 	Substr(Port.SB_Product_Type_Facility,1,4) = 'RLOC'	then
											PD.Subproduct_Desc = 'RLOC'	and	
											case 	when 	Port.Rating_Aux not = "Missing Rating" then
															PD.Grade_Of_Tool_From <= Input(Strip(Port.Rating_Aux), 3.)	<	PD.Grade_Of_Tool_To 
													when 	(Port.Rating_Aux = "Missing Rating" and PD.Grade_Of_Tool_To = 1) or Input(Strip(Port.Rating_Aux), 3.)>300 then
															PD.Grade_Of_Tool_From < 0	
											end
									when 	Port.SB_Product_Type_Facility in ('Other', 'Term - Secured', 'Term - Unsecured', 'CRE', 'SBA Dallas') then
											PD.Subproduct_Desc = ''	and	
											case 	when 	Port.Rating_Aux not = "Missing Rating" then
															PD.Grade_Of_Tool_From <= Input(Strip(Port.Rating_Aux), 3.)	<	PD.Grade_Of_Tool_To
													when 	(Port.Rating_Aux = "Missing Rating" and PD.Grade_Of_Tool_To = 1) or Input(Strip(Port.Rating_Aux), 3.)>300 then
															PD.Grade_Of_Tool_From < 0	
											end
							end
		end

when 	Port.Product_Final_Facility in	("SB - Construction Commercial")	and
		PD.aggregation_key in 			( 17 )								then

		case		when 	Port.DPD_Facility_Aux 	> 0 and PD.Past_Due_Days_From > 0 then
							Port.DPD_Facility_Aux 	>=  PD.Past_Due_Days_From	and
							Port.DPD_Facility_Aux	<	PD.Past_Due_Days_To	

					when  	Port.DPD_Facility_Aux in (., 0) and PD.Past_Due_Days_From in (0,.) then
							case 	when 	Port.Rating_Aux not = "Missing Rating" and input(strip(Port.Rating_Aux),3.)<24 then
											PD.Grade_Of_Tool_From <= input((substr(Port.Rating_Aux, 1, 2)),2.) < PD.Grade_Of_Tool_To 
					
									when 	(Port.Rating_Aux = "Missing Rating" or input(strip(Port.Rating_Aux),3.)>=24) and PD.Grade_Of_Tool_To = 1 then
											PD.Grade_Of_Tool_From < 0
							end
		end

when 	Port.Product_Final_Facility in 	("SB - CRE") 						and
		PD.aggregation_key in 			( 18 )								then

		case	 	when 	Port.DPD_Facility_Aux 	> 0 and PD.Past_Due_Days_From > 0 then
							Port.DPD_Facility_Aux 	>=  PD.Past_Due_Days_From	and
							Port.DPD_Facility_Aux	<	PD.Past_Due_Days_To	

					when 	Port.DPD_Facility_Aux in (0, . ) and PD.Past_Due_Days_From in (0, .) then
							case 	when	Substr(Port.SB_Product_Type_Facility,1,3) =	'SBA' then
											PD.Subproduct_Desc = 'SBA'	and
								case 	when 	Port.Rating_Aux not = "Missing Rating" then
												PD.Grade_Of_Tool_From <= Input(Strip(Port.Rating_Aux), 3.)	<	PD.Grade_Of_Tool_To
										when 	Port.Rating_Aux = "Missing Rating" and PD.Grade_Of_Tool_To = 1 then
												PD.Grade_Of_Tool_From < 0
								end	
									else		Port.orig_bal_facility	>=	PD.Original_Balance_From	and
												Port.orig_bal_facility	<	PD.Original_Balance_To		and
												PD.Subproduct_Desc ne 'SBA'	and
														case 	when 	Port.Rating_Aux not = "Missing Rating" then
																		PD.Grade_Of_Tool_From <= Input(Strip(Port.Rating_Aux), 3.)	<	PD.Grade_Of_Tool_To
																when 	Port.Rating_Aux = "Missing Rating" and PD.Grade_Of_Tool_To = 1 then
																		PD.Grade_Of_Tool_From < 0
														end	
									end
		end
	
end
;quit;
/*End of PD_driver join*/

/*Creates Cohort Variable*/
proc sql ;
	create table Portfolio_PD_C as
		select 	product_final_facility, account_final_MIS, BATCH_ID, PD_Driver, 
				input((substr(Put(BATCH_ID, 8.),1, 4)),4.) as Cohort
	from &Portfolio._PD 
;quit;

/*Creates Origination_Batch_ID Variable to show opening date of each account*/
proc sql ;
	create table Portfolio_PD_C_Orig as
		select * , min(BATCH_ID) as Origination_Batch_ID
	from Portfolio_PD_C
	Group by account_final_MIS
;quit;

proc sql; drop Portfolio_PD_C; quit;
/*Creates Origination_Cohort_Batch_ID variable to show the origination date of each year
as well as creates an auxilary variable to be used in selecting the first PD from each year*/
proc sql ;
	create table Portfolio_PD_Orig_Cohort as
	select 	* , min(BATCH_ID) as Origination_Cohort_Batch_ID,
			cats(account_final_MIS,Cohort) as aux
	from Portfolio_PD_C_Orig
	group by account_final_MIS, Cohort
;quit;

/*Sorts table to prepare for the use of the first function*/
proc sort data =  Portfolio_PD_Orig_Cohort out = Portfolio_PD_Orig_Cohort;
by account_final_MIS  Cohort BATCH_ID Origination_Cohort_Batch_ID;
run;

/*Creates table with the first PD Driver of every cohort for each account*/
data First_Portfolio;
set Portfolio_PD_Orig_Cohort;
by  aux Cohort ;
if first.aux  then output;
run;

/*Joins the prior two tables to generate the original_PD_Driver for every cohort for each account*/
proc sql ;
	create table Portfolio_PD_Orig as
		select  distinct C.product_final_facility, C.account_final_MIS, C.BATCH_ID, C.Origination_Batch_ID, C.Origination_Cohort_Batch_ID, C.PD_Driver, 
						F.PD_Driver as Original_PD_Driver, F.Cohort, F.aux
		from  		Portfolio_PD_Orig_Cohort 	as C
		left join 	First_Portfolio 			as F
		on 	C.account_final_MIS = F.account_final_MIS
		and C.Cohort 			= F.Cohort
;quit;

/*Adds the horizon variable to determine the number of months on books*/
proc sql ;
	create table Portfolio_PD_H as
		select 	* , (input((substr(Put(BATCH_ID, 8.),3, 2)),2.)- input((substr(Put(Origination_BATCH_ID, 8.),3, 2)),2.))*12 +
				(input((substr(Put(BATCH_ID, 8.),5, 2)),2.)- input((substr(Put(Origination_BATCH_ID, 8.),5, 2)),2.)) 
				as Horizon
	from Portfolio_PD_Orig
;quit;

/*Macros to generate PD Drivers for each Cohort in each successive year*/
/*Creates tables for each year following the initial cohort year*/
%macro year_loop(year, i);
proc sql ;
%do i = &i. %to %eval(2018-&year.);;
	create table year_&year._&i. as
	select product_final_facility, account_final_MIS, PD_Driver as PD_Driver_%eval(&year.+&i.)
	from Portfolio_PD_H
	where Cohort = %eval(&year.+&i.) and Horizon in (0, 12, 24, 36, 48, 60, 72, 84, 96, 108, 120, 132, 144)
%end;
;quit;
%mend year_loop;
/*%year_loop(2008, 0);*/

/*Joins yearly tables together to create final cohort table*/
%macro PD_Driver_Yearly(year, i);
data PD_Driver_Yearly_&year.;
set Year_&year._&i.;
run;
proc sql;
%do i=%eval(&i.+1) %to %eval(2018-&year.);;
	create table PD_Driver_Yearly_&year. as 
	select distinct * , Y&i..PD_Driver_%eval(&year. + &i.)
	from PD_Driver_Yearly_&year. as Y0
	left join Year_&year._&i. as Y&i.
	on Y0.account_final_MIS = Y&i..account_final_MIS
	
%end;
;quit;
%mend PD_Driver_Yearly;
/*%PD_Driver_Yearly(2008, 0);*/

/*Calls prior two macros in order to generate PD_Driver tables for each cohort*/
%macro PD_Driver_Yearly_Cohort (year);
%local i;
%do i=0 %to %eval(2018-&year.);;
	%year_loop(%eval(&year. + &i.), 0)
	%PD_Driver_Yearly(%eval(&year. + &i.), 0);
%end;
%mend PD_Driver_Yearly_Cohort;

/*Creates earliest cohort variable to be used in the loops of the prior macros*/
proc sql noprint;
select min(Cohort)
  into :min_cohort
  from Portfolio_PD_H
;quit;

%PD_Driver_Yearly_Cohort (&min_Cohort.);

/*Drops intermediate tables to save space*/
proc sql;
drop table 
DPD_Rating_Aux,
Portfolio_PD_C,
Portfolio_PD_C_Orig,
Portfolio_PD_Orig_Cohort,
First_Portfolio, 
Portfolio_PD_Orig

;quit;

%mend PD_Driver_Assign;




/*Macro to run all Migration Tables*/
%macro migration_tables (Portfolio);

/*Creates table with all migration possibilities for each Family Code (Aggregation_Key)*/
proc sql ;
	create table Migration_1 as
		select Aggregation_Key as Agg1, PD_driver as PD_Driver1
		from Output.PD_Driver
		order by Aggregation_Key, PD_Driver
;quit;

/*Creates the same table from above in order to join the two tables*/
proc sql ;
	create table Migration_2 as
		select Aggregation_Key as Agg2, PD_driver as PD_Driver2
		from Output.PD_Driver
	order by Aggregation_Key, PD_Driver
;quit;

/*Adds the Family Code Description and abbrevation for naming the final table
for each Aggregation_Key and adds the value to Migration_2 Table*/
Data Migration_2;
Set Migration_2;
format Family_Code $80.;
format Fmly_Abr $25.;

if Agg2 = 1 then 
do;
 	Family_Code='Commercial - C&I';
 	Fmly_Abr= "Com_CI";
end;
else if Agg2 = 2 then 
do;
 	Family_Code='Commercial - Construction Commercial';
 	Fmly_Abr= "Com_Constr_Com";
end;
else if Agg2 = 3 then 
do;
 	Family_Code='Commercial - Construction Residential';
 	Fmly_Abr= "Com_Constr_Res";
end;
else if Agg2 = 4 then
do;
	Family_Code='Commercial - CRE';
 	Fmly_Abr= "Com_CRE";
end;
else if Agg2 = 5 then 
do;
	Family_Code='Commercial - Credit Card';
	Fmly_Abr= "Com_CC";
end;
else if Agg2 in (6, 7) then 
do;
	Family_Code='Retail - Consumer Direct';
	Fmly_Abr= "Retail_CD";
end;
else if Agg2 = 8 then 
do;
	Family_Code='Retail - Credit Card';
	Fmly_Abr= "Retail_CC";
end;
else if Agg2 = 9 then 
do;
	Family_Code='Retail - DFS';
	Fmly_Abr= "Retail_DFS";
end;
else if Agg2 = 10 then 
do;
	Family_Code='Retail - HELOAN';
	Fmly_Abr= "Retail_HELOAN";
end;
else if Agg2 = 11 then 
do;
	Family_Code='Retail - HELOC';
	Fmly_Abr= "Retail_HELOC";
end;
else if Agg2 = 12 then 
do;
	Family_Code='Retail - Mortgages';
	Fmly_Abr= "Retail_Mort";
end;
else if Agg2 = 13 then 
do;
	Family_Code='Retail - Other';
	Fmly_Abr= "Retail_Oth";
end;
else if Agg2 = 14 then 
do;
	Family_Code='Retail - Prosper';
	Fmly_Abr= "Retail_Pr";
end;
else if Agg2 = 15 then 
do;
	Family_Code='SB - CF&A Secured';
	Fmly_Abr= "SB_CFA_Sec";
end;
else if Agg2 = 16 then 
do;
	Family_Code='SB - CF&A Unsecured';
	Fmly_Abr= "SB_CFA_Unsec";
end;
else if Agg2 = 17 then 
do;
	Family_Code='SB - Construction Commercial';
	Fmly_Abr= "SB_Constr_Com";
end;
else if Agg2 = 18 then 
do;
	Family_Code='SB - CRE';
	Fmly_Abr= "SB_CRE";
end;
else if Agg2 = 19 then
do;
 	Family_Code='RE LHFS';
 	Fmly_Abr= "RE_LHRS";
end;
else if Agg2 = 20 then 
do;
	Family_Code='SC&M - Debt Securities';
	Fmly_Abr= "SCM_DS";
end;
else if Agg2 = 21 then
do;
 	Family_Code='Debt Securities';
 	Fmly_Abr= "DS";
end;
else if Agg2 = 22 then 
do;
	Family_Code='Repos';
	Fmly_Abr= "Repos";
end;
else  
do;
	Family_Code='Other';
	Fmly_Abr= "Other";
end;
run;

/*Joins Migration_1 and Migration_2 in order to create a Migration Matrix*/
proc sql ;
	create table Migration_Final as
		select distinct a.Agg1 as Aggregation_Key, b.Family_Code, a.PD_driver1 as Current_PD_Driver, 
		b.PD_Driver2 as Future_PD_Driver, b.Fmly_Abr
		from Migration_1 as a
		left join Migration_2 as b
		on a.Agg1 = b.Agg2
		order by Agg1, PD_Driver1, PD_Driver2
;quit;

/*Counts the number of migrations for each change in PD_Driver across the first year of each cohort*/
%macro PD_Migration_Count(year);
%local i;
PROC SQL ;
%do i = 0 %to %eval(2017-&year.);;
   CREATE TABLE PD_%eval(&year.+&i.)_%eval(&year. +1 +&i.)_Migration AS 
   SELECT distinct t1.product_final_facility,
		  t1.PD_Driver_%eval(&year.+&i.), 
          t1.PD_Driver_%eval(&year.+&i.+1), 
          (COUNT(t1.account_final_MIS)) AS Ct_acc_fin_%eval(&year.+&i.)_%eval(&year.+1+&i.)
      FROM WORK.PD_DRIVER_YEARLY_%eval(&year.+&i.) t1
      GROUP BY t1.PD_Driver_%eval(&year.+&i.),
               t1.PD_Driver_%eval(&year. +1 +&i.);
%end;
QUIT;
%mend PD_Migration_Count;

/*Creates a variable for the earliest cohort,
the var is then used in the loop of the macro above*/
proc sql noprint;
select min(Cohort)
  into :min_cohort
  from Portfolio_PD_H
;quit;

%PD_Migration_Count(&min_Cohort.);


/*Joins Migration_final with all of the about Migration_Count Tables to display the 
count for each change in PD_Driver across the first year of each cohort*/
%macro PD_Migration_Count_Join(year);
%local i;
proc sql ;
%do i=0 %to %eval(2017-&year.);;
	create table Migration_Final as
	select distinct a.*, b.Ct_acc_fin_%eval(&year.+&i.)_%eval(&year.+1+&i.) 
	from Migration_Final as a
	left join PD_%eval(&year.+&i.)_%eval(&year.+1+&i.)_Migration as b
	on 	a.Current_PD_Driver = b.PD_Driver_%eval(&year.+&i.) and
		a.Future_PD_Driver = b.PD_Driver_%eval(&year.+1+&i.)	
%end;
	where a.family_code = b.Product_final_facility
;quit;
%mend PD_Migration_Count_Join;


%PD_Migration_Count_Join(&min_Cohort.);

/*Format to define counts in case not created before
Defining macro variable for the final output name*/
data MIGRATION_FINAL;
set MIGRATION_FINAL;

format ct_acc_fin_2015_2016 8.;
format ct_acc_fin_2016_2017 8.;
format ct_acc_fin_2017_2018 8.;

call symput('Fmly_Abr', Fmly_Abr);
run;

%put Fmly_Abr = &Fmly_Abr.;


/*Counts the number of accounts in each transfer bucket for the last three years of data*/
PROC SQL;
   CREATE TABLE MIGRATION_FINAL_Count AS 
   SELECT t1.Family_Code, 
          t1.Current_PD_Driver, 
          t1.Future_PD_Driver,
			coalesce(t1.ct_acc_fin_2015_2016,0) + coalesce(t1.ct_acc_fin_2016_2017,0) 
			+ coalesce(t1.ct_acc_fin_2017_2018,0) as calculation
	FROM WORK.MIGRATION_FINAL t1
      WHERE (CALCULATED Calculation) NOT = .;
QUIT;

/*Sums the number of accounts in each starting PD_Driver*/
PROC SQL;
   CREATE TABLE MIGRATION_FINAL_Sum AS 
   SELECT t1.Family_Code, 
          t1.Current_PD_Driver, 
          (SUM(t1.Calculation)) AS SUM_of_Calculation
      FROM MIGRATION_FINAL_Count t1
      GROUP BY t1.Family_Code,
               t1.Current_PD_Driver;
QUIT;

/*Calculates the percentage of each Migration out of the total starting from the same Current_PD_Driver*/
proc sql;
	create table Output.Migration_Perc_&Fmly_Abr. as
		select  a.family_code, a.Current_PD_Driver, a.Future_PD_Driver,
				a.calculation/b.sum_of_calculation as Percentage format =percent10.2
		from MIGRATION_FINAL_Count a
		left join MIGRATION_FINAL_Sum b
		on a.Current_PD_Driver = b.Current_PD_Driver
		
;quit;

%mend migration_tables;



/*Runs all code for all portfolios in order to generate final RISK PROFILE parametric tables*/
%macro run_all;

%PD_Driver_Assign (RKA.Commercial_Construction);
%migration_tables (RKA.Commercial_Construction);

%PD_Driver_Assign (RKA.Commercial_CRE);
%migration_tables (RKA.Commercial_CRE);

%PD_Driver_Assign (RKA.Commercial_CI);
%migration_tables (RKA.Commercial_CI);

%PD_Driver_Assign (RKA.Commercial_Credit_Card);
%migration_tables (RKA.Commercial_Credit_Card);

%PD_Driver_Assign (RKA.Retail_Consumer_Direct);
%migration_tables (RKA.Retail_Consumer_Direct);

%PD_Driver_Assign (RKA.Retail_Credit_Card);
%migration_tables (RKA.Retail_Credit_Card);

%PD_Driver_Assign (RKA.Retail_DFS);
%migration_tables (RKA.Retail_DFS);

%PD_Driver_Assign (RKA.Retail_HELOAN);
%migration_tables (RKA.Retail_HELOAN);

%PD_Driver_Assign (RKA.Retail_HELOC);
%migration_tables (RKA.Retail_HELOC);

%PD_Driver_Assign (RKA.Retail_Mortgages);
%migration_tables (RKA.Retail_Mortgages);

%PD_Driver_Assign (RKA.Retail_Other);
%migration_tables (RKA.Retail_Other);

%PD_Driver_Assign (RKA.Retail_Prosper);
%migration_tables (RKA.Retail_Prosper);

%PD_Driver_Assign (RKA.SB_CFA_Secured);
%migration_tables (RKA.SB_CFA_Secured);

%PD_Driver_Assign (RKA.SB_CFA_Unsecured);
%migration_tables (RKA.SB_CFA_Unsecured);

%PD_Driver_Assign (RKA.SB_CRE);
%migration_tables (RKA.SB_CRE);

%PD_Driver_Assign (RKA.SB_Construction_Commercial);
%migration_tables (RKA.SB_Construction_Commercial);

%mend run_all;
%run_all;



/*Combining all Risk Profiles*/
data Output.migration_perc_all(drop=Aggregation_Key);
format lob_dept1;
set 
Output.migration_perc_com_cc
Output.migration_perc_com_ci
Output.migration_perc_com_constr_com
Output.migration_perc_com_cre
Output.migration_perc_retail_cc
Output.migration_perc_retail_cd
Output.migration_perc_retail_dfs
Output.migration_perc_retail_heloan
Output.migration_perc_retail_heloc
Output.migration_perc_retail_mort
Output.migration_perc_retail_oth
Output.migration_perc_retail_pr
Output.migration_perc_sb_cfa_sec
Output.migration_perc_sb_cfa_unsec
Output.migration_perc_sb_constr_com
Output.migration_perc_sb_cre;

lob_dept1 = "";
run;