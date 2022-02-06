#pragma once

using namespace System;

ref class Venta
{
public:
	Venta();
	Venta(String^ nombreCliente, String^ DNI);
private:
	String^ nombreCliente;
	String^ DNI;
public:
	String^ get_nombre();
	String^ get_DNI();
};

