
/*Consolidation of all Exclusions of Foreign Countries*/
data Exclusion_Country_Tot;
set 
Exclusion_Country_Agri
Exclusion_Country_Com
Exclusion_Country_Agency
Exclusion_Country_Unsec
Exclusion_Country_Sec
Exclusion_Country_CRE
Exclusion_Country_Constr;
run;

/*Exporting Foreign Country Exclusions Log*/
%exportXLSX(Exclusion_Country_Tot,
/SAS_RiskModelDev/SAS_FSB/Pledged loans/Exclusions_Log.xlsx,
Foreign Country);


/*Consolidation of all New Loans Exclusions*/
data Exclusion_Origination;
set 
Agricultural_Origination
Commercial_Origination
Agency_Origination
Unsecured_Origination
Secured_Origination
CRE_Origination
Construction_Origination;
run;

/*Exporting New Loans Log*/
%exportXLSX(Exclusion_Origination,
/SAS_RiskModelDev/SAS_FSB/Pledged loans/Exclusions_Log.xlsx,
New Loans);



/************CRE Data Quality Table************/
data DQ_Cre_Flags;
set PLEDGED.CRE_FINAL;
	IF ObligorName = "" then 
		Flag_ObligorName = 0;
	ELSE
		Flag_ObligorName = 1;
	
	IF obligorcity = "" then 
		Flag_obligorcity = 0;
	ELSE
		Flag_obligorcity = 1;

	IF ObligorCountry NOT IN ("","US") AND 
	(CCDESC_H10 =: 'COMMERCIAL' OR CCDESC_H10 =: 'CORPORATE') then
		Flag_ObligorCountry_Foreign = 0;
	ELSE
		Flag_ObligorCountry_Foreign = 1;

	IF ObligorCountry = "" then 
		Flag_ObligorCountry = 0;
	ELSE
		Flag_ObligorCountry = 1;

	IF MasterNoteReferenceNumber = "" AND Subsystem NE "ALS" then 
		Flag_MasterNoteRef = 0;
	ELSE
		Flag_MasterNoteRef = 1;

	IF PrincipalPaymentFrequency = "N" then 
		Flag_PrincPayFreq_N = 0;
	ELSE
		Flag_PrincPayFreq_N = 1;

	IF InterestNextDueDate = . then 
		Flag_Interest_Null = 0;
	ELSE
		Flag_Interest_Null = 1;	

	IF InterestNextDueDate < &batch_begin_month. then 
		Flag_Intst_Date_in_Past = 0;
	ELSE
		Flag_Intst_Date_in_Past = 1;

	IF InterestNextDueDate >= &batch_begin_month. AND InterestNextDueDate < &batch. then 
		Flag_Intst_Date_in_Past2 = 0;
	ELSE
		Flag_Intst_Date_in_Past2 = 1;
	
	IF InterestPaidThroughDate = . then 
		Flag_IntPaidThrouDate_Blank = 0;
	ELSE
		Flag_IntPaidThrouDate_Blank = 1;	

	IF InterestPaidThroughDate < &batch_begin_month. AND InterestPaidThroughDate NOT IN (0,.) then 
		Flag_IntPaidThrouDate_Past = 0;
	ELSE
		Flag_IntPaidThrouDate_Past = 1;
		
	IF PrincipalNextDueDate < &batch_begin_month. then 
		Flag_PrincNxtDueDat_Past = 0;
	ELSE
		Flag_PrincNxtDueDat_Past = 1;

	IF PrincipalPaidThroughDate = . then 
		Flag_PrincPaidThrouDate_Blank = 0;
	ELSE
		Flag_PrincPaidThrouDate_Blank = 1;	

	IF PrincipalPaidThroughDate < &batch_begin_month. AND PrincipalPaidThroughDate NOT IN (0,.) then 
		Flag_PrincPaidThrouDate_Past = 0;
	ELSE
		Flag_PrincPaidThrouDate_Past = 1;

	IF MaturityDate = 99991231 AND Demand_Flag = 0 then 
		Flag_MaturityDate_DefaultVal = 0;
	ELSE
		Flag_MaturityDate_DefaultVal = 1;	
	
	IF DIInternalRiskRating = "" AND MRA_LOAN_ID NOT IN (0,.) then 
		Flag_DIInternalRisk = 0;
	ELSE
		Flag_DIInternalRisk = 1;
	
	IF OriginationDate > &batch. then 
		Flag_OriginationDate = 0;
	ELSE
		Flag_OriginationDate = 1;

	IF InterestRateSpread = 0 then 
		Flag_InterestRateSpread = 0;
	ELSE
		Flag_InterestRateSpread = 1;
	
	IF InterestRateFloor = -99 then 
		Flag_InterestRateFloor = 0;
	ELSE
		Flag_InterestRateFloor = 1;	

	IF InterestRateCap = -99 then 
		Flag_InterestRateCap = 0;
	ELSE
		Flag_InterestRateCap = 1;	

	IF DrawPeriodEndDate = . AND DrawdownType NE "1" then 
		Flag_DrawPeriodEndDate_Blank = 0;
	ELSE
		Flag_DrawPeriodEndDate_Blank = 1;

	IF CollateralType = . then 
		Flag_CollateralType = 0;
	ELSE
		Flag_CollateralType = 1;	

	IF MostRecentDSCR = . AND MRA_LOAN_ID NOT IN (0,.) then 
		Flag_MostRecentDSCR = 0;
	ELSE
		Flag_MostRecentDSCR = 1;

	IF DateofMostRecentDSCR = . AND MRA_LOAN_ID NOT IN (0,.) then 
		Flag_DateofMostRecentDSCR = 0;
	ELSE
		Flag_DateofMostRecentDSCR = 1;

	IF DSCRatOrigination = . AND MRA_LOAN_ID NOT IN (0,.) then 
		Flag_DSCRatOrigination = 0;
	ELSE
		Flag_DSCRatOrigination = 1;

	IF MostRecentLTVCLTV = . AND subsystem = "CLS" then 
		Flag_MostRecentLTV_Blanks = 0;
	ELSE
		Flag_MostRecentLTV_Blanks = 1;

	IF MostRecentLTVCLTV > 1.2 then 
		Flag_MostRecentLTV_High = 0;
	ELSE
		Flag_MostRecentLTV_High = 1;

	IF LTVCLTVatOrigination = . then 
		Flag_LTVatOrig_Blanks = 0;
	ELSE
		Flag_LTVatOrig_Blanks = 1;

	IF LTVCLTVatOrigination > 1.2 then 
		Flag_LTVatOrig_High = 0;
	ELSE
		Flag_LTVatOrig_High = 1;

	IF CollateralLocationZipCode = "" then 
		Flag_CollatLocZipCode = 0;
	ELSE
		Flag_CollatLocZipCode = 1;	
run;


/************Commercial Data Quality Table************/
data DQ_Commercial_Flags;
set PLEDGED.CL_FINAL;
	IF ObligorName = "" then 
		Flag_ObligorName = 0;
	ELSE
		Flag_ObligorName = 1;

	IF obligorcity = "" then 
		Flag_obligorcity = 0;
	ELSE
		Flag_obligorcity = 1;

	IF ObligorCountry NOT IN ("", "US") AND 
	(CCDESC_H10_Source =: 'COMMERCIAL' OR CCDESC_H10_Source =: 'CORPORATE') then
		Flag_ObligorCountry_Foreign = 0;
	ELSE
		Flag_ObligorCountry_Foreign = 1;

	IF ObligorCountry = "" then 
		Flag_ObligorCountry = 0;
	ELSE
		Flag_ObligorCountry = 1;

	IF MasterNoteReferenceNumber = "" AND Subsystem NOT IN ("ALS", "DFP") then 
		Flag_MasterNoteRef = 0;
	ELSE
		Flag_MasterNoteRef = 1;

	IF PrincipalPaymentFrequency = "N" then 
		Flag_PrincPayFreq_N = 0;
	ELSE
		Flag_PrincPayFreq_N = 1;

	IF InterestNextDueDate = . then 
		Flag_Interest_Null = 0;
	ELSE
		Flag_Interest_Null = 1;	

	IF InterestNextDueDate < &batch_begin_month. then 
		Flag_Intst_Date_in_Past = 0;
	ELSE
		Flag_Intst_Date_in_Past = 1;

	IF InterestNextDueDate >= &batch_begin_month. AND InterestNextDueDate < &batch. then 
		Flag_Intst_Date_in_Past2 = 0;
	ELSE
		Flag_Intst_Date_in_Past2 = 1;

	IF InterestPaidThroughDate = . then 
		Flag_IntPaidThrouDate_Blank = 0;
	ELSE
		Flag_IntPaidThrouDate_Blank = 1;	

	IF InterestPaidThroughDate < &batch_begin_month. AND InterestPaidThroughDate NOT IN (0,.) then 
		Flag_IntPaidThrouDate_Past = 0;
	ELSE
		Flag_IntPaidThrouDate_Past = 1;
		
	IF PrincipalNextDueDate < &batch_begin_month. then 
		Flag_PrincNxtDueDat_Past = 0;
	ELSE
		Flag_PrincNxtDueDat_Past = 1;

	IF PrincipalPaidThroughDate = . then 
		Flag_PrincPaidThrouDate_Blank = 0;
	ELSE
		Flag_PrincPaidThrouDate_Blank = 1;	

	IF PrincipalPaidThroughDate < &batch_begin_month. AND PrincipalPaidThroughDate NOT IN (0,.) then 
		Flag_PrincPaidThrouDate_Past = 0;
	ELSE
		Flag_PrincPaidThrouDate_Past = 1;

	IF InterestRate = 0 then 
		Flag_InterestRate_Zero = 0;
	ELSE
		Flag_InterestRate_Zero = 1;	

	IF InterestRate > 20 then 
		Flag_InterestRate_High = 0;
	ELSE
		Flag_InterestRate_High = 1;	

	IF MaturityDate = 99991231 AND Demand_Flag = 0 then 
		Flag_MaturityDate_DefaultVal = 0;
	ELSE
		Flag_MaturityDate_DefaultVal = 1;	
	
	IF DIInternalRiskRating = "" AND MRA_LOAN_ID NOT IN (0,.) then 
		Flag_DIInternalRisk = 0;
	ELSE
		Flag_DIInternalRisk = 1;

	IF OriginationDate > &batch. then 
		Flag_OriginationDate = 0;
	ELSE
		Flag_OriginationDate = 1;

	IF InterestRateSpread = 0 then 
		Flag_InterestRateSpread = 0;
	ELSE
		Flag_InterestRateSpread = 1;
	
	IF InterestRateFloor = -99 then 
		Flag_InterestRateFloor = 0;
	ELSE
		Flag_InterestRateFloor = 1;	

	IF InterestRateCap = -99 then 
		Flag_InterestRateCap = 0;
	ELSE
		Flag_InterestRateCap = 1;	

	IF DrawPeriodEndDate = . AND DrawdownType NE "1" then 
		Flag_DrawPeriodEndDate_Blank = 0;
	ELSE
		Flag_DrawPeriodEndDate_Blank = 1;

	IF MostRecentLeverage = . then 
		Flag_MostRecLeve_Blank = 0;
	ELSE
		Flag_MostRecLeve_Blank = 1;

	IF MostRecentLeverage = 0 then 
		Flag_MostRecLeve_Zeros = 0;
	ELSE
		Flag_MostRecLeve_Zeros = 1;

	IF MostRecentLeverage <= 0.01 AND MostRecentLeverage NOT IN (.,0) then 
		Flag_MostRecLeve_Low = 0;
	ELSE
		Flag_MostRecLeve_Low = 1;

	IF LeverageAtOrigination = . then 
		Flag_LevAtOrig_Blank = 0;
	ELSE
		Flag_LevAtOrig_Blank = 1;

	IF LeverageAtOrigination = 0 then 
		Flag_LevAtOrig_Zeros = 0;
	ELSE
		Flag_LevAtOrig_Zeros = 1;

	IF LeverageAtOrigination <= 0.01 AND LeverageAtOrigination NOT IN (.,0) then 
		Flag_LevAtOrig_Low = 0;
	ELSE
		Flag_LevAtOrig_Low = 1;

	IF IndustryCode = "" then 
		Flag_IndustryCode = 0;
	ELSE
		Flag_IndustryCode = 1;
		
