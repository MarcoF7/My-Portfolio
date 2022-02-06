#include "Jugador.h"


Jugador::Jugador()
{
	this->col = 0;
	this->row = 0;
	this->icono = 'X';
	this->posicion = 0;
}


Jugador::Jugador(char icono)
{
	this->col = 0;
	this->row = 0;
	this->icono = icono;
	this->posicion = 0;
}


Jugador::~Jugador()
{
}


void Jugador::setear_posicion(int col, int row)
{
	this->posicion = 0;
	this->col = col;
	this->row = row;
}


void Jugador::avanzar(int pasos, int filas, int columnas)
{
	this->posicion += pasos;
	if (this->posicion > filas*columnas - 1)
	{
		this->posicion = filas*columnas - 1;
	}
	this->row = posicion / columnas;
	if (row % 2 == 0)
	{
		this->col = posicion % columnas;
	}
	else
	{
		this->col = columnas - 1 - posicion % columnas;
	}
}


bool Jugador::ganador(int filas, int columnas)
{
	return (this->posicion == filas*columnas - 1);
}


int Jugador::get_col()
{
	return this->col;
}
int Jugador::get_row()
{
	return this->row;
}
char Jugador::get_icon()
{
	return this->icono;
}
