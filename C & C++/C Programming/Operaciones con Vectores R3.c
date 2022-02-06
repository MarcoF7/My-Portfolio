int main(){
         int i;
         float producto,modulo;
         float vA[3]={0.};
         float vB[3]={0.};
         int opcion;
         printf("0. Mostrar Menu\n");
         printf("1. Ingresar Vector A\n");
         printf("2. Mostrar Vector A\n");
         printf("3. Sumar: Vector A + Vector B\n");
         printf("4. Restar: Vector A - Vector B\n");
         printf("5. Producto Escalar: Vector A . Vector B\n");
         printf("6. Modulo: Vector A\n");
         printf("7. Salir\n");
         do{
            printf("\n");
            printf("? ");
            scanf("%d",&opcion);
            if(opcion==0) {
                          printf("0. Mostrar Menu\n");
                          printf("1. Ingresar Vector A\n");
                          printf("2. Mostrar Vector A\n");
                          printf("3. Sumar: Vector A + Vector B\n");
                          printf("4. Restar: Vector A - Vector B\n");
                          printf("5. Producto Escalar: Vector A . Vector B\n");
                          printf("6. Modulo: Vector A\n");
                          printf("7. Salir\n");
                          continue;
                          }
            if(opcion==7) continue;
            if(opcion==1) {
                          printf("Ingrese coordenadas del vector A (x y z)\n");
                          for(i=0;i<3;++i){
                                           scanf("%f",&vA[i]);
                                           }                               
                          }
            if(opcion==2){
                          printf("Vector A: ( %.2f, %.2f, %.2f )\n",vA[0],vA[1],vA[2]);
                          }
            if((opcion>=3) && (opcion<=5)){
                           printf("Ingrese coordenadas del vetor B (x y z)\n");
                           for(i=0;i<3;++i) scanf("%f",&vB[i]);
                           switch (opcion){
                                  case 3: printf("Vector A: ( %.2f, %.2f, %.2f ) +\n",vA[0],vA[1],vA[2]);
                                          printf("Vector B: ( %.2f, %.2f, %.2f ) =\n",vB[0],vB[1],vB[2]);
                                          for(i=0;i<3;++i){
                                                          vA[i]=vA[i]+vB[i];
                                                          }
                                          printf("Vector A: ( %.2f, %.2f, %.2f )\n",vA[0],vA[1],vA[2]);
                                          break;
                                  case 4: printf("Vector A: ( %.2f, %.2f, %.2f ) -\n",vA[0],vA[1],vA[2]);
                                          printf("Vector B: ( %.2f, %.2f, %.2f ) =\n",vB[0],vB[1],vB[2]);
                                          for(i=0;i<3;++i){
                                                           vA[i]=vA[i]-vB[i];
                                                            }
                                          printf("Vector A: ( %.2f, %.2f, %.2f )\n",vA[0],vA[1],vA[2]);
                                          break;                   
                                  case 5: printf("Vector A: ( %.2f, %.2f, %.2f ) .\n",vA[0],vA[1],vA[2]);
                                          printf("Vector B: ( %.2f, %.2f, %.2f ) =\n",vB[0],vB[1],vB[2]);
                                          producto=(vA[0]*vB[0])+(vA[1]*vB[1])+(vA[2]*vB[2]);
                                          printf("%.2f\n",producto);
                                          break; 
                           }
            }
            if(opcion==6){
                          modulo=sqrt((vA[0]*vA[0])+(vA[1]*vA[1])+(vA[2]*vA[2]));
                          printf("Modulo del vector A: ( %.2f, %.2f, %.2f ) = %.2f\n",vA[0],vA[1],vA[2],modulo);
                          }
            
            }while(opcion!=7);
         system("pause");
}




















