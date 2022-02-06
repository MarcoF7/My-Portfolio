/*** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***/

/* PROGRAMA: 00_IHM_Credito_a_la_Clientela.sas
/* OBJETIVO: Punto de entrada al programa que inicializa variables,
/*			 lee y verifica los inputs y llama a los procesos
/*			 que generan las salidas
/* AUTOR:	 Management Solutions
/* PROCESO:  ...
/*
/* 			 CONJUNTOS DE DATOS GENERADOS:
/* 			 - ...
/* 			 - ...
/*
/* FECHA: 10/02/2018
/*
/* NOTAS: ...
/*
/* LOG DE CAMBIOS:
/* FECHA	AUTOR	Objetivo
/* ...
/*** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***/

/********************************************************************************
 * PASO 1 - SE CARGAN LOS PARÁMETROS INICIALES, EL FICHERO DE MACROS AUXILIARES
 *			Y LAS RUTAS DE LOS FICHEROS QUE SIRVEN COMO INPUT AL PROCESO
 ********************************************************************************/

*** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***;
*** PROCESADO DE TODOS LOS PARÁMETROS INICIALES DEL PROGRAMA									***;

*** NOMBRE MACRO: 			cargarParametrosIniciales
*** PARÁMETROS DE ENTRADA:	- nombre_del_instrumento: Nombre del instrumento que se va a procesar
***							- nombre_biblioteca: Nombre de la biblioteca de tablas intermedias
*** SALIDA DE LA MACRO: 	Macrovariables con parámetros iniciales cargados:
***							- localProjectPath: directorio local del proyecto en ejecución
***							- fechaReporte: fecha de reporte con formato AAAAMM
***							- Sociedad_Informante: código de sociedad que genera el reporte
***							- hora_generacion_pestana_ajust: hora de ejecución del proyecto
***							- instrumento: instrumento que se está generando
*** PROCESO DE LA MACRO:	Comprueba si el proyecto se ha ejecutado desde el superproceso Main 
***							y asigna los parámetros iniciales teniéndolo en cuenta
*** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***;
%macro cargarParametrosIniciales(nombre_instrumento, nombre_biblioteca);
	* Se declara la macrovariable global para poder utilizarla fuera de la macro;
	%global localProjectPath;
	%global fechaReporte;
	%global Sociedad_Informante;
	%global hora_generacion_pestana_ajust;
	%global instrumento;
	%global dirOutput;
	%global dirTablasIntermedias;
	%global dirHomologPorDefecto;
	%global dirLog;
	%global biblioteca;
	%global bibliotecaHPorDefecto;
	%global dirTablaHomologaciones;
	%global bibliotecaHomo;
	%global dirTablasTemporales;
	%global bibliotecaInputs;
	%global bibliotecaOutputs;
	%global dirSalidasFinales;

	* Se asigna el nombre del instrumento a construir;
	%let instrumento = &nombre_instrumento;

	* Se asigna el nombre de la biblioteca de tablas intermedias con que se va a trabajar;
	%let biblioteca = &nombre_biblioteca;
	%let bibliotecaHomo = Homo;
	%let bibliotecaInputs = Inputs;
	%let bibliotecaOutputs = Outputs;

	* Se asigna el nombre de la biblioteca donde se recogerán los registros homologados por defecto;
	%let bibliotecaHPorDefecto = hDefecto;

	* Se indican los directorios en los que se va a trabajar;
	%let dirOutput = Output/;
	%let dirTablasIntermedias = Tablas_Intermedias/;
	%let dirSalidasFinales = Salidas_Stress_Test/;
	%let dirHomologPorDefecto = Homologaciones_Por_Defecto/;
	%let dirTablasTemporales=nuevo_work/;
	%let dirLog = Log/;

	* Se asigna la fecha y hora de generación de la pestaña;
	%let hora_generacion_pestana=%SysFunc(putn(%SysFunc(datetime()),datetime22.));

	* Se ajusta el formato eliminando los signos ":" para poder utilizar la variable en el nombre de exportación del fichero;
	%let hora_generacion_pestana_ajust = %SysFunc(TranWrd(&hora_generacion_pestana, :, _));

	* Se asigna la variable del directorio local del proyecto;
	* En caso de estarse ejecutando desde el proyecto Main, el valor de esta variable será la ruta del proyecto Main;
	%let localProjectPath = 
		%sysfunc(substr(%sysfunc(dequote(&_CLIENTPROJECTPATH)), 1, 
		%sysfunc(findc(%sysfunc(dequote(&_CLIENTPROJECTPATH)), %str(/\), -255 ))));

	%let localProjectPath=/sasdata/test/StressTest2018/Main/;

	* Se cargan la macros auxiliares utilizadas como apoyo durante todo el proceso;
	%include "&localProjectPath.Codigo_SAS/01_Macros_Auxiliares.sas";

	* Si se está invocando el instrumento desde el proyecto Main, hay que añadir la subruta del instrumento;
	* De esta forma, localProjectPatch hará referencia al directorio del instrumento y no al directorio del proyecto Main;
	* Por otro lado, si se está invocando de forma local el proyecto, se limpia lo existente en la biblioteca WORK;
	%if %SYMEXIST(localMainProjectPath) = 1 %then
		%do;
			%let localProjectPath = &localProjectPath.&dirInstrumentos.&instrumento\;
		%end;

	* Si no se ha invocado el instrumento desde el proyecto Main, se limpia la biblioteca WORK;
	%if %SYMEXIST(localMainProjectPath) = 0 %then
		%do;
			* Se limpia la biblioteca WORK;
			%vaciarBiblioteca(biblioteca=WORK);
		%end;
