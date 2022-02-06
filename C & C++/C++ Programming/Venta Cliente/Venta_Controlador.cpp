#include "Venta_Controlador.h"


Venta_Controlador::Venta_Controlador()
{
	this->listaVentas = gcnew List < Venta^ > ;
	// inicializo mi lista
}

void Venta_Controlador::agregar_venta(String^ nombreCliente, String^ DNI)
{
	Venta^ nueva = gcnew Venta(nombreCliente, DNI);
	this->listaVentas->Add(nueva);
}

Venta^ Venta_Controlador::buscar_venta(String^ nombre)
{
	Venta^ encontrada;
	bool found = false;
	// un metodo
	// quiero buscar un elemento de un arreglo
	for (int i = 0; i < this->listaVentas->Count; i++)   //Count da el numero de elementos que contiene una lista
	{ 
		if (this->listaVentas[i]->get_nombre()->Equals(nombre))
		{
			encontrada = this->listaVentas[i];
			found = true;
			break;
		}
	}
	if (found)
	{
		return encontrada;
	}
	else
	{
		nullptr;// retorno un puntero que no apunta a nada    puntero vacio
	}
}