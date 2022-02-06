#include "Tablero.h"
#include <iostream>

using namespace std;

Tablero::Tablero()
{
	this->filas = 10;
	this->columnas = 10;
	this->dado = new Dado();
	this->jugador_actual = 0;
	this->ganador = -1;
	for (int i = 0; i < 10; i++)
	{
		for (int j = 0; j < 10; j++)
		{
			this->arr[i][j] = 0;
		}
	}
}


Tablero::~Tablero()
{
	delete this->dado;
	for (int i = 0; i < this->jugadores.size(); i++)
	{
		delete this->jugadores[i];
	}
}


void Tablero::iniciar_tablero(int filas, int columnas)
{
	if (filas > 0 && columnas > 0 && filas <= 10 && columnas <= 10)
	{
		this->filas = filas;
		this->columnas = columnas;
	}
}
void Tablero::imprimir_tablero()
{
	system("CLS");
	int index = -1;
	for (int i = 0; i < this->filas; i++)
	{
		for (int j = 0; j < this->columnas; j++)
		{
			cout << "+--";
		}
		cout << "+" << endl;
		for (int j = 0; j < this->columnas; j++)
		{
			cout << "|";
			index = this->jugador_en(i, j);
			if (index != -1)
			{
				cout << this->jugadores[index]->get_icon() << " ";
			}
			else
			{
				cout << "  ";
			}

		}
		cout << "|" << endl;
	}
	for (int j = 0; j < this->columnas; j++)
	{
		cout << "+--";
	}
	cout << "+" << endl;
	//cout << this->dado->get_ultimo() << endl;
	if (this->ganador >= 0)
	{
		cout << "Jugador " << this->jugadores[ganador]->get_icon() << " ha ganado!" << endl;
	}
}


void Tablero::anadir_jugador(char icono)
{
	Jugador* nuevo = new Jugador(icono);
	this->jugadores.push_back(nuevo);
}


//Metodo auxiliar que retorna el indice del jugador que se encuentre en una posicion
//determinada.  En caso la posicion este vacia, retorna -1
int Tablero::jugador_en(int fila, int columna)
{
	int result = -1;
	int last_player = this->jugador_actual - 1;
	if (this->jugador_actual == 0)
	{
		last_player = this->jugadores.size() - 1;
	}
	for (unsigned int i = 0; i < this->jugadores.size(); i++)
	{
		if (this->jugadores[i]->get_row() == fila && this->jugadores[i]->get_col() == columna)
		{
			result = i;
			if (this->jugadores[last_player]->get_row() == fila && this->jugadores[last_player]->get_col() == columna)
			{
				result = last_player;
			}
			break;
		}
	}
	return result;
}


void Tablero::lanzar_dado()
{
	int numero = this->dado->lanzar();
	//cout << numero << endl;
	this->jugadores[this->jugador_actual]->avanzar(numero, this->filas, this->columnas);
	if (this->jugadores[this->jugador_actual]->ganador(this->filas, this->columnas))
	{
		ganador = this->jugador_actual;
	}
	this->jugador_actual++;
	if (this->jugador_actual > this->jugadores.size() - 1)
	{
		this->jugador_actual = 0;
	}
}


bool Tablero::game_over()
{
	return (this->ganador >= 0);
}


void Tablero::reiniciar()
{
	this->jugador_actual = 0;
	this->ganador = -1;
	for (unsigned int i = 0; i < this->jugadores.size(); i++)
	{
		this->jugadores[i]->setear_posicion(0, 0);
	}
}