/**/
	* Si se está invocando desde el proyecto Main se recoge este parámetro;
	* Si no, se asigna por defecto la fecha del sistema;
	%if %SYMEXIST(YYYYMM) = 1 %then
		%do;
			%let fechaReporte = &YYYYMM;
		%end;
	%else
		%do;
			* Se estima la fecha de reporte como el mes anterior a la fecha de ejecución del proceso;
			%let fechaReporte = %sysfunc(putn("&sysdate9"d-32,yymmn6.));
		%end;

	* Si se está invocando desde el proyecto Main se recoge este parámetro;
	* Si no, se asigna por defecto el valor 00141;
	%if %SYMEXIST(cod_Sociedad) = 1 %then
		%do;
			%let Sociedad_Informante = &cod_Sociedad;
		%end;
	%else
		%do;
			%let Sociedad_Informante = 00141;
		%end;
%mend cargarParametrosIniciales;

* Se invoca la carga de la hora actual, directorio del proyecto, fecha del reporte y sociedad informante;
%cargarParametrosIniciales(Stress_Test, ST);


data _null_;
	format oneMonthAgo DDMMYY10.;
	Anio_Periodo = input(substr("&fechaReporte", 1, 4), 8.);
	Mes_Periodo = input(substr("&fechaReporte", 5, 2), 8.);

	* Se obtiene el último día del mes del periodo de reporte;
	oneMonthAgo = intnx('mon', input(compress("01/"||Mes_Periodo||"/"||Anio_Periodo), DDMMYY10.), 0, 'e');

	/*Se obtiene la fecha en fromato string*/
	DATENEW=PUT(oneMonthAgo, yymmddn8.);

	* Se almacena esta fecha en una macrovariable;
	call symput('oneMonthAgo',oneMonthAgo);
	call symput('DiaReporte',DATENEW);
run;

/*Todas las tablas seran guardadas por defecto en la libreria user (carpeta nuevo_work)*/
%LibreriaUser;

%let libRutaOrig = &localProjectPath.Ruta_Fichero_Origenes.txt;
%include "&localProjectPath.Codigo_SAS/02_Ruta_Fichero_Origenes.sas" / lrecl=5000;

* Se cargan los orígenes necesarios para este proceso;
%include "&localProjectPath.Codigo_SAS/03_Comprobar_Inputs.sas" / lrecl=5000;

LIBNAME &biblioteca "&localProjectPath.&dirTablasIntermedias";

/*Se carga la biblioteca que apunta al Aprovisionamiento Unico*/
LIBNAME &bibliotecaInputs "&dirinputsorig.";

/*Se carga la biblioteca con las tablas de salida finales de Stress Test*/
LIBNAME &bibliotecaOutputs "&localProjectPath.&dirSalidasFinales";


/*Rellenamos con la fecha de datos del reporte*/
%let FechaReporte=201803;


