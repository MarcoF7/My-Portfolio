*---------------------------------------------------------------------------------------;
*							Pledged Loans - Libraries;
*							Author: Management Solutions;
*---------------------------------------------------------------------------------------;

%let batch = 20190531;


data _null_;
	format _year z4.0;
	format _month z2.0;
	format _day z2.0;
	format _date mmddyy10.;
	format _date_begin mmddyy10.;
	format _date_prev mmddyy10.;
	format _date_begin_format 8.;
	format _date_prev_format 8.;

	_year = input(substr(left(&batch),1,4),4.);
	_month = input(substr(left(&batch),5,2),2.);
	_day = input(substr(left(&batch),7,2),2.);
	_date = mdy(_month, _day, _year);
	call symput('_processing_date',_date); /*batch in date format*/

	_date_begin = intnx("Month",_date,0,"BEGINNING");
	_date_prev = intnx("Day",_date_begin,-1);

	_date_begin_format = input(cats(
	substr(put(_date_begin, mmddyy10.),7,4),
	substr(put(_date_begin, mmddyy10.),1,2),
	substr(put(_date_begin, mmddyy10.),4,2)
	),$8.);
	call symput('_date_begin_format', _date_begin_format);

	_date_prev_format = input(cats(
	substr(put(_date_prev, mmddyy10.),7,4),
	substr(put(_date_prev, mmddyy10.),1,2),
	substr(put(_date_prev, mmddyy10.),4,2)
	),$8.);
	call symput('batch_prev', _date_prev_format);

	today_day = today();
	today_hour = time();
	format today_day YYMMDD10.;
	format today_hour time.;
	format today_day_format 8.;
	format today_hour_format z6.;
	today_day_format = input(cats(
	substr(put(today_day, YYMMDD10.),1,4),
	substr(put(today_day, YYMMDD10.),6,2),
	substr(put(today_day, YYMMDD10.),9,2)
	),$8.);
	today_hour_format = input(cats(
	substr(put(today_hour, time.),1,2),
	substr(put(today_hour, time.),4,2),
	substr(put(today_hour, time.),7,2)
	),$6.);
	call symput ('Today_Date',today_day_format); /*Today's DATE in numeric format*/
	call symput ('Today_Hour',today_hour_format); /*Today's HOUR in numeric format*/
run;

%let batch_begin_month = &_date_begin_format.;
%let batch_WHS = &batch.;
/*%let batch_MRT = &batch_prev.;*/
%let batch_MRT = &batch.;
/*%let batch_HST = &batch_prev.;*/
%let batch_HST = &batch.;

%put &batch_WHS;
%put &batch_MRT;
%put &batch_HST;


/*SC user info*/
%let userid =  xsc7842;  
%let pwd = compas33;

/*Market Smart user info*/
%let userid2 =SAS_DP;
%let pwd2 =Dpeop123;

/*
%let userid3 = ;
%let pwd3 = ;
*/

LIBNAME MRT ORACLE USER = "&userid" PASSWORD = "&pwd"
		BUFFSIZE = 10000 PATH = 'CRPROD' PRESERVE_TAB_NAMES = YES SCHEMA = MRT;

LIBNAME HST ORACLE USER = "&userid" PASSWORD = "&pwd"
		BUFFSIZE = 10000 PATH = 'CRPROD' PRESERVE_TAB_NAMES = YES SCHEMA = HST;

LIBNAME WHS ORACLE USER = "&userid" PASSWORD = "&pwd"  
		BUFFSIZE = 10000 PATH = 'CRPROD' PRESERVE_TAB_NAMES = YES SCHEMA = WHS;

 LIBNAME RADB ORACLE USER = "&userid" PASSWORD = "&pwd"  
		BUFFSIZE = 1000 PATH = 'CRPROD' PRESERVE_TAB_NAMES = YES SCHEMA = RADB; 

LIBNAME EDWPRD_S ORACLE USER='edw_user' PASSWORD='edwuser12'
	BUFFSIZE=10000 PATH='EXA_EDWPRD' PRESERVE_TAB_NAMES=YES SCHEMA=EDW_STG;
LIBNAME EDWPRD_O ORACLE USER='edw_user' PASSWORD='edwuser12'
	BUFFSIZE=10000 PATH='EXA_EDWPRD' PRESERVE_TAB_NAMES=YES SCHEMA=EDW_OWNER;

