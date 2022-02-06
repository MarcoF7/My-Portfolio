int main(){
        int pos_1,pos_2,i,j,pos_disp,nro_disp=0,aciertos=0;
        int arr1[3][4]={{1,2,3,4},{5,6,7,8},{9,10,11,12}};
        char arr2[3][4]={0};
        pos_1=(rand()%12+1);
        pos_2=(rand()%12+1);
        
        
        while(aciertos!=2){
             printf("\nTablero Battleship:\n");
             for(i=0;i<3;++i){
                  for(j=0;j<4;++j){
                       if(arr2[i][j]=='X' || arr2[i][j]=='-' ) printf("%c  ",arr2[i][j]);
                       else printf("%.2d ",arr1[i][j]);
                       
                  }
             printf("\n");     
             }
             printf("Ingresa posicion de tu disparo: ");
             scanf("%d",&pos_disp);
             ++nro_disp;
             if(pos_disp==pos_1 || pos_disp==pos_2){
                   for(i=0;i<3;++i){
                       for(j=0;j<4;++j){
                           if(arr1[i][j]==pos_disp){
                           arr2[i][j]='X';
                           }
                       }
                   }             
                   ++aciertos;
             }
             else {
                  for(i=0;i<3;++i){
                       for(j=0;j<4;++j){
                           if(arr1[i][j]==pos_disp){
                           arr2[i][j]='-';
                           }
                       }
                   }
                  
                  }
                        
        }
        printf("\nMe venciste en %d disparos!!!\n",nro_disp);
        printf("\nTablero Battleship:\n");
             for(i=0;i<3;++i){
                  for(j=0;j<4;++j){
                       if(arr2[i][j]=='X' || arr2[i][j]=='-' ) printf("%c  ",arr2[i][j]);
                       else printf("%.2d ",arr1[i][j]);
                       
                  }
             printf("\n");     
             }
        
        
        
        
        system("pause");   
}
