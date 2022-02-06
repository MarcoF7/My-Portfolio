int main(){
        char letra=' ';
        int i=0,j,vidas=6,k=0,contador=0;  // se coloca 6, PERO EN VERDAD SOLO SON 5 VIDAS
        char car[10000]={0};
        char car2[20]={'_','_','_','_','_','_','_','_','_','_','_','_','_','_','_','_','_','_','_','_'};
        printf("Jugador 1: Ingrese palabra : ");
        scanf("%c",&car[i]);
        for(;car[i]!='\n';scanf("%c",&car[i])){
                      ++i;   //i da el numero de caracteres de la palabra
        }
        printf("\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n");
        
        while(vidas>0){
              k=0;
              contador=0;
              printf("\nPalabra: ");
              for(j=0;j<i;++j){
                   if(letra==car[j]) { //k permanece en 0 solo si nunca entra a este if
                        car2[j]=car[j];
                        printf("%c ",car[j]);
                        ++k;
                   }
                    else printf("%c ",car2[j]);
              }
              
             if(k==0){
                       vidas--;   
              }
              if(vidas==0) continue;
              
              for(j=0;j<i;++j){  // VERIFICANDO SI GANO EL JUGADOR 2
                  if(car2[j] != '_') contador++;             
              }
              if(contador==i) {
                      printf("Gano el jugador 2\n");
                      break;
              }
              
              printf("Jugador 2: Tiene %d vidas. Eliga una letra: ",vidas);
              letra=getch();
              printf("%c\n",letra);
      //     scanf("%c",&letra);    NO USARRRRRRRRRR  SCANF    ENTER ESTA EN ASCII!!!!!!!!!!!!!
              
        
        }
        
        if(vidas==0){
                     printf("Jugador 2: Perdio el juego\n");
                     printf("La palabra era: ");
                     for(j=0;j<i;++j){
                          printf("%c",car[j]);                 
                     }
                     }
        printf("\n");
        system("pause");
}















