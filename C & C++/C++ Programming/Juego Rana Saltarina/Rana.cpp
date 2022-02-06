#include "Rana.h"


Rana::Rana()
{
	this->caracter = ' ';
	this->direccion = gcnew Direccion();
}

Rana::Rana(char sentido)
{
	this->caracter = caracter;
	if (caracter == 'M')
	{
		this->direccion = gcnew Direccion('D');
	}
	else if (caracter == 'V')
	{
		this->direccion = gcnew Direccion('V');
	}
}
