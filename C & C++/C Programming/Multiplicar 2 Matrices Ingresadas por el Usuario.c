
int main(){
         int fil1,col1,fil2,col2;
         int i,j,k,s;
         do{
         printf("Ingrese numero de filas y columnas de matriz A: ");
         scanf("%d %d",&fil1,&col1);
         printf("Ingrese numero de filas y columnas de matriz B: ");
         scanf("%d %d",&fil2,&col2);
         if(col1 != fil2) printf("Estas matrices no se puden multiplicar\n");
         } while(col1 != fil2);
         
         int a[fil1][col1];  
         int b[fil2][col2];

         int c[fil1][col2];
         
  /*       for(i=0;i<fil1;++i){  INICIALIZANDOOOO!!! o sino hacer if s==0
             for(j=0;j<col2;++j){
                 c[i][j]=0;
             }
         }               */
         
         printf("Ingrese matriz A:\n");
         for(i=0;i<fil1;++i){
              for(j=0;j<col1;++j){
                    scanf("%d",&a[i][j]);
              }
         }
         printf("Ingrese matriz B:\n");
         for(i=0;i<fil2;++i){
              for(j=0;j<col2;++j){
                    scanf("%d",&b[i][j]);
              }
         }
         
         printf("\nEl producto es:\n");
         // multiplicar
         for(i=0;i<fil1;++i){
              for(j=0;j<col2;++j){
                   s=0;
                   for(k=0;k<col1;++k){  // col1 = fil2 
                         
                        if(s==0) c[i][j]=0;
                         c[i][j]+= a[i][k]*b[k][j];
                        ++s;
                   }
                   printf("%d ",c[i][j]);
              }
              printf("\n");
         }
         
            
         system("pause");
}
