int main(){
         int i;
         char car;
         char a[52]={'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z','a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z'};
         int b[52]={0};
         for(scanf("%c",&car);car!='\n';scanf("%c",&car)){
                       for(i=0;i<52;++i){
                                         if(car==a[i]) b[i]+=1;
                                         
                                         }
                                         
                       } 
         for(i=0;i<52;++i){
                           if(b[i]!=0) printf("%c   ",a[i]);
                           } 
         printf("\n");                  
         for(i=0;i<52;++i){
                           if(b[i]!=0) printf("%d   ",b[i]);
                           }                                                                 
         printf("\n");
         system("pause");
         return 20;
}

