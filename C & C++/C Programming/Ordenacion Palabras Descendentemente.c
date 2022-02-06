int main(){
         int a[1000]; //ARREGLO PARA EL NUMERO DE CARACTERES DE CADA CADENA 
         int num,i,j,k,mayor,m,temp,menor;
         printf("Ingrese el numero de palabras: ");
       //  scanf("%d",&num);
         num=getch();
         num=num-'0';
         printf("%d\n",num);
         char arreglo[num][1000];
         
         for(i=0;i<num;++i){
             printf("Ingrese la palabra %d: ",(i+1));
             j=0;
             scanf("%c",&arreglo[i][j]);
             for(;arreglo[i][j]!='\n';scanf("%c",&arreglo[i][j])){
                  ++j;
                  
             }
             a[i]=j;   
         }
         
         for(i=0;i<(num-1);++i){
             for(j=(i+1);j<num;++j){
                 if(a[i]<a[j]) menor=a[i];                   
                 else menor=a[j];                   
                 for(k=0;k<menor;++k){  //OBVIAMENTE SOLO COMPARA LA CANTIDAD DEL MENOR VECES 
                     if(arreglo[i][k]<arreglo[j][k]){ //cambio de posicion
                         if(a[i]>a[j]) mayor=a[i];
                         else mayor=a[j];
                         
                         for(m=0;m<mayor;++m){
                             temp=arreglo[i][m];
                             arreglo[i][m]=arreglo[j][m];
                             arreglo[j][m]=temp;
                         }
                         temp=a[i];  // TAMBIEN SE DEBE CAMBIAR DE CANTIDAD DE CARACTERES
                         a[i]=a[j];
                         a[j]=temp;
                         break;
                     }
                     else if(arreglo[i][k]>arreglo[j][k]){
                         break;     
                     }
                     if(k==(menor-1)) { 
                        if(menor==a[i]){ //ENTRA SI EL MENOR ESTA INCLUIDO EN EL MAYOR Y SI ES NECESARIO HACER UN CAMBIO
                        if(a[i]>a[j]) mayor=a[i];
                        else mayor=a[j];
                        for(m=0;m<mayor;++m){
                           temp=arreglo[i][m];
                           arreglo[i][m]=arreglo[j][m];
                           arreglo[j][m]=temp;
                        }
                        temp=a[i];
                        a[i]=a[j];
                        a[j]=temp;
                        break;
                        }
                     } 
                 }
             }
         }
         
         printf("Las palabras ordenadas descendentemente son: \n");
         for(i=0;i<num;++i){
             for(j=0;j<a[i];++j){
                 printf("%c",arreglo[i][j]);
             }
             printf("\n");
         }
         
         
         
         
         system("pause");
}







