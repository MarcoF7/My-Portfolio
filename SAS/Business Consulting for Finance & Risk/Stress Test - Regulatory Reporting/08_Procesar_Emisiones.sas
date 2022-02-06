/*PASO 1: SE HOMOLOGAN LOS CAMPOS STRESS TEST*/
DATA EMISIONES_INSTRUMENTO;
	SET &BIBLIOTECA..SALIDA_EMISIONES_LIQ;
	G001 = "&FECHAREPORTE";
	G002 = "&SOCIEDAD_INFORMANTE";
	G003="06";
	G004='';
	G005='';
	G006='';
	OFICINA='0639';
	G010='';
	G011='';
	G013='';
	G014='';
	G016=DIVISA;
	G017='F';
	G018='N';
	G020='';
	G021='';
	G022='';
	G023='';
	G024='';
	G026='';
	A002=.;
	A003=.;
	A004=.;
	A005=.;
	A006=.;
	A008=.;
RUN;

/*PASO 2: SE TIENE QUE CONTRAVALORAR EL SALDO CONTABLE BRUTO DE SOLES A EUROS*/
PROC SQL;
	CREATE TABLE EMISIONES_EUROS
		AS 

		SELECT A.*,A.SALDO_CONTRAVALORADO*B.TIPO_CAMBIO_EUR  AS SALDO_CONTRAVALORADO_EUR
			FROM
				EMISIONES_INSTRUMENTO A
				,
				TIPO_DE_CAMBIO B 
			WHERE COMPRESS(UPCASE(B.DIVISA))='PEN';
QUIT;

/*PASO 3: SE HOMOLOGA LA MARCA DE INTERGRUPO*/
DATA EMISIONES_MINTERGRUPO;
	SET EMISIONES_EUROS;

	IF INTERCOMPANY ='Tercero' THEN
		G012= 'TER';
	ELSE  
		G012='INT';
RUN;

/*PASO 4: SE HOMOLOGA EL CAMPO PRODUCTO DEPOSITO*/
PROC SQL;
	CREATE TABLE EMISIONES_PRODUCTO AS 
		SELECT 
			A.*,
			B.VALOR_PRODUCTO AS G015
		FROM
			EMISIONES_MINTERGRUPO A 
		LEFT JOIN
			&BIBLIOTECA..H_PRODUCTO_EMISIONES B
			ON
			A.PRODUCTO=B.PRODUCTO
	;
QUIT;

/*PASO 5: ADICIONALMENTE SE TIENE QUE HOMOLOGAR LA CUENTAS BAF*/
PROC SQL;
	CREATE TABLE EMISIONES_BAF AS
		SELECT A.* ,B.VALOR_PRODUCTO
			FROM
				EMISIONES_PRODUCTO A 
			LEFT JOIN
				&BIBLIOTECA..H_PRODUCTO_EMISIONES_BAF B 
				ON A.CTA_NOMINAL LIKE B.CUENTA_CONTABLE;
QUIT;

/*PASO 6: SE SOBREESCRIBE*/
DATA EMISONES_PRODUCTO_DEF(DROP=VALOR_PRODUCTO);
	SET EMISIONES_BAF;

	IF VALOR_PRODUCTO NE'' THEN
		G015=VALOR_PRODUCTO;
RUN;

/*PASO7: SE OBTIENE EL TRAMOS TIPO DE INTERES*/
PROC SQL;
	CREATE TABLE EMISIONES_TRAMO_INT AS 
		SELECT 
			A.*,
			B.TIPO_TRAMO AS G019

		FROM
			EMISONES_PRODUCTO_DEF A
		LEFT JOIN
			&BIBLIOTECA..H_TRAMOS_TIPO B
			ON
			A.TASA>B.COTA_INFERIOR 
			AND 
			A.TASA<=B.COTA_SUPERIOR;
QUIT;

/*PASO 8: SE HOMOLOGA SALDO CONTRAVALORADO*/
DATA EMISIONES_SALDO;
	SET EMISIONES_TRAMO_INT;
	A001=(SALDO_CONTRAVALORADO_EUR);
RUN;

