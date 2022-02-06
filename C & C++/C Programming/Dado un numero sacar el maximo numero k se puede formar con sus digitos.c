long Retirar_Cifra(long numero, int cifra){
      long nuevo_num=0;
      int digito,bandera=1;
      while(numero!=0){
            digito=numero%10;
            if(digito==cifra){
                              if(bandera==1){
                                             bandera=0;  //para el caso de 2 digitos mayores iguales  SOLO SE KITA UNO
                                             }
                              else {
                                   nuevo_num=nuevo_num*10+digito;
                                   }               
                              }
            else {
                 nuevo_num=nuevo_num*10+digito;
                 }                  
      numero=numero/10;           
      }             
      return nuevo_num;  
}

int Q_Cifras(long numero){
     int contador=0;
     while(numero>0){
           numero/=10;
           contador++;           
     }
     return contador++;
     
}

int main(){
         long numero;
         long mayor=0,aux,bkup,resultado;
         int cifra_mayor=0,cifra,i,n,m;
         printf("Ingrese numero:");
         scanf("%d",&numero);
         aux=numero;
         bkup=numero;
         while(bkup>0){
               aux=bkup;
               cifra_mayor=0;
               while(aux>0){
                    cifra_mayor=(aux%10>cifra_mayor)? aux%10:
                                                      cifra_mayor;
                    aux=aux/10;                                  
               }
               mayor=10*mayor+cifra_mayor;
               bkup=Retirar_Cifra(bkup,cifra_mayor);              
         }
         for(i=Q_Cifras(mayor);i<Q_Cifras(numero);i++)  // ESTO ES SI ESKE EL USUARIO INGRESA CERO O CEROS 
             mayor=mayor*10;
              
         resultado = mayor;
         printf("%d\n",mayor);
         system("pause");
}





