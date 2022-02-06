#include "MyForm.h"

using namespace Project1;

int main(array<String^>^args)
{
	Application::EnableVisualStyles();
	Application::SetCompatibleTextRenderingDefault(false);
	Application::Run(gcnew MyForm());  //llamo al constructor de la ventana
	//MyForm^ formulario = gcnew MyForm();
	return 0;
}