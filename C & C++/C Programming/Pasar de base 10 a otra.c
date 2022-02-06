
int main(){
         int n,base,res,nuevo=0,coef=1;
         printf("Ingrese numero y nueva base:");   
         scanf("%d %d", &n, &base);
         do{
            res=n%base;
            nuevo=nuevo+(coef*res);
            coef=coef*10;
            n=n/base;
            } while(n!=0);
         printf("%d\n",nuevo);
         system("pause");
         return 0;   
                   
         
}
