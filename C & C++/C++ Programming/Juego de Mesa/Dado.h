#pragma once
class Dado
{
public:
	Dado();
	~Dado();
private:
	int max;
	int ultimo;
public:
	int lanzar();
	int get_ultimo();
};

