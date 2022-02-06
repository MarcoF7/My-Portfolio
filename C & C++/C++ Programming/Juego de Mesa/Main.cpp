
#include "Tablero.h"
#include <iostream>

using namespace std;

int main()
{
	Tablero* board = new Tablero();
	board->iniciar_tablero(10, 10);
	board->anadir_jugador('A');
	board->anadir_jugador('B');
	board->anadir_jugador('C');

	char key;
	board->imprimir_tablero();

	do
	{
		if (board->game_over())
		{
			cout << "ingrese S para volver a jugar" << endl;
			cin >> key;
			if (key == 'S' || key == 's')
			{
				board->reiniciar();
			}
		}
		else
		{
			cout << "ingrese S para lanzar dado" << endl;
			cin >> key;
			if (key == 'S' || key == 's')
			{
				board->lanzar_dado();
			}
		}
		board->imprimir_tablero();
	} while (key != 'X' && key != 'x');
	
	delete board;
	system("PAUSE");
	return 0;
}