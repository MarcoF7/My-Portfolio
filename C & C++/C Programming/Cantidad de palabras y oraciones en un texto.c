int main(){
         char **texto=(char**)malloc(200*sizeof(char*));
         int i=0,j,k;
         int cont_esp=0,cont_punt=0;
         printf("Ingrese el parrafo de texto:\n");
         while(1){
               *(texto+i)=(char*)malloc(200*sizeof(char));
               //scanf("%s",*(texto+i));   NO USAR SCANF, XQ EL SCANF TERMINA CUANDO ENCUENTRA '\0' O ' '
               gets(*(texto+i));
               for(j=0;*(*(texto+i)+j)!=0;++j);//j da numero de elementos de cada linea
               for(k=0;k<j;++k){
                   if(*(*(texto+i)+k)==' ') cont_esp++;
               }
               for(k=0;k<j;++k){
                   if(*(*(texto+i)+k)=='.') cont_punt++;
               }
               if(*(*(texto+i)+j-1)=='.') break;
               cont_esp++;
               ++i; //i da numero de lineas - 1 
         }
         
         printf("\nCantidada de palabras: %d\n",cont_esp+1);
         printf("Cantidada de oraciones: %d\n",cont_punt);
         printf("Cantidada de lineas: %d\n",i+1);
         system("pause");
}
