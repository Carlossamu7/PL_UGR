#include <stdio.h>
/** escribe la descomposición de un numero entero en sus factores primos,
*** usa exclusivamente: multiplicacion, division y suma de enteros
**/

int main(int argc, char * argv[] )
{
	int n, curr = 2, ultim = 0, cuenta = 0, primero = 1 ;
	
	printf("introduce numero : ");
	scanf("%d",&n);
	printf("%d == ",n);
	curr = 2 ;

	while( curr <= n )
	{
		int d = n/curr ;
		if ( d*curr == n ) /* curr divide a n */
		{
			if ( curr != ultim )
			{
				ultim = curr ;
				cuenta = 1 ;
			}
			else
				cuenta = cuenta + 1 ;
			n = n/curr ;
		}
		else /* curr no divide a ’n’ */
		{
			if ( cuenta > 0 )
			{
				if ( primero == 0 ) printf(" *");
				primero = 0 ;
				printf(" %d",curr) ;
				if ( cuenta > 1 ) printf("^%d",cuenta) ;
			}
			curr = curr+1 ;
			cuenta = 0 ;
		}
	}

	if ( cuenta > 0 )
	{
		if ( primero == 0 ) printf(" *");
		primero = 0 ;
		printf(" %d",curr) ;
		if ( cuenta > 1 ) printf("^%d",cuenta) ;
	}

	printf("\n");
}
