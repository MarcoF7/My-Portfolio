#include <time.h>
#include <windows.h>
#include <stdio.h>
#include <math.h>
#include <stdlib.h>

int main(){
         /* char *a, cad[81];
          a=(char*)gets(cad);
          printf("%s\n",a);      */
          int i=0,j,k,m=0,n,num,cantidad;
          //char *cad;
          char temp;
          char cad[30];//para guardar la palabra a escribir
          char cadd[30]={0};//este es de tamaño 30 fijo, es todo
          printf("Ingrese la cadena a mostrar: ");
          scanf("%c",& *(cad+i));
          for(;*(cad+i)!='\n';){
              ++i;
              scanf("%c",& *(cad+i));
          }
          *(cad+i)=0; //i da numero de elementos
          printf("%s\n",cad);
          printf("Ingrese la cantidad de veces a desplazar: ");
          scanf("%d",&cantidad);
          num=i*2;
          num=30-num;
          num=num/2;
          
          for(j=0;j<30;++j){  //inicializando la barra de 30 caracteres!!
              
              if(j<num) *(cadd+j)=' ';
              else if(j>=num && j<=(num+(i*2-1))){
                 for(k=1;k<=2;++k){
                     if(k%2==1){
                        cadd[j]=cad[m];
                        ++m;
                        ++j;
                     }
                     else cadd[j]=' ';   
                 }
              }
              else if(j>(num+(i*2-1))) cadd[j]=' ';
          }
          
          for(n=0;n<30;++n){
             printf("%c",cadd[n]);
          }
          printf("\n");
          
          for(j=0;j<cantidad;++j){
              temp=*(cadd+0);
              for(k=0;k<30;++k){ //moviendo 1 a la izquierda
                  
                  if(k==29){
                     *(cadd+k)=temp;
                             
                  }else *(cadd+k)=*(cadd+k+1);              
              }                  
               for(m=0;m<30;++m){
                  printf("%c",cadd[m]);
               }
               printf("\n");
              
              Sleep(700);
              system("CLS");
          }
          system("pause");        
}









