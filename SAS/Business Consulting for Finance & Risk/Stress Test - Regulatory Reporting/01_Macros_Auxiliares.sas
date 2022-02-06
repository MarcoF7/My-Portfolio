/*** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***/
/* PROGRAMA: 01_Macros_Auxiliares.sas
/* OBJETIVO: Carga todas las macros que sirven de soporte a la
			 ejecuci�n del proceso principal
/* AUTOR:	 Management Solutions
/* PROCESO:  Carga de todas las macros auxiliares definidas
/*
/* FECHA: 22/04/2015
/* 
/* NOTAS: No aplica
/*
/* LOG DE CAMBIOS:
/* FECHA	AUTOR	Objetivo
/* ...
/*** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***/

*** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***;
*** BORRADO DE UNA TABLA																		***;
*** NOMBRE MACRO: 			borrarTabla
*** PAR�METROS DE ENTRADA:	- table: Nombre del dataset donde a borrar
*** SALIDA DE LA MACRO: 	Si la tabla existe se elimina y no se realizan acciones adicionales.
***							Si la tabla no existe, se muestra un aviso en el log.
*** PROCESO DE LA MACRO:	Comprueba si la tabla existe y en tal caso la borra. En caso contrario
***							se genera un mensaje de aviso en el log.
*** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***;
%MACRO LibreriaUser ;
  %LET RC = 0;
  data _null_ ;
    set sashelp.vslib (where=(libname="user")) ;
    call symput('RC',1) ;
  run ;
  %IF &RC = 1 %THEN %DO ;
    libname user clear ;
  %END ;
    %IF &RC = 0 %THEN %DO ;
    libname user "&localProjectPath.&dirTablasTemporales";
/*	%vaciarBiblioteca(biblioteca=user);*/

  %END ;
%MEND ;
%macro borrarTabla(table);
	%if %sysfunc(exist(&table)) %then %do;
			proc sql;
				drop table &table;
			quit;
	%end;
	%else %do;
			data _null_;
				putlog 'Aviso: ha intentado borrar una tabla que no existe';
			run;
	%end;
%mend borrarTabla;

%MACRO now( fmt= DATETIME23.3 ) /DES= 'timestamp';
	%SYSFUNC( DATETIME(), &fmt )
%MEND now;

%macro Mes_Ant();
       %let Anio = %substr(&fechaReporte, 1, 4);
 
       %if  %substr(&fechaReporte, 5, 2)=01 %then
             %do;
                    %let Anio_a=%sysevalf(&Anio -1);
                    %let Mes_a=12;
                    %let fechaReporte=&Anio_a&Mes_a;
             %end;
       %else
             %do;
                    %let Mes_a=%sysevalf(%substr(&fechaReporte, 5, 2)-1);
                    %let fechaReporte=&Anio&Mes_a;
             %end;
%mend;

*** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***;
*** OBTENCI�N DE LAS VARIABLES DE UNA TABLA														***;
*** NOMBRE MACRO: 			getvars
*** PAR�METROS DE ENTRADA:	- dataset: Nombre de la tabla cuyas variables se desean conocer
*** SALIDA DE LA MACRO: 	Macrovariable con lista de variables:
***							- vlist: lista de variables
*** PROCESO DE LA MACRO:	Comprueba las variables de la tabla en la tabla 
***							de metadatos "dictionary"
*** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***;
%macro getvars(dataset);
	%global vlist;

	proc sql;
		create table &dataset.Vars as 
			select name into :vlist separated by ' '
				from dictionary.columns
					where memname=upcase("&dataset");
	quit;
%mend;


*** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***;
*** EXPORTACI�N DE UN DATASET A EXCEL CUYAS CABECERAS SON LOS "LABEL" DEL DATASET				***;
*** NOMBRE MACRO: 			exportXLSwithLABEL
*** PAR�METROS DE ENTRADA:	- dataset: Nombre de la tabla a exportar
***							- file: Nombre del fichero en que se va a exportar
***							- sheet: Nombre de la pesta�a del Excel en que se va a exportar
*** SALIDA DE LA MACRO: 	Fichero Excel con el nombre contenido en la variable "file"
*** PROCESO DE LA MACRO:	Exporta la tabla al fichero indicado en "file". Si el fichero no existe
***							lo crea y si ya existe a�ade una pesta�a con el nombre contenido en la
***							variable "sheet"
*** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***;


