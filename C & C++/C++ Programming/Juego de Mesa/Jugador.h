#pragma once
class Jugador
{
public:
	Jugador();
	Jugador(char icono);
	~Jugador();
private:
	int col;
	int row;
	char icono;
	int posicion;
public:
	void setear_posicion(int col, int row);
	void avanzar(int pasos, int filas, int columnas);
	bool ganador(int filas, int columnas);      // bool es true(1)  o false (0)  cualquiera de esos 2 imprimiria
	int get_col();
	int get_row();
	char get_icon();
};

