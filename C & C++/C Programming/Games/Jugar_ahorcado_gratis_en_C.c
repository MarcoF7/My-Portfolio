#include <time.h>
#include <windows.h>
#include <stdio.h>
#include <math.h>
#include <stdlib.h>

int main(){
         int intentos=0,digito,intentos_acertados=0,intentos_errados=0,k,i,j;
         char arr1[4]={'-','-','-','-'};
         int arr2[4]={10,10,10,10};
         int arr3[4]={3,8,2,3};   // esta sera la clave numerica del juego
         
         printf("Juego El Ahorcado Digital:\n");
         printf("    |====|\n");
         printf("    |\n");
         printf("    |\n");          
         printf("    |\n"); 
         printf("    |\n"); 
         printf("    |\n"); 
         printf("    |======\n"); 
         printf("Clave Numerica: ");
         
         while(intentos_errados<6){
         k=0;
         for(i=0;i<4;++i){ //imprimiendo clave numerica
               if(arr2[i]>=0 && arr2[i]<=9){
                     printf("%d",arr2[i]);
               }
               else printf("%c",arr1[i]);
         } 
         intentos++;
         printf("\nIntento %d Ingrese digito: ",intentos);
         scanf("%d",&digito);
         for(i=0;i<4;++i){
                if(digito==arr3[i]){
                       arr2[i]=digito;
                       intentos_acertados++;
                       k++;
                       
                }
                
         }
         if(intentos_acertados==4){
                                   printf("Adivinaste la clave en %d intentos\n",intentos);
                                   printf("Clave numerica: ");
                                   for(i=0;i<4;++i){
                                          printf("%d",arr3[i]);
                                      }
                                   printf("\n");
                                   break;
                                   }
                                   
         
         if(k==0){  // solo entra si el digito introducido no esta en la CLAVE NUMERICA
                   intentos_errados++;
                   switch(intentos_errados){
                              case 1: printf("Juego El Ahorcado Digital:\n");
                                      printf("    |====|\n");
                                      printf("    |    O\n");
                                      printf("    |\n");          
                                      printf("    |\n"); 
                                      printf("    |\n"); 
                                      printf("    |\n"); 
                                      printf("    |======\n"); 
                                      printf("Clave Numerica: ");
                                      break;
                              case 2: printf("Juego El Ahorcado Digital:\n");
                                      printf("    |====|\n");
                                      printf("    |    O\n");
                                      printf("    |    |\n");          
                                      printf("    |    |\n"); 
                                      printf("    |\n"); 
                                      printf("    |\n"); 
                                      printf("    |======\n"); 
                                      printf("Clave Numerica: ");
                                      break;
                              case 3: printf("Juego El Ahorcado Digital:\n");
                                      printf("    |====|\n");
                                      printf("    |    O\n");
                                      printf("    |   /|\n");          
                                      printf("    |    |\n"); 
                                      printf("    |\n"); 
                                      printf("    |\n"); 
                                      printf("    |======\n"); 
                                      printf("Clave Numerica: ");
                                      break;
                              case 4: printf("Juego El Ahorcado Digital:\n");
                                      printf("    |====|\n");
                                      printf("    |    O\n");
                                      printf("    |   /|\\\n");          
                                      printf("    |    |\n");
                                      printf("    |\n"); 
                                      printf("    |\n"); 
                                      printf("    |======\n"); 
                                      printf("Clave Numerica: ");
                                      break;  
                              case 5: printf("Juego El Ahorcado Digital:\n");
                                      printf("    |====|\n");
                                      printf("    |    O\n");
                                      printf("    |   /|\\\n");        
                                      printf("    |    |\n");
                                      printf("    |   /\n"); 
                                      printf("    |\n"); 
                                      printf("    |======\n"); 
                                      printf("Clave Numerica: ");
                                      break;
                               case 6: printf("Juego El Ahorcado Digital:\n");
                                      printf("    |====|\n");
                                      printf("    |    O\n");
                                      printf("    |   /|\\\n");       
                                      printf("    |    |\n");
                                      printf("    |   / \\\n"); 
                                      printf("    |\n"); 
                                      printf("    |======\n"); 
                                      printf("AHORCADO!\n");
                                      printf("Clave numerica: ");
                                      for(i=0;i<4;++i){
                                          printf("%d",arr3[i]);
                                      }
                                      printf("\n");
                                      break;                                     
                              
                   }
         }
         
         
         } 
         
         
         system("pause");
}                       

         
         
         
         
         
         
         
         
         
         
         
         
             
