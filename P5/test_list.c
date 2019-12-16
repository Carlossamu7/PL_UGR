#include <stdio.h>
#include "dec_dat.h"

int main(){
    Node* a;
    int entero = 2;

    push(a, entero);
    push(a, entero);
    printList(a);
    begin(a);
    //sum(a, 2);
    return 0;
}
