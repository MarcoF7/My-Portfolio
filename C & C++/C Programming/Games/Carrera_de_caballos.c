#include <stdio.h>
#include <math.h>
#include <time.h>
#include <stdlib.h>
#define MAX 50
int main(){
         srand(time(NULL));
         int a=1,i,j;
         int mov_A,mov_B,mov_C,mov_D,mov_E;
         int cant_A=0,cant_B=0,cant_C=0,cant_D=0,cant_E=0;
         char arr1[MAX]={0};
         char arr2[MAX]={0};
         char arr3[MAX]={0};
         char arr4[MAX]={0};
         char arr5[MAX]={0};
         while(1){
               printf("\nVez Nro %d\n\n",a); 
               mov_A=rand()%11;
               mov_B=rand()%11;
               mov_C=rand()%11;
               mov_D=rand()%11;
               mov_E=rand()%11;
               printf("Kilometros avanzados por A: %d\n",mov_A);
               printf("Kilometros avanzados por B: %d\n",mov_B);
               printf("Kilometros avanzados por C: %d\n",mov_C);
               printf("Kilometros avanzados por D: %d\n",mov_D);
               printf("Kilometros avanzados por E: %d\n",mov_E);
               printf("1)");
               cant_A+=mov_A;
               if(cant_A<49){
               *(arr1+cant_A)='A';
               }else *(arr1+49)='A';
               for(i=0;i<MAX;++i){
                   printf("%c",arr1[i]);
               }
               printf("\n");
                *(arr1+cant_A)='\0';
               
               printf("2)");
               cant_B+=mov_B;
               if(cant_B<49){
               *(arr2+cant_B)='B';
               }else *(arr2+49)='B';
               for(i=0;i<MAX;++i){
                   printf("%c",arr2[i]);
               }
               printf("\n");
                *(arr2+cant_B)='\0';
               
               printf("3)");
               cant_C+=mov_C;
               if(cant_C<49){
               *(arr3+cant_C)='C';
               }else *(arr3+49)='C';
               for(i=0;i<MAX;++i){
                   printf("%c",arr3[i]);
               }
               printf("\n");
                *(arr3+cant_C)='\0';
               
               printf("4)");
               cant_D+=mov_D;
               if(cant_D<49){
               *(arr4+cant_D)='D';
               }else *(arr4+49)='D';
               for(i=0;i<MAX;++i){
                   printf("%c",arr4[i]);
               }
               printf("\n");
                *(arr4+cant_D)='\0';
                
               printf("5)");
               cant_E+=mov_E;
               if(cant_E<49){
               *(arr5+cant_E)='E';
               }else *(arr5+49)='E';
               for(i=0;i<MAX;++i){
                   printf("%c",arr5[i]);
               }
               printf("\n");
                *(arr5+cant_E)='\0';
               if(*(arr1+49)=='A' || *(arr2+49)=='B' || *(arr3+49)=='C' || *(arr4+49)=='D' || *(arr5+49)=='E'){
               //SOLO ENTRA SI X LO MENOS UN CABALLO LLEGO A LA META!!!!
               if(*(arr1+49)=='A' && *(arr2+49)!='B' && *(arr3+49)!='C' && *(arr4+49)!='D' && *(arr5+49)!='E'){
                   printf("Jugador 1 ha ganado!\n");
                   break;
               }else if(*(arr1+49)!='A' && *(arr2+49)=='B' && *(arr3+49)!='C' && *(arr4+49)!='D' && *(arr5+49)!='E'){
                   printf("Jugador 2 ha ganado!\n");
                   break;
               }else if(*(arr1+49)!='A' && *(arr2+49)!='B' && *(arr3+49)=='C' && *(arr4+49)!='D' && *(arr5+49)!='E'){
                   printf("Jugador 3 ha ganado!\n");
                   break;
               }else if(*(arr1+49)!='A' && *(arr2+49)!='B' && *(arr3+49)!='C' && *(arr4+49)=='D' && *(arr5+49)!='E'){
                   printf("Jugador 4 ha ganado!\n");
                   break;
               }else if(*(arr1+49)!='A' && *(arr2+49)!='B' && *(arr3+49)!='C' && *(arr4+49)!='D' && *(arr5+49)=='E'){
                   printf("Jugador 5 ha ganado!\n");
                   break;
               }else{
                  printf("\n\nEMPATE!!!!\n");
                  break;
               }
               }
               ++a;
               system("pause");
         }
         
         system("pause");
}


















