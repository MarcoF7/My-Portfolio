Factorial(int num){
              
              int i=1,fac=1;
              if(num >0){
              while(i<=num){
                            fac=fac*i;
                            i++;
                            }
               return fac;
                           }
              else {
                   return 1;
                   }              
              }

int main(){
        int potencia,k=0,n,coef;
        printf("Sea:  (x+y)^n  donde n es la potencia\n");
        printf("Ingrese la potencia del binomio ( >0 ):");
        scanf("%d",&n);
        printf("Los coeficientes del binomio con n=%d son:\n",n);
        if(potencia>0){
                       while(k<=n){
                                   coef=((Factorial(n))/(Factorial(k)*Factorial(n-k)));
                                   k++;
                                   printf("%d \n",coef);
                                   }
                       
                       }
        else printf("Potencia debe ser mayor que cero\n");
        system("pause");
        return 0;               
}
