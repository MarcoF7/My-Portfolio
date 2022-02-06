#pragma once
#include "Rana.h"
//array o vector o el sgt:
using  namespace System::Collections::Generic;
using namespace System;

ref class Juego          // en primera y en segunda estan las posiciones
{
public:
	Juego();
public: // para no hacer sets ni gets
	List<Rana^> ^Ranas;
	//los botones:
	int primera;// cual rana quiero
	int segunda; //a donde quiero que se mueva
	bool moverRana;

public:
	void botonPresionado(int indice);  // cada vez que presiono un boton
	void moveRana();
	List<String^>^ devuelveRanas();
		//lista o arreglo
		//lista es una clase que almacena un arreglo
		// al igual que vector
		//reemplaza a vector el visual studio  es otro nombre de vector

	bool ganar();
};

