int main () {
         int dia,mes,ano,diasfeb,diastrans;
         printf("Ingrese una fecha determinada [dd mm aaaa] : ");
         scanf("%d %d %d",&dia,&mes,&ano);
         if ((ano%4==0) && (ano%100 !=0) || (ano%400==0)) {
                        diasfeb = 29;
                        }
         else {
              diasfeb=28;
              }
         if ((dia>0) && (mes>=1) && (mes<=12) && (ano>=0)) {
         
         
         if ((mes==12)&&(dia<=31)) {
                      diastrans = 31+diasfeb+31+30+31+30+31+31+30+31+30+dia;
                      printf("EL numero de dias transcurridos desde el primer dia es %d\n",diastrans);
                      } 
         else if ((mes==11)&&(dia<=30)) {
                      diastrans = 31+diasfeb+31+30+31+30+31+31+30+31+dia; 
                      printf("EL numero de dias transcurridos desde el primer dia es %d\n",diastrans);
                      }
         else if ((mes==10)&&(dia<=31)) {
                      diastrans = 31+diasfeb+31+30+31+30+31+31+30+dia;
                      printf("EL numero de dias transcurridos desde el primer dia es %d\n",diastrans);
                      }  
         else if ((mes==9)&&(dia<=30)) {
                      diastrans = 31+diasfeb+31+30+31+30+31+31+dia;
                      printf("EL numero de dias transcurridos desde el primer dia es %d\n",diastrans);
                      } 
         else if ((mes==8)&&(dia<=31)) {
                      diastrans = 31+diasfeb+31+30+31+30+31+dia;
                      printf("EL numero de dias transcurridos desde el primer dia es %d\n",diastrans);
                      }
         else if ((mes==7)&&(dia<=31)) {
                      diastrans = 31+diasfeb+31+30+31+30+dia;
                      printf("EL numero de dias transcurridos desde el primer dia es %d\n",diastrans);
                      } 
         else if ((mes==6)&&(dia<=30)) {
                      diastrans = 31+diasfeb+31+30+31+dia;
                      printf("EL numero de dias transcurridos desde el primer dia es %d\n",diastrans);
                      }     
         else if ((mes==5)&&(dia<=31)) {
                      diastrans = 31+diasfeb+31+30+dia;
                      printf("EL numero de dias transcurridos desde el primer dia es %d\n",diastrans);
                      }      
         else if ((mes==4)&&(dia<=30)) {
                      diastrans = 31+diasfeb+31+dia;
                      printf("EL numero de dias transcurridos desde el primer dia es %d\n",diastrans);
                      }
         else if ((mes==3)&&(dia<=31)) {
                      diastrans = 31+diasfeb+dia;
                      printf("EL numero de dias transcurridos desde el primer dia es %d\n",diastrans);
                      } 
         else if (((mes==2)&&(dia<=29)&&(diasfeb==29)) || ((mes==2)&&(diasfeb==28)&&(dia<=28))) {
                      diastrans = 31+dia;
                      printf("EL numero de dias transcurridos desde el primer dia es %d\n",diastrans);
                      }
         else if ((mes==1)&&(dia<=31)) {
                      diastrans = dia;
                      printf("EL numero de dias transcurridos desde el primer dia es %d\n",diastrans);
                      }
         else {
              printf("Fecha invalida, vuelva a ejecutar el programa!\n");
              }                   
         
         }
         else {
              printf("Fecha invalida, vuelva a ejecutar el programa!\n");
              }                                                                                 
                                                                                        
         system("pause");
         return 0;
}
















