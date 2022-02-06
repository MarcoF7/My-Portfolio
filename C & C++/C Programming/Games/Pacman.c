#include <time.h>
#include <windows.h>
#include <stdio.h>
#include <math.h>
#include <stdlib.h>

int main(){
         int posx,posy;
         float menor,distancia_nueva;
         unsigned char arr[10][10]={{219,219,219,219,219,219,219,219,219,219},
                                    {219,250,219,250,219,250,219,250,219,219},
                                    {219,250,250,250,250,250,250,250,250,219},
                                    {219,250,219,250,219,250,219,250,219,219},
                                    {219,250,250,250,250,250,250,250,250,219},
                                    {219,250,219,250,219,250,219,250,219,219},
                                    {219,250,250,250,250,250,250,250,250,219},
                                    {219,250,219,250,219,250,219,250,219,219},
                                    {219,250,250,250,250,250,250,250,250,219},
                                    {219,219,219,219,219,219,219,219,219,219}};
         
         srand(time(NULL)); //PARA K SIEMPRE CAMBIE LAS POSICIONES ALEATORIAS
         int posx_pac,posy_pac,posx_nueva_fan,posy_fan;
      //   int nro_pac=5;  // LOS POSIBLES VALORES SON DE 1 A 48 en el laberinto
         int nro_pac=(rand()%48+1); // se escoge un numero al azar del 1 al 48
      //   int nro_fan=36;
         int nro_fan=(rand()%48+1);
         int i,j,k=0,w=1,m,n;
         while(1){
         
         menor=10000.0;
         k=0;
         if(w==1){ //ENTRA SOLO EN LA PRIMERA ITERACION!!
               for(i=0;i<10;++i){
                  for(j=0;j<10;++j){
                      if(arr[i][j]==219) printf("%c",arr[i][j]);
                      else {
                         ++k;
                         if(nro_pac==k){  //SOLO ENTRA 1 VES A ESTE IF
                            printf("%c",2);
                            posx_pac=i;
                            posy_pac=j;
                         }
                         else if(nro_fan==k){ //SOLO ENTRA UNA VEZ A ESTA IF
                            printf("%c",148);
                            posx_nueva_fan=i;
                            posy_fan=j; 
                         }
                         else printf("%c",arr[i][j]);
                      }
                  }
                  printf("\n");
               }         
         printf("Posicione inical (x y) de PACMAN:%d %d\n",posx_pac,posy_pac);
         printf("Posicione inical (x y) del FANTASMA:%d %d\n",posx_nueva_fan,posy_fan);
         
         }// TERMINA SI W=1
         
         else {  // ENTRA SIEMPRE DESPUES DE LA PRIMERA ITERACION
            for(m=(posx_nueva_fan-1);m<=(posx_nueva_fan+1);++m){  // calculando nueva posicion del fantasma
                    for(n=(posy_fan-1);n<=(posy_fan+1);++n){
                             if(arr[m][n]==250){ //SOLO ANALIZA SI NO ES PARED 
                                    distancia_nueva=pow((posx_pac*1.0-m),2)+pow((posy_pac*1.0-n),2); 
                                    distancia_nueva=sqrt(distancia_nueva);
                                    if(distancia_nueva<menor){
                                         menor=distancia_nueva;
                                         posx=m; //se usa un posx y un posy PARA NO ALTERAR la posicion actual del fantasma!!!!!
                                         posy=n;
                                    }
                             }
                    }
            }
            posx_nueva_fan=posx;
            posy_fan=posy;
            
            if(menor==0.0){
                  printf("\nGAME OVER!!!!!!!\n");
                  break;
                  
            }
            for(i=0;i<10;++i){
                  for(j=0;j<10;++j){
                      if(arr[i][j]==219) printf("%c",arr[i][j]);
                      else {
                         ++k;
                         if(nro_pac==k){
                            printf("%c",2);
                            posx_pac=i;
                            posy_pac=j;
                         }
                         else if((i==posx_nueva_fan) && (j==posy_fan)){
                            printf("%c",148);
                         }
                         else printf("%c",arr[i][j]);
                      }
                  }
                  printf("\n");
               }  
            
         
         
         }
         
         
         
         ++w;
         
         //system("pause"); 
         Sleep(2000);
         system("CLS"); 
         }  
         system("pause"); 
}
