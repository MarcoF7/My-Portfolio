#define MAX 10000

int Tiene_Ant(char * , char** *, int );
char *Sacar_Ant(char * , char** *, int); 
int SonIguales(char *, char *);

int main(){
         int cantidad,i;
         char** *palabras;
         char *antonimo;         
         printf("Ingrese la cantidad de palabras: ");
         scanf("%d",&cantidad);
         palabras=(char ***)malloc(cantidad * sizeof(char **));
         
         for(i=0;i<cantidad;++i){
             *(palabras+i)=(char **)malloc(2*sizeof(char *));
             *(*(palabras+i)+0)=(char *)malloc(sizeof(char)*100); //max de 100 caracteres
             *(*(palabras+i)+1)=(char *)malloc(sizeof(char)*100);
             scanf("%s %s",*(*(palabras+i)+0),*(*(palabras+i)+1));
         }
         
         char pal[100];
         while(1){
               printf("Ingrese la palabra a consultar('Q' para terminar):\n");
               scanf("%s",pal);
               if(*pal=='Q') break; 
               if(Tiene_Ant(pal,palabras,cantidad)){                                 
                  antonimo=Sacar_Ant(pal,palabras,cantidad);
                  printf("El antonimo de %s es %s\n",pal,antonimo);
               }
               else {
                  printf("La palabras no se encuentra en el diccionario\n");
               }
               
         }
         printf("Gracias por usar el diccionario\n");
         system("pause");
}

int Tiene_Ant(char *pal, char** *palabras, int cant){
     int i;
     char *pal1;
     char *pal2;
     for(i=0;i<cant;++i){
         pal1=*(*(palabras+i)+0);
         pal2=*(*(palabras+i)+1);
         if(SonIguales(pal,pal1)) return 1;
         if(SonIguales(pal,pal2)) return 1;
     }
     return 0;
}

int SonIguales(char *pal1, char *pal2){
     int i,j,k;
     for(i=0;*(pal1+i)!='\0';++i);       
     for(j=0;*(pal2+j)!='\0';++j);
     if(i==j){
        for(k=0;k<i;++k){
            if(*(pal1+k)!= *(pal2+k)) return 0;
        }
     }
     else return 0; 
     return 1; 
}

char *Sacar_Ant(char *pal, char** *palabras, int cant){
     int i;
     char *pal1;
     char *pal2;
     for(i=0;i<cant;++i){
         pal1=*(*(palabras+i)+0);
         pal2=*(*(palabras+i)+1);
         if(SonIguales(pal,pal1)){
            return pal2;
         }
         else if(SonIguales(pal,pal2)){
             return pal1;     
         }
     }
     
}
























