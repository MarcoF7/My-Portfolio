const float PI = 3.1415;
int main(){
         int num,numInv=0,dig,num_prueb;
         printf("Ingrese numero:");
         scanf("%d",&num);
         num_prueb=num;
         if(num_prueb>=0 && num_prueb<=999){
                                while(num_prueb!=0){
                                              dig=num_prueb%10;
                                              num_prueb=num_prueb/10;
                                              numInv = (numInv*10)+dig;
                                              }
                                if(numInv==num){
                                                printf("El numero es capicua\n");
                                                }              
                                else printf("El numero no es capicua\n");
                                                
                               }
         else printf("Numero no valido\n");
                               
         system("pause");
         return 0;  
}