run;


/************Agricultural Data Quality Table************/
data DQ_Agricultural_Flags;
set PLEDGED.AGRICULTURAL_FINAL;

	IF PrincipalPaymentFrequency = "N" then 
		Flag_PrincPayFreq_N = 0;
	ELSE
		Flag_PrincPayFreq_N = 1;

	IF InterestNextDueDate = . then 
		Flag_Interest_Null = 0;
	ELSE
		Flag_Interest_Null = 1;	

	IF InterestNextDueDate < &batch_begin_month. then 
		Flag_Intst_Date_in_Past = 0;
	ELSE
		Flag_Intst_Date_in_Past = 1;

	IF InterestNextDueDate >= &batch_begin_month. AND InterestNextDueDate < &batch. then 
		Flag_Intst_Date_in_Past2 = 0;
	ELSE
		Flag_Intst_Date_in_Past2 = 1;

	IF InterestPaidThroughDate = . then 
		Flag_IntPaidThrouDate_Blank = 0;
	ELSE
		Flag_IntPaidThrouDate_Blank = 1;	

	IF InterestPaidThroughDate < &batch_begin_month. AND InterestPaidThroughDate NOT IN (0,.) then 
		Flag_IntPaidThrouDate_Past = 0;
	ELSE
		Flag_IntPaidThrouDate_Past = 1;
		
	IF PrincipalNextDueDate < &batch_begin_month. then 
		Flag_PrincNxtDueDat_Past = 0;
	ELSE
		Flag_PrincNxtDueDat_Past = 1;

	IF PrincipalPaidThroughDate = . then 
		Flag_PrincPaidThrouDate_Blank = 0;
	ELSE
		Flag_PrincPaidThrouDate_Blank = 1;	

	IF PrincipalPaidThroughDate < &batch_begin_month. AND PrincipalPaidThroughDate NOT IN (0,.) then 
		Flag_PrincPaidThrouDate_Past = 0;
	ELSE
		Flag_PrincPaidThrouDate_Past = 1;

	IF DIInternalRiskRating = "" AND MRA_LOAN_ID NOT IN (0,.) then 
		Flag_DIInternalRisk = 0;
	ELSE
		Flag_DIInternalRisk = 1;

	IF InterestRateSpread = 0 then 
		Flag_InterestRateSpread = 0;
	ELSE
		Flag_InterestRateSpread = 1;
	
	IF InterestRateFloor = -99 then 
		Flag_InterestRateFloor = 0;
	ELSE
		Flag_InterestRateFloor = 1;	

	IF InterestRateCap = -99 then 
		Flag_InterestRateCap = 0;
	ELSE
		Flag_InterestRateCap = 1;	
		
run;


/************Unsecured Consumer Data Quality Table************/
data DQ_Unsecured_Consu_Flags;
set PLEDGED.UnsecuredConsumerFinal;
	IF ObligorName = "" then 
		Flag_ObligorName = 0;
	ELSE
		Flag_ObligorName = 1;

	IF ObligorCountry = "" then 
		Flag_ObligorCountry = 0;
	ELSE
		Flag_ObligorCountry = 1;

	IF InterestNextDueDate = . then 
		Flag_Interest_Null = 0;
	ELSE
		Flag_Interest_Null = 1;	

	IF InterestNextDueDate < &batch_begin_month. then 
		Flag_Intst_Date_in_Past = 0;
	ELSE
		Flag_Intst_Date_in_Past = 1;

	IF InterestNextDueDate >= &batch_begin_month. AND InterestNextDueDate < &batch. then 
		Flag_Intst_Date_in_Past2 = 0;
	ELSE
		Flag_Intst_Date_in_Past2 = 1;

	IF InterestPaidThroughDate = . then 
		Flag_IntPaidThrouDate_Blank = 0;
	ELSE
		Flag_IntPaidThrouDate_Blank = 1;	

	IF InterestPaidThroughDate < &batch_begin_month. AND InterestPaidThroughDate NOT IN (0,.) then 
		Flag_IntPaidThrouDate_Past = 0;
	ELSE
		Flag_IntPaidThrouDate_Past = 1;
		
	IF PrincipalNextDueDate < &batch_begin_month. then 
		Flag_PrincNxtDueDat_Past = 0;
	ELSE
		Flag_PrincNxtDueDat_Past = 1;

	IF PrincipalPaidThroughDate = . then 
		Flag_PrincPaidThrouDate_Blank = 0;
	ELSE
		Flag_PrincPaidThrouDate_Blank = 1;	

	IF PrincipalPaidThroughDate < &batch_begin_month. AND PrincipalPaidThroughDate NOT IN (0,.) then 
		Flag_PrincPaidThrouDate_Past = 0;
	ELSE
		Flag_PrincPaidThrouDate_Past = 1;

	IF Balance > CURR_LINE and CURR_LINE ne 0 then 
		Flag_Balance_Greater_Line = 0;
	ELSE
		Flag_Balance_Greater_Line = 1;

	IF InterestRate = 0 then 
		Flag_InterestRate_Zero = 0;
	ELSE
		Flag_InterestRate_Zero = 1;	

	IF InterestRate > 20 then 
		Flag_InterestRate_High = 0;
	ELSE
		Flag_InterestRate_High = 1;	

	IF MaturityDate = 99991231 AND Demand_Flag = 0 then 
		Flag_MaturityDate_DefaultVal = 0;
	ELSE
		Flag_MaturityDate_DefaultVal = 1;	
	
	IF InterestRateSpread = 0 then 
		Flag_InterestRateSpread = 0;
	ELSE
		Flag_InterestRateSpread = 1;

	IF DrawPeriodEndDate = . AND DrawdownType NE "1" then 
		Flag_DrawPeriodEndDate_Blank = 0;
	ELSE
		Flag_DrawPeriodEndDate_Blank = 1;

	IF DrawPeriodEndDate = 99991231 then 
		Flag_DrawPeriodEndDate = 0;
	ELSE
		Flag_DrawPeriodEndDate = 1;

	IF MostRecentCreditBureauScore = 99 then 
		Flag_MostRecCreBureau_Def = 0;
	ELSE
		Flag_MostRecCreBureau_Def = 1;
	
	IF MostRecentCreditBureauScore = 0 then 
		Flag_MostRecCreBureau_Zer = 0;
	ELSE
		Flag_MostRecCreBureau_Zer = 1;

	IF DateMostRecCreditBurScore = . then 
		Flag_DateMostRecCreBureau = 0;
	ELSE
		Flag_DateMostRecCreBureau = 1;

	IF CreditBureauScoreAtOrigination = 0 then 
		Flag_CredBureauAtOrig = 0;
	ELSE
		Flag_CredBureauAtOrig = 1;

run;


/************Secured Consumer Data Quality Table************/
data DQ_Secured_Consu_Flags;
set PLEDGED.SecuredConsumerFinal;
	IF ObligorName = "" then 
		Flag_ObligorName = 0;
	ELSE
		Flag_ObligorName = 1;
	
	IF obligorcity = "" then 
		Flag_obligorcity = 0;
	ELSE
		Flag_obligorcity = 1;

	IF ObligorCountry = "" then 
		Flag_ObligorCountry = 0;
	ELSE
		Flag_ObligorCountry = 1;

	IF PrincipalPaymentFrequency = "N" then 
		Flag_PrincPayFreq_N = 0;
	ELSE
		Flag_PrincPayFreq_N = 1;

	IF InterestNextDueDate = . then 
		Flag_Interest_Null = 0;
	ELSE
		Flag_Interest_Null = 1;	

	IF InterestNextDueDate < &batch_begin_month. then 
		Flag_Intst_Date_in_Past = 0;
	ELSE
		Flag_Intst_Date_in_Past = 1;	

	IF InterestNextDueDate >= &batch_begin_month. AND InterestNextDueDate < &batch. then 
		Flag_Intst_Date_in_Past2 = 0;
	ELSE
		Flag_Intst_Date_in_Past2 = 1;

	IF InterestPaidThroughDate = . then 
		Flag_IntPaidThrouDate_Blank = 0;
	ELSE
		Flag_IntPaidThrouDate_Blank = 1;	

	IF InterestPaidThroughDate < &batch_begin_month. AND InterestPaidThroughDate NOT IN (0,.) then 
		Flag_IntPaidThrouDate_Past = 0;
	ELSE
		Flag_IntPaidThrouDate_Past = 1;
		
	IF PrincipalNextDueDate < &batch_begin_month. then 
		Flag_PrincNxtDueDat_Past = 0;
	ELSE
		Flag_PrincNxtDueDat_Past = 1;

	IF PrincipalPaidThroughDate = . then 
		Flag_PrincPaidThrouDate_Blank = 0;
	ELSE
		Flag_PrincPaidThrouDate_Blank = 1;	

	IF PrincipalPaidThroughDate < &batch_begin_month. AND PrincipalPaidThroughDate NOT IN (0,.) then 
		Flag_PrincPaidThrouDate_Past = 0;
	ELSE
		Flag_PrincPaidThrouDate_Past = 1;

	IF InterestRate = 0 then 
		Flag_InterestRate_Zero = 0;
	ELSE
		Flag_InterestRate_Zero = 1;	

	IF InterestRate > 20 then 
		Flag_InterestRate_High = 0;
	ELSE
		Flag_InterestRate_High = 1;	

	IF MaturityDate = 99991231 AND Demand_Flag = 0 then 
		Flag_MaturityDate_DefaultVal = 0;
	ELSE
		Flag_MaturityDate_DefaultVal = 1;	

	IF InterestRateSpread = 0 then 
		Flag_InterestRateSpread = 0;
	ELSE
		Flag_InterestRateSpread = 1;
	
	IF InterestRateFloor = -99 then 
		Flag_InterestRateFloor = 0;
	ELSE
		Flag_InterestRateFloor = 1;	

	IF InterestRateCap = -99 then 
		Flag_InterestRateCap = 0;
	ELSE
		Flag_InterestRateCap = 1;	

	IF DrawPeriodEndDate = . AND DrawdownType NE "1" then 
		Flag_DrawPeriodEndDate_Blank = 0;
	ELSE
		Flag_DrawPeriodEndDate_Blank = 1;

	IF CollateralType = . then 
		Flag_CollateralType = 0;
	ELSE
		Flag_CollateralType = 1;
	
	IF LTVCLTVatOrigination = 0 then 
		Flag_LTVatOrig_Zeros = 0;
	ELSE
		Flag_LTVatOrig_Zeros = 1;

	IF LTVCLTVatOrigination = . then 
		Flag_LTVatOrig_Blanks = 0;
	ELSE
		Flag_LTVatOrig_Blanks = 1;

	IF LTVCLTVatOrigination > 1.2 then 
		Flag_LTVatOrig_High = 0;
	ELSE
		Flag_LTVatOrig_High = 1;

	IF MostRecentCreditBureauScore = 0 then 
		Flag_MostRecCreBureau_Zer = 0;
	ELSE
		Flag_MostRecCreBureau_Zer = 1;

	IF MostRecentCreditBureauScore = . then 
		Flag_MostReCreBureau_Blank = 0;
	ELSE
		Flag_MostReCreBureau_Blank = 1;

	IF DateMostRecCreditBurScore = . then 
		Flag_DateMostRecCreBureau = 0;
	ELSE
		Flag_DateMostRecCreBureau = 1;

	IF CreditBureauScoreAtOrigination = 0 then 
		Flag_CredBureauAtOri_Zero = 0;
	ELSE
		Flag_CredBureauAtOri_Zero = 1;

	IF CreditBureauScoreAtOrigination = . then 
		Flag_CredBureauAtOri_Blank = 0;
	ELSE
		Flag_CredBureauAtOri_Blank = 1;

