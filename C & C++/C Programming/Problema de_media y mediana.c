
int main(){
    int A,B;
    int C,menor,mayor;
    do{
       printf("Ingrese dos numeros enteros[A B]: ");
       scanf("%d %d",&A,&B);
       if(A==B){
                printf("Los numeros ingresados deben ser distintos\n");
                }
       } while(A==B);
    if(A>B){
            mayor=A;
            menor=B;
            }   
    else {
         menor=A;
         mayor=B;
         }       
    C=(2*menor)-mayor;
    printf("El minimo entero C, tal que la media y la mediana de %d, %d y C son iguales es: %d\n",A,B,C);      
    system("pause");                    
    return 20;     
}
