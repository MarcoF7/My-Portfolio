#pragma once
#include "Direccion.h"

ref class Rana
{
public:
	Rana();
	Rana(char caracter);
public:
	char caracter;
	Direccion^ direccion;  //puntero
};

