#define MAX 10000

char *strinsert(char *, char *, int);

int main(){
         char po;
         int i,pos;
         char pal1[MAX];
         char pal2[MAX];
         char *pal;
         printf("Ingrese pal1:");
         i=0;
         scanf("%c",&pal1[i]);
         for(;pal1[i]!='\n';){
            ++i;
            scanf("%c",&pal1[i]);
         }
         pal1[i]='\0';
         printf("Ingrese pal2:");
         i=0;
         scanf("%c",&pal2[i]);
         for(;pal2[i]!='\n';){
            ++i;
            scanf("%c",&pal2[i]);
         }
         pal2[i]='\0';
         printf("Ingrese pos: ");
         po=getch();
         pos=po-'0';
         printf("%d\n",pos);
         pal=strinsert(pal1,pal2,pos);
         printf("\nResultado:%s\n",pal);
         system("pause");
}

char *strinsert(char *pal1, char *pal2, int pos){
      int i,j,k,p3;
      char pal3[10000];
      for(i=0;pal1[i]!=0;++i);
      for(j=0;pal2[j]!=0;++j);
      for(k=pos;pal1[k]!=0;++k){  
         pal3[k-pos]=pal1[k];
      }
      for(k=pos;k<pos+j;++k){
          pal1[k]=pal2[k-pos];
      }
      p3=i-pos;//longitud de pal3
      for(k=(pos+j);k<(pos+j+p3);++k){
          pal1[k]=pal3[k-(pos+j)];
      }
      pal1[i+j]=0;   // FINDE CADENA!!!!!!!
      return pal1;
}




       //           