run;


/************US Agency Guaranteed Data Quality Table************/
data DQ_US_Agency_Guaranteed_Flags;
set PLEDGED.US_Agency_Guaranteed;

	IF PrincipalPaymentFrequency = "P" then 
		Flag_PrincPayFreq_P = 0;
	ELSE
		Flag_PrincPayFreq_P = 1;

	IF InterestNextDueDate = . then 
		Flag_Interest_Null = 0;
	ELSE
		Flag_Interest_Null = 1;	

	IF InterestNextDueDate < &batch_begin_month. then 
		Flag_Intst_Date_in_Past = 0;
	ELSE
		Flag_Intst_Date_in_Past = 1;	

	IF InterestNextDueDate >= &batch_begin_month. AND InterestNextDueDate < &batch. then 
		Flag_Intst_Date_in_Past2 = 0;
	ELSE
		Flag_Intst_Date_in_Past2 = 1;

	IF InterestPaidThroughDate = . then 
		Flag_IntPaidThrouDate_Blank = 0;
	ELSE
		Flag_IntPaidThrouDate_Blank = 1;	

	IF InterestPaidThroughDate < &batch_begin_month. AND InterestPaidThroughDate NOT IN (0,.) then 
		Flag_IntPaidThrouDate_Past = 0;
	ELSE
		Flag_IntPaidThrouDate_Past = 1;
		
	IF PrincipalNextDueDate < &batch_begin_month. then 
		Flag_PrincNxtDueDat_Past = 0;
	ELSE
		Flag_PrincNxtDueDat_Past = 1;

	IF PrincipalPaidThroughDate = . then 
		Flag_PrincPaidThrouDate_Blank = 0;
	ELSE
		Flag_PrincPaidThrouDate_Blank = 1;	

	IF PrincipalPaidThroughDate < &batch_begin_month. AND PrincipalPaidThroughDate NOT IN (0,.) then 
		Flag_PrincPaidThrouDate_Past = 0;
	ELSE
		Flag_PrincPaidThrouDate_Past = 1;

run;


/************Construction Data Quality Table************/
data DQ_Construction_Flags;
set PLEDGED.ConstructionLoansFinal;

	IF obligorcity = "" then 
		Flag_obligorcity = 0;
	ELSE
		Flag_obligorcity = 1;

	IF ObligorCountry NOT IN ("", "US") AND 
	(CCDESC_H10 =: 'COMMERCIAL' OR CCDESC_H10 =: 'CORPORATE') then
		Flag_ObligorCountry_Foreign = 0;
	ELSE
		Flag_ObligorCountry_Foreign = 1;

	IF ObligorCountry = "" then 
		Flag_ObligorCountry = 0;
	ELSE
		Flag_ObligorCountry = 1;

	IF MasterNoteReferenceNumber = "" AND Subsystem NE "ALS" then 
		Flag_MasterNoteRef = 0;
	ELSE
		Flag_MasterNoteRef = 1;

	IF PrincipalPaymentFrequency = "N" then 
		Flag_PrincPayFreq_N = 0;
	ELSE
		Flag_PrincPayFreq_N = 1;

	IF InterestNextDueDate = . then 
		Flag_Interest_Null = 0;
	ELSE
		Flag_Interest_Null = 1;	

	IF InterestNextDueDate < &batch_begin_month. then 
		Flag_Intst_Date_in_Past = 0;
	ELSE
		Flag_Intst_Date_in_Past = 1;	

	IF InterestNextDueDate >= &batch_begin_month. AND InterestNextDueDate < &batch. then 
		Flag_Intst_Date_in_Past2 = 0;
	ELSE
		Flag_Intst_Date_in_Past2 = 1;

	IF InterestPaidThroughDate = . then 
		Flag_IntPaidThrouDate_Blank = 0;
	ELSE
		Flag_IntPaidThrouDate_Blank = 1;	

	IF InterestPaidThroughDate < &batch_begin_month. AND InterestPaidThroughDate NOT IN (0,.) then 
		Flag_IntPaidThrouDate_Past = 0;
	ELSE
		Flag_IntPaidThrouDate_Past = 1;
		
	IF PrincipalNextDueDate < &batch_begin_month. then 
		Flag_PrincNxtDueDat_Past = 0;
	ELSE
		Flag_PrincNxtDueDat_Past = 1;

	IF PrincipalPaidThroughDate = . then 
		Flag_PrincPaidThrouDate_Blank = 0;
	ELSE
		Flag_PrincPaidThrouDate_Blank = 1;	

	IF PrincipalPaidThroughDate < &batch_begin_month. AND PrincipalPaidThroughDate NOT IN (0,.) then 
		Flag_PrincPaidThrouDate_Past = 0;
	ELSE
		Flag_PrincPaidThrouDate_Past = 1;

	IF MaturityDate = 99991231 AND Demand_Flag = 0 then 
		Flag_MaturityDate_DefaultVal = 0;
	ELSE
		Flag_MaturityDate_DefaultVal = 1;	
	
	IF DIInternalRiskRating = "" AND MRA_LOAN_ID NOT IN (0,.) then 
		Flag_DIInternalRisk = 0;
	ELSE
		Flag_DIInternalRisk = 1;
	
	IF OriginationDate > &batch. then 
		Flag_OriginationDate = 0;
	ELSE
		Flag_OriginationDate = 1;

	IF InterestRateSpread = 0 then 
		Flag_InterestRateSpread = 0;
	ELSE
		Flag_InterestRateSpread = 1;
	
	IF InterestRateFloor = -99 then 
		Flag_InterestRateFloor = 0;
	ELSE
		Flag_InterestRateFloor = 1;	

	IF InterestRateCap = -99 then 
		Flag_InterestRateCap = 0;
	ELSE
		Flag_InterestRateCap = 1;	

	IF CollateralLocationZipCode = "" then 
		Flag_CollatLocZipCode = 0;
	ELSE
		Flag_CollatLocZipCode = 1;

	IF CollateralLocationCountry = 0 AND CollateralLocationZipCode = "" then 
		Flag_CollatLocCountry = 0;
	ELSE
		Flag_CollatLocCountry = 1;
	
run;



/*Macro to perform the DQ of a Field of a Report*/
%Macro DQ_Report_Field(Report, Table, Field, DQ_Type, Check);

/*Summarize the Balance at Report, Field, Subsystem and Check Status Level*/
/*Table with new Balance information*/
proc sql;
	create table DQ_Balances_Insert_p as 
		select &Report. as Report, &Field. as Field, &DQ_Type. as DQ_Type,
			   Subsystem, &Check. as Check_Status,
			   count(*) as counting,
			   sum(Balance) as Balance
			from &Table.
				group by 1,2,3,4,5;
quit;

/*Table with information of total Balance to calculate the Balance % */
proc sql;
	create table DQ_Balances_Perc_Insert as 
		select &Report. as Report, &Field. as Field, 
			   &DQ_Type. as DQ_Type, Subsystem,
			   sum(Balance) as Balance_Tot
			from &Table.
				group by 1,2,3,4;
quit;

/*Calculating the Percentage of Balance*/
proc sql;
	create table DQ_Balances_Insert as
		select a.*, (a.Balance/b.Balance_Tot)*100 as Percentage_Balance
			from DQ_Balances_Insert_p a LEFT JOIN
				DQ_Balances_Perc_Insert b
					ON a.Report = b.Report AND a.Field = b.Field AND
						a.DQ_Type = b.DQ_Type AND a.Subsystem = b.Subsystem;
quit;


/*We insert it in our Template Table*/
data DQ_Balances;
set DQ_Balances DQ_Balances_Insert;
run;


/*Determine the Percentage that Passed the Check*/
proc sql;
	create table DQ_Percent_1_Insert as
		select &Report. as Report, &Field. as Field, &DQ_Type. as DQ_Type,
				Subsystem, 1 as Check_Passed,
				(sum(&Check.)/count(*))*100 as Percent_Passed
			from &Table.
				group by 1,2,3,4,5;
quit;

/*We insert it in our Template Table*/
data DQ_Percent_1;
set DQ_Percent_1 DQ_Percent_1_Insert;
run;


/*Determine the Percentage that did not Passed the Check*/
proc sql;
	create table DQ_Percent_0_Insert as
		select &Report. as Report, &Field. as Field, &DQ_Type. as DQ_Type,
				Subsystem, 0 as Check_Not_Passed,
				(1-(sum(&Check.)/count(*)))*100 as Percent_Not_Passed
			from &Table.
				group by 1,2,3,4,5;
quit;

/*We insert it in our Template Table*/
data DQ_Percent_0;
set DQ_Percent_0 DQ_Percent_0_Insert;
run;



%Mend;


/*Define Template table for Balance*/
proc sql;
	create table DQ_Balances
	(Report varchar(255),
	 Field varchar(255),
	 DQ_Type varchar(255),
	 Subsystem varchar(255),
	 Check_Status numeric,
	 counting numeric,
	 Balance numeric,
	 Percentage_Balance numeric
	);
quit;

/*Define Template table for DQ Percent Passed*/
proc sql;
	create table DQ_Percent_1
	(Report varchar(255),
	 Field varchar(255),
	 DQ_Type varchar(255),
	 Subsystem varchar(255),
	 Check_Passed numeric,
	 Percent_Passed numeric
	);
quit;


