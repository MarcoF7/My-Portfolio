int main(){
         long num;
         int i=1,dig,dig1=0,dig2=0,dig3=0,dig4=0,dig5=0,dig6=0,dig7=0,dig8=0,dig9=0;
         printf("Ingrese un numero de maximo 9 digitos:");
         scanf("%d",&num);
         while(num!=0){
                       dig=num%10;
                       num=num/10;
                       switch (i){
                                 case (1):dig1=dig;
                                          break;
                                 case (2):dig2=dig;
                                          break;
                                 case (3):dig3=dig;
                                          break;
                                 case (4):dig4=dig;
                                          break;
                                 case (5):dig5=dig;
                                          break;
                                 case (6):dig6=dig;
                                          break;
                                 case (7):dig7=dig;
                                          break;                                                      
                                 case (8):dig8=dig;
                                          break;
                                 case (9):dig9=dig;
                                          break;
                                 
                                 }
                                 i++;
                       }
        printf("Digitos del numero: %d %d %d %d %d %d %d %d %d",dig1,dig2,dig3,dig4,dig5,dig6,dig7,dig8,dig9);
        system("pause");
        return 0;               
         
}
