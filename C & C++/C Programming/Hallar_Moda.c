#include <string.h>

int Moda_Mat(int *ptr, int num){
    int i,cant=0,mayor=-1;
    int var=*(ptr+0);
    int moda;
    for(i=0;i<num;++i){
        
        if(var==*(ptr+i)){
            cant++;
            if(cant>mayor){
               mayor=cant;
               moda=var;
            }
        }
        else {
            cant=1; 
        }
        var=*(ptr+i);
    }
    return moda;
}

int main(){
         int *ptr=(int *)malloc(100*sizeof(int));
         int i,j,num,aux,moda;
         printf("Ingrese num:");
         scanf("%d",&num);
         for(i=0;i<num;++i){
             printf("Ingrese num %d: ",i+1);
             scanf("%d",&(*(ptr+i)));
         }
         for(i=0;i<num-1;++i){
             for(j=i+1;j<num;++j){
                 if(*(ptr+i)>*(ptr+j)){
                     aux=*(ptr+i);
                     *(ptr+i)=*(ptr+j);
                     *(ptr+j)=aux;
                 }
             }
         }
         
         for(i=0;i<num;++i){
             printf("%d ",*(ptr+i));
         }
         
         moda=Moda_Mat(ptr,num);
         printf("\n");
         printf("moda=%d\n",moda);
         system("pause");
}






