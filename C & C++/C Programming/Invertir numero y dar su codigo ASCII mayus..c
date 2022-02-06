int main() {
       int numero,nuevoNum=0,digito,num;
       char letra;
       printf("Ingrese un numero:");
       scanf("%d",&numero);
       letra=numero;
       num = numero;
       if(numero<1000){
                       while(numero!=0){
                                        digito=numero%10;
                                        numero=numero/10;
                                        nuevoNum=(nuevoNum*10)+digito;
                                        }
                       if(num>=65 && num<=90){
                                   printf("El equivalente mayusculo ASCII es %c y el numero invertido es %d\n",letra,nuevoNum);
                                    }  
                       else {
                             printf("El numero no tiene equivalente mayusculo en ASCII y el numero invertido es %d\n",nuevoNum);
                            }
                       } 
       
       
       else {
            printf("El numero es invalido\n");
            }
       
                                       
                           
       system("pause");
       return 0;
}