/*Define Template table for DQ Percent Not Passed*/
proc sql;
	create table DQ_Percent_0
	(Report varchar(255),
	 Field varchar(255),
	 DQ_Type varchar(255),
	 Subsystem varchar(255),
	 Check_Not_Passed numeric,
	 Percent_Not_Passed numeric
	);
quit;


/*Execution of the Data Quality*/

/*Calling DQ Report Field Macro*/
%DQ_Report_Field("CRE", DQ_Cre_Flags, "ObligorName", "Blanks", Flag_ObligorName);
%DQ_Report_Field("CRE", DQ_Cre_Flags, "ObligorCity", "Blanks", Flag_obligorcity);
%DQ_Report_Field("CRE", DQ_Cre_Flags, "ObligorCountry", "Foreign Country", Flag_ObligorCountry_Foreign);
%DQ_Report_Field("CRE", DQ_Cre_Flags, "ObligorCountry", "Blanks", Flag_ObligorCountry);
%DQ_Report_Field("CRE", DQ_Cre_Flags, "MasterNoteReferenceNumber", "Blanks", Flag_MasterNoteRef);
%DQ_Report_Field("CRE", DQ_Cre_Flags, "PrincipalPaymentFrequency", "No Freq", Flag_PrincPayFreq_N);
%DQ_Report_Field("CRE", DQ_Cre_Flags, "InterestNextDueDate", "Blanks", Flag_Interest_Null);
%DQ_Report_Field("CRE", DQ_Cre_Flags, "InterestNextDueDate", "In the Past", Flag_Intst_Date_in_Past);
%DQ_Report_Field("CRE", DQ_Cre_Flags, "InterestNextDueDate", "In the Past Current Month", Flag_Intst_Date_in_Past2);
%DQ_Report_Field("CRE", DQ_Cre_Flags, "InterestPaidThroughDate", "Blanks", Flag_IntPaidThrouDate_Blank);
%DQ_Report_Field("CRE", DQ_Cre_Flags, "InterestPaidThroughDate", "In the Past", Flag_IntPaidThrouDate_Past);
%DQ_Report_Field("CRE", DQ_Cre_Flags, "PrincipalNextDueDate", "In the Past", Flag_PrincNxtDueDat_Past);
%DQ_Report_Field("CRE", DQ_Cre_Flags, "PrincipalPaidThroughDate", "Blanks", Flag_PrincPaidThrouDate_Blank);
%DQ_Report_Field("CRE", DQ_Cre_Flags, "PrincipalPaidThroughDate", "In the Past", Flag_PrincPaidThrouDate_Past);
%DQ_Report_Field("CRE", DQ_Cre_Flags, "MaturityDate", "99991231 Value", Flag_MaturityDate_DefaultVal);
%DQ_Report_Field("CRE", DQ_Cre_Flags, "DIInternalRiskRating", "Blanks", Flag_DIInternalRisk);
%DQ_Report_Field("CRE", DQ_Cre_Flags, "OriginationDate", "In the Future", Flag_OriginationDate);
%DQ_Report_Field("CRE", DQ_Cre_Flags, "InterestRateSpread", "Zeros", Flag_InterestRateSpread);
%DQ_Report_Field("CRE", DQ_Cre_Flags, "InterestRateFloor", "-99 Value", Flag_InterestRateFloor);
%DQ_Report_Field("CRE", DQ_Cre_Flags, "InterestRateCap", "-99 Value", Flag_InterestRateCap);
%DQ_Report_Field("CRE", DQ_Cre_Flags, "DrawPeriodEndDate", "Blanks", Flag_DrawPeriodEndDate_Blank);
%DQ_Report_Field("CRE", DQ_Cre_Flags, "CollateralType", "Blanks", Flag_CollateralType);
%DQ_Report_Field("CRE", DQ_Cre_Flags, "MostRecentDSCR", "Blanks", Flag_MostRecentDSCR);
%DQ_Report_Field("CRE", DQ_Cre_Flags, "DateofMostRecentDSCR", "Blanks", Flag_DateofMostRecentDSCR);
%DQ_Report_Field("CRE", DQ_Cre_Flags, "DSCRatOrigination", "Blanks", Flag_DSCRatOrigination);
%DQ_Report_Field("CRE", DQ_Cre_Flags, "MostRecentLTVCLTV", "Blanks", Flag_MostRecentLTV_Blanks);
%DQ_Report_Field("CRE", DQ_Cre_Flags, "MostRecentLTVCLTV", ">120%", Flag_MostRecentLTV_High);
%DQ_Report_Field("CRE", DQ_Cre_Flags, "LTVCLTVatOrigination", "Blanks", Flag_LTVatOrig_Blanks);
%DQ_Report_Field("CRE", DQ_Cre_Flags, "LTVCLTVatOrigination", ">120%", Flag_LTVatOrig_High);
%DQ_Report_Field("CRE", DQ_Cre_Flags, "CollateralLocationZipCode", "Blanks", Flag_CollatLocZipCode);

%DQ_Report_Field("Commercial", DQ_Commercial_Flags, "ObligorName", "Blanks", Flag_ObligorName);
%DQ_Report_Field("Commercial", DQ_Commercial_Flags, "ObligorCity", "Blanks", Flag_obligorcity);
%DQ_Report_Field("Commercial", DQ_Commercial_Flags, "ObligorCountry", "Foreign Country", Flag_ObligorCountry_Foreign);
%DQ_Report_Field("Commercial", DQ_Commercial_Flags, "ObligorCountry", "Blanks", Flag_ObligorCountry);
%DQ_Report_Field("Commercial", DQ_Commercial_Flags, "MasterNoteReferenceNumber", "Blanks", Flag_MasterNoteRef);
%DQ_Report_Field("Commercial", DQ_Commercial_Flags, "PrincipalPaymentFrequency", "No Freq", Flag_PrincPayFreq_N);
%DQ_Report_Field("Commercial", DQ_Commercial_Flags, "InterestNextDueDate", "Blanks", Flag_Interest_Null);
%DQ_Report_Field("Commercial", DQ_Commercial_Flags, "InterestNextDueDate", "In the Past", Flag_Intst_Date_in_Past);
%DQ_Report_Field("Commercial", DQ_Commercial_Flags, "InterestNextDueDate", "In the Past Current Month", Flag_Intst_Date_in_Past2);
%DQ_Report_Field("Commercial", DQ_Commercial_Flags, "InterestPaidThroughDate", "Blanks", Flag_IntPaidThrouDate_Blank);
%DQ_Report_Field("Commercial", DQ_Commercial_Flags, "InterestPaidThroughDate", "In the Past", Flag_IntPaidThrouDate_Past);
%DQ_Report_Field("Commercial", DQ_Commercial_Flags, "PrincipalNextDueDate", "In the Past", Flag_PrincNxtDueDat_Past);
%DQ_Report_Field("Commercial", DQ_Commercial_Flags, "PrincipalPaidThroughDate", "Blanks", Flag_PrincPaidThrouDate_Blank);
%DQ_Report_Field("Commercial", DQ_Commercial_Flags, "PrincipalPaidThroughDate", "In the Past", Flag_PrincPaidThrouDate_Past);
%DQ_Report_Field("Commercial", DQ_Commercial_Flags, "InterestRate", "Zeros", Flag_InterestRate_Zero);
%DQ_Report_Field("Commercial", DQ_Commercial_Flags, "InterestRate", ">20%", Flag_InterestRate_High);
%DQ_Report_Field("Commercial", DQ_Commercial_Flags, "MaturityDate", "99991231 Value", Flag_MaturityDate_DefaultVal);
%DQ_Report_Field("Commercial", DQ_Commercial_Flags, "DIInternalRiskRating", "Blanks", Flag_DIInternalRisk);
%DQ_Report_Field("Commercial", DQ_Commercial_Flags, "OriginationDate", "In the Future", Flag_OriginationDate);
%DQ_Report_Field("Commercial", DQ_Commercial_Flags, "InterestRateSpread", "Zeros", Flag_InterestRateSpread);
%DQ_Report_Field("Commercial", DQ_Commercial_Flags, "InterestRateFloor", "-99 Value", Flag_InterestRateFloor);
%DQ_Report_Field("Commercial", DQ_Commercial_Flags, "InterestRateCap", "-99 Value", Flag_InterestRateCap);
%DQ_Report_Field("Commercial", DQ_Commercial_Flags, "DrawPeriodEndDate", "Blanks", Flag_DrawPeriodEndDate_Blank);
%DQ_Report_Field("Commercial", DQ_Commercial_Flags, "MostRecentLeverage", "Blanks", Flag_MostRecLeve_Blank);
%DQ_Report_Field("Commercial", DQ_Commercial_Flags, "MostRecentLeverage", "Zeros", Flag_MostRecLeve_Zeros);
%DQ_Report_Field("Commercial", DQ_Commercial_Flags, "MostRecentLeverage", "<1%", Flag_MostRecLeve_Low);
%DQ_Report_Field("Commercial", DQ_Commercial_Flags, "LeverageAtOrigination", "Blanks", Flag_LevAtOrig_Blank);
%DQ_Report_Field("Commercial", DQ_Commercial_Flags, "LeverageAtOrigination", "Zeros", Flag_LevAtOrig_Zeros);
%DQ_Report_Field("Commercial", DQ_Commercial_Flags, "LeverageAtOrigination", "<1%", Flag_LevAtOrig_Low);
%DQ_Report_Field("Commercial", DQ_Commercial_Flags, "IndustryCode", "Blanks", Flag_IndustryCode);

%DQ_Report_Field("Agricultural", DQ_Agricultural_Flags, "PrincipalPaymentFrequency", "No Freq", Flag_PrincPayFreq_N);
%DQ_Report_Field("Agricultural", DQ_Agricultural_Flags, "InterestNextDueDate", "Blanks", Flag_Interest_Null);
%DQ_Report_Field("Agricultural", DQ_Agricultural_Flags, "InterestNextDueDate", "In the Past", Flag_Intst_Date_in_Past);
%DQ_Report_Field("Agricultural", DQ_Agricultural_Flags, "InterestNextDueDate", "In the Past Current Month", Flag_Intst_Date_in_Past2);
%DQ_Report_Field("Agricultural", DQ_Agricultural_Flags, "InterestPaidThroughDate", "Blanks", Flag_IntPaidThrouDate_Blank);
%DQ_Report_Field("Agricultural", DQ_Agricultural_Flags, "InterestPaidThroughDate", "In the Past", Flag_IntPaidThrouDate_Past);
%DQ_Report_Field("Agricultural", DQ_Agricultural_Flags, "PrincipalNextDueDate", "In the Past", Flag_PrincNxtDueDat_Past);
%DQ_Report_Field("Agricultural", DQ_Agricultural_Flags, "PrincipalPaidThroughDate", "Blanks", Flag_PrincPaidThrouDate_Blank);
%DQ_Report_Field("Agricultural", DQ_Agricultural_Flags, "PrincipalPaidThroughDate", "In the Past", Flag_PrincPaidThrouDate_Past);
%DQ_Report_Field("Agricultural", DQ_Agricultural_Flags, "DIInternalRiskRating", "Blanks", Flag_DIInternalRisk);
%DQ_Report_Field("Agricultural", DQ_Agricultural_Flags, "InterestRateSpread", "Zeros", Flag_InterestRateSpread);
%DQ_Report_Field("Agricultural", DQ_Agricultural_Flags, "InterestRateFloor", "-99 Value", Flag_InterestRateFloor);
%DQ_Report_Field("Agricultural", DQ_Agricultural_Flags, "InterestRateCap", "-99 Value", Flag_InterestRateCap);

