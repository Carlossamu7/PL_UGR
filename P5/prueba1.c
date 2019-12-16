#include <stdio.h>
#include <stdlib.h>
#include <string.h>


typedef struct 
{
	char* str1;
	char* str2;
	int int1;
}asd;


int main(){
	asd test;
	test.str1 = strdup("hola");
	test.str2 = strdup("adios");
	test.int1 = 3;
	asd test2;
	test2 = test;
	printf("%s %d", test2.str1, test2.int1);
}
