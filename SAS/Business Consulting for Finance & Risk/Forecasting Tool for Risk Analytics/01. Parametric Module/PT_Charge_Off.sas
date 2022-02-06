

/*Importing Charge Off Parametric Table*/
proc import datafile= '/SAS_RiskParams/SASData/SASUSER/SAS_ALLL/CECL/04. Forecasting Tool/Forecasting Tool (Parametric Tables)'
	dbms=xlsx replace
	out=output.Charge_Off;
	range="6. Charge Offs$B2:E102";
	getnames=yes;
run;