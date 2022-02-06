int main(){
         int equipo1,equipo2,gol1,gol2,nro_partidos,q=1,tipo_torneo;
         int N,i,j;
         float a[5]={3,1,0,0.05,-0.05};
         float b[5]={2,1,0,0.2,-0.2};
         float c[5]={3,1,0,0,0};
         
         printf("Ingrese Nro de equipos: ");
         scanf("%d",&N);
         printf("Ingrese numero de partidos jugados en total: ");
         scanf("%d",&nro_partidos);
         
         int matriz[N][5]; 
         float puntajes[N];
         for(i=0;i<N;++i){
             puntajes[i]=0.;
         }
         
         for(i=0;i<N;++i){   // INICIALIZANDO MANUALMENTE 
              for(j=0;j<5;++j){
                  matriz[i][j]=0;
              }
         }
         for(i=0;i<N;++i){
              for(j=0;j<5;++j){
                  printf("%d ",matriz[i][j]);
              }
              printf("\n");
         }
        while(q<=nro_partidos){                       
        printf("\nIngrese el resultado del partido %d(equipo1 equipo2 goles1 goles2): ",q);
        scanf("%d %d %d %d",&equipo1,&equipo2,&gol1,&gol2); 
        
        if(gol1>gol2){      // actualizando partidos ganados perdidos o empatados
            matriz[equipo1-1][0]++;
            matriz[equipo2-1][2]++;
        }
        else if(gol1==gol2){
             matriz[equipo1-1][1]++;
             matriz[equipo2-1][1]++;
        }
        else {
             matriz[equipo1-1][2]++;
             matriz[equipo2-1][0]++;
        }
        
        matriz[equipo1-1][3]+=gol1;  // actualizando los goles metidos
        matriz[equipo1-1][4]+=gol2;
        matriz[equipo2-1][3]+=gol2;
        matriz[equipo2-1][4]+=gol1;
        
        for(i=0;i<N;++i){
              for(j=0;j<5;++j){
                  printf("%d ",matriz[i][j]);
              }
              printf("\n");
         }
        
        
        
        q++;
        }
        
        printf("Seleccione torneo(1 2 o 3):"); // FUERA DEL BUCLE
        scanf("%d",&tipo_torneo);
        
        
        switch(tipo_torneo){
            case 1: for(i=0;i<N;++i){
                       for(j=0;j<5;++j){
                           puntajes[i]+=matriz[i][j]*a[j];
                
                       }
                    }
                    break;
             case 2: for(i=0;i<N;++i){
                       for(j=0;j<5;++j){
                           puntajes[i]+=matriz[i][j]*b[j];
                
                       }
                    }
                    break;       
             case 3: for(i=0;i<N;++i){
                       for(j=0;j<5;++j){
                           puntajes[i]+=matriz[i][j]*c[j];
                
                       }
                    }
                    break;
        }
        
        printf("\nPuntaje final del torneo: \n");
        for(i=0;i<N;++i){
             printf("Equipo %d: %.2f puntos\n",(i+1),puntajes[i]);
                              
        }
        
        system("pause");
}
