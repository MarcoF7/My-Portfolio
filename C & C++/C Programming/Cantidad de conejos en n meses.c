int main(){
         int numMes,nPares=0,prim_mes,seg_mes,i;
         printf("Ingrese el numero de mes:");
         scanf("%d",&numMes);
         if(numMes==1 || numMes==2){
                                   nPares=1;
                                   }
         else {
              prim_mes=1;
              seg_mes=1;
              for(i=3;i<=numMes;++i){
                                     nPares=prim_mes+seg_mes;
                                     prim_mes=seg_mes;
                                     seg_mes=nPares;
                                     }
              }                          
         printf("Numero de pares de conejos para %d mes(es) es de %d\n",numMes,nPares);     
         system("pause");            
         
         
}
