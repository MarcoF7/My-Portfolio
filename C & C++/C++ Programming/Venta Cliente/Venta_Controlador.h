#pragma once

#include "Venta.h"  // para crear objetos venta
using namespace System::Collections::Generic;

ref class Venta_Controlador
{
public:
	Venta_Controlador();
private:
	List<Venta^> ^ listaVentas;
public:
	void agregar_venta(String^ nombreCliente, String^ DNI);
	Venta^ buscar_venta(String^ nombre);
};

