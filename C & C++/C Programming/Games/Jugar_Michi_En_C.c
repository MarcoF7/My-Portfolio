int main(){
         char arr1[3][3]={{'_','_','_'},{'_','_','_'},{'_','_','_'}};
         int cont=0,i,j,k; 
               cont=0;
               
               
               
               printf("\nJugador1: Ingrese posicion en la que quiere marcar(i j):");
               scanf("%d %d",&i,&j);
               arr1[i][j]='O';
               ++k;
               
               
               printf("tablero actual:\n");
               for(i=0;i<3;++i){
                    for(j=0;j<3;++j){
                        printf("%c ",arr1[i][j]);
                    }                 
                    printf("\n");
               } 
               
               for(i=0;i<3;++i){ //verificando si gano de forma horizontal
                  cont=0;
                  for(j=0;j<3;++j){
                       if(arr1[i][j]!='O') break;
                       else cont++;
                  }
               if(cont==3){
                           printf("Gano el primer jugador!\n");
                           printf("Raya con que gano: -\n");
                           break;
                           }   
               }
               
               if (cont==3) break;
               cont=0;
               
               for(j=0;j<3;++j){  //verificando si gano de forma vertical
                    cont=0;
                    for(i=0;i<3;++i){
                         if(arr1[i][j]!='O') break;
                         else cont++;
                    }
               if(cont==3){
                           printf("Gano el primer jugador!\n");
                           printf("Raya con que gano: |\n");
                           break;
                           }     
               }
               
               if (cont==3) break;
               cont=0;
               
               if(arr1[0][0]=='O' && arr1[1][1]=='O' && arr1[2][2]=='O'){
                                  printf("Gano el primer jugador!\n");
                                  printf("Raya con que gano: \\\n");
                                  break;
                                  }
                                  
               if(arr1[2][0]=='O' && arr1[1][1]=='O' && arr1[0][2]=='O'){
                                  printf("Gano el primer jugador!\n");
                                  printf("Raya con que gano: /\n");
                                  break;
                                  } 
               
               if(k==9){
                        printf("EMPATE!!!\n");
                        printf("tablero actual:\n");
                        for(i=0;i<3;++i){
                            for(j=0;j<3;++j){
                        printf("%c ",arr1[i][j]);
                        }                 
                        printf("\n");
                        } 
                        break;
                        }
              
              // AHORA ANALIZANDO AL JUGADOR 2:
         
               
               
               printf("\nJugador2: Ingrese posicion en la que quiere marcar(i j):");
               scanf("%d %d",&i,&j);
               arr1[i][j]='X';
               ++k;
               
               printf("tablero actual:\n");
               for(i=0;i<3;++i){
                    for(j=0;j<3;++j){
                        printf("%c ",arr1[i][j]);
                    } 
                    printf("\n");                
               }
               
               for(i=0;i<3;++i){ //verificando si gano de forma horizontal
                  cont=0;
                  for(j=0;j<3;++j){
                       if(arr1[i][j]!='X') break;
                       else cont++;
                  }
               if(cont==3){
                           printf("Gano el segundo jugador!\n");
                           printf("Raya con que gano: -\n");
                           break;
                           }   
               }
               
               if (cont==3) break;
               cont=0;
               
               for(j=0;j<3;++j){  //verificando si gano de forma vertical
                    cont=0;
                    for(i=0;i<3;++i){
                         if(arr1[i][j]!='X') break;
                         else cont++;
                    }
               if(cont==3){
                           printf("Gano el segundo jugador!\n");
                           printf("Raya con que gano: |\n");
                           break;
                           }     
               }
               
               if (cont==3) break;
               cont=0;
               
               if(arr1[0][0]=='X' && arr1[1][1]=='X' && arr1[2][2]=='X'){
                                  printf("Gano el segundo jugador!\n");
                                  printf("Raya con que gano: \\\n");
                                  break;
                                  }
                                  
               if(arr1[2][0]=='X' && arr1[1][1]=='X' && arr1[0][2]=='X'){
                                  printf("Gano el segundo jugador!\n");
                                  printf("Raya con que gano: /\n");
                                  break;
                                  }
               
         
         
         }
         
         system("pause");
}












