void Tablero_vacio(char [][]); 
void Posiciones_caballo(int , int , char [][]);
void Tablero_final(char [][]);

int main(){
        char arreglo[17][17]={{'-','-','-','-','-','-','-','-','-','-','-','-','-','-','-','-','-'},
                              {'|',' ','|',' ','|',' ','|',' ','|',' ','|',' ','|',' ','|',' ','|'},
                              {'-','-','-','-','-','-','-','-','-','-','-','-','-','-','-','-','-'},
                              {'|',' ','|',' ','|',' ','|',' ','|',' ','|',' ','|',' ','|',' ','|'},
                              {'-','-','-','-','-','-','-','-','-','-','-','-','-','-','-','-','-'},
                              {'|',' ','|',' ','|',' ','|',' ','|',' ','|',' ','|',' ','|',' ','|'},
                              {'-','-','-','-','-','-','-','-','-','-','-','-','-','-','-','-','-'},
                              {'|',' ','|',' ','|',' ','|',' ','|',' ','|',' ','|',' ','|',' ','|'},
                              {'-','-','-','-','-','-','-','-','-','-','-','-','-','-','-','-','-'},
                              {'|',' ','|',' ','|',' ','|',' ','|',' ','|',' ','|',' ','|',' ','|'},
                              {'-','-','-','-','-','-','-','-','-','-','-','-','-','-','-','-','-'},
                              {'|',' ','|',' ','|',' ','|',' ','|',' ','|',' ','|',' ','|',' ','|'},
                              {'-','-','-','-','-','-','-','-','-','-','-','-','-','-','-','-','-'},
                              {'|',' ','|',' ','|',' ','|',' ','|',' ','|',' ','|',' ','|',' ','|'},
                              {'-','-','-','-','-','-','-','-','-','-','-','-','-','-','-','-','-'},
                              {'|',' ','|',' ','|',' ','|',' ','|',' ','|',' ','|',' ','|',' ','|'},
                              {'-','-','-','-','-','-','-','-','-','-','-','-','-','-','-','-','-'}};
         int pos_x, pos_y,p_x,p_y;
         
         Tablero_vacio(arreglo);
         
         do{      // posiciones x y y deben ser de 1 a 8
         printf("Ingrese la coordenada x del caballo <1,8>: ");
         scanf("%d",&pos_x);
         printf("Ingrese la coordenada y del caballo <1,8>: ");
         scanf("%d",&pos_y);
         if ((pos_x<=0 || pos_x>8) || (pos_y<=0 || pos_y>8)) printf("Coordenadas incorrectas\n");
         else printf("Coordenadas correctas\n");
         } while ((pos_x<=0 || pos_x>8) || (pos_y<=0 || pos_y>8));
         
         p_x=2*pos_x;
         p_y=2*pos_y;
         p_x--;
         p_y--;
         
         arreglo[p_x][p_y]='C';
         
         Posiciones_caballo(pos_x,pos_y,arreglo);
         
         Tablero_final(arreglo);
         
         system("pause"); 
}

void Tablero_vacio(char arreglo[][17]){
      int i,j;
      for(i=0;i<17;++i){
          for(j=0;j<17;++j){
              printf("%c",arreglo[i][j]);
          }
          printf("\n");
      }
      
}

void Posiciones_caballo(int pos_x, int pos_y, char arreglo[][17]){
      int x1,y1,x2,y2,x3,y3,x4,y4,x5,y5,x6,y6,x7,y7,x8,y8;  // tambien deben ser del 1 al 8 para aparecer en el tablero
      int nuevo_x,nuevo_y;
      
   // USANDO ARREGLOS:
   
   /*   int arr[16]={pos_x-1,pos_y-2,pos_x-2,pos_y-1,pos_x-2,pos_y+1,pos_x-1,pos_y+2,
                   pos_x+1,pos_y-2,pos_x+2,pos_y-1,pos_x+2,pos_y+1,pos_x+1,pos_y+2};
      int i,j=0;
      for(i=0;i<16;i+=2){
          if(arr[i]>=1 && arr[i]<8){  //si el x esta en tablero
             j=i+1;
             if(arr[j]>=1 && arr[j]<8){ // si el y esta en el tablero
                nuevo_x=2*arr[i];
                nuevo_x--;
                nuevo_y=2*arr[j];       
                nuevo_y--;
                arreglo[nuevo_x][nuevo_y]='X';
             }
          }
          
      }
                     */
  
  
  // NO USANDO ARREGLOS:
  
      x1=pos_x-1;
      y1=pos_y-2;
      if (((x1>=1) && (x1<=8))&&(y1>=1 && y1<=8)){
          nuevo_x=2*x1;
          nuevo_x--;
          nuevo_y=2*y1;       // nuevo_x y nuevo_y son las posiciones en el arreglo
          nuevo_y--;
          arreglo[nuevo_x][nuevo_y]='X';
      }
      x2=pos_x-2;
      y2=pos_y-1;
      if (((x2>=1) && (x2<=8))&&(y2>=1 && y2<=8)){
          nuevo_x=2*x2;
          nuevo_x--;
          nuevo_y=2*y2;       
          nuevo_y--;
          arreglo[nuevo_x][nuevo_y]='X';
      }
      x3=pos_x-2;
      y3=pos_y+1;
      if (((x3>=1) && (x3<=8))&&(y3>=1 && y3<=8)){
          nuevo_x=2*x3;
          nuevo_x--;
          nuevo_y=2*y3;       
          nuevo_y--;
          arreglo[nuevo_x][nuevo_y]='X';
      }
      x4=pos_x-1;
      y4=pos_y+2;
      if (((x4>=1) && (x4<=8))&&(y4>=1 && y4<=8)){
          nuevo_x=2*x4;
          nuevo_x--;
          nuevo_y=2*y4;       
          nuevo_y--;
          arreglo[nuevo_x][nuevo_y]='X';
      }
      x5=pos_x+1;
      y5=pos_y-2;
      if (((x5>=1) && (x5<=8))&&(y5>=1 && y5<=8)){
          nuevo_x=2*x5;
          nuevo_x--;
          nuevo_y=2*y5;       
          nuevo_y--;
          arreglo[nuevo_x][nuevo_y]='X';
      }
      x6=pos_x+2;
      y6=pos_y-1;
      if (((x6>=1) && (x6<=8))&&(y6>=1 && y6<=8)){
          nuevo_x=2*x6;
          nuevo_x--;
          nuevo_y=2*y6;       
          nuevo_y--;
          arreglo[nuevo_x][nuevo_y]='X';
      }
      x7=pos_x+2;
      y7=pos_y+1;
      if (((x7>=1) && (x7<=8))&&(y7>=1 && y7<=8)){
          nuevo_x=2*x7;
          nuevo_x--;
          nuevo_y=2*y7;       
          nuevo_y--;
          arreglo[nuevo_x][nuevo_y]='X';
      }
      x8=pos_x+1;
      y8=pos_y+2;
      if (((x8>=1) && (x8<=8))&&(y8>=1 && y8<=8)){
          nuevo_x=2*x8;
          nuevo_x--;
          nuevo_y=2*y8;       
          nuevo_y--;
          arreglo[nuevo_x][nuevo_y]='X';
      }
                       
      
}

void Tablero_final(char arreglo[][17]){
      int i,j;
      printf("\nTablero final: \n");
      
      for(i=0;i<17;++i){
          for(j=0;j<17;++j){
              printf("%c",arreglo[i][j]);
          }
          printf("\n");
      }
}


















