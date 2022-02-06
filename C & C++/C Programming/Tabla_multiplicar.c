
int main() {
         int m,n,a,b;
         printf("Ingrese valores de a y b(tabla de multiplicar hasta axb):");
         scanf("%d %d",&a,&b);
         for(m=1;m<=a;m++){
                            for(n=1;n<=b;n++){
                                               printf("%d por %d = %d\n",m,n,(m*n));
                                               }
                            }   
         system("pause");
         return 0;
}
