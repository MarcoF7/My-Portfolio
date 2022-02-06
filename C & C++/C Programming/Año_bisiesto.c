#include<stdio.h>
int main() {
         int ano;
         printf("Ingrese un ano:");
         scanf("%d",&ano);
         if ((ano%4==0) && (ano%100 !=0) || (ano%400==0)){
                         printf("Es ano bisisesto\n");
                         }
         else {
              printf("No es ano bisiesto\n");
         }
         system("pause");
         return 0;
}