/*PASO 9: SE CALCULA EL PROMEDIO DE VENCIMIENTO*/
DATA EMISIONES_VENC_PRO(DROP= INTERES_ANUAL NUMERO_DIAS_PRORRATEO);
	SET EMISIONES_SALDO;
	A007= (FECHA_VENCIMIENTO-'FECHA CONTRATACION'N )/365;

	* SE PREPARA EL CAMPO PARA LOS INTERESES;
	INTERES_ANUAL = TASA/100 * SALDO_CONTRAVALORADO_EUR;

	IF YEAR('FECHA CONTRATACION'N) < 2015 THEN
		DO;
			NUMERO_DIAS_PRORRATEO = 365;
		END;
	ELSE
		DO;
			NUMERO_DIAS_PRORRATEO = &ONEMONTHAGO - 'FECHA CONTRATACION'N;
		END;

	A009 = ROUND(INTERES_ANUAL * (NUMERO_DIAS_PRORRATEO/365)/1000000,.01);
/*SE HOMOLOGA EL CAMPO NEW_BUSINESS*/
	IF 'FECHA CONTRATACION'N=SUBSTR("&FECHAREPORTE",1,4) THEN 
	G025='S';ELSE G025='N';
RUN;

/*PASO 10: SE HOMOLOGA EL EPIGRAFE*/
PROC SQL;
	CREATE TABLE EMISIONES_EPIGRAFE AS 
		SELECT A.*,B.'EPIGRAFE LOCAL'N AS G009
			FROM EMISIONES_VENC_PRO A
				LEFT JOIN
					Epigrafe_CContable_Format_dis B 
					ON A.CTA_NOMINAL =B.CUENTA;
QUIT;

/*PASO 11: DAMOS FORMATO A LA CUENTA NEOCON*/
DATA EMISIONES_EPIGRAFE2 (DROP=CTAGESTIONBBV RENAME=(CTAGESTIONBBV2 = CTAGESTIONBBV));
SET EMISIONES_EPIGRAFE;
	FORMAT CTAGESTIONBBV2 5.;
	CTAGESTIONBBV2 = INPUT(CTAGESTIONBBV,$5.);
RUN;

/*PASO 12: SE TIENE QUE HOMOLOGAR LO DE EMISIONES QUE PASAN A DEPOSITOS*/
PROC SQL;
	CREATE TABLE EMISIONES_DEPOSITOS AS 
		SELECT A.*,
		CASE WHEN B.INSTRUMENTO NE '' THEN B.INSTRUMENTO ELSE "" END AS INSTRUMENTO_DEP,
		CASE WHEN B.SEGMENTO_FINREP NE '' THEN B.SEGMENTO_FINREP ELSE "" END AS SEGMENTO_DEP,
		CASE WHEN B.PRODUCTO_DEPOSITOS NE '' THEN B.PRODUCTO_DEPOSITOS ELSE "" END AS PRODUCTO_DEP
			FROM
				EMISIONES_EPIGRAFE2 A 
			LEFT JOIN
				&BIBLIOTECA..H_DEPOSITOS_SUBORDINADOS B
				ON
				A.CTAGESTIONBBV=B.CUENTA_NEOCON;
QUIT;

/*PASO 13: SE HOMOLOGA INSTRUMENTO Y SEGMENTO*/
DATA EMISIONES_DEPOSITOS_H;
	FORMAT G014 $3.;
	FORMAT G004 $5.;
	SET EMISIONES_DEPOSITOS;

	IF INSTRUMENTO_DEP NE '' THEN
		G003=INSTRUMENTO_DEP;

	IF SEGMENTO_DEP NE '' THEN
		G004=SEGMENTO_DEP;

	IF PRODUCTO_DEP NE '' THEN
		DO;
			G014 =PRODUCTO_DEP;
			G015='';
		END;
RUN;

/*PASO 14: NUEVOS CAMPOS Y FORMATOS STRESS TEST*/
DATA EMISIONES_FLUJOS_HOMOLO (DROP= INSTRUMENTO); /*G003 YA SERA EL INSTRUMENTO*/
	SET EMISIONES_DEPOSITOS_H;
	FORMAT CUENTA_NEOCON $5.;
	G028='';
	SECTOR_CONTRAPARTE = ""; /*SECTOR CONTRAPARTE ES PARA FINREP Y LIQUIDEZ*/
	TIPOREF = .; /*EMISIONES NO TIENEN TASA REFERENCIA*/

	CUENTA_NEOCON = PUT(CTAGESTIONBBV, 5.);
	A001=ABS(A001);
RUN;

