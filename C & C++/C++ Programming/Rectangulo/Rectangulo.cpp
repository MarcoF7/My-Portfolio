#include "Rectangulo.h"


void Rectangulo::setear_valores(int x, int y)
{
	ancho = x;
	largo = y;
}

int Rectangulo::area()
{
	return ancho*largo;
}

int Rectangulo::perimetro()
{
	return (2 * (largo = ancho));
}