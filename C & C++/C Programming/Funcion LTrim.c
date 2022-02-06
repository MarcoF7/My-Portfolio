char *LTrim(char *, char );

int main(){
         char *pal=(char *)malloc(100*sizeof(char));
         char *pal2=(char *)malloc(100*sizeof(char));
         char car=' ';
         printf("Ingrese texto:");
         scanf("%s",pal); 
         pal = LTrim(pal,car);        
         printf("%s\n",pal);
         system("pause");
         return 0;
}

char *LTrim(char *texto, char car){
      int i,j,k,m;
      for(i=0;*(texto+i)!=0;++i);
      i=i/2;
      j=0;
      for(m=0;m<i;++m){
          if(*(texto+j)==car){
             //quita el texto[j] de texto
             for(k=j;*(texto+k)!=0;++k){
                 *(texto+k)=*(texto+k+1);
             }
          }
          else{
             ++j;
          }
      }
      return texto;
}
