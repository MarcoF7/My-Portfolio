
/************************************************************************************/
/*                                                                               	*/
/*	888888b.   888888b.  888     888     d8888 									 	*/
/*	888  "88b  888  "88b 888     888    d88888 		 Engine Output Analysis	    	*/
/*	888  .88P  888  .88P 888     888   d88P888 									 	*/
/*	8888888K.  8888888K. Y88b   d88P  d88P 888 			      CECL	          	 	*/
/*	888  "Y88b 888  "Y88b Y88b d88P  d88P  888 									 	*/
/*	888    888 888    888  Y88o88P  d88P   888 				Version 1.1			 	*/
/*	888   d88P 888   d88P   Y888P  d8888888888 									 	*/
/*	8888888P"  8888888P"     Y8P  d88P     888 		       2019	             	 	*/
/*                                                                               	*/
/************************************************************************************/
	/*%let user = xs16242; 
	%let pw   = compas13; */
	%let user = xsc5977;	
	%let pw   = compas03;
/*Defining Libraries*/
	LIBNAME HST        oracle user=&user. password=&pw. path='crprod' PRESERVE_TAB_NAMES=YES SCHEMA=HST;
	LIBNAME MRT        oracle user=&user. password=&pw. path='crprod' PRESERVE_TAB_NAMES=YES SCHEMA=MRT;
	LIBNAME WHS        oracle user=&user. password=&pw. path='crprod' PRESERVE_TAB_NAMES=YES SCHEMA=WHS;
	LIBNAME RKA        '/SAS_RiskParams/SASData2/SASUSER/SAS_CREDRISK/Economic_Capital/C_RHODES/OUTPUT/RKA';
	LIBNAME IFRS9      oracle user=&user. password=&pw. path='REGPRD' PRESERVE_TAB_NAMES=YES SCHEMA=IFRS9_OWNER;
	LIBNAME IFRS_9     "/SAS_RiskParams/SASData/SASUSER/SAS_ALLL/IFRS_9";	
	LIBNAME CECLPRD	   oracle user=&user. password=&pw. path='REGPRD' PRESERVE_TAB_NAMES=YES SCHEMA=CECL_OWNER;
	LIBNAME CECLTST	   oracle user=&user. password=&pw. path='REGTST' PRESERVE_TAB_NAMES=YES SCHEMA=CECL_OWNER;
	LIBNAME CECLDEV    oracle user=&user. password=&pw. path='REGDEV' PRESERVE_TAB_NAMES=YES SCHEMA=CECL_OWNER;
	LIBNAME CECL       '/SAS_RiskParams/SASData/SASUSER/SAS_ALLL/CECL/03. SAS Tables';
	LIBNAME CECLSTG	   oracle user=&user. password=&pw. path='REGDEV' PRESERVE_TAB_NAMES=YES SCHEMA=CECL_STAGE;
	LIBNAME EADOUT     '/SAS_RiskParams/SASData2/SASUSER/SAS_CREDRISK/Risk Parameters/11. ECL Engine/00. Tables/01. IFRS9/05. EAD Decrease/';
	LIBNAME Output "/SAS_RiskParams/SASData/SASUSER/SAS_ALLL/CECL/04. Forecasting Tool/02. Results";
	/*Database parameters location*/
	LIBNAME ALLPROD "/SAS_RiskParams/SASData2/SASUSER/SAS_CREDRISK/Risk Parameters/00. Database Parameters/201809/02. Datasets/02. Database all Products";

/*Defining Macro Variables*/
	%let DAY					   = 20190531;
	%let SCENARIO				   = ;/*_V1_2, _V2_2*/
	%let ENGINE		               = CECL.ENGINE_&DAY.;
	%let Master_Of_Contracts       = CECL.MASTER_&DAY.&SCENARIO._ADJ;
	%let master_alll               = IFRS_9.MASTER_IFRS9_ALLL_&DAY._FNL;
	%let PD  					   = Output.pd_driver;
	%let Auxiliar_Table			   = serg.SUB_PRODUCT_&DAY.;

	%let Parametric_Tbl 		   = /SAS_RiskParams/SASData/SASUSER/SAS_ALLL/CECL/04. Forecasting Tool/Parametric Tables/;
	%let PD_Param_Name 			   = PD Driver - Parametric Tables.xlsx;
	%let Forec_Tool 			   = /SAS_RiskParams/SASData/SASUSER/SAS_ALLL/CECL/04. Forecasting Tool/;
	%let Forecast_PT 			   = Forecasting Tool (Parametric Tables).xlsx;
	%let Code_sas 				   = /SAS_RiskParams/SASData/SASUSER/SAS_ALLL/CECL/04. Forecasting Tool/01. Codes/;


/*CALLING FORECASTING TOOL*/
/*
  			%Put *******************PD Driver;
			%include "&Code_sas.PD Driver.sas" / lrecl = 5000;
  			%Put *******************LGD Driver;
			%include "&Code_sas.LGD Driver.sas" / lrecl = 5000;
*/