%DQ_Report_Field("Unsecured Consumer", DQ_Unsecured_Consu_Flags, "ObligorName", "Blanks", Flag_ObligorName);
%DQ_Report_Field("Unsecured Consumer", DQ_Unsecured_Consu_Flags, "ObligorCountry", "Blanks", Flag_ObligorCountry);
%DQ_Report_Field("Unsecured Consumer", DQ_Unsecured_Consu_Flags, "InterestNextDueDate", "Blanks", Flag_Interest_Null);
%DQ_Report_Field("Unsecured Consumer", DQ_Unsecured_Consu_Flags, "InterestNextDueDate", "In the Past", Flag_Intst_Date_in_Past);
%DQ_Report_Field("Unsecured Consumer", DQ_Unsecured_Consu_Flags, "InterestNextDueDate", "In the Past Current Month", Flag_Intst_Date_in_Past2);
%DQ_Report_Field("Unsecured Consumer", DQ_Unsecured_Consu_Flags, "InterestPaidThroughDate", "Blanks", Flag_IntPaidThrouDate_Blank);
%DQ_Report_Field("Unsecured Consumer", DQ_Unsecured_Consu_Flags, "InterestPaidThroughDate", "In the Past", Flag_IntPaidThrouDate_Past);
%DQ_Report_Field("Unsecured Consumer", DQ_Unsecured_Consu_Flags, "PrincipalNextDueDate", "In the Past", Flag_PrincNxtDueDat_Past);
%DQ_Report_Field("Unsecured Consumer", DQ_Unsecured_Consu_Flags, "PrincipalPaidThroughDate", "Blanks", Flag_PrincPaidThrouDate_Blank);
%DQ_Report_Field("Unsecured Consumer", DQ_Unsecured_Consu_Flags, "PrincipalPaidThroughDate", "In the Past", Flag_PrincPaidThrouDate_Past);
%DQ_Report_Field("Unsecured Consumer", DQ_Unsecured_Consu_Flags, "Balance", "Balance Greater than Current Line", Flag_Balance_Greater_Line);
%DQ_Report_Field("Unsecured Consumer", DQ_Unsecured_Consu_Flags, "InterestRate", "Zeros", Flag_InterestRate_Zero);
%DQ_Report_Field("Unsecured Consumer", DQ_Unsecured_Consu_Flags, "InterestRate", ">20%", Flag_InterestRate_High);
%DQ_Report_Field("Unsecured Consumer", DQ_Unsecured_Consu_Flags, "MaturityDate", "99991231 Value", Flag_MaturityDate_DefaultVal);
%DQ_Report_Field("Unsecured Consumer", DQ_Unsecured_Consu_Flags, "InterestRateSpread", "Zeros", Flag_InterestRateSpread);
%DQ_Report_Field("Unsecured Consumer", DQ_Unsecured_Consu_Flags, "DrawPeriodEndDate", "Blanks", Flag_DrawPeriodEndDate_Blank);
%DQ_Report_Field("Unsecured Consumer", DQ_Unsecured_Consu_Flags, "DrawPeriodEndDate", "99991231 Value", Flag_DrawPeriodEndDate);
%DQ_Report_Field("Unsecured Consumer", DQ_Unsecured_Consu_Flags, "MostRecentCreditBureauScore", "99 Value", Flag_MostRecCreBureau_Def);
%DQ_Report_Field("Unsecured Consumer", DQ_Unsecured_Consu_Flags, "MostRecentCreditBureauScore", "Zeros", Flag_MostRecCreBureau_Zer);
%DQ_Report_Field("Unsecured Consumer", DQ_Unsecured_Consu_Flags, "DateMostRecCreditBurScore", "Blanks", Flag_DateMostRecCreBureau);
%DQ_Report_Field("Unsecured Consumer", DQ_Unsecured_Consu_Flags, "CreditBureauScoreAtOrigination", "Zeros", Flag_CredBureauAtOrig);
	

%DQ_Report_Field("Secured Consumer", DQ_Secured_Consu_Flags, "ObligorName", "Blanks", Flag_ObligorName);
%DQ_Report_Field("Secured Consumer", DQ_Secured_Consu_Flags, "ObligorCity", "Blanks", Flag_obligorcity);
%DQ_Report_Field("Secured Consumer", DQ_Secured_Consu_Flags, "ObligorCountry", "Blanks", Flag_ObligorCountry);
%DQ_Report_Field("Secured Consumer", DQ_Secured_Consu_Flags, "PrincipalPaymentFrequency", "No Freq", Flag_PrincPayFreq_N);
%DQ_Report_Field("Secured Consumer", DQ_Secured_Consu_Flags, "InterestNextDueDate", "Blanks", Flag_Interest_Null);
%DQ_Report_Field("Secured Consumer", DQ_Secured_Consu_Flags, "InterestNextDueDate", "In the Past", Flag_Intst_Date_in_Past);
%DQ_Report_Field("Secured Consumer", DQ_Secured_Consu_Flags, "InterestNextDueDate", "In the Past Current Month", Flag_Intst_Date_in_Past2);
%DQ_Report_Field("Secured Consumer", DQ_Secured_Consu_Flags, "InterestPaidThroughDate", "Blanks", Flag_IntPaidThrouDate_Blank);
%DQ_Report_Field("Secured Consumer", DQ_Secured_Consu_Flags, "InterestPaidThroughDate", "In the Past", Flag_IntPaidThrouDate_Past);
%DQ_Report_Field("Secured Consumer", DQ_Secured_Consu_Flags, "PrincipalNextDueDate", "In the Past", Flag_PrincNxtDueDat_Past);
%DQ_Report_Field("Secured Consumer", DQ_Secured_Consu_Flags, "PrincipalPaidThroughDate", "Blanks", Flag_PrincPaidThrouDate_Blank);
%DQ_Report_Field("Secured Consumer", DQ_Secured_Consu_Flags, "PrincipalPaidThroughDate", "In the Past", Flag_PrincPaidThrouDate_Past);
%DQ_Report_Field("Secured Consumer", DQ_Secured_Consu_Flags, "InterestRate", "Zeros", Flag_InterestRate_Zero);
%DQ_Report_Field("Secured Consumer", DQ_Secured_Consu_Flags, "InterestRate", ">20%", Flag_InterestRate_High);
%DQ_Report_Field("Secured Consumer", DQ_Secured_Consu_Flags, "MaturityDate", "99991231 Value", Flag_MaturityDate_DefaultVal);
%DQ_Report_Field("Secured Consumer", DQ_Secured_Consu_Flags, "InterestRateSpread", "Zeros", Flag_InterestRateSpread);
%DQ_Report_Field("Secured Consumer", DQ_Secured_Consu_Flags, "InterestRateFloor", "-99 Value", Flag_InterestRateFloor);
%DQ_Report_Field("Secured Consumer", DQ_Secured_Consu_Flags, "InterestRateCap", "-99 Value", Flag_InterestRateCap);
%DQ_Report_Field("Secured Consumer", DQ_Secured_Consu_Flags, "DrawPeriodEndDate", "Blanks", Flag_DrawPeriodEndDate_Blank);
%DQ_Report_Field("Secured Consumer", DQ_Secured_Consu_Flags, "CollateralType", "Blanks", Flag_CollateralType);
%DQ_Report_Field("Secured Consumer", DQ_Secured_Consu_Flags, "LTVCLTVatOrigination", "Zeros", Flag_LTVatOrig_Zeros);
%DQ_Report_Field("Secured Consumer", DQ_Secured_Consu_Flags, "LTVCLTVatOrigination", "Blanks", Flag_LTVatOrig_Blanks);
%DQ_Report_Field("Secured Consumer", DQ_Secured_Consu_Flags, "LTVCLTVatOrigination", ">120%", Flag_LTVatOrig_High);
%DQ_Report_Field("Secured Consumer", DQ_Secured_Consu_Flags, "MostRecentCreditBureauScore", "Zeros", Flag_MostRecCreBureau_Zer);
%DQ_Report_Field("Secured Consumer", DQ_Secured_Consu_Flags, "MostRecentCreditBureauScore", "Blanks", Flag_MostReCreBureau_Blank);
%DQ_Report_Field("Secured Consumer", DQ_Secured_Consu_Flags, "DateMostRecCreditBurScore", "Blanks", Flag_DateMostRecCreBureau);
%DQ_Report_Field("Secured Consumer", DQ_Secured_Consu_Flags, "CreditBureauScoreAtOrigination", "Zeros", Flag_CredBureauAtOri_Zero);
%DQ_Report_Field("Secured Consumer", DQ_Secured_Consu_Flags, "CreditBureauScoreAtOrigination", "Blanks", Flag_CredBureauAtOri_Blank);
			

%DQ_Report_Field("US Agency Guaranteed", DQ_US_Agency_Guaranteed_Flags, "PrincipalPaymentFrequency", "P Value", Flag_PrincPayFreq_P);
%DQ_Report_Field("US Agency Guaranteed", DQ_US_Agency_Guaranteed_Flags, "InterestNextDueDate", "Blanks", Flag_Interest_Null);
%DQ_Report_Field("US Agency Guaranteed", DQ_US_Agency_Guaranteed_Flags, "InterestNextDueDate", "In the Past", Flag_Intst_Date_in_Past);
%DQ_Report_Field("US Agency Guaranteed", DQ_US_Agency_Guaranteed_Flags, "InterestNextDueDate", "In the Past Current Month", Flag_Intst_Date_in_Past2);
%DQ_Report_Field("US Agency Guaranteed", DQ_US_Agency_Guaranteed_Flags, "InterestPaidThroughDate", "Blanks", Flag_IntPaidThrouDate_Blank);
%DQ_Report_Field("US Agency Guaranteed", DQ_US_Agency_Guaranteed_Flags, "InterestPaidThroughDate", "In the Past", Flag_IntPaidThrouDate_Past);
%DQ_Report_Field("US Agency Guaranteed", DQ_US_Agency_Guaranteed_Flags, "PrincipalNextDueDate", "In the Past", Flag_PrincNxtDueDat_Past);
%DQ_Report_Field("US Agency Guaranteed", DQ_US_Agency_Guaranteed_Flags, "PrincipalPaidThroughDate", "Blanks", Flag_PrincPaidThrouDate_Blank);
%DQ_Report_Field("US Agency Guaranteed", DQ_US_Agency_Guaranteed_Flags, "PrincipalPaidThroughDate", "In the Past", Flag_PrincPaidThrouDate_Past);


