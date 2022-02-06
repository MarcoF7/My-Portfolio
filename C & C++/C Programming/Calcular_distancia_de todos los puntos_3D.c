#include<stdio.h>
#include<math.h>
#include<time.h>
#include <stdlib.h>

int main(){
         float temp;
         char car='A';
         int N,i,j,k,m,cant_dist;
         do{
            printf("Ingrese numero de puntos(N<=20) :");
            scanf("%d",&N);
             
         }  while(N<0 || N>20);   
         
         float arreglo[N][3];
         
         for(i=0;i<N;++i){
                          printf("Ingrese punto %c (x y z): ",car);
                          car++; 
                          for(j=0;j<3;++j){
                                           scanf("%f",&arreglo[i][j]);
                                           }
                          }
         
         cant_dist=((N)*(N-1))/2.0;
         float dist[cant_dist][3];
         float D[10000]={0.0};
         
         for(i=0;i<3;++i){ //tres porque son tres variables: x:i=0   y:i=1   z:i=2
                          m=0;
                          for(j=0;j<(N-1);++j){
                                           for(k=j+1;k<N;++k){  
                                                              dist[m][i]=pow((arreglo[j][i]-arreglo[k][i]),2); 
                                                              ++m;
                                                              }
                                           }
                          }
         for(i=0;i<cant_dist;++i){ //Sumando los ((x-x0)^2+(y-y0)^2+(z-z0)^2) y colocandolos en un nuevo ARREGLO
                                   for(j=0;j<3;++j){
                                                    D[i]+=dist[i][j];
                                                    }
                                   }
         for(i=0;i<cant_dist;++i){  //sacando raiz a (x-x0)^2+(y-y0)^2+(z-z0)^2
                                  D[i]=sqrt(D[i]);
                                  }                        
                                   
         for(i=0;i<(cant_dist-1);++i){
                                      for(j=i+1;j<cant_dist;++j){
                                                                 if(D[i]>D[j]){
                                                                               temp=D[i];
                                                                               D[i]=D[j];
                                                                               D[j]=temp;
                                                                               }
                                                                 }
                                      }
         for(i=0;i<cant_dist;++i){
                                  printf("%.3f\n",D[i]);
                                  }                             
         system("pause");
}









