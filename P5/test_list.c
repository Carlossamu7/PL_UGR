#include <stdio.h>
#include "dec_dat.h"

int main(){
    Node* a = NULL;
    int entero = 2, en=0;
    Node* b = NULL;
    Node* c = NULL;

    push(&b, entero);
    push(&b, 3);

    push(&a, entero);
    push(&a, 3);
    printListNext(a);
    printf("Lista original: "); printList(a);
    sum(a, 2);
    printf("Suma 2: "); printList(a);
    subtract(a, 1);
    printf("Resta 1: "); printList(a);
    mult(a, 2);
    printf("Multiplica por 2: "); printList(a);
    divi(a, 2);
    printf("Divide por 2: "); printList(a);

    en = length(a);
    printf("%d\n", en);

    printList(a);
    printList(b);
    c = concatenate(&a, &b);
    printf("Concateno las listas a y b en c: \n");
    printList(a);
    printList(b);
    printList(c);
    deleteSince(a, 2);
    printf("Borramos desde la pos 2 en adelante en lista a: "); printList(a);
    deleteAt(b, 0);
    printf("Borramos la pos 0 en lista b: "); printList(b);
    addAt(b, 0, 3);
    printf("Añadimos en pos 0 de c el valor 3: "); printList(b);
    printf("Dato en la pos 0 de b: %d\n", dataAt(b,0));
    printf("Dato actual de b: %d\n", currentData(b));
    return 0;
}