/*
FDM Library to test the Population Filter Logic based on FDM:

libname FDM2 ORACLE user="&userid3" password="&pwd3" 
path='FDMPRD' schema=FDM_MTHLY PRESERVE_TAB_NAMES=yes DBINDEX=YES;
*/

LIBNAME SMART ORACLE USER="&userid2" PASSWORD="&pwd2"  
BUFFSIZE=500 PATH='CMPP2.WORLD' PRESERVE_TAB_NAMES=YES SCHEMA=CACC;
/******************************************************************/



/*
LIBNAME TS2 ODBC user=TA002229 pwd=9greentea123 DSN="Shadow_DB2" schema="TA6364";
LIBNAME TS1 ODBC user=TA002229 pwd=9greentea123 DSN="Shadow_DB2" schema="TA0022"; 
*/

 /*  CRTEST */

LIBNAME CRTSTMRT ORACLE USER="&userid" PASSWORD="&pwd"
           BUFFSIZE=10000 PATH='CRTST' PRESERVE_TAB_NAMES=YES SCHEMA=MRT;

LIBNAME CRTSTHST ORACLE USER="&userid" PASSWORD="&pwd"
           BUFFSIZE=10000 PATH='CRTST' PRESERVE_TAB_NAMES=YES SCHEMA=HST;

LIBNAME CRTSTWHS ORACLE USER="&userid" PASSWORD="&pwd"
           BUFFSIZE=10000 PATH='CRTST' PRESERVE_TAB_NAMES=YES SCHEMA=WHS;
 /*  CRPRE */
/*CRPRE commented because it is not used in the program*/
/*		   
LIBNAME CRPREMRT ORACLE USER="&userid" PASSWORD="&pwd"
           BUFFSIZE=10000 PATH='CRPRE' PRESERVE_TAB_NAMES=YES SCHEMA=MRT;


LIBNAME CRPREHST ORACLE USER="&userid" PASSWORD="&pwd"  
           BUFFSIZE=10000 PATH='CRPRE' PRESERVE_TAB_NAMES=YES SCHEMA=HST;

LIBNAME CRPREWHS ORACLE USER="&userid" PASSWORD="&pwd"  
           BUFFSIZE=10000 PATH='CRPRE' PRESERVE_TAB_NAMES=YES SCHEMA=WHS;
*/


libname CPS ORACLE user=xAccess password=cps911
	path='cpsprd' PRESERVE_TAB_NAMES=YES SCHEMA=CPS;


/*Libname FDBR Oracle user="&userid" PASSWORD="&pwd" */
/*	BUFFSIZE=10000 PATH='FDBR' PRESERVE_TAB_NAMES=YES SCHEMA=FDBR*/
/*
LIBNAME cacc     ORACLE path="cmpp2.world" user=&userid2 Password=&Pwd2 schema=cacc;


LIBNAME daily    ORACLE path="cmpp2.world" user=&userid2 Password=&Pwd2 schema=daily;

LIBNAME damart   ORACLE path="cmpp2.world" user=&userid2 Password=&Pwd2 schema=damart;
*/

/* Collections databases */
/*
LIBNAME COLLDB1 ORACLE USER="&userid" PASSWORD="&pwd"  
           BUFFSIZE=1000 PATH='COLL_DB' PRESERVE_TAB_NAMES=YES SCHEMA=CACS_TPR;

LIBNAME COLLDB2 ORACLE USER="&userid" PASSWORD="&pwd"  
           BUFFSIZE=1000 PATH='COLL_DB' PRESERVE_TAB_NAMES=YES SCHEMA=COLL_DAT;

LIBNAME COLLDB3 ORACLE USER="&userid" PASSWORD="&pwd"  
           BUFFSIZE=1000 PATH='COLL_DB' PRESERVE_TAB_NAMES=YES SCHEMA=COLLDB_DAT;
*/
LIBNAME SCOTTDW '/SASData/SASUSER/SAS_CREDRISK/ScottDW';


