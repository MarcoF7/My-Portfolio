long Factorial(int );
int Binomial(int , int );
void Imprimir(int n);

int main(){
         int n;
         printf("Ingrese n: ");
         scanf("%d",&n);
         Imprimir(n);
         printf("\n");
         system("pause");
}

long Factorial(int numero){
     long fact=1;
     int i;
     for(i=1;i<=numero;++i){
         fact=fact*i;
     }
     return fact;
}

int Binomial(int n, int k){  //siempre bota entero, no se necesita colocar float
    int num,den;
    num=Factorial(n);
    den=Factorial(k)*Factorial(n-k);
    return (num/den);
}

void Imprimir(int n){
     int k,coef;
     for(k=0;k<=n;++k){
         coef=Binomial(n,k);
         if(k==0) printf("%d x^%d y^%d",coef,(n-k),k);
         else printf(" + %d x^%d y^%d",coef,(n-k),k);                 
     }
     
}





















