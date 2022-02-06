#include "Rectangulo.h"
#include <iostream>

using namespace std;

int main()
{
	Rectangulo * MiRectangulo, *MiRect;
	MiRectangulo = new Rectangulo();
	MiRect = new Rectangulo();

	MiRectangulo->setear_valores(7, 8);
	MiRect->setear_valores(4, 5);
	int area1, area2;
	area1 = MiRectangulo->area();
	area2 = MiRect->area();
	delete MiRectangulo;
	delete MiRect;
	cout << "El area de MiRectangulo es " << area1 << " mientras que el area de MiRect es " << area2 << endl;
	
	return 0;
}


