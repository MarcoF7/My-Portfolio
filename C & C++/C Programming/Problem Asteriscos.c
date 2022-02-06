int main(){
         int i, n,m=1,l=0,k,j,num,p=0,q=1;
         printf("Ingrese el numero del patron:");
         scanf("%d",&n);
         
         for(i=n;i>=2;--i,printf("\n")){
         if(i%2==1){
                    if((n%2)==1){
                    for(j=1;j<=m;++j){
                                      printf("* ");
                                      }
                    for(k=1;k<=((2*i)-5);++k) printf(" ");
                    for(j=1;j<=m;++j) printf(" *");
                    
                    ++m;
                    }
                    else{
                         for(j=1;j<=q;++j) printf(" *");
                         for(j=1;j<=((2*i)-3);++j) printf(" ");
                         for(j=1;j<=q;++j) printf("* ");
                         ++q;
                         }
                    
                    } 
         else {  // i par
              if((n%2)==1){
              for(j=1;j<=l;++j) printf("* ");
              for(j=1;j<=(2*i+1);++j) printf("*");
              for(j=1;j<=l;++j) printf(" *");
              ++l;
              }
              else {  // NO USAR VARIABLE l aca, usar p  parak no aumente el l y afecte al de arriba 
                   for(j=1;j<=p;++j) printf(" *");
                   for(j=1;j<=((2*i)-1);++j) printf("*");
                   for(j=1;j<=p;++j) printf("* ");
                   ++p;
                   }
              }           
         }
         
         if(n%2==1){  // LA LINEA DEL MEDIO
         for(j=1;j<=n;++j) printf("* ");
         }
         else {
              for(j=1;j<=(n-1);++j) printf(" *");
              }
         
         printf("\n");                
// FALTA LA PARTE DE ABAJO
          
          m=(n-1)/2;
          q=(n-2)/2;
          l=(n-3)/2;
          p=(n/2)-1;
          for(i=2;i<=n;++i,printf("\n")){
                                         if(i%2==1){ // i impares 
                                                    if(n%2==1){
                                                               for(j=1;j<=m;++j) printf("* ");
                                                               for(j=1;j<=((2*i)-5);++j) printf(" ");
                                                               for(j=1;j<=m;++j) printf(" *");
                                                               m--;
                                                               }
                                                    else{
                                                         for(j=1;j<=q;++j) printf(" *");
                                                         for(j=1;j<=((2*i)-3);++j) printf(" ");
                                                         for(j=1;j<=q;++j) printf("* ");
                                                         q--;
                                                         }           
                                                    }
                                         else {
                                              if(n%2==1){
                                                         for(j=1;j<=l;++j) printf("* ");
                                                         for(j=1;j<=((2*i)+1);++j) printf("*");
                                                         for(j=1;j<=l;++j) printf(" *");
                                                         --l;
                                                         }
                                              else {
                                                   for(j=1;j<=p;++j) printf(" *");
                                                   for(j=1;j<=((2*i)-1);++j) printf("*");
                                                   for(j=1;j<=p;++j) printf("* ");
                                                   --p;
                                                   }           
                                              }
          }                      
                                         
                                         
         system("pause");
         return 17;
}
