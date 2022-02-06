float fx(float x){
            return ((x*x*x)-x-1);
            
}
int main(){
        float xi,xu,xr,f;
        int repet,i=1;
        do{
          printf("Ingrese el intervalo [a,b]:");
          scanf("%f %f",&xi,&xu);
          } while(xi>xu);
        printf("Ingrese maximo de iteraciones:");
        scanf("%d",&repet);
        printf("Iter\tXi\t\tXu\t\tXr\t\tF(xi)*F(xr)\n");  
        while(i<=repet){
                        xr=(xi+xu)/2.0;
                        f=(fx(xi)*fx(xr));
                        printf("%d\t%f\t%f\t%f\t%f\n",i,xi,xu,xr,f);
                        
                        if(f<0) xu=xr;
                        else 
                            xi=xr;
                        ++i;    
                        }
        
        printf("La raiz es:%f\n",xr);                   
        system("pause");
        return 0;
}
