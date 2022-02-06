int main() {
       int a,b,c,cont=0,residuo,q;
       printf("Ingrese dos numeros:");
       scanf("%d %d",&a,&b);
       c=b;
       if(a>0 && b>0){
       if(a>=b){
               do {
               c=c+b;
               cont++;
                }
               while(c<=a);
               q = cont;
               residuo = (a-(c-b));
               }
       else {
            q = 0;
            residuo=a;
            }    
       printf("El cociente y el residuo son: %d y %d\n",q,residuo);               
                      }
       else {
            printf("Numeros deben ser positivos!\n");
            }               
       system("pause");
       return 0;           
                  
}
