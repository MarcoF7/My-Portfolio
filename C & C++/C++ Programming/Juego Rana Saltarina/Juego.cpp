#include "Juego.h"


Juego::Juego()
{
	this->Ranas = gcnew List < Rana^ > ;
	for (int i = 0; i < 3; i++)   
	{
		this->Ranas->Add(gcnew Rana('M'));   //va anadiendo un elemento al arreglo y expandiendolo si es que sencesita mas espacio   igual al push back
	}
	this->Ranas->Add(gcnew Rana());
	for (int i = 0; i < 3; i++)
	{
		this->Ranas->Add(gcnew Rana('V'));
	}
}

void Juego::botonPresionado(int indice)
{
	if (moverRana == true)     // if(moverRana)  tmb se pudo usar
	{
		this->segunda = indice;
		//Mueva la rana
		this->moveRana();
		this->moverRana = false;
	}
	else
	{
		this->primera = indice;
		this->moverRana = true;
	}
}


void Juego::moveRana()// revisa si el lugar al que quiero mover la rana sea el correcto
{
	Rana^ amover = this->Ranas[this->primera];
	char  direc = amover->direccion->sentido;
	if (  ((direc=='D') && (segunda>primera) && (segunda-primera <= 2) && (Ranas[segunda]->caracter == ' ')) ||  //el segundo boton debe estar a la derecha que el primero xq es rana marron osea se mueve a la derecha
		((direc == 'I') && (segunda<primera) && (primera-segunda <= 2) && (Ranas[segunda]->caracter == ' ')))    // la resta debe ser 1 o 2       si fuera 3 me estaria llendo muy lejos
	{                                         
		// cambio de posicion a las ranas
		this->Ranas[this->primera] = this->Ranas[this->segunda];
		this->Ranas[this->segunda] = amover;
	}

}

List<String^>^ Juego::devuelveRanas()
{
	List<String^>^ temp = gcnew List < String^ > ;   //crea un arreglo temporal donde se meten valores y luego los devuelve

	for (int i = 0; i < this->Ranas->Count; i++)   //en ves de size ahora count
	{                                  // tambien se podria poner 7 xq ya se sabe 
		if (this->Ranas[i]->caracter == 'M')
		{
			temp->Add("M");
		}
		else if (this->Ranas[i]->caracter == 'V')
		{
			temp->Add("V");
		}
		else
		{
			temp->Add("");
		}
	}
	return temp;
}

bool Juego::ganar()
{
	bool win = (Ranas[0]->caracter == 'V' && Ranas[1]->caracter == 'V' && Ranas[2]->caracter == 'V' && )
		return win;
}