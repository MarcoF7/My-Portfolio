int EsPrimo(int n){
      int cont=0,i;
      for(i=1;i<=n;++i){
             if(n%i==0) cont++;
      }
      if(cont==2) return 1;
      else return 0;
}

int main(){
         int i,j=0,k=0;
         int n,aux;
         do{
         printf("Ingrese N: ");
         scanf("%d",&n);
         aux=n;
         } while(n<=1);
         printf("Descomposicion: ");
         for(i=2;i<=n;++i){
              aux=n;
              if(EsPrimo(i)){
                             j=0;
                             while(aux%i==0){
                                        ++j;
                                        aux=aux/i;
                                        
                             }          
                             if(j>0){
                                  if(k==0) // solo la primera ves entrara a este if
                                      printf("%d^%d ",i,j);
                                  else 
                                      printf("* %d^%d ",i,j);
                             ++k;    
                             }  
              }
              
         }
         printf("\n");
         system("pause");
}











