%macro exportXLSwithLABEL(dataset, file, sheet);

	proc export data = &dataset
		outfile="&file"
		LABEL
		DBMS=XLSX REPLACE;
		sheet="&sheet";
	run;

%mend exportXLSwithLABEL;

*** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***;
*** EXPORTACI�N DE UN DATASET CON UN FORMATO DE SALIDA DETERMINADO								***;
*** NOMBRE MACRO: 			exportFormattedXLS
*** PAR�METROS DE ENTRADA:	- dataset: Nombre de la tabla a exportar
***							- file: Nombre del fichero en que se va a exportar
***							- sheet: Nombre de la pesta�a del Excel en que se va a exportar
*** SALIDA DE LA MACRO: 	Fichero Excel con el nombre contenido en la variable "file"
*** PROCESO DE LA MACRO:	Exporta la tabla al fichero indicado en "file". Si el fichero no existe
***							lo crea y si ya existe a�ade una pesta�a con el nombre contenido en la
***							variable "sheet"
*** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***;
%macro exportFormattedXLS (dataset, file, sheet);
	* Se redefine a una ruta temporal la declaraci�n de estilos;
	ods path(prepend) templat(update);

	* Se declara el estilo;
	proc template;
		define style newstyle;
			style header / 
				backgroundcolor=very dark blue
				textalign=center
				fontfamily="arial"
				fontweight=bold
				fontsize=2
				color=white;
			style footer from systemtitle /
				fontfamily="arial"
				fontsize=2;
			style table /
				fontfamily="arial"
				borderwidth=1;
		end;
	run;
	
	ods tagsets.excelxp file = "&file"
		options (autofilter='all' absolute_column_width="42" sheet_name="&sheet") style=newstyle;

	proc print data = &dataset noobs label;
	run;

	ods tagsets.excelxp close;

%mend exportFormattedXLS;

*** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***;
*** COMPROBACI�N DE LA EXISTENCIA DE UNA PESTA�A DETERMINADA EN UN FICHERO EXCEL				***;
*** NOMBRE MACRO: 			comprobarPestana
*** PAR�METROS DE ENTRADA:	- nombre_pestana: Nombre de la pesta�a a comprobar
***							- rutaInput: Ruta del fichero a comprobar
***							- errores: Tabla donde se expotar�n los errores (si los hubiera)
*** SALIDA DE LA MACRO: 	Si se produce alg�n error, se insertar� en la tabla "errores"
*** PROCESO DE LA MACRO:	Se comprueba la existencia de la pesta�a en el fichero Excel indicado,
***							el cual ha sido cargado en la biblioteca "Input" en un paso previo. En 
***							dicha biblioteca deber�a existir una tabla con el nombre de la pesta�a
***							si esta estuviese contenida en el fichero
*** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***;
%macro comprobarPestana(nombre_pestana=, rutaInput=, errores=);
	* Se construye la tabla sobre la que se va a consultar su existencia;
	%let pestanaConsultar = %str(Input.%'&nombre_pestana.$%'n);

	* Se realiza la comprobaci�n de existencia;
	%if %sysfunc(exist(&pestanaConsultar)) = 0 %then %do;
		* Si no existe la tabla de errores, se crea;
		%if %sysfunc(exist(&errores)) = 0 %then
			%do;
				data &errores;
					format Input $500.;
					format Descripcion $100.;
					stop;
				run;
			%end;

		* Se escribe el error en la tabla de errores;
		proc sql;
			INSERT INTO &errores (Input, Descripcion)
				VALUES ("&rutaInput pesta�a '&nombre_pestana'", "No se encuentra la pesta�a '&nombre_pestana' en el fichero &rutaInput");
		quit;
	%end;
%mend comprobarPestana;

*** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***;
*** COMPROBACI�N DE LA EXISTENCIA DE UN CONJUNTO DE PESTA�AS EN UN FICHERO EXCEL				***;
*** NOMBRE MACRO: 			comprobarPestanasFichero
*** PAR�METROS DE ENTRADA:	- rutaInput: Ruta del fichero a comprobar
***							- nombre_logico: Nombre l�gico del fichero
***							- errores: Tabla donde se expotar�n los errores (si los hubiera)
*** SALIDA DE LA MACRO: 	Si se produce alg�n error, se insertar� en la tabla "errores"
*** PROCESO DE LA MACRO:	Se recogen las pesta�as que, de forma param�trica, se ha indicado que 
***							debe contener el fichero Excel y se invoca a la macro "comprobarPestana"
***							para comprobar de forma individual cada una de ellas
*** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***;
%macro comprobarPestanasFichero(rutaInput=, nombre_logico=, errores=);
	%put "noenter";

	%if %sysfunc(fileexist("&dir_ficheros_orig.&rutaInput")) = 1 %then
		%do;
			%put enter;


/*Se corrigio en DATAFILE, debe apuntar a Copia de Nombre_Fichero_Origenes.xlsx */
			PROC IMPORT OUT=rttrmp
				DATAFILE="&dir_ficheros_orig.&fichero_listado_inputs"
				DBMS=xlsx replace;
				getnames=yes;
				sheet="&nombre_logico";
			RUN;

			* Se lee la pesta�a del fichero de listado de inputs que contiene el listado de pesta�as;
			* que debe contener el fichero "rutaInput";
			proc sql;
				create table &nombre_logico._Pestanas as 
					/*select Nombre_fisico_pestana*/
				select *
					from rttrmp;
			quit;

		%end;
	%else
		%do;
			* Si no existe la tabla de errores, se crea;
			%if %sysfunc(exist(&errores)) = 0 %then
				%do;

					data &errores;
						format Input $500.;
						format Descripcion $100.;
						stop;
					run;

				%end;

			* Se escribe el error en la tabla de errores;
			proc sql;
				INSERT INTO &errores (Input, Descripcion)
					VALUES ("FichOrig.&nombre_logico.$", "No se encuentra la pesta�a en el fichero con el listado de inputs");
			quit;

		%end;
%mend comprobarPestanasFichero;

*** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***;
*** COMPROBACI�N DE LA EXISTENCIA DE UN FICHERO													***;
*** NOMBRE MACRO: 			comprobarExistenciaFichero
*** PAR�METROS DE ENTRADA:	- rutaInput: Ruta del fichero a comprobar
***							- errores: Tabla donde se expotar�n los errores (si los hubiera)
*** SALIDA DE LA MACRO: 	Si se produce alg�n error, se insertar� en la tabla "errores"
*** PROCESO DE LA MACRO:	Se comprueba si el fichero especificado en "rutaInput" existe en la  
***							ruta contenida por esta variable
*** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***;
%Macro comprobarExistenciaFichero (rutaInput=, errores=);
	* Se comprueba la existencia del input y, en caso de no existir se incluye en la lista de errores;
	%if %sysfunc(fileexist("&dir_ficheros_orig.&rutaInput")) = 0 %then %do;
			* Si no existe la tabla de errores, se crea;
			%if %sysfunc(exist(&errores)) = 0 %then
				%do;

					data &errores;
						format Input $500.;
						format Descripcion $100.;
						stop;
					run;

				%end;

			* Se escribe el error en la tabla de errores;
			proc sql;
				INSERT INTO &errores (Input, Descripcion)
					VALUES ("&dir_ficheros_orig.&rutaInput", "No se encuentra el fichero en la ruta especificada");
			quit;

		%end;
%mend comprobarExistenciaFichero;

*** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***;
*** PRESENTACI�N DE ERRORES EN EXISTENCIA DE FICHEROS INPUT										***;
*** NOMBRE MACRO: 			mostrarErroresRutas
*** PAR�METROS DE ENTRADA:	- errores: Tabla donde se encuentran los errores (si los hubiera)
*** SALIDA DE LA MACRO: 	Si existe alg�n error, se genera un Excel con el listado de errores
*** PROCESO DE LA MACRO:	Se comprueba si la tabla "errores" existe y en tal caso se vuelva a  
***							un fichero Excel mostr�ndose en el log un mensaje de error relacionado
*** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***;
%macro mostrarErroresRutas(errores=);
	* Se muestra la tabla de errores por pantalla;
	* Se indica la select como "noprint" ya que la propia exportaci�n a Excel con formato HTML mostrar� por pantalla esta salida;
	proc sql noprint;
		title "Errores de carga de inputs por ruta err�nea";
		select * from &errores;
	quit;

	* Se vuelca a un Excel la tabla de errores para consultarla externamente;
	%exportFormattedXLS(&errores, &localProjectPath.&dirLog.&hora_generacion_pestana_ajust._LogErrorInputs.xls, ErrorInputs);

	* Se aborta la ejecuci�n;
	data _null_;
		putlog 'ERROR: ************************** ERROR EN LOS INPUTS ***************************';
		putlog 'ERROR: Uno o m�s inputs del proceso no se encuentran en la localizaci�n indicada.';
		putlog 'ERROR: Consultar detalles en el directorio Log el fichero LogErrorInputs.xlsx';
		putlog 'ERROR: **************************************************************************';
	run;

%mend mostrarErroresRutas;

*** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***;
*** PRESENTACI�N DE ERRORES EN PESTA�AS DE FICHEROS INPUT										***;
*** NOMBRE MACRO: 			mostrarErroresPestanas
*** PAR�METROS DE ENTRADA:	- errores: Tabla donde se encuentran los errores (si los hubiera)
*** SALIDA DE LA MACRO: 	Si existe alg�n error relativo a la existencia de alguna pesta�a, 
***							se genera un Excel con el listado de errores
*** PROCESO DE LA MACRO:	Se comprueba si la tabla "errores" existe y en tal caso se vuelva a  
***							un fichero Excel mostr�ndose en el log un mensaje de error relacionado
*** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***;
%macro mostrarErroresPestanas(errores=);
	* Se muestra la tabla de errores por pantalla;
	* Se indica la select como "noprint" ya que la propia exportaci�n a Excel con formato HTML mostrar� por pantalla esta salida;
	proc sql noprint;
		title "Errores de carga de inputs por pesta�as err�neas";
		select * from &errores;
	quit;

	* Se vuelca a un Excel la tabla de errores para consultarla externamente;
	%exportFormattedXLS(&errores, &localProjectPath.&dirLog.&hora_generacion_pestana_ajust._LogErrorPestanasInputs.xls, ErrorInputs);

	* Se aborta la ejecuci�n;
	data _null_;
		putlog 'ERROR: *********************** ERROR EN LAS PESTA�AS DE LOS INPUTS ************************';
		putlog 'ERROR: Uno o m�s inputs del proceso no tienen las pesta�as indicadas en su parametrizaci�n.';
		putlog 'ERROR: Consultar detalles en el directorio Log el fichero _LogErrorPestanasInputs.xlsx';
		putlog 'ERROR: ************************************************************************************';
	run;

%mend mostrarErroresPestanas;

*** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***;
*** BORRADO DE TABLAS DE UNA BIBLIOTECA															***;
*** NOMBRE MACRO: 			vaciarBiblioteca
*** PAR�METROS DE ENTRADA:	- contenido: Biblioteca a vaciar
*** SALIDA DE LA MACRO: 	Biblioteca vac�a
*** PROCESO DE LA MACRO:	Se eliminan todas las tablas de la biblioteca indicada
*** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***;
%macro vaciarBiblioteca(biblioteca=);
	* Se limpia el contenido de la biblioteca especificada;
	proc datasets lib=&biblioteca kill nolist memtype=data;
	quit;
%mend vaciarBiblioteca;

*** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***;
*** BORRADO DE FICHEROS																			***;
*** NOMBRE MACRO: 			borrarFichero
*** PAR�METROS DE ENTRADA:	- fichBorrar: Fichero a eliminar
*** SALIDA DE LA MACRO: 	NA
*** PROCESO DE LA MACRO:	Si existe el fichero indicado, se elimina. Si no, no se hace nada
*** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***;
%macro borrarFichero (fichBorrar);
	data _null_;
		fname="tempfile";
		rc=filename(fname,"&fichBorrar");

		if rc = 0 and fexist(fname) then
			rc=fdelete(fname);
		rc=filename(fname);
	run;
%mend borrarFichero;

*** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***;
*** COMPROBACI�N DEL N�MERO DE REGISTROS DE LAS TABLAS INTERVINIENTES EN UN CRUCE				***;
*** NOMBRE MACRO: 			comprobarNumeroRegistros
*** PAR�METROS DE ENTRADA:	- t1: Nombre de la primera tabla interviniente en el cruce
*** 						- t2: Nombre de la segunda tabla interviniente en el cruce
***							- tfinal: Nombre de la tabla originada al realizarse el cruce
***							- treg: Nombre de la tabla donde se va a almacenar el n�mero de 
***									registros de t1, t2 y tfinal
***							- tipoCruce: Descripcion del tipo de cruce realizado (INNER JOIN,
***										 LEFT JOIN o RIGHT JOIN)
*** SALIDA DE LA MACRO: 	Tabla "treg" con la informaci�n sobre el cruce
*** PROCESO DE LA MACRO:	Se realiza la apertura de cada tabla, se recoge el n�mero de elementos
*** 						de cada una de ellas y, si existe la tabla "treg" se escribe en ella 
***							o si no se crea la tabla y despu�s se escribe
*** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***;
%macro comprobarNumeroRegistros(t1, t2, tfinal, treg, tipoCruce);

	* Se lee el n�mero de registros de la tabla "t1";
	%let dsid=%sysfunc(open(&t1));
	%let nRegT1=%sysfunc(attrn(&dsid,nlobs));
	%let rc=%sysfunc(close(&dsid));

	* Se lee el n�mero de registros de la tabla "t2";
	%let dsid=%sysfunc(open(&t2));
	%let nRegT2=%sysfunc(attrn(&dsid,nlobs));
	%let rc=%sysfunc(close(&dsid));

	* Se lee el n�mero de registros de la tabla "tfinal";
	%let dsid=%sysfunc(open(&tfinal));
	%let nRegTfinal=%sysfunc(attrn(&dsid,nlobs));
	%let rc=%sysfunc(close(&dsid));

	* Si no existe la tabla de errores, se crea;
	%if %sysfunc(exist(&treg)) = 0 %then
		%do;

			data &treg;
				format Tabla1 $50.;
				format Num_Registros_Tabla1 25.;
				format Tabla2 $50.;
				format Num_Registros_Tabla2 25.;
				format TablaFinal $50.;
				format Num_Registros_TablaFinal 25.;
				format Tipo_Cruce $50.;
				stop;
			run;

		%end;

	* Se escribe el n�mero de elementos de cada tabla en la tabla de registro;
	proc sql;
		INSERT INTO &treg (Tabla1, Num_Registros_Tabla1, Tabla2, Num_Registros_Tabla2, TablaFinal, Num_Registros_TablaFinal, Tipo_Cruce)
			VALUES ("&t1", &nRegT1, "&t2", &nRegT2, "&tfinal", &nRegTfinal, "&tipoCruce");
	quit;

%mend comprobarNumeroRegistros;

*** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***;
*** COMPROBACI�N DE ATRIBUTO NO HOMOLOGADO DE FORMA ADECUADA									***;
*** NOMBRE MACRO: 			comprobarAtributoHomologado
*** PAR�METROS DE ENTRADA:	- tablaHomologada: Tabla sobre la que se ha realizado la homologaci�n
***							- atributoHomologado: Atributo homologado
***							- atributoInfoHomologacion: Variable con la informaci�n sobre el 
***								atributo que no se ha podido homologar correctamente
***							- tituloSelect: T�tulo de la consulta que se mostrar� por pantalla
***							- pestana: Nombre de la pesta�a en el Excel de salida
***							- tablaRegNoHomolOK: Nombre de la tabla que se generar� para infomar
***								sobre los registros que no se han podido homologar correctamente
*** SALIDA DE LA MACRO: 	Fichero Excel en el directorio "Log" con el nombre contenido en la 
***							variable "tablaRegNoHomolOK"
*** PROCESO DE LA MACRO:	Comprueba si existen registros cuya variable "atributoInfoHomologacion"
***							no sea nula y, en tal caso, los vuelca a un fichero de log para que el 
***							usuario pueda visualizarlos
*** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***;
%macro comprobarAtributoHomologado(tablaHomologada=, atributoHomologado=, atributoInfoHomologacion=, tituloSelect=, pestana=, tablaRegNoHomolOK=);

%put En el comprobarAtributoHomologado al inicio;

	* Se realiza un recuento del n�mero de observaciones con irregularidades en su homologaci�n;
	proc sql noprint;
		select count(*) into :nobsNoHomol 
			from &tablaHomologada
				where &atributoInfoHomologacion is not null;
	quit;

%put En el comprobarAtributoHomologado punto 2;

	* Si han quedado registros sin homologar se vuelcan a una tabla para su posterior volcado a log;
	%if &nobsNoHomol > 0 %then	%do;
		* Se crea la tabla RegistrosNoHomologadosOK con aquellos registros que no han sido homologados de forma normal;
		proc sql;
			create table &tablaRegNoHomolOK as
				select * 
					from &tablaHomologada
						where &atributoInfoHomologacion is not null;
		quit;

		* Se muestra la tabla registros que no han sido homologados de forma normal por pantalla;
		proc sql;
			title "&tituloSelect";
			select * from &tablaRegNoHomolOK;
		quit;

		%exportXLS(&tablaRegNoHomolOK, &localProjectPath.&dirLog.&hora_generacion_pestana_ajust._&tablaRegNoHomolOK..xls, &pestana);

	%end;
%mend comprobarAtributoHomologado;

*** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***;
*** EXPORTACI�N DE UN DATASET A UN FICHERO EXCEL											***;
*** NOMBRE MACRO: 			exportXLS
*** PAR�METROS DE ENTRADA:	- dataset: Nombre de la tabla a exportar
***							- file: Ruta del fichero de salida
***							- sheet: Nombre de la pesta�a en el Excel de salida
*** SALIDA DE LA MACRO: 	Fichero Excel la ruta indicada por la variable "file" con la 
***							informaci�n de la tabla indicada por la variable "dataset
*** PROCESO DE LA MACRO:	Exportar a Excel una tabla SAS
*** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***;
%macro exportXLS(dataset, file, sheet);
	proc export data = &dataset
		outfile="&file"
		DBMS=XLSX REPLACE;
		sheet="&sheet";
	run;
%mend exportXLS;


*** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***;
*** MOSTRADO DE TABLA POR PANTALLA Y VOLCADO A EXCEL										***;
*** NOMBRE MACRO: 			mostrarYvolcarDataset
*** PAR�METROS DE ENTRADA:	- dataset: Nombre de la tabla a exportar
***							- tituloSelect: T�tulo que se mostrar� por pantalla
***							- pestana: Nombre de la pesta�a en el Excel de salida
*** SALIDA DE LA MACRO: 	Fichero Excel la ruta indicada por la variable "file" con la 
***							informaci�n de la tabla indicada por la variable "dataset
*** PROCESO DE LA MACRO:	Mostrar y exportar a Excel una tabla SAS
*** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***;
%macro mostrarYvolcarDataset(dataset=, tituloSelect=, pestana=);
	* Se muestra la tabla de saldos ajustados por pantalla;
	* Se indica la select como "noprint" ya que la propia exportaci�n a Excel con formato HTML mostrar� por pantalla esta salida;
	proc sql noprint;
		title "&tituloSelect";
		select * from &dataset;
	quit;

	* Se vuelca a un Excel la tabla de errores para consultarla externamente;
	%exportFormattedXLS(&dataset, &localProjectPath.&dirLog.&hora_generacion_pestana_ajust._&dataset..xls, &pestana);
%mend mostrarYvolcarDataset;