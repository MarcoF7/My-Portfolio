#include <time.h>
#include <windows.h>
#include <stdio.h>
#include <math.h>

void Generar( int [][]);
void Imprimir(int [][]);
void Girar(int [][], char );

int main(){
         char signo;
         int num_giros,i;
         int mat[4][4]; 
         srand(time(NULL));
         Generar(mat);
         Imprimir(mat);  
         printf("Ingrese la cantidad de giros de 90 a dar y el sentido:\n");
         scanf("%d %c",&num_giros,&signo);
    
         for(i=1;i<=num_giros;++i){
             Girar(mat,signo);
         }
         Imprimir(mat);
         system("pause");
}

void Generar(int mat[][4]){
      int i,j;
      for(i=0;i<4;++i){
          for(j=0;j<4;++j){
              mat[i][j]= rand()% 99 + 1;
          }
      }
}

void Imprimir( int mat[][4]){
      int i,j;
      for(i=0;i<4;++i){
          for(j=0;j<4;++j){
              printf("%2d ",mat[i][j]);
          }
          printf("\n");
      }
}

void Girar( int mat[][4], char signo){
      int i,j;
      int arr[4][4];
      for(i=0;i<4;++i){  //para no perder a mat
          for(j=0;j<4;++j){
              arr[i][j]=mat[i][j];
          }
      }
      if(signo=='+'){
           for(i=0;i<4;++i){
               for(j=0;j<4;++j){
                   mat[i][j]=arr[4-1-j][i];
               } 
           }
      }
      else if(signo=='-'){
            for(i=0;i<4;++i){
                for(j=0;j<4;++j){
                    mat[i][j]=arr[j][4-1-i];
                }
            }
      }
}















