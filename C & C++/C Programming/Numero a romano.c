int main(){
         int num,dece,unid;
         do{
           printf("Ingrese un numero del 1 al 100\n");
           scanf("%d",&num);
           
           } while((num<1) || (num>100));  
         unid=num%10;
         dece=num/10;   
         printf("Su equivalente en numero romano es:\n");
         if(num==100) printf("C\n");
         
         switch (dece){
                      case(1): printf("X");
                               break;
                      case(2): printf("XX");
                               break;
                      case(3): printf("XXX");
                               break;
                      case(4): printf("XL");
                               break;
                      case(5): printf("L");
                               break;
                      case(6): printf("LX");
                               break;
                      case(7): printf("LXX");
                               break;
                      case(8): printf("LXXX");
                               break;
                      case(9): printf("XC");
                               break;         
                       }  
          switch (unid){
                      case(1): printf("I\n");
                               break;
                      case(2): printf("II\n");
                               break;
                      case(3): printf("III\n");
                               break;
                      case(4): printf("IV\n");
                               break;
                      case(5): printf("V\n");
                               break;
                      case(6): printf("VI\n");
                               break;
                      case(7): printf("VII\n");
                               break;
                      case(8): printf("VIII\n");
                               break;
                      case(9): printf("IX\n");
                               break;         
                       }                      
                               
                               
         system("pause");
         return 0;
}

