
* Se asigna el nombre lógico del fichero;
%let Nombre_Logico_Input = TI_Dl521;

* Se busca la ruta física en la tabla "FICHEROS_INPUT";
data _NULL_;
	set FICHEROS_INPUT;

	if Nombre_Logico_Fichero = "&Nombre_Logico_Input" then do;
		call symput('Ruta_input_a_cargar', trim(Ruta));
	end;

run;

%put "&dir_ficheros_orig.&Ruta_input_a_cargar.";


%put &dir_ficheros_orig.&Ruta_input_a_cargar.;

* Se importa la tabla;
data Rep_DL521_Cta_Text;
	set "&dir_ficheros_orig.&Ruta_input_a_cargar.";
run;

* Nos quedamos solo con los registros que cumplan el patron de cuenta contable;
proc sql;
	create table Rep_DL521_Repos as 
		select a.Deal_Star, a.CTA_PRINCIPAL as Cuenta_Contable, a.Cod_Contraparte as Cliente,
				a.Fecha_Valor, a.Fecha_Vencimiento, a.Tasa, a.Divisa, a.Oficina,
				a.Interes_a_la_Fecha,
				sum(a.Principal_Amortizado/1000) as Saldo /* se milea el saldo */
			from Rep_DL521_Cta_Text a
				inner join &biblioteca..H_Repos_DL521 b
					on compress(a.CTA_PRINCIPAL) like compress(b.Patron_Cuenta_Contable) /*and compress(upcase(Clase)) = "ADEUDADOCORTOPLAZO"*/
						group by 1, 2, 3, 4, 5, 6, 7, 8, 9;
quit;

* Se contravalora el DL521;
proc sql;
	create table DL521_Contravalorado as
		select a.Deal_Star, a.Cuenta_Contable, a.Cliente,
				a.Fecha_Valor, a.Fecha_Vencimiento, a.Tasa, a.Divisa, a.Oficina,
				a.Interes_a_la_Fecha, a.Saldo * b.Tipo_Cambio as Saldo
			from Rep_DL521_Repos a
				left join Tipo_De_Cambio b
					on compress(upcase(a.Divisa)) = compress(upcase(b.Divisa));
quit;

* Se cruza con el DL521 para sacar la parte del efectivo entregado en la CTA;
proc sql;
	create table DL521_Efectivo_CTA as
		select a.Deal_Star, a.Cuenta_Contable, a.Cliente,
				a.Fecha_Valor, a.Fecha_Vencimiento, a.Tasa, a.Divisa, 
				a.Oficina, a.Interes_a_la_Fecha, a.Saldo
			from DL521_Contravalorado a
				inner join &biblioteca..H_Repos_DL521 b
					on compress(a.Cuenta_Contable) = compress(b.Cuenta_Concreta);
quit;

* Se formatea la cuenta contable y la oficina;
data DL521_Efectivo_CTA_Format;


	format Oficina_Texto $4.;	

	set DL521_Efectivo_CTA;

	format Cuenta $15.;

	Cuenta = compress(Cuenta_Contable || "000000000000000");
	Oficina_Texto = compress("0" || Oficina);

	drop Cuenta_Contable Oficina;
	rename Cuenta = Cuenta_Contable;
	rename Oficina_Texto = Oficina;
run;

