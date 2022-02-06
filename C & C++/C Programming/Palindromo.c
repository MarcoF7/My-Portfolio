int main(){
         int i=0,j,k=0;
         char car1[1000];
         char car2[1000]; 
         char car3[1000];   //car3 es la palabra invertida
         printf("Ingrese palabra:\n");
         
         scanf("%c",&car1[i]);
         for(;car1[i]!='\n';scanf("%c",&car1[i])){
                                                  if(car1[i]==' ') continue;
                                                  car2[i]=car1[i];
                                                  
                                                  ++i;
                                                  }
         
         for(j=0;j<i;++j){
                          car3[j]=car2[i-1-j];
                          }
         for(j=0;j<i;++j){
                          if(car1[j]!=car3[j]){
                                               printf("no es palindromo\n");
                                               ++k;
                                               break;
                                               }
                          }
         if(k==0){  //siginifica que nunca imprimio "no es palindromo"
                  printf("es palindromo\n");
                  }
         
         system("pause");
}
