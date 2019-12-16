#include <stdio.h>
#include "dec_dat.h"

int main(){
    Node* a = NULL;
    int entero = 2;

    a = push(a, entero);
    push(a, 3);
    printList(a);
    begin(a);
    //sum(a, 2);
    return 0;
}
