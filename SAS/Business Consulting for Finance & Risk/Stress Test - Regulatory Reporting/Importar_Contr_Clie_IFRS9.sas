/*** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***/

/* PROGRAMA: Importar_Contr_Clie_IFRS9.sas
/* OBJETIVO: Carga de fecha de apertura actualizada para los contratos con 
/*			 fecha de apertura mayor a la fecha de vencimiento (legal)
/* AUTOR:	 Management Solutions
/* PROCESO:  Se realiza la importación de la tabla contrato cliente usada en IFRS9
/*			 
/*
/* 			 CONJUNTOS DE DATOS GENERADOS:
/* 			 - ...
/* 			 - ...
/*
/* FECHA: 26/02/2018
/*
/* NOTAS: ...
/*
/* LOG DE CAMBIOS:
/* FECHA	AUTOR	Objetivo
/* ...
/*** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***/


/*%PUT job "Importar_Contr_Clie_IFRS9.sas" comenzó a %now;*/

* Se asigna el nombre lógico del fichero;

/*%let Nombre_Logico_Input = Contrato_Cliente_IFRS9;*/


* Se busca la ruta física en la tabla "FICHEROS_INPUT";
/*data _NULL_;*/
/*	set FICHEROS_INPUT;*/
/**/
/*	if Nombre_Logico_Fichero = "&Nombre_Logico_Input." then do;*/
/*		call symput('Ruta_input_a_cargar', trim(Ruta));*/
/*	end;*/
/*run;*/

/*%put &Ruta_input_a_cargar;*/


/*data &biblioteca..contr_cliente_ifrs;*/
/*	set "&dir_ficheros_orig.&Ruta_input_a_cargar";*/
/*run;*/




/*Esta tabla es obtenida directamente del Aprovisionamiento Unico:

&bibliotecainputs..contrato_cliente_prev
(Fecha de apertura actualizada a nivel contrato)
*/

/*Se debe tener a nivel contrato la nueva fecha de apertura,
Si hay contratos iguales con distintas fechas de apertura, se toma la menor*/
proc sql;
	create table &biblioteca..contr_cliente_ifrs as
		select CONTRATO, min(FECALTA) as FECALTA
			from &bibliotecainputs..contrato_cliente_prev
				group by 1;
quit;