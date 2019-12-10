#include<stdio.h>
int main (int argc,char argv){
int  sal, sec, prim, nu;
prim = 0;
sec = 1;
printf("Introduce un numero : ");
scanf("%d",&nu);
while(nu > 0){
sal = prim + sec;
printf("%d",sal);
prim = sec;
sec = sal;
nu = nu - 1;
if(nu != 0)printf(" - ");

else printf("\n");
}
}
