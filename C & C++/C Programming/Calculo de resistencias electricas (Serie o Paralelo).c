int main() {
         int R1,R2,R3;
         float Rt;
         char tipo,resp;
        do {
        printf("Ingrese resistencia R1: ");
         scanf("%d",&R1);
         printf("Ingrese resistencia R2: ");
         scanf("%d",&R2);                      
         printf("Ingrese resistencia R3: ");
         scanf("%d",&R3);                         
         printf("Ingrese la distribucion de las resistencias (S/P): ");      
         tipo = getch();
         printf("%c\n",tipo);
         if((R1>=R2)&&(R1>=R3)){
                                printf("La resistencia de mayor valor es %d\n",R1);
                                }
         else if ((R2>=R1)&&(R2>=R3)){
                                      printf("La resistencia de mayor valor es %d\n",R2);
                                      }
         else {
              printf("La resistencia de mayor valor es %d\n",R3);
              }        
         if(tipo='S'){
                      Rt=(float)R1+R2+R3;
                      }                               
         else if(tipo = 'P'){
                       Rt=(float) 1/((1/R1)+(1/R2)+(1/R3));
                       }
         printf("El valor de Rt = %.2f\n",Rt);
         
         printf("Desea realizar otra operacion (S/N):");
       //  scanf("%c",&resp);     USAR GETCH()
         resp=getch();
         printf("%c\n",resp);
            }
         
         while(resp=='S');           
         
         system("pause");
         return 0;              
}