%DQ_Report_Field("Construction", DQ_Construction_Flags, "ObligorCity", "Blanks", Flag_obligorcity);
%DQ_Report_Field("Construction", DQ_Construction_Flags, "ObligorCountry", "Foreign Country", Flag_ObligorCountry_Foreign);
%DQ_Report_Field("Construction", DQ_Construction_Flags, "ObligorCountry", "Blanks", Flag_ObligorCountry);
%DQ_Report_Field("Construction", DQ_Construction_Flags, "MasterNoteReferenceNumber", "Blanks", Flag_MasterNoteRef);
%DQ_Report_Field("Construction", DQ_Construction_Flags, "PrincipalPaymentFrequency", "No Freq", Flag_PrincPayFreq_N);
%DQ_Report_Field("Construction", DQ_Construction_Flags, "InterestNextDueDate", "Blanks", Flag_Interest_Null);
%DQ_Report_Field("Construction", DQ_Construction_Flags, "InterestNextDueDate", "In the Past", Flag_Intst_Date_in_Past);
%DQ_Report_Field("Construction", DQ_Construction_Flags, "InterestNextDueDate", "In the Past Current Month", Flag_Intst_Date_in_Past2);
%DQ_Report_Field("Construction", DQ_Construction_Flags, "InterestPaidThroughDate", "Blanks", Flag_IntPaidThrouDate_Blank);
%DQ_Report_Field("Construction", DQ_Construction_Flags, "InterestPaidThroughDate", "In the Past", Flag_IntPaidThrouDate_Past);
%DQ_Report_Field("Construction", DQ_Construction_Flags, "PrincipalNextDueDate", "In the Past", Flag_PrincNxtDueDat_Past);
%DQ_Report_Field("Construction", DQ_Construction_Flags, "PrincipalPaidThroughDate", "Blanks", Flag_PrincPaidThrouDate_Blank);
%DQ_Report_Field("Construction", DQ_Construction_Flags, "PrincipalPaidThroughDate", "In the Past", Flag_PrincPaidThrouDate_Past);
%DQ_Report_Field("Construction", DQ_Construction_Flags, "MaturityDate", "99991231 Value", Flag_MaturityDate_DefaultVal);
%DQ_Report_Field("Construction", DQ_Construction_Flags, "DIInternalRiskRating", "Blanks", Flag_DIInternalRisk);
%DQ_Report_Field("Construction", DQ_Construction_Flags, "OriginationDate", "In the Future", Flag_OriginationDate);
%DQ_Report_Field("Construction", DQ_Construction_Flags, "InterestRateSpread", "Zeros", Flag_InterestRateSpread);
%DQ_Report_Field("Construction", DQ_Construction_Flags, "InterestRateFloor", "-99 Value", Flag_InterestRateFloor);
%DQ_Report_Field("Construction", DQ_Construction_Flags, "InterestRateCap", "-99 Value", Flag_InterestRateCap);
%DQ_Report_Field("Construction", DQ_Construction_Flags, "CollateralLocationZipCode", "Blanks", Flag_CollatLocZipCode);
%DQ_Report_Field("Construction", DQ_Construction_Flags, "CollateralLocationCountry", "Zeros", Flag_CollatLocCountry);

	
		
/*Final Consolidation*/
proc sql;
create table PLEDGED.DQ_Consolid as
	select  a.Report as Portfolio, a.Field, a.DQ_Type, a.Subsystem, 
			(case when a.Check_Status = 1 then "OK"
				 when a.Check_Status = 0 then "NO OK" end) as Check_Status, 
			a.counting as Count_Rows,
			coalesce(b.Percent_Passed, c.Percent_Not_Passed) as Percentage_Rows format = 6.2, 
			a.Balance format = comma18.2,
			a.Percentage_Balance format = 6.2
		from DQ_Balances a 
			LEFT JOIN DQ_Percent_1 b
			ON a.Report = b.Report AND a.Field = b.Field AND a.DQ_Type = b.DQ_Type AND
				a.Subsystem=b.Subsystem AND a.Check_Status = b.Check_Passed
			LEFT JOIN DQ_Percent_0 c
			ON a.Report = c.Report AND a.Field = c.Field AND a.DQ_Type = c.DQ_Type AND
				a.Subsystem=c.Subsystem AND a.Check_Status = c.Check_Not_Passed
			order by a.Report, a.Field, a.DQ_Type, a.Subsystem, a.Check_Status;
quit;

/*Exporting*/
%exportXLSX(PLEDGED.DQ_Consolid,
/SAS_RiskModelDev/SAS_FSB/Pledged loans/Data_Quality.xlsx,
DQ);




/*****************************************************************/
/*************************DQ Analysis*****************************/
/*****************************************************************/

/*Selecting Fields that didn't pass the DQ*/
proc sql;
create table DQ_Consolid_Columns as
	select distinct Portfolio, Field
		from PLEDGED.DQ_Consolid
			where Check_Status = "NO OK";
quit;


/*Agricultural*/
proc contents 
data=PLEDGED.AGRICULTURAL_FINAL
(keep=ObligationNumber ObligorNumber ObligorName ObligorCity ObligorState ObligorCountry MasterNoteReferenceNumber MASTERNOTEORIGBAL MasterNoteCurrCommAm MASTERNOTEMATDATE InterestFrequency PrincipalPaymentFrequency InterestNextDueDate InterestPaidThroughDate PrincipalNextDueDate PrincipalPaidThroughDate Balance InterestRate MaturityDate FXFLFlag DIInternalRiskRating OriginationDate OriginalBalance AmortizationStartDate AmortizationEndDate InterestRateIndex InterestRateSpread InterestRateCap InterestRateFloor CollateralizedFlag CallReportCode IndustryCode IndustryCodeType) 
out=Agri_Names1(keep=NAME rename=(NAME = Field));
run;

data Agri_Names2;
format Portfolio;
format Field;
set Agri_Names1;
	Portfolio = "Agricultural";
run;

proc sql;
	create table Agri_Columns_DQ_p as
		select a.*, 
				case when b.Portfolio NE "" AND b.Field NE "" then
						0 else 1 end as Pass_DQ 
			from Agri_Names2 a LEFT JOIN DQ_Consolid_Columns b
				ON a.Portfolio = b.Portfolio AND a.Field = b.Field;
quit;


data Agri_Columns_DQ_p2;
set Agri_Columns_DQ_p;
	format Status_DQ $30.;
	IF (Pass_DQ = 1) THEN
		DO;
			Status_DQ  ="OK";
		END;
	ELSE
		DO;
			IF Field IN ("PrincipalPaymentFrequency",
						"InterestNextDueDate","InterestPaidThroughDate",
						"PrincipalNextDueDate","PrincipalPaidThroughDate",
						"InterestRate", "InterestRateCap","InterestRateFloor",
						"LTVCLTVatOrigination","MostRecentLTVCLTV",
						"MostRecentLeverage","LeverageAtOrigination") THEN
				Status_DQ  ="NO OK - Treasury Logic";
			ELSE
				Status_DQ  ="NO OK - Format";
		END;
run;

proc sql;
	create table Agri_Columns_DQ as
		select Status_DQ, count(*) as Counting
			from Agri_Columns_DQ_p2
				group by 1
				order by 1 desc;
quit;


/*Exporting Agricultural*/
%exportXLSX(Agri_Columns_DQ,
/SAS_RiskModelDev/SAS_FSB/Pledged loans/DQ_TypeLogic_Impact.xlsx,
Agricultural);


/*Commercial*/
proc contents 
data=PLEDGED.CL_FINAL
(keep=ObligationNumber ObligorNumber ObligorName ObligorCity ObligorState ObligorCountry MasterNoteReferenceNumber MasterNoteOrigBalComm MasterNoteCurrCommAm MasterNoteMaturityDate InterestFrequency PrincipalPaymentFrequency InterestNextDueDate InterestPaidThroughDate PrincipalNextDueDate PrincipalPaidThroughDate Balance InterestRate MaturityDate FXFLFlag DIInternalRiskRating OriginationDate OriginalBalance CurrentCommitment AmortizationStartDate AmortizationEndDate InterestRateIndex InterestRateSpread InterestRateCap InterestRateFloor DrawdownType DrawPeriodEndDate ResidualValue MostRecentLeverage DataMostRecentLeverage LeverageAtOrigination CollateralizedFlag CallReportCode IndustryCode IndustryCodeType) 
out=Commercial_Names1(keep=NAME rename=(NAME = Field));
run;

data Commercial_Names2;
format Portfolio;
format Field;
set Commercial_Names1;
	Portfolio = "Commercial";
run;

proc sql;
	create table Commercial_Columns_DQ_p as
		select a.*, 
				case when b.Portfolio NE "" AND b.Field NE "" then
						0 else 1 end as Pass_DQ 
			from Commercial_Names2 a LEFT JOIN DQ_Consolid_Columns b
				ON a.Portfolio = b.Portfolio AND a.Field = b.Field;
quit;


data Commercial_Columns_DQ_p2;
set Commercial_Columns_DQ_p;
	format Status_DQ $30.;
	IF (Pass_DQ = 1) THEN
		DO;
			Status_DQ  ="OK";
		END;
	ELSE
		DO;
			IF Field IN ("PrincipalPaymentFrequency",
						"InterestNextDueDate","InterestPaidThroughDate",
						"PrincipalNextDueDate","PrincipalPaidThroughDate",
						"InterestRate", "InterestRateCap","InterestRateFloor",
						"LTVCLTVatOrigination","MostRecentLTVCLTV",
						"MostRecentLeverage","LeverageAtOrigination") THEN
				Status_DQ  ="NO OK - Treasury Logic";
			ELSE
				Status_DQ  ="NO OK - Format";
		END;
run;

proc sql;
	create table Commercial_Columns_DQ as
		select Status_DQ, count(*) as Counting
			from Commercial_Columns_DQ_p2
				group by 1
				order by 1 desc;
quit;

/*Exporting Commercial*/
%exportXLSX(Commercial_Columns_DQ,
/SAS_RiskModelDev/SAS_FSB/Pledged loans/DQ_TypeLogic_Impact.xlsx,
Commercial);


/*CRE*/
proc contents 
data=PLEDGED.CRE_FINAL
(keep=ObligationNumber ObligorNumber ObligorName ObligorCity ObligorState ObligorCountry MasterNoteReferenceNumber MasterNoteOrigBalComm MasterNoteCurrCommAm MasterNoteMaturityDate InterestFrequency PrincipalPaymentFrequency InterestNextDueDate InterestPaidThroughDate PrincipalNextDueDate PrincipalPaidThroughDate Balance InterestRate MaturityDate FXFLFlag DIInternalRiskRating OriginationDate OriginalBalance CurrentCommitment AmortizationStartDate AmortizationEndDate InterestRateIndex InterestRateSpread InterestRateCap InterestRateFloor PrepayLockoutEndDate DrawdownType DrawPeriodEndDate CollateralType MostRecentDSCR DateofMostRecentDSCR DSCRatOrigination MostRecentLTVCLTV DateofMostRecentLTVCLTV LTVCLTVatOrigination CallReportCode CollateralLocationZipCode CollateralLocationCountry)
out=CRE_Names1(keep=NAME rename=(NAME = Field));
run;

data CRE_Names2;
format Portfolio;
format Field;
set CRE_Names1;
	Portfolio = "CRE";
run;

