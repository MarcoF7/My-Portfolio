int main(){
         int i,j,opcion;
         char txt[1000];
         char txt2[1000];
         char car,opc;
         do{
         i=0; //OVIAMENTE i debe de empezar en 0 en cada iteracion 
         printf("Ingrese Frase: ");
         scanf("%c",&txt[i]);
         for(;txt[i]!='\n';scanf("%c",&txt[i])){
                                                 ++i; //i es el numero de elementos 
         } 
         printf("Eliga opcion...\n");
         printf("1. Mayuscula a la primera letra de cada palabra.\n");
         printf("2. Mayuscula solo a la primera letra de la frase.\n");
         printf("3. Toda la frase a mayuscula\n");
         printf("4. Toda la frase a minuscula\n");
         printf("5. Ingrese otra frase\n");
         printf("6. Salir\n");
         //scanf("%d",&opcion);
         opc=getch();
         printf("%c\n",opc);
         opcion=opc-'0';
         if(opcion==5  || opcion==6) continue;
         switch (opcion){
                case 1: for(j=0;j<i;++j){
                                if(j==0){
                                         if(txt[j]>='a' && txt[j]<='z') txt[j]=(txt[j]-32);
                                         }
                                if(txt[j]==' '){
                                            car=txt[j+1];
                                            if(car>='a' && car<='z') txt[j+1]=(txt[j+1]-32);
                                            }         
                         }
                         break;
                case 2: if(txt[0]>='a' && txt[0]<='z') txt[0]=txt[0]-32;       
                         break;
                case 3: for(j=0;j<i;++j){
                               if(txt[j]>='a' && txt[j]<='z') txt[j]-=32;
                        }         
                        break;
                case 4: for(j=0;j<i;++j){
                               if(txt[j]>='A' && txt[j]<='Z') txt[j]+=32;
                        }
                        break;
                        
         }
         printf("Resultado: ");
         for(j=0;j<i;++j){
                          printf("%c",txt[j]);
                          }
         printf("\n");
         
         } while(opcion!=6);
         
         
         
         system("pause");
}






