
int main(){
         int cant_banco[5]={0};
         int cant_total=0,suma_tot,num,n;
         while(1){
                  printf("Ingrese el valor del tipo de billete que desea ingresar(0 para terminar):");
                  scanf("%d",&num);
                  if(num==0) break;
                  printf("Ingrese el numero de billetes que desea ingresar de dicho valor: ");
                  scanf("%d",&n);
                  switch(num){
                              case 10: cant_banco[0]+=n;
                                       cant_total+=n;
                                       break;
                              case 20: cant_banco[1]+=n;
                                       cant_total+=n;
                                       break;
                              case 50: cant_banco[2]+=n;
                                       cant_total+=n;
                                       break;
                              case 100: cant_banco[3]+=n;
                                       cant_total+=n;
                                       break;
                              case 200: cant_banco[4]+=n;
                                       cant_total+=n;
                                       break;
                              default: printf("Billete no valido\n");         
                              }
                  
                              
                  }
         printf("Numero de billetes ingresados en total: %d\n",cant_total);
                  printf("Cantidad de billetes de 10 soles: %d\n",cant_banco[0]);
                  printf("Cantidad de billetes de 20 soles: %d\n",cant_banco[1]);
                  printf("Cantidad de billetes de 50 soles: %d\n",cant_banco[2]);
                  printf("Cantidad de billetes de 100 soles: %d\n",cant_banco[3]);
                  printf("Cantidad de billetes de 200 soles: %d\n",cant_banco[4]);
                  suma_tot=cant_banco[0]*10+cant_banco[1]*20+cant_banco[2]*50+cant_banco[3]*100+cant_banco[4]*200;
                  printf("Suma total ingresada en nuevos soles: %d\n",suma_tot);         
         
         
         system("pause");
         return 0;     
         
         
}
