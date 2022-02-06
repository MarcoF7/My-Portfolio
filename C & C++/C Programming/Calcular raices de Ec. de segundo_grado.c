// usar %lf PARA DOUBLE!!!!!

int main() {
         double a,b,c,discr,x1,x2,xr,xi;
         printf("Ingrese los coeficientes a, b y c:");
         scanf("%lf %lf %lf",&a,&b,&c);
         discr = ((b*b)-(4.0*a*c));
         if (discr>0.0){
                        x1=(-b+(sqrt(discr)))/(2*a);
                        x2=(-b-(sqrt(discr)))/(2*a);
                        printf("Las dos raices reales son: %lf y %lf\n",x1,x2);
                        
                        }
          else if (discr==0.0){
                              x1=(-b)/(2*a);
                              x2=(-b)/(2*a);
                              printf("Las dos raices son iguales y valen: %lf\n",x1);
                              }
          else {     //solo queda el caso de que discr<0.0
               xr=(-b)/(2*a);
               xi=(sqrt(-discr))/(2*a);
               printf("Las raices son complejas:(%lf, %lf i),(%lf, %lf i)\n",xr,xi,xr,-xi);
               }                                   
         system("pause");
}