LIBNAME AQR       '/SAS_RiskModelDev/SASData/SAS_CCAR/AQR/sas94'; 
LIBNAME CCAR      '/SAS_RiskModelDev/SASData/SAS_CCAR/sas94'; 
LIBNAME CCAR14QR  '/SAS_RiskModelDev/SASData/SAS_CCAR/14Q/Retail/sas94';
LIBNAME CCAR14QW  '/SAS_RiskModelDev/SASData/SAS_CCAR/14Q/Wholesale/sas94';
LIBNAME CCAR14MA  '/SAS_RiskModelDev/SASData/SAS_CCAR/14M/ARGUS/sas94';
LIBNAME CCAR14ML  '/SAS_RiskModelDev/SASData/SAS_CCAR/14M/LPS/sas94';

LIBNAME PLEDGED       '/SAS_RiskModelDev/SAS_FSB/Pledged loans/Tables'; 

LIBNAME SASDQS '/SAS_RiskModelDev/SASData/SASUSER/SAS_ALL_USERS/SAS_DQS';

LIBNAME SBA2 ORACLE USER="&userid" PASSWORD="&pwd"
           PATH='CRPROD' PRESERVE_TAB_NAMES=YES SCHEMA=SBA_ADMIN;

LIBNAME BWCLS ORACLE USER="&userid" PASSWORD="&pwd"
           PATH='CRPROD' PRESERVE_TAB_NAMES=YES SCHEMA=BWCLS;

LIBNAME DISC '/SASData/SASUSER/SAS_MF/Data/Discounts';

LIBNAME HOME '/SASData/SASUSER/XSC5025';

LIBNAME CCAR_PRO '/SAS_RiskModelDev/SASData/SAS_CCAR/CCAR_PRO/sas94';  	
LIBNAME CCAR_HIS '/SAS_RiskModelDev/SASData/SAS_CCAR/CCAR_HIS/sas94';

LIBNAME WKFSTEST odbc dsn=Summixfsdbtest schema=dbo;

/*LIBNAME WKFSPRO odbc dsn=Summixfsdbprod schema=dbo;*/

/*LIBNAME WKFSCCAR odbc dsn=CCARprod schema=dbo;*/
/*LIBNAME WKCCARTS odbc dsn=ccartest schema=dbo;*/

LIBNAME RRM ORACLE USER="reg_rpt" PASSWORD="regrpt12"
           PATH='REGPRD' PRESERVE_TAB_NAMES=YES SCHEMA=MIS_OPS;

/*Macrovariable with the path of the SAS scripts*/
%LET Code_sas = /SAS_RiskModelDev/SAS_FSB/Pledged loans/Code reporting/; 


/*Macro to set the work library in a physical directory*/
/*
%Macro LibreriaUser;
	%Let RC = 0;
	data _null_;
	set sashelp.vslib(where=(libname="user"));
		call symput('RC',1);	
	run;
	%IF &RC = 1 %THEN %DO;
		LIBNAME USER CLEAR;
	%END;
	%IF &RC = 0 %THEN %DO;
		LIBNAME USER "/SAS_RiskModelDev/SAS_FSB/Pledged loans/Nuevo_Work/";
	%END;
%Mend;

%LibreriaUser;
*/


/*Macro to Export a SAS table to an xlsx Excel file*/
%Macro exportXLSX(dataset, file, sheet);
	proc export data=&dataset
		outfile="&file"
		DBMS=XLSX REPLACE;
		sheet="&sheet";
	run;
%Mend;



/*Call the rest of the program*/
%include "&Code_sas.Pledge Population.sas" / lrecl = 5000;
%include "&Code_sas.Check Population.sas" / lrecl = 5000;
%include "&Code_sas.Common.sas" / lrecl = 5000;
%include "&Code_sas.Exclusions.sas" / lrecl = 5000;

%include "&Code_sas.Agricultural.sas" / lrecl = 5000;
%include "&Code_sas.Commercial Loans.sas" / lrecl = 5000;
%include "&Code_sas.US Agency Guaranteed.sas" / lrecl = 5000;
%include "&Code_sas.Unsecured Consumer.sas" / lrecl = 5000;
%include "&Code_sas.Secured Consumer.sas" / lrecl = 5000;
%include "&Code_sas.CRE.sas" / lrecl = 5000;
%include "&Code_sas.Construction Loans.sas" / lrecl = 5000;
%include "&Code_sas.CreditCards.sas" / lrecl = 5000;

%include "&Code_sas.Data_Quality.sas" / lrecl = 5000;

%include "&Code_sas.Export to TXT.sas" / lrecl = 5000;
