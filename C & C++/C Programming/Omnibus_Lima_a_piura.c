#define CAPACIDAD 55
#include <time.h>
#include <windows.h>
#include <stdio.h>
#include <math.h>
#include <stdlib.h>

int main(){
         int n=0,i=1,nbajan,nsuben;
         while(i<=7){
                     switch(i){
                               case(1): printf("Paradero: Ciudad de Lima\n");break;
                               case(2): printf("Paradero: Ciudad de Huacho\n");break;
                               case(3): printf("Paradero: Ciudad de Chimbote\n");break;
                               case(4): printf("Paradero: Ciudad de Trujillo\n");break;
                               case(5): printf("Paradero: Ciudad de Chiclayo\n");break;
                               case(6): printf("Paradero: Ciudad de Piura\n");break;
                               case(7): printf("Paradero: Ciudad de Tumbes\n");break;
                               }
                     printf("Pasajeros que arriban a la ciudad: %d\n",n);
                     do{
                        printf("Ingrese numero de pasajeros que bajan es esta ciudad:");
                        scanf("%d",&nbajan);
                        if((n-nbajan)<0) printf("No pueden bajar mas de los que habia\n");
                        
                        } while((n-nbajan)<0);
                     n=n-nbajan;   
                     do{
                        printf("Ingrese numero de pasajeros que suben en esta ciudad:");
                        scanf("%d",&nsuben);
                        if((n+nsuben)>CAPACIDAD) printf("Numero de pasajeros no puede exceder la capacidad del omnibus\n");
                        
                        }while((n+nsuben)>CAPACIDAD); 
                     n = n+nsuben;
                     printf("... viajando ...\n");
                                        
                                        
                              
                     ++i;
                     }
         if(i==8){
                  i=i-1;
                  n=0;
                  
                  while(i>=1){
                               switch(i){
                               case(1): printf("Paradero: Ciudad de Lima\n");break;
                               case(2): printf("Paradero: Ciudad de Huacho\n");break;
                               case(3): printf("Paradero: Ciudad de Chimbote\n");break;
                               case(4): printf("Paradero: Ciudad de Trujillo\n");break;
                               case(5): printf("Paradero: Ciudad de Chiclayo\n");break;
                               case(6): printf("Paradero: Ciudad de Piura\n");break;
                               case(7): printf("Paradero: Ciudad de Tumbes\n");break;
                               }
                              printf("Pasajeros que arriban a la ciudad: %d\n",n);
                              do{
                                 printf("Ingrese numero de pasajeros que bajan es esta ciudad:");
                                 scanf("%d",&nbajan);
                                 if((n-nbajan)<0) printf("No pueden bajar mas de los que habia\n");
                        
                                 } while((n-nbajan)<0);
                               n=n-nbajan;   
                              do{
                                 printf("Ingrese numero de pasajeros que suben en esta ciudad:");
                                 scanf("%d",&nsuben);
                                 if((n+nsuben)>CAPACIDAD) printf("Numero de pasajeros no puede exceder la capacidad del omnibus\n");
                        
                                 }while((n+nsuben)>CAPACIDAD); 
                              n = n+nsuben;
                              printf("... viajando ...\n");
                              i--;
                              }
                            }            
         system("pause");
         return 0;
}
















