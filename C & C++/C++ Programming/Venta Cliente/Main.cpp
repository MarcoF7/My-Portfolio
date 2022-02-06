#include "MyForm.h"
// ir agregando ventas al arreglo
//

using namespace Project1;

int main(array<String^>^ args)
{
	Application::EnableVisualStyles();
	Application::SetCompatibleTextRenderingDefault(false);
	Application::Run(gcnew MyForm());  // este ejecuta el programa
	return 0;
}


//Convert::ToString