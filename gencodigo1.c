#include <stdio.h>
/** escribe la descomposición de un numero entero en sus factores primos,
*** usa exclusivamente: multiplicacion, division y suma de enteros
**/

int main(int argc, char * argv[] ) {
	int n, curr ;
	printf("introduce numero : ");
	scanf("%d",&n);
	printf(" %d == ",n);
	curr = 2 ;

	while( curr <= n )
	{
		int d = n/curr ;
		if ( d*curr == n ) /* curr divide a n */
		{
			printf("* %d ",curr);
			n = n/curr ;
		}
		else
			curr = curr+1 ;
	}

	printf("\n");
}
