#include <stdio.h>
#include <stdlib.h>

void concatenarStrings(char* destination, char* format, ...){
	if( destination == NULL)
		destination = (char*) malloc(200);
	_G_va_list argptr;
	sprintf(destination, format, argptr[0]);
}

int main(){
	char* a;
	concatenarStrings(a, "%s lo que tu quieras %d\n", "dasd", 3);
	printf("%s", a);
}
