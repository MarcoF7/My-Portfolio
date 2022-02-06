#pragma once

#include "Jugador.h"
#include "Dado.h"
#include <vector>

class Tablero
{
public:
	Tablero();
	~Tablero();
private:
	int arr[10][10];
	int filas;
	int columnas;
	std::vector<Jugador *> jugadores;
	Dado* dado;
	unsigned int jugador_actual;
	int ganador;
public:
	void iniciar_tablero(int filas, int columnas);
	void imprimir_tablero();
	void anadir_jugador(char icono);
	void lanzar_dado();
	bool game_over();
	void reiniciar();
private:
	int jugador_en(int fila, int columna);
};

