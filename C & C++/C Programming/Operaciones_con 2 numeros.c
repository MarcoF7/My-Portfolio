const char MAS = '+';
const char MENOS = '-';

int Esprimo(int n){
                   int cantDiv=0,i=1;
                   while(i<=n){
                               if((n%i)==0) cantDiv++;
                               ++i;
                               }
                   if(cantDiv==2) return 1;
                   else return 0;            
                   }
int Suma_digit(int num){
                        int suma=0,dig;
                        while(num!=0){
                                      dig=num%10;
                                      num=num/10;
                                      suma=suma+dig;
                                      
                                      }
                        return suma;              
                        }
int Inverso(int num){
                     int nuevo = 0,dig;
                     while(num!=0){
                                   dig=num%10;
                                   num=num/10;
                                   nuevo = (nuevo*10)+dig;
                                   }
                     return nuevo;
                     }

int Num_primo(int num,char car){
                                int i=1,j=100;
                                if(car=='+'){
                                             while(i<=100){
                                                              if(Esprimo(i)){
                                                                             if(i>=num) return i;
                                                                             }
                                                              ++i;
                                                              }
                                             
                                             }
                                else if(car=='-'){
                                                  while(j>=1){
                                                              if(Esprimo(j)){
                                                                             if(j<=num) return j;
                                                                             }
                                                              --j;               
                                                              }
                                                  
                                                  }             
                                }




int main(){
         int num1,num2,sum_num1,sum_num2,inv_num1,inv_num2,primo_ant1,primo_ant2,primo_sgt1,primo_sgt2;
         int multipl1,multipl2;
         printf("INGRESE EL NUMERO ELEGIDO POR EL PRIMER JUGADOR\n");
         scanf("%d",&num1);
         printf("INGRESE EL NUMERO ELEGIDO POR EL SEGUNDO JUGADOR\n");
         scanf("%d",&num2);
         sum_num1=Suma_digit(num1);
         sum_num2=Suma_digit(num2);
         inv_num1=Inverso(num1);
         inv_num2=Inverso(num2);
         primo_ant1=Num_primo(num1,MENOS);
         primo_ant2=Num_primo(num2,MENOS);
         primo_sgt1=Num_primo(num1,MAS);
         primo_sgt2=Num_primo(num2,MAS);
         multipl1=sum_num1*inv_num1*primo_ant1*primo_sgt1;
         multipl2=sum_num2*inv_num2*primo_ant2*primo_sgt2;
         if(multipl1>multipl2){
                               printf("EL PRIMER JUGADOR GANA CON %d\n",multipl1);
                               }
         else if(multipl1==multipl2){
                                     printf("EMPATE\n");
                                     }                      
         else printf("EL SEGUNDO JUGADOR GANA CON %d\n",multipl2); 
         system("pause");
         return 0;
}






