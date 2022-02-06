#include "Venta.h"


Venta::Venta()
{
	this->nombreCliente = "";
	this->DNI = "";
}

Venta::Venta(String^ cliente, String^ DNI)
{
	this->nombreCliente = cliente;
	this->DNI = DNI;
}

String^ Venta::get_DNI()
{
	return this->DNI;
}

String^ Venta::get_nombre()
{
	return this->nombreCliente;
}