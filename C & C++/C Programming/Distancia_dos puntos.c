int main(){
         float distancia,x1,y1,x2,y2;
         char car;
         do{
         printf("Ingresar x1,y1,x2,y2:");
         scanf("%f %f %f %f",&x1,&y1,&x2,&y2);
         distancia = sqrt(((x1-x2)*(x1-x2))+((y1-y2)*(y1-y2)));
         printf("La distancia es: %f\n",distancia);
         printf("Desea realizar otra operacion (S/N):");
         car = getch();
         printf("%c\n",car);
           }
           while(car=='S');
         system("pause");
         return 0;  
}
