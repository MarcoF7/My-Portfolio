#include <iostream>
#include <string>
//#include <sstream>

using namespace std;

void roman_to_dec(int, int, string&);

int main() {
	int num, mil, cen, dec;
	string roman;
	cout << "Ingrese un numero: ";
	scanf_s("%d", &num);

	/*mil = num / 1000;
	num -= 1000 * mil;
	cen = num / 100;
	num -= 100 * cen;
	dec = num / 10;
	num -= 10 * dec;*/
	mil = num / 1000;
	cen = (num % 1000) / 100;
	dec = (num % 100) / 10;
	num = num % 10;

	roman_to_dec(mil, 1000, roman);
	roman_to_dec(cen, 100, roman);
	roman_to_dec(dec, 10, roman);
	roman_to_dec(num, 1, roman);

	cout << roman << endl;
	return 1;
}

void roman_to_dec(int num, int unit, string& roman) {
	char help1, help2, help3;
	switch (unit) {
	case 1:
		help1 = 'X';
		help2 = 'V';
		help3 = 'I';
		break;
	case 10:
		help1 = 'C';
		help2 = 'L';
		help3 = 'X';
		break;
	case 100:
		help1 = 'M';
		help2 = 'D';
		help3 = 'C';
		break;
	case 1000:
		break;
	default:
		return;
		break;
	}
	for (int i = num; i > 0; i--) {
		if (unit == 1000) {
			roman += "M";
			continue;
		}
		if (i == 9) {
			roman += help3;
			roman += help1;
			i -= 8;
		}
		else if (i >= 5) {
			roman += help2;
			i -= 4;
		}
		else if (i == 4) {
			roman += help3;
			roman += help2;
			i -= 3;
		}
		else 
			roman += help3;
	}
}