/*PASO 15: SE OBTIENE EL TRAMO DE VENCIMIENTO ORIGINAL*/
DATA EMISIONES_VTORIGINAL;
	SET EMISIONES_FLUJOS_HOMOLO;
	FORMAT C1014 $2.;
	FORMAT FE_REV DDMMYY10.;
	SPREAD = .; /* G023 SE PUSO A '' , SPREAD SOLO SE DEFINE PARA ACTIVOS*/
	FE_REV = .;

	IF VTO_ORIGINAL <=365 THEN
		G030='01';
	ELSE IF VTO_ORIGINAL>365 AND VTO_ORIGINAL<=730 THEN
		G030='02';
	ELSE G030='03';
	C1014 = G015; /*TIPO DE EMISI�N FINREP, ES G015*/
RUN;

/*PASO 16: SE CARGA LA FECHA DE BAJA DE INVENTARIOS MIS*/
PROC SQL;
	CREATE TABLE EMISIONES_PREVIO1 AS
		SELECT	 A.*, B.FECANCEL
			FROM EMISIONES_VTORIGINAL A LEFT JOIN INVENTARIOS_MIS_SALDO_FECANCEL B
				ON A.CONTRATO =  B.CONTRATO;				
QUIT;

/*PASO 17: SE DA FORMATO A LAS FECHAS Y RENOMBRA CAMPOS*/
DATA EMISIONES_PREVIO2 
(
DROP=FECANCEL
RENAME=(FECANCEL2 = FECANCEL G003=INSTRUMENTO G004 = SEGMENTO_FINREP G013 = PROD_PRESTAMOS G014 = PROD_DEPOSITOS
	  	 G015 = PROD_EMIRF G025 = INDNEWBUS));
SET EMISIONES_PREVIO1;

/*SE HALLAN LOS INDICADORES QUE PIDEN EN EL REQUERIMIENTO AGREGADO*/
	
	IF (FECANCEL = "00010101") THEN
		FECANCEL = "";

	FECANCEL2 = INPUT(FECANCEL,YYMMDD8.);
	FORMAT FECANCEL2 DATE10.;
RUN;

/*PASO 18: SE HOMOLOGA INDICADORES MATURING BUSINESS Y OPERATIVA VIVA*/
DATA EMISIONES_PREVIO3;
SET EMISIONES_PREVIO2;
	FORMAT INDOPERVIVA $1.;
	FORMAT INDMATBUS $1.;
	INDOPERVIVA = "V"; 
	ANIODATOS = SUBSTR(G001,1,4);

	IF(ANIODATOS = YEAR(FECANCEL)) THEN
		DO;
			INDMATBUS = "S";
			A001 = 0; /*LAS OPERATIVAS VENCIDAS NO DEBEN TENER SALDO PUNTUAL A CIERRE DE MES*/
			INDOPERVIVA = "F";
		END;	
	ELSE	
		INDMATBUS = "N";
RUN;		


/*PASO 19: TRATAMIENTO DEL MARGEN FINANCIERO*/
/*PASO 19.1: SE CARGA EL MARGEN FINANCIERO SEGUN EL F16 EN SOLES*/
PROC SQL;
	CREATE TABLE MARGEN_EMI AS
		SELECT SUM(MARGEN_SOLES) AS SUM_MARGEN_EMI
			FROM &BIBLIOTECA..MARGEN_EMISIONES;
QUIT;

/*PASO 19.2: ES INSERTADO EN UNA MACROVARIABLE*/
DATA _NULL_;
SET MARGEN_EMI;
	IF (_N_ = 1) THEN
		DO;
			CALL SYMPUT('MARGEN_EMI_TOT', TRIM(SUM_MARGEN_EMI));
		END;
RUN;

/*PASO 19.3: SE CALCULA EL SALDO TOTAL DE EMISIONES
EN SOLES (SOLO LOS SALDOS POSITIVOS)*/
PROC SQL;
	CREATE TABLE SALDO_TOT_EMI AS
		SELECT SUM(SALDO_CONTRAVALORADO) AS SALDO_CONTRAVALORADO_T
			FROM EMISIONES_PREVIO3
				WHERE(INSTRUMENTO = "06" AND SALDO_CONTRAVALORADO>=0);
QUIT;