proc sql;
	create table CRE_Columns_DQ_p as
		select a.*, 
				case when b.Portfolio NE "" AND b.Field NE "" then
						0 else 1 end as Pass_DQ 
			from CRE_Names2 a LEFT JOIN DQ_Consolid_Columns b
				ON a.Portfolio = b.Portfolio AND a.Field = b.Field;
quit;

data CRE_Columns_DQ_p2;
set CRE_Columns_DQ_p;
	format Status_DQ $30.;
	IF (Pass_DQ = 1) THEN
		DO;
			Status_DQ  ="OK";
		END;
	ELSE
		DO;
			IF Field IN ("PrincipalPaymentFrequency",
						"InterestNextDueDate","InterestPaidThroughDate",
						"PrincipalNextDueDate","PrincipalPaidThroughDate",
						"InterestRate", "InterestRateCap","InterestRateFloor",
						"LTVCLTVatOrigination","MostRecentLTVCLTV",
						"MostRecentLeverage","LeverageAtOrigination") THEN
				Status_DQ  ="NO OK - Treasury Logic";
			ELSE
				Status_DQ  ="NO OK - Format";
		END;
run;

proc sql;
	create table CRE_Columns_DQ as
		select Status_DQ, count(*) as Counting
			from CRE_Columns_DQ_p2
				group by 1
				order by 1 desc;
quit;


/*Exporting CRE*/
%exportXLSX(CRE_Columns_DQ,
/SAS_RiskModelDev/SAS_FSB/Pledged loans/DQ_TypeLogic_Impact.xlsx,
CRE);


/*Unsecured*/
proc contents 
data=PLEDGED.UnsecuredConsumerFinal
(keep=ObligationNumber ObligorNumber ObligorName ObligorCity ObligorState ObligorCountry InterestFrequency PrincipalPaymentFrequency InterestNextDueDate InterestPaidThroughDate PrincipalNextDueDate PrincipalPaidThroughDate Balance InterestRate MaturityDate FXFLFlag OriginationDate OriginalBalance InterestRateIndex InterestRateSpread DrawdownType DrawPeriodEndDate MostRecentCreditBureauScore DateMostRecCreditBurScore CreditBureauScoreAtOrigination CallReportCode)
out=Unsecured_Names1(keep=NAME rename=(NAME = Field));
run;

data Unsecured_Names2;
format Portfolio;
format Field;
set Unsecured_Names1;
	Portfolio = "Unsecured Consumer";
run;

proc sql;
	create table Unsecured_Columns_DQ_p as
		select a.*, 
				case when b.Portfolio NE "" AND b.Field NE "" then
						0 else 1 end as Pass_DQ 
			from Unsecured_Names2 a LEFT JOIN DQ_Consolid_Columns b
				ON a.Portfolio = b.Portfolio AND a.Field = b.Field;
quit;

data Unsecured_Columns_DQ_p2;
set Unsecured_Columns_DQ_p;
	format Status_DQ $30.;
	IF (Pass_DQ = 1) THEN
		DO;
			Status_DQ  ="OK";
		END;
	ELSE
		DO;
			IF Field IN ("PrincipalPaymentFrequency",
						"InterestNextDueDate","InterestPaidThroughDate",
						"PrincipalNextDueDate","PrincipalPaidThroughDate",
						"InterestRate", "InterestRateCap","InterestRateFloor",
						"LTVCLTVatOrigination","MostRecentLTVCLTV",
						"MostRecentLeverage","LeverageAtOrigination") THEN
				Status_DQ  ="NO OK - Treasury Logic";
			ELSE
				Status_DQ  ="NO OK - Format";
		END;
run;

proc sql;
	create table Unsecured_Columns_DQ as
		select Status_DQ, count(*) as Counting
			from Unsecured_Columns_DQ_p2
				group by 1
				order by 1 desc;
quit;

/*Exporting Unsecured*/
%exportXLSX(Unsecured_Columns_DQ,
/SAS_RiskModelDev/SAS_FSB/Pledged loans/DQ_TypeLogic_Impact.xlsx,
Unsecured);



/*Secured*/
proc contents 
data=PLEDGED.SecuredConsumerFinal
(keep=ObligationNumber ObligorNumber ObligorName ObligorCity ObligorState ObligorCountry InterestFrequency PrincipalPaymentFrequency InterestNextDueDate InterestPaidThroughDate PrincipalNextDueDate PrincipalPaidThroughDate Balance InterestRate MaturityDate FXFLFlag OriginationDate OriginalBalance InterestRateIndex InterestRateSpread InterestRateCap InterestRateFloor DrawdownType DrawPeriodEndDate CollateralType MostRecentLTVCLTV DateofMostRecentLTVCLTV LTVCLTVatOrigination MostRecentCreditBureauScore DateMostRecCreditBurScore CreditBureauScoreAtOrigination CallReportCode)
out=Secured_Names1(keep=NAME rename=(NAME = Field));
run;

data Secured_Names2;
format Portfolio;
format Field;
set Secured_Names1;
	Portfolio = "Secured Consumer";
run;

proc sql;
	create table Secured_Columns_DQ_p as
		select a.*, 
				case when b.Portfolio NE "" AND b.Field NE "" then
						0 else 1 end as Pass_DQ 
			from Secured_Names2 a LEFT JOIN DQ_Consolid_Columns b
				ON a.Portfolio = b.Portfolio AND a.Field = b.Field;
quit;

data Secured_Columns_DQ_p2;
set Secured_Columns_DQ_p;
	format Status_DQ $30.;
	IF (Pass_DQ = 1) THEN
		DO;
			Status_DQ  ="OK";
		END;
	ELSE
		DO;
			IF Field IN ("PrincipalPaymentFrequency",
						"InterestNextDueDate","InterestPaidThroughDate",
						"PrincipalNextDueDate","PrincipalPaidThroughDate",
						"InterestRate", "InterestRateCap","InterestRateFloor",
						"LTVCLTVatOrigination","MostRecentLTVCLTV",
						"MostRecentLeverage","LeverageAtOrigination") THEN
				Status_DQ  ="NO OK - Treasury Logic";
			ELSE
				Status_DQ  ="NO OK - Format";
		END;
run;

proc sql;
	create table Secured_Columns_DQ as
		select Status_DQ, count(*) as Counting
			from Secured_Columns_DQ_p2
				group by 1
				order by 1 desc;
quit;


/*Exporting Secured*/
%exportXLSX(Secured_Columns_DQ,
/SAS_RiskModelDev/SAS_FSB/Pledged loans/DQ_TypeLogic_Impact.xlsx,
Secured);


/*US Agency Guaranteed*/
proc contents 
data=PLEDGED.US_Agency_Guaranteed
(keep=ObligationNumber ObligorNumber ObligorName ObligorCity ObligorState ObligorCountry MasterNoteReferenceNumber MasterNoteOrigBalComm MasterNoteCurrCommAm MasterNoteMaturityDate InterestFrequency PrincipalPaymentFrequency InterestNextDueDate InterestPaidThroughDate PrincipalNextDueDate PrincipalPaidThroughDate Balance InterestRate MaturityDate FXFLFlag OriginationDate OriginalBalance AmortizationStartDate AmortizationEndDate CallReportCode IndustryCode IndustryCodeType)
out=Guaranteed_Names1(keep=NAME rename=(NAME = Field));
run;

data Guaranteed_Names2;
format Portfolio;
format Field;
set Guaranteed_Names1;
	Portfolio = "US Agency Guaranteed";
run;

proc sql;
	create table Guaranteed_Columns_DQ_p as
		select a.*, 
				case when b.Portfolio NE "" AND b.Field NE "" then
						0 else 1 end as Pass_DQ 
			from Guaranteed_Names2 a LEFT JOIN DQ_Consolid_Columns b
				ON a.Portfolio = b.Portfolio AND a.Field = b.Field;
quit;

data Guaranteed_Columns_DQ_p2;
set Guaranteed_Columns_DQ_p;
	format Status_DQ $30.;
	IF (Pass_DQ = 1) THEN
		DO;
			Status_DQ  ="OK";
		END;
	ELSE
		DO;
			IF Field IN ("PrincipalPaymentFrequency",
						"InterestNextDueDate","InterestPaidThroughDate",
						"PrincipalNextDueDate","PrincipalPaidThroughDate",
						"InterestRate", "InterestRateCap","InterestRateFloor",
						"LTVCLTVatOrigination","MostRecentLTVCLTV",
						"MostRecentLeverage","LeverageAtOrigination") THEN
				Status_DQ  ="NO OK - Treasury Logic";
			ELSE
				Status_DQ  ="NO OK - Format";
		END;
run;

proc sql;
	create table Guaranteed_Columns_DQ as
		select Status_DQ, count(*) as Counting
			from Guaranteed_Columns_DQ_p2
				group by 1
				order by 1 desc;
quit;


/*Exporting Guaranteed*/
%exportXLSX(Guaranteed_Columns_DQ,
/SAS_RiskModelDev/SAS_FSB/Pledged loans/DQ_TypeLogic_Impact.xlsx,
Guaranteed);


/*Construction*/
proc contents 
data=PLEDGED.ConstructionLoansFinal
(keep=ObligationNumber ObligorNumber ObligorName ObligorCity ObligorState ObligorCountry MasterNoteReferenceNumber MasterNoteOrigBalComm MasterNoteCurrCommAm MasterNoteMaturityDate InterestFrequency PrincipalPaymentFrequency InterestNextDueDate InterestPaidThroughDate PrincipalNextDueDate PrincipalPaidThroughDate Balance InterestRate MaturityDate FXFLFlag DIInternalRiskRating OriginationDate OriginalBalance AmortizationStartDate AmortizationEndDate InterestRateIndex InterestRateSpread InterestRateCap InterestRateFloor CallReportCode CollateralLocationZipCode CollateralLocationCountry)
out=Construction_Names1(keep=NAME rename=(NAME = Field));
run;

data Construction_Names2;
format Portfolio;
format Field;
set Construction_Names1;
	Portfolio = "Construction";
run;

proc sql;
	create table Construction_Columns_DQ_p as
		select a.*, 
				case when b.Portfolio NE "" AND b.Field NE "" then
						0 else 1 end as Pass_DQ 
			from Construction_Names2 a LEFT JOIN DQ_Consolid_Columns b
				ON a.Portfolio = b.Portfolio AND a.Field = b.Field;
quit;

data Construction_Columns_DQ_p2;
set Construction_Columns_DQ_p;
	format Status_DQ $30.;
	IF (Pass_DQ = 1) THEN
		DO;
			Status_DQ  ="OK";
		END;
	ELSE
		DO;
			IF Field IN ("PrincipalPaymentFrequency",
						"InterestNextDueDate","InterestPaidThroughDate",
						"PrincipalNextDueDate","PrincipalPaidThroughDate",
						"InterestRate", "InterestRateCap","InterestRateFloor",
						"LTVCLTVatOrigination","MostRecentLTVCLTV",
						"MostRecentLeverage","LeverageAtOrigination") THEN
				Status_DQ  ="NO OK - Treasury Logic";
			ELSE
				Status_DQ  ="NO OK - Format";
		END;
run;

