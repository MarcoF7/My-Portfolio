EsPrimo(int num){
       int divisor=1,i=1,cantDiv=0;
        while(i<=num){
                      if ((num%i)==0) cantDiv++;
                      
                      i++;
                      }
        if(cantDiv==2) {
                       return 1;
                       }
        else {
             return 0;
             }
}

int main() {
        int numero,numAEvaluar=1,j=1;
        printf("Ingrese un numero:");
        scanf("%d",&numero);
        while(j<=numero){
                         if(EsPrimo(numAEvaluar)) {    
                                             
                                             printf("El numero primo (%d) es: %d\n",j,numAEvaluar);
                                             j++;
                                             }
                         
                         numAEvaluar++;
                         }
        system("pause");
        return 0;
}