/*Cargamos todos los procesos de importacion*/
%include "&localProjectPath.Codigo_SAS/Importar_H_Stress_Test.sas" / lrecl=5000;
%include "&localProjectPath.Codigo_SAS/Importar_Tipo_Cambio.sas" / lrecl=5000;
%include "&localProjectPath.Codigo_SAS/Importar_Tepirela.sas" / lrecl=5000;
%include "&localProjectPath.Codigo_SAS/Importar_B29.sas" / lrecl=5000;
%include "&localProjectPath.Codigo_SAS/Importar_Personas.sas" / lrecl=5000;
%include "&localProjectPath.Codigo_SAS/Importar_Inventarios6.sas" / lrecl=5000;

%include "&localProjectPath.Codigo_SAS/Importar_Bases_Liquidez.sas" / lrecl=5000;
%include "&localProjectPath.Codigo_SAS/Importar_Derivados_Param.sas" / lrecl=5000;
%include "&localProjectPath.Codigo_SAS/Importar_Param_FINREP_Neocon.sas" / lrecl=5000;
%include "&localProjectPath.Codigo_SAS/Importar_Credito_Param_Finrep.sas" / lrecl=5000;
%include "&localProjectPath.Codigo_SAS/Importar_Depositos_Param_Finrep.sas" / lrecl=5000;
%include "&localProjectPath.Codigo_SAS/Importar_Contr_Clie_IFRS9.sas" / lrecl=5000;
%include "&localProjectPath.Codigo_SAS/Importar_Reportes_Finrep.sas" / lrecl=5000;

%include "&localProjectPath.Codigo_SAS/Importar_Repositorio_Historico.sas" / lrecl=5000;
%include "&localProjectPath.Codigo_SAS/Importar_Clientes_Sector.sas" / lrecl=5000;

%include "&localProjectPath.Codigo_SAS/Importar_EEFF.sas" / lrecl=5000;
%include "&localProjectPath.Codigo_SAS/Importar_RelaCont.sas" / lrecl=5000;

%include "&localProjectPath.Codigo_SAS/Importar_Tabla_Credito_Finrep.sas" / lrecl=5000;
%include "&localProjectPath.Codigo_SAS/Importar_Inventarios_Mis.sas" / lrecl=5000;
%include "&localProjectPath.Codigo_SAS/Importar_Mis_No_Vivas.sas" / lrecl=5000;

%include "&localProjectPath.Codigo_SAS/Importar_Dl521.sas" / lrecl=5000;
%include "&localProjectPath.Codigo_SAS/Importar_Tablas_Intemedias_Otros_AyP.sas" / lrecl=5000;

/*Renta Fija ya no es parte del perimetro de Stress Test:*/
/*%include "&localProjectPath.Codigo_SAS/Importar_Tablas_Intemedias_RF.sas" / lrecl=5000;*/

%include "&localProjectPath.Codigo_SAS/Importar_Plan_Cuotas_Completo.sas" / lrecl=5000;
%include "&localProjectPath.Codigo_SAS/Importar_Contratos_Morosos.sas" / lrecl=5000;
%include "&localProjectPath.Codigo_SAS/Importar_Curva_Libre_Sol.sas" / lrecl=5000;
%include "&localProjectPath.Codigo_SAS/Importar_Curva_Libre_Dol.sas" / lrecl=5000;


/*Cargamos todos los procesos que procesan los inputs*/
%include "&localProjectPath.Codigo_SAS/05_Procesar_Depositos.sas" / lrecl=5000;
%include "&localProjectPath.Codigo_SAS/06_Procesar_Credito_Finrep.sas" / lrecl=5000;
%include "&localProjectPath.Codigo_SAS/07_Procesar_Credito_Liquidez.sas" / lrecl=5000;
%include "&localProjectPath.Codigo_SAS/08_Procesar_Emisiones.sas" / lrecl=5000;
%include "&localProjectPath.Codigo_SAS/09_Procesar_CTAs.sas" / lrecl=5000;
%include "&localProjectPath.Codigo_SAS/10_Procesar_Derivados.sas" / lrecl=5000;

/*Union de todos los instumentos y consolidacion*/
%include "&localProjectPath.Codigo_SAS/Union_Todos_Final.sas" / lrecl=5000;




/*LIBNAME p023917 ORACLE  PATH=ETL_PROD  SCHEMA=P023917  USER=p023917  PASSWORD="P023917";*/
/**/
/*libname frg_rutt "/sasdata2/Finanzas/Datamart FIN/MIS CLIENTES/";*/
/**/
/*data frg_rutt.h_sm_slecmov0_2_1712;*/
/*set p023917.STG_HDM201712_3;*/
/*run;*/
