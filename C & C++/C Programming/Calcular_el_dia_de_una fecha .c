int main() {
         int dia,mes,anio,A,B,C,D,E,R,dosUlt;
         printf("Ingrese la fecha cuyo dia desea averiguar (dia mes anio) : ");
         scanf("%d %d %d",&dia,&mes,&anio);
         if((anio>=1700) && (anio<=2299)){
                                          if((anio>=1700) && (anio<=1799)){
                                                                           A=5;
                                                                           }
                                          else if(anio<=1899) A=3;
                                          else if(anio<=1999) A=1;
                                          else if(anio<=2099) A=0;
                                          else if(anio<=2199) A=-2;  
                                          else if(anio<=2299) A=-4;
                                          dosUlt = anio%100;
                                          B= (dosUlt*5)/4;
                                          if((((anio%4==0) && (anio%100)!=0) || ((anio%400)==0))&& (mes==1 || mes==2)){
                                                           C=-1;
                                                           }    
                                          else C=0;
                                          
                                          switch (mes) {
                                                 case 1: D=6;
                                                         break;
                                                 case 2: D=2;
                                                         break;
                                                 case 3: D=2;
                                                         break;
                                                 case 4: D=5;
                                                         break;
                                                 case 5: D=0;
                                                         break;
                                                 case 6: D=3;
                                                         break;
                                                 case 7: D=5;
                                                         break;
                                                 case 8: D=1;
                                                         break;
                                                 case 9: D=4;
                                                         break;
                                                 case 10: D=6;
                                                         break;
                                                 case 11: D=2;
                                                         break;
                                                 case 12: D=4;
                                                         break;                                                                                       
                                                 }
                                          E=dia;
                                          R=((A+B+C+D+E)%7);
                                          printf("A=%d B=%d C=%d D=%d E=%d R=%d\n",A,B,C,D,E,R);
                                          
                                          switch(R){
                                                    case 1: printf("El %d/%d/%d es dia Lunes\n",dia,mes,anio);
                                                            break;
                                                    case 2: printf("El %d/%d/%d es dia Martes\n",dia,mes,anio);
                                                            break; 
                                                    case 3: printf("El %d/%d/%d es dia Miercoles\n",dia,mes,anio);
                                                            break; 
                                                    case 4: printf("El %d/%d/%d es dia Jueves\n",dia,mes,anio);
                                                            break; 
                                                    case 5: printf("El %d/%d/%d es dia Viernes\n",dia,mes,anio);
                                                            break; 
                                                    case 6: printf("El %d/%d/%d es dia Sabado\n",dia,mes,anio);
                                                            break; 
                                                    case 0: printf("El %d/%d/%d es dia Domingo\n",dia,mes,anio);
                                                            break; 
                                                     
                                                                   
                                                    }
                                          
                                                   
                                                         
                                          }
                                          
        system("pause");
        return 0; 
}







