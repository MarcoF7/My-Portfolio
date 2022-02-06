int main(){
         int i,j;
         int arr[40]={0};
         int vendidos=0,no_vendidos=40,num;
         printf("Los estados de los asientos son: LIBRE=0, VENDIDO=1\n");
         do{
         printf("Cual asiento quieres comprar?: ");
         scanf("%d",&num);
         i=num;
         if(i>=1 && i<=40) {
                 vendidos++;
                 no_vendidos--;
                 arr[i-1]=1;
                 for(j=0;j<40;++j){
                                   printf("Asiento %.2d= %d   ",(j+1),arr[j]); 
                                   if((j+1)%4==0) printf("\n");
                                   }
                 }
         else {
              printf("Asiento fuera del rango del autobus.\n");
              
              }
                      
         printf("\n");
         printf("Asientos vendidos    : %.2d\n",vendidos);
         printf("Asientos no vendidos : %d\n",no_vendidos);
         printf("\n");
         }while(no_vendidos!=0);
         
         system("pause");
}
