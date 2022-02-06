#include "Dado.h"
#include <random>

Dado::Dado()
{
	this->max = 6;
}


Dado::~Dado()
{
}


int Dado::lanzar()
{
	std::uniform_int_distribution<int> distribution(1, this->max);
	std::random_device rd;
	std::default_random_engine generador(rd());
	ultimo = distribution(generador);
	return ultimo;
}


int Dado::get_ultimo()
{
	return ultimo;
}
