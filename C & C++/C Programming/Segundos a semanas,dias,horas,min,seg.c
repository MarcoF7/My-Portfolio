int main() {
        int seg,min,hor,dia,sem;
        printf("Introdusca segundos:  ");
        scanf("%d",&seg);
        min=seg/60;
        seg=seg%60;
        hor=min/60;
        min=min%60;
        dia=hor/24;
        hor=hor%24;
        sem=dia/7;
        dia=dia%7;
        printf("El numero de segundos es: %d\n",seg);
        printf("El numero de minutos es: %d\n",min);
        printf("El numero de horas es: %d\n",hor);
        printf("El numero de dias es: %d\n",dia);
        printf("El numero de semanas es: %d\n",sem);
        system("pause");
        return 0;
}
