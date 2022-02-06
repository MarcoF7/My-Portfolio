#include "Formulario_Principal.h"

using namespace Formulario;

int main(array<String^> ^args)
{
	Application::EnableVisualStyles();
	Application::SetCompatibleTextRenderingDefault(false);

	Application::Run(gcnew Formulario_Principal()); // ejecuta esta aplicacion
	return 0;
}