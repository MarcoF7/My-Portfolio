/*********************************************************************/
/*********************************************************************/
/*********************************************************************/
/*********************************************************************/
					/*Importar Base Emisiones*/
/*********************************************************************/
/*********************************************************************/
/*********************************************************************/
/*********************************************************************/

%PUT job "Importar_Emisiones_Liq.sas" comenzó a %now;
/**/
* Se asigna el nombre lógico del fichero;
%let Nombre_Logico_Input = Base_Emisiones_Liq;

/** Se busca la ruta física en la tabla "FICHEROS_INPUT";*/
data _NULL_;
	set FICHEROS_INPUT;

	if Nombre_Logico_Fichero = "&Nombre_Logico_Input." then do;
		call symput('Ruta_input_a_cargar', trim(Ruta));
	end;
run;

data &biblioteca..Salida_Emisiones_Liq;
	set "&dir_ficheros_orig.&Ruta_input_a_cargar";

run;

/*********************************************************************/
/*********************************************************************/
/*********************************************************************/
/*********************************************************************/
					/*Importar Base Depositos*/
/*********************************************************************/
/*********************************************************************/
/*********************************************************************/
/*********************************************************************/

%PUT job "Importar_Depositos_Liq.sas" comenzó a %now;
/**/
* Se asigna el nombre lógico del fichero;
%let Nombre_Logico_Input = Base_Depositos_Liq;

/** Se busca la ruta física en la tabla "FICHEROS_INPUT";*/
data _NULL_;
	set FICHEROS_INPUT;

	if Nombre_Logico_Fichero = "&Nombre_Logico_Input." then do;
		call symput('Ruta_input_a_cargar', trim(Ruta));
	end;
run;

data &biblioteca..Salida_Depositos_Liq;
	set "&dir_ficheros_orig.&Ruta_input_a_cargar";

run;

/*********************************************************************/
/*********************************************************************/
/*********************************************************************/
/*********************************************************************/
					/*Importar Base Credito Clientela*/
/*********************************************************************/
/*********************************************************************/
/*********************************************************************/
/*********************************************************************/

%PUT job "Importar_Credito_Liq.sas" comenzó a %now;
/**/
* Se asigna el nombre lógico del fichero;
%let Nombre_Logico_Input = Base_Credito_Clientela_Liq;

/** Se busca la ruta física en la tabla "FICHEROS_INPUT";*/
data _NULL_;
	set FICHEROS_INPUT;

	if Nombre_Logico_Fichero = "&Nombre_Logico_Input." then do;
		call symput('Ruta_input_a_cargar', trim(Ruta));
	end;
run;

data &biblioteca..Salida_Credito_Liq;
	set "&dir_ficheros_orig.&Ruta_input_a_cargar";

run;


/*********************************************************************/
/*********************************************************************/
/*********************************************************************/
/*********************************************************************/
					/*Importar Base Credito Derivados*/
/*********************************************************************/
/*********************************************************************/
/*********************************************************************/
/*********************************************************************/

%PUT job "Importar_Derivados_Liq.sas" comenzó a %now;
/**/
* Se asigna el nombre lógico del fichero;
%let Nombre_Logico_Input = Base_Derivados_Liq;

/** Se busca la ruta física en la tabla "FICHEROS_INPUT";*/
data _NULL_;
	set FICHEROS_INPUT;

	if Nombre_Logico_Fichero = "&Nombre_Logico_Input." then do;
		call symput('Ruta_input_a_cargar', trim(Ruta));
	end;
run;

data &biblioteca..Anexos8_Derivados_Liq;
	set "&dir_ficheros_orig.&Ruta_input_a_cargar";
run;