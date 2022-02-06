/*** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***/
/* PROGRAMA: Importar_TEPIRELA.sas
/* OBJETIVO: Carga del fichero que contiene la relación entre epígrafe y 
/*			 Cuenta Contable
/* AUTOR:	 Management Solutions
/* PROCESO:  Se realiza la importación del fichero TEPIRELA
/*
/* 			 CONJUNTOS DE DATOS GENERADOS:
/* 			 - ...
/* 			 - ...
/*
/* FECHA: 29/06/2015
/*
/* NOTAS: ...
/*
/* LOG DE CAMBIOS:
/* FECHA	AUTOR	Objetivo
/* ...
/*** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***/

%PUT job "Importar_TEPIRELA.sas" comenzó a %now;

* Se asigna el nombre lógico del fichero;
%let Nombre_Logico_Input = TEPIRELA;

* Se busca la ruta física en la tabla "FICHEROS_INPUT";
data _NULL_;
	set FICHEROS_INPUT;

	if Nombre_Logico_Fichero = "&Nombre_Logico_Input" then do;
		call symput('Ruta_input_a_cargar', trim(Ruta));
	end;

run;

%borrarTabla(&biblioteca..Epigrafe_CContable);
%let _EFIERR_ = 0;


* Se importa el fichero que relaciona código de cliente e intercompany;
* Al tratarse de un fichero de texto, se debe conocer la copy para aplantillarlo;
data &biblioteca..Epigrafe_CContable;
     infile "&dir_ficheros_orig.&Ruta_input_a_cargar" lrecl=4096;
     INPUT
          @2 'CUENTA'n				$20.
          @24 'ESTADO'n				$4.
          @30 'EPIGRAFE LOCAL'n		$7.
          @40 'EPIGRAFE BASICO'n	$7.
     ;

	OUTPUT &biblioteca..Epigrafe_CContable;

	if _ERROR_ then
		call symput('_EFIERR_',1);
run;


data Epigrafe_CContable_Format;
	format Cuenta_Contable $15.;
	set &biblioteca..Epigrafe_CContable;

	Cuenta_Contable = compress(Cuenta || "0000000000000");

	drop Cuenta;
	rename Cuenta_Contable = Cuenta;
	/*Queremos tanto cuentas de balance como de resultados entonces comentamos:*/
/*	where 'ESTADO'n	 = "55";*/
run;



/*Tratamiento Duplicados TEPIRELA (no aplica)*/

/*data Epigrafe_CContable_Format2;*/
/*set Epigrafe_CContable_Format;*/
/*	format IDP $2.;*/
/*	IDP = substr('EPIGRAFE LOCAL'n,6,2);*/
/*run;*/
/**/
/*proc sort data=Epigrafe_CContable_Format2 out=Epigrafe_CContable_Format3;*/
/*by Cuenta descending 'EPIGRAFE LOCAL'n ESTADO;*/
/*where (ESTADO ne '55' or 'EPIGRAFE LOCAL'n ne '2860000') and Cuenta ne "" and IDP le '49';*/
/*run;*/
/**/
/*data Epigrafe_CContable_Format4;*/
/*set Epigrafe_CContable_Format3;*/
/*retain rcuenta "000000000000000";*/
/*if cuenta ne rcuenta then output;*/
/*rcuenta = cuenta;*/
/*run;*/


/*Se verifica que cada Cuenta Contable apunta a 1 solo Epígrafe*/
proc sql;
	create table Epigrafe_CContable_Format_dis as
		select distinct Cuenta, 'EPIGRAFE LOCAL'n
			from Epigrafe_CContable_Format;
quit;



%PUT job "Importar_TEPIRELA.sas" finalizó a %now;