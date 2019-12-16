#include <stdio.h>
#include "dec_dat.h"

int main(){
    Node* a = NULL;
    int entero = 2;

    a = push(a, entero);
    push(a, 3);
    printListNext(a);
    printf("Lista original: "); printList(a);/*
    sum(a, 2);
    printf("Suma 2: "); printList(a);
    subtract(a, 1);
    printf("Resta 1: "); printList(a);
    mult(a, 2);
    printf("Multiplica por 2: "); printList(a);
    divi(a, 2);
    printf("Divide por 2: "); printList(a);*/
    return 0;
}
