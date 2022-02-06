int main(){
         int i=0,num,suma=0,mayor,x,ord=0;
         float promedio;
         printf("Ingrese los numeros para hacer las operaciones (ingrese un numero negativo para finalizar):");
         scanf("%d",&num);
         while(num>=0){
                       ++i;
                       if(i==1){    //solo podra entrar una ves aca
                                mayor=num;
                                }
                       suma=suma+num;
                       x=num;
                       scanf("%d",&num);
                       if(num<x && num>=0)  ord++; 
                       if(num>mayor){
                                     mayor=num;
                                     }
                                
                       }
         
         
         if(i>0){
                 promedio=(float)suma/i;
                 printf("Cantidad:%d\n",i);
                 printf("Promedio:%.2f\n",promedio);
                 printf("El mayor:%d\n",mayor);
                 if(ord==0){
                            printf("Estan ordenados\n");
                            }
                 else printf("No estan ordenados\n");            
                 }
         else {
              printf("No se ingresaron numeros enteros positivos\n");
              }        
         system("pause");
         return 0;   
}