proc sql;
	create table Construction_Columns_DQ as
		select Status_DQ, count(*) as Counting
			from Construction_Columns_DQ_p2
				group by 1
				order by 1 desc;
quit;


/*Exporting Constructions*/
%exportXLSX(Construction_Columns_DQ,
/SAS_RiskModelDev/SAS_FSB/Pledged loans/DQ_TypeLogic_Impact.xlsx,
Constructions);





/*Ordering by most relevant DQ results*/
proc sql;
	create table DQ_Consolid_Non_Checks as
		select *
			from PLEDGED.DQ_Consolid
				where Check_Status = "NO OK"
					order by Percentage_Balance desc;
quit;

/*Aggregated DQ dropping the report*/
proc sql;
	create table DQ_Consolid_Without_Report as
		select Field, DQ_Type, Subsystem,
				sum(Percentage_Balance) as Percentage_Balance format = 6.2
			from PLEDGED.DQ_Consolid
				where Check_Status = "NO OK"
					group by 1,2,3
					order by Percentage_Balance desc;
quit;




/*Generating some SAMPLES of DQ not passed*/

/*1) PrincipalPaidThroughDate and InterestPaidThroughDate in the Past for ALS and DFP*/
data DQ_Samples_Dates_Past_ALS;
format Report $30.;
set PLEDGED.ConstructionLoansFinal(obs=10);
	Report = "Construction";
	where (Subsystem = "ALS" AND PrincipalPaidThroughDate < &batch_begin_month. AND PrincipalPaidThroughDate NOT IN (0,.));
run;

/*2) PrincipalPaidThroughDate and InterestPaidThroughDate zeros for CLS*/
data DQ_Samples_Dates_Blank_CLS;
format Report $30.;
set PLEDGED.CRE_FINAL(obs=10);
	Report = "CRE";
	where (Subsystem = "CLS" AND PrincipalPaidThroughDate = .);
run;

/*3) InterestRateFloor -99 Value*/
data DQ_Samp_InterestRateFloor_cls;
format Report $30.;
set PLEDGED.CL_FINAL(obs=4);
	Report = "Commercial";
	where subsystem = "CLS" AND InterestRateFloor = -99;
run;

data DQ_Samp_InterestRateFloor_als;
format Report $30.;
set PLEDGED.CL_FINAL(obs=3);
	Report = "Commercial";
	where subsystem = "ALS" AND InterestRateFloor = -99;
run;

data DQ_Samp_InterestRateFloor_dfp;
format Report $30.;
set PLEDGED.CL_FINAL(obs=3);
	Report = "Commercial";
	where subsystem = "DFP" AND InterestRateFloor = -99;
run;

/*Consolidating CLS, ALS and DFP*/
data DQ_Samples_InterestRateFloor;
set DQ_Samp_InterestRateFloor_cls DQ_Samp_InterestRateFloor_als DQ_Samp_InterestRateFloor_dfp;
run;

/*4) InterestRateCap -99 Value for DFP*/
data DQ_Samples_IntRatCap_DFP;
format Report $30.;
set PLEDGED.CL_FINAL(obs=10);
	Report = "Commercial";
	where subsystem = "DFP" AND InterestRateCap = -99;
run;


/*5) PrincipalPaymentFrequency with no Freq*/
data DQ_Samples_PrincipPaymtFreq_DFP;
format Report $30.;
set PLEDGED.CL_FINAL(obs=5);
	Report = "Commercial";
	where subsystem = "DFP" AND PrincipalPaymentFrequency ="N";
run;

data DQ_Samples_PrincipPaymtFreq_CLS;
format Report $30.;
set PLEDGED.CL_FINAL(obs=5);
	Report = "Commercial";
	where subsystem = "CLS" AND PrincipalPaymentFrequency ="N";
run;

data DQ_Samples_PrincPymtFreq_DFP_CLS;
set DQ_Samples_PrincipPaymtFreq_DFP DQ_Samples_PrincipPaymtFreq_CLS;
run;


/*6) PrincipalPaymentFrequency with Freq = "P"*/
data DQ_Samples_PrincPymtFreq_SBA;
format Report $30.;
set PLEDGED.US_Agency_Guaranteed (obs=10);
	Report = "US Agency Guaranteed";
	where PrincipalPaymentFrequency ="P";
run;


/*7) MostRecentLeverage Blanks and LeverageAtOrigination Blanks
For Commercial Report*/
data DQ_Samples_Leverage_CLS;
format Report $30.;
set PLEDGED.CL_FINAL(obs=4);
	Report = "Commercial";
	where Subsystem = "CLS" AND MostRecentLeverage = . AND LeverageAtOrigination = .;
run; 

data DQ_Samples_Leverage_ALS;
format Report $30.;
set PLEDGED.CL_FINAL(obs=4);
	Report = "Commercial";
	where Subsystem = "ALS" AND MostRecentLeverage = . AND LeverageAtOrigination = .;
run; 

data DQ_Samples_Leverage_DFP;
format Report $30.;
set PLEDGED.CL_FINAL(obs=3);
	Report = "Commercial";
	where Subsystem = "DFP" AND MostRecentLeverage = . AND LeverageAtOrigination = .;
run; 

data DQ_Samples_Leverage;
set DQ_Samples_Leverage_CLS DQ_Samples_Leverage_ALS DQ_Samples_Leverage_DFP;
run;


/*8) DateofMostRecentDSCR, MostRecentDSCR and DSCRatOrigination
For CRE Report*/
data DQ_Samples_DSCR_ALS;
format Report $30.;
set PLEDGED.CRE_FINAL(obs=5);
	Report = "CRE";
	where subsystem = "ALS" AND 
			DateofMostRecentDSCR = . AND MostRecentDSCR = . AND DSCRatOrigination = . AND
			MRA_LOAN_ID NOT IN (0,.);
run;

data DQ_Samples_DSCR_CLS;
format Report $30.;
set PLEDGED.CRE_FINAL(obs=5);
	Report = "CRE";
	where subsystem = "CLS" AND 
			DateofMostRecentDSCR = . AND MostRecentDSCR = . AND DSCRatOrigination = . AND
			MRA_LOAN_ID NOT IN (0,.);
run;

data DQ_Samples_DSCR;
set DQ_Samples_DSCR_ALS DQ_Samples_DSCR_CLS;
run;


/*9) LTVCLTVatOrigination >120%*/
proc sql;
	create table SecuredConsumerFinal_order as
		select *
			from PLEDGED.SecuredConsumerFinal
				order by LTVCLTVatOrigination desc;
quit;

data DQ_Samples_LTVCLTVatOrig;
format Report $30.;
set SecuredConsumerFinal_order(obs=10);
	Report = "Secured Consumer";
	where LTVCLTVatOrigination>1.2;
run;


/*10) IndustryCode Blanks*/
data DQ_Samples_IndustryCode;
format Report $30.;
set PLEDGED.CL_FINAL(obs=10);
	Report = "Commercial";
	where Subsystem = "CLS" AND IndustryCode = "";
run; 


/*11) DateMostRecCreditBurScore Blanks*/
data DQ_Samples_DateMostRecCreditBur;
format Report $30.;
set PLEDGED.UnsecuredConsumerFinal(obs=10);
	Report = "Unsecured Consumer";
	where DateMostRecCreditBurScore = .;
run;


/*12) InterestPaidThroughDate and PrincipalPaidThroughDate in the Past*/
data DQ_Samples_Date_In_Past_Constr;
format Report $30.;
set PLEDGED.ConstructionLoansFinal(obs=10);
	Report = "Construction";
	where InterestPaidThroughDate < &batch_begin_month. AND InterestPaidThroughDate NE 0;
run;


/*13) InterestNextDueDate In the Past Current Month*/
data DQ_Samples_Date_In_Past_Current;
format Report $30.;
set PLEDGED.SecuredConsumerFinal (obs=10);
	Report = "Secured Consumer";
	where InterestNextDueDate >= &batch_begin_month. AND InterestNextDueDate < &batch.;
run;



/*Exporting all Samples*/

/*1)*/
%exportXLSX(DQ_Samples_Dates_Past_ALS,
/SAS_RiskModelDev/SAS_FSB/Pledged loans/DQ_Samples.xlsx,
DateInPast_ALS);

%exportXLSX(DQ_Samples_Dates_Blank_CLS,
/SAS_RiskModelDev/SAS_FSB/Pledged loans/DQ_Samples.xlsx,
Dates_Blank_CLS);

%exportXLSX(DQ_Samples_InterestRateFloor,
/SAS_RiskModelDev/SAS_FSB/Pledged loans/DQ_Samples.xlsx,
InterestRateFloor);

%exportXLSX(DQ_Samples_IntRatCap_DFP,
/SAS_RiskModelDev/SAS_FSB/Pledged loans/DQ_Samples.xlsx,
InterestRateCap);

/*5*/
%exportXLSX(DQ_Samples_PrincPymtFreq_DFP_CLS,
/SAS_RiskModelDev/SAS_FSB/Pledged loans/DQ_Samples.xlsx,
NoFrequency_DFP_CLS);

%exportXLSX(DQ_Samples_PrincPymtFreq_SBA,
/SAS_RiskModelDev/SAS_FSB/Pledged loans/DQ_Samples.xlsx,
NoFrequency_SBA);

%exportXLSX(DQ_Samples_Leverage,
/SAS_RiskModelDev/SAS_FSB/Pledged loans/DQ_Samples.xlsx,
Leverage_Blanks);

%exportXLSX(DQ_Samples_DSCR,
/SAS_RiskModelDev/SAS_FSB/Pledged loans/DQ_Samples.xlsx,
DSCR_Blanks);

%exportXLSX(DQ_Samples_LTVCLTVatOrig,
/SAS_RiskModelDev/SAS_FSB/Pledged loans/DQ_Samples.xlsx,
LTVCLTVatOrig);

/*10*/
%exportXLSX(DQ_Samples_IndustryCode,
/SAS_RiskModelDev/SAS_FSB/Pledged loans/DQ_Samples.xlsx,
IndustryCode);

%exportXLSX(DQ_Samples_DateMostRecCreditBur,
/SAS_RiskModelDev/SAS_FSB/Pledged loans/DQ_Samples.xlsx,
DateMostRecCreditBur);

%exportXLSX(DQ_Samples_Date_In_Past_Constr,
/SAS_RiskModelDev/SAS_FSB/Pledged loans/DQ_Samples.xlsx,
DatesInPast_Construction);

%exportXLSX(DQ_Samples_Date_In_Past_Current,
/SAS_RiskModelDev/SAS_FSB/Pledged loans/DQ_Samples.xlsx,
DatesInPast_Current_Month);



/*Analysis at DQ_Type type to make a Graph*/
proc sql;
	create table DQ_Consolid_Type as
		select Portfolio, Subsystem, DQ_Type, 
				sum(Percentage_Balance) as Percentage_Balance format = 6.2
			from PLEDGED.DQ_Consolid
				where Check_Status = "NO OK"
					group by 1,2,3
					order by 1,2,3;
quit;

/*Exporting*/
%exportXLSX(DQ_Consolid_Type,
/SAS_RiskModelDev/SAS_FSB/Pledged loans/DQ_Graphs.xlsx,
DQ_Type);