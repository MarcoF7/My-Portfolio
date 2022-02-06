#include <stdio.h>
#define MAX 10000

void Mostrar(void);
void LeerCadena(char *);
void Invertir(char *);
int SonIguales(char * , char *);
void Mezclar(char *, char *, char *);

int main(){
         char opc,a;
         char cad1[MAX]={0};
         char cad2[MAX]={0};
         char cad[MAX]={0};
        // char *cad;
         printf("Programa que realiza operaciones con cadenas\n\n");
         Mostrar();
         printf("? ");
         opc=getch();
         opc=opc-'0';
         printf("%d\n",opc);
         while(1){
               if(opc==0){
                  Mostrar();
                  printf("? ");
                  opc=getch();
                  opc=opc-'0';
                  printf("%d\n",opc);
                  continue;
               }
               else if(opc==1){
                   printf("Cadena 1: (%s)\n",cad1);
                   printf("Cadena 1? ");
                   LeerCadena(cad1);
                   printf("Cadena 1: (%s)\n",cad1);
               }
               else if(opc==2){
                   printf("Cadena 2: (%s)\n",cad2);
                   printf("Cadena 2? ");
                   LeerCadena(cad2);
                   printf("Cadena 2: (%s)\n",cad2); 
               }
               else if(opc==3){
                   printf("Cadena? ");
                   a=getch();
                   a=a-'0';
                   printf("%d\n",a);
                   if(a==1){
                      printf("Cadena 1 original: (%s)\n",cad1);
                      Invertir(cad1);
                      printf("Cadena 1 invertida: (%s)\n",cad1);
                   }
                   else if(a==2){
                      printf("Cadena 2 original: (%s)\n",cad2);
                      Invertir(cad2);
                      printf("Cadena 2 invertida: (%s)\n",cad2); 
                   }
                   else printf("Solo hay 2 cadenas\n");
               }
               else if(opc==4){
                   printf("Cadena 1: (%s)\n",cad1);
                   printf("Cadena 2: (%s)\n",cad2);
                   if(SonIguales(cad1,cad2)){
                      printf("Tienen los mismos caracteres, es palindroma\n");
                   } 
                   else printf("No tienen los mismos caracteres, no es palindroma\n");
               }
               else if(opc==5){
                   Mezclar(cad1,cad2,cad);
                   printf("Cadena: (%s)\n",cad);
               }
               else if(opc==6) break;
               
               printf("\n? ");
               opc=getch();
               opc=opc-'0';
               printf("%d\n",opc); 
         }
         system("pause");
}

void Mostrar(){
     printf("0. Mostrar Menu\n");
     printf("1. Ingresar cadena 1\n");
     printf("2. Ingresar cadena 2\n");
     printf("3. Invertir cadena 1\n");
     printf("4. Comparar cadenas\n");
     printf("5. Mezclar cadenas\n");
     printf("6. Salir\n\n");
}

void LeerCadena(char *cad){
     int i=0;
     scanf("%c",&*(cad+i));
     for(;*(cad+i)!='\n';){
         ++i;
         scanf("%c",&*(cad+i));
     }
     *(cad+i)=0;
}

void Invertir(char *cad){
     char inv[1000],cadd[1000];
     int i,j=0;
     for(i=0;*(cad+i)!=0;++i){    //EN cadd se guarda cad SIN ESPACIOS
         if(*(cad+i)==' ') continue;
         *(cadd+j)=*(cad+i);
         ++j;  
     }
     for(i=0;*(cadd+i)!=0;++i);//i da numero de elementos de cad sin espacios
     
     for(j=0;j<i;++j){
         *(inv+j)=*(cadd+i-j-1);
     }
     for(j=0;j<i;++j){
         cad[j]=inv[j];
     }
     
     cad[j]=0;
}

int SonIguales(char *cad1 , char *cad2){
     char cadd1[1000],cadd2[1000];
     int i,j=0,k=0;
     for(i=0;*(cad1+i)!=0;++i){    
         if(*(cad1+i)==' ') continue;
         *(cadd1+j)=*(cad1+i);
         ++j;  
     }
     for(j=0;*(cadd1+j)!=0;++j); //j da num de elementos
     j=0;
     for(i=0;*(cad2+i)!=0;++i){    
         if(*(cad2+i)==' ') continue;
         *(cadd2+j)=*(cad2+i);
         ++j;  
     }
     for(k=0;*(cadd2+k)!=0;++k);// k da numero de elementos
     if(j==k){
        for(i=0;i<j;++i){
            if(cadd1[i]!=cadd2[i]) return 0;
        } 
     }
     else return 0;
     return 1;
}

void Mezclar(char *cad1, char *cad2, char *cad){
     int i=0,j=0,k=0;//i para cad1  j para cad2   k para cad
     
     while(1){
           if(cad1[i]!=0){  // cuando termine cad1  nunca mas entra
              for(;cad1[i]!=' '&&cad1[i]!=0;){ //i termina con la posicion de ' '
                *(cad+k)=*(cad1+i);            //por ello al final del bucle se debe aumentar en 1
                ++i;
                ++k;
              }
              *(cad+k)=' ';
              ++k;
           }
           
           if(cad2[j]!=0){  // cuando termine cad2  nunca mas entra
              for(;*(cad2+j)!=' '&&*(cad2+j)!=0;){
                 *(cad+k)=*(cad2+j);
                 ++j;
                 ++k;  
              }
              *(cad+k)=' ';
              ++k;
           }
           
           if((*(cad1+i)==0) && (*(cad2+j)==0)) break;
           ++i;          //i y j se HABIAN KEDADO CON LA POSICION DE ' ', por ello se debe aumentar en 1
           ++j;    
     }
     
     --k;
     cad[k]=0; 
     
}




















