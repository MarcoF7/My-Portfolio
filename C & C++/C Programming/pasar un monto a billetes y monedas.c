int calcularBilletes(int , int );
int calcularMonedas(int , int );

int main(){
         int i,b100,b50,b20,b10,m5,m2,m1;
         float a1[4]={45.00,234.56,123.20,899.00};
         int a2[4];
         for(i=0;i<4;++i) a2[i]=a1[i];
         for(i=0;i<4;++i){
             if((a1[i]-(a2[i]*1.0))>= 0.50) a2[i]++;  //a2 es el arreglo de los montos enteros con aproximacion
         }
         
         printf("Dinero          b100    b50     b20     b10     m5      m2      m1\n");
         printf("------------------------------------------------------------------\n");
         for(i=0;i<4;++i){
             b100=calcularBilletes(a2[i],100);
             a2[i]-=(b100*100); //actualizando monto
             b50=calcularBilletes(a2[i],50);
             a2[i]-=(b50*50);
             b20=calcularBilletes(a2[i],20);
             a2[i]-=(b20*20);
             b10=calcularBilletes(a2[i],10);
             a2[i]-=(b10*10);
             m5=calcularMonedas(a2[i],5);
             a2[i]-=(m5*5);
             m2=calcularMonedas(a2[i],2);
             a2[i]-=(m2*2);
             m1=calcularMonedas(a2[i],1);
             a2[i]-=(m1*1);
             
             printf("%6.2f%14d%7d%8d%8d%7d%8d%8d ",a1[i],b100,b50,b20,b10,m5,m2,m1);
             printf("\n");
         }
         
         system("pause");
}

int calcularBilletes(int monto, int tipo){
    int cant;
    cant=monto/tipo;
    return cant;
}

int calcularMonedas(int monto, int tipo){
    int cant;
    cant=monto/tipo;
    return cant;
}






