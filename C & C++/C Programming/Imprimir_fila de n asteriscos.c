int main(){
         int i,j,nroFil,k;
         printf("Ingrese numero de filas:");
         scanf("%d",&nroFil);
         for(i=1;i<=nroFil;++i){
                                for(k=1;k<=(nroFil-i);++k){
                                                           printf(" ");
                                                           }
                                for(j=1;j<=(2*i)-1;++j){
                                                        printf("*");
                                                        }
                                printf("\n");                        
                                }
         
         system("pause");
         return 0;
}