/*PASO 19.4: SE ALMACENA EN UNA MACROVARIABLE*/
DATA _NULL_;
SET SALDO_TOT_EMI;
	IF (_N_ = 1) THEN
		DO;
			CALL SYMPUT('SALDO_EMISIONES_T', TRIM(SALDO_CONTRAVALORADO_T));
		END;
RUN;

/*PASO 19.5: SE A�ADE 2 NUEVAS COLUMNAS CON LOS VALORES CALCULADOS PREVIAMENTE*/
DATA EMISIONES_PREVIO3_MARG;
SET EMISIONES_PREVIO3;
	MARGEN_TOT_EMI = &MARGEN_EMI_TOT;
	SALDO_EMI_T = &SALDO_EMISIONES_T;
RUN;

/*PASO 19.6: SE DISTRIBUYE EL MARGEN PROPORCIONALMENTE AL SALDO CONTABLE*/
DATA EMISIONES_PREVIO3_MARG_CAL (DROP=MARGEN_TOT_EMI SALDO_EMI_T);
SET EMISIONES_PREVIO3_MARG;
		IF(INSTRUMENTO = "06" AND SALDO_CONTRAVALORADO>=0) THEN
			DO;
				MARGEN_FINANCIERO = (SALDO_CONTRAVALORADO/SALDO_EMI_T)*MARGEN_TOT_EMI;
			END;
		ELSE
			DO;
				MARGEN_FINANCIERO = 0;
			END;
RUN;

/*PASO 20: SE CONTRAVALORA A EUROS AL MARGEN, 
AL SALDO CONTABLE YA LO TENEMOS EN EUROS*/
PROC SQL;
	CREATE TABLE EMISIONES_PREVIO4
		AS 

		SELECT A.*, A.MARGEN_FINANCIERO*B.TIPO_CAMBIO_EUR AS MARGEN_FINANCIERO_EUR
			FROM
				EMISIONES_PREVIO3_MARG_CAL A
				,
				TIPO_DE_CAMBIO B 
			WHERE COMPRESS(UPCASE(B.DIVISA))='PEN';
QUIT;

/*PASO 21: ESTA LOGICA DE CALCULO DE MARGEN FINANCIERO ES SOLO PARA EMISIONES ("06")*/
DATA EMISIONES_PREVIO5;
SET EMISIONES_PREVIO4;
	IF (INSTRUMENTO = "06") THEN
		DO;
			MARGEN_FINANCIERO_EUR_F = MARGEN_FINANCIERO_EUR;
		END;
	ELSE
		DO;
			MARGEN_FINANCIERO_EUR_F = A009;
		END;
RUN;

/*PASO 22: SE SELECCIONA LOS CAMPOS EXIGIDOS A NIVEL CONTRATO*/
PROC SQL;
	CREATE TABLE EMISIONES_STRESS_2017_CONTR AS
		SELECT CONTRATO AS C0000 FORMAT = $18.,SECTOR_CONTRAPARTE AS C0001 FORMAT=$25., "" AS C0005 FORMAT = $1.,
			ABS(A001) AS C0016, G001 AS C0019,
			G002 AS C0020, INTERCOMPANY AS C0021, G016 AS C0022, G017 AS C0023, G018 AS C0024, G019 AS C0025,
			TASA AS C0026, G021 AS C0027, TIPOREF AS C0028, SPREAD AS C0029,
			G024 AS C0030, FE_REV AS C0038, 'FECHA CONTRATACION'N AS C0039, FECANCEL AS C0040,
			ABS(A002) AS C0041, FECHA_VENCIMIENTO AS C0050, G023 AS C0052, 
			MARGEN_FINANCIERO_EUR_F AS C0067,  . AS C0068,
			"PE" AS C0900, "PEN" AS C0901, "" AS C0973, G028 AS C1010 FORMAT = $2., C1014,

			CUENTA_NEOCON, CTA_NOMINAL AS CTA_CONTABLE,

			. AS PLAZOREF,INSTRUMENTO, SEGMENTO_FINREP FORMAT = $3., PROD_PRESTAMOS, PROD_DEPOSITOS, PROD_EMIRF, 
			"" AS PROD_DERIVADOS FORMAT = $2., INDNEWBUS, INDOPERVIVA, INDMATBUS, VTO_ORIGINAL AS DIAS, G012 AS MARCA_INTERGRUPO
		FROM 

			EMISIONES_PREVIO5 ;
QUIT;