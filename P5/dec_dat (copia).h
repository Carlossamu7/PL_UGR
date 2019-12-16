#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct Node_t {
    void* data;
    struct Node_t* next;
	struct Node_t* previous;
} Node;

typedef int bool;
typedef enum {desconocido, entero, real, caracter, booleano, lista, cadena} dtipo ;

void push(Node* inicial, void *new_data, size_t data_size)
{
	Node* new_node = (Node*) malloc(sizeof(Node));
	new_node->data  = malloc(data_size);
	new_node->next = inicial;

	for (int i=0; i<data_size; ++i)
		*(char*) (new_node->data + i) = *(char*) (new_data + i);

	inicial = new_node;
}

void printList(Node* l, dtipo td)
{
	printf("[");
    while (l != NULL)
    {
		if (td == real) {
			if (l->next != NULL)
				printf("%f, ", * (float*) l->data);
			else
				printf("%f", * (float*) l->data);
        }
        else if (td == entero){
            if (l->next != NULL)
				printf("%d, ", * (int*) l->data);
			else
				printf("%d", * (int*) l->data);
        }
		else{
			if (l->next != NULL)
				printf("%s, ", (char*) l->data);
			else
				printf("%s", (char*) l->data);
        }
        l = l->next;
    }
	printf("]");
}

void next(Node* l){
	if (l->next != NULL)
		l = l->next;
}

void previous(Node* l){
	if (l->previous != NULL)
		l = l->previous;
}

void begin(Node* l){
	while (l->previous != NULL)
		previous(l);
}

void end(Node* l){
	while (l->next != NULL)
		next(l);
}


unsigned int length(Node* l){
	if (l == NULL)
		return 0;
	unsigned int count = 1;
	Node* aux = l;
	begin(aux);
	while(l->next != NULL){
		next(aux);
		++count;
	}
	return count;
}

void* currentData(Node* l){
	return l->data;
}

void* dataAt(Node* l, int pos){
	if (l == NULL)
		return 0;
	if (pos >= length(l))
		return 0;
	Node* aux = l;
	begin(aux);
	for(int i = 0; i < pos; ++i){
		next(aux);
	}
	return currentData(aux);
}

Node* addAt(Node* l, unsigned int pos, void* dat){
	if (l == NULL)
		return NULL;
	if (pos >= length(l))
		pos = length(l)-1;
	Node* aux = l;
	begin(aux);
	for(int i = 0; i < pos; ++i){
		next(aux);
	}
	Node* n = malloc(sizeof(Node));
	n->previous = aux->previous;
	n->next = aux;
	(aux->previous)->next = n;
	aux->previous = n;
	n->data = dat;
	return l;
}

Node* deleteAt(Node* l, unsigned int pos){
	if (l == NULL)
		return NULL;
	if (pos >= length(l))
		return NULL;
	Node* aux = l;
	begin(aux);
	for(int i = 0; i < pos; ++i){
		next(aux);
	}
	(aux->previous)->next = aux->next;
	(aux->next)->previous = aux->previous;
	if (aux == l)
		l = aux->next;
	free(aux);
	return l;
}

Node* deleteSince(Node* l, unsigned int pos){
	if (l == NULL)
		return NULL;
	if (pos >= length(l))
		return NULL;
	Node* aux = l;
	begin(aux);
	for(int i = 0; i < pos; ++i){
		next(aux);
	}
	Node* node_aux = aux;
	Node* node_last = aux;
	while (node_aux->next != NULL){
		if (node_aux == l)
			l = node_last;
		node_aux = aux->next;
		free(aux);
	}
	free(node_aux);
}

Node* concatenate(Node* l1, Node* l2){
	if (l1 == NULL)
		return l2;
	else if (l2 == NULL)
		return l1;

	end(l1);
	begin(l2);
	l1->next = l2;
	l2->previous = l1;
	begin(l1);
	return l1;
}

Node* sum(Node* l, float dat){
	if (l == NULL)
		return NULL;
	Node* aux = l;
	begin(aux);
	while(aux->next != NULL){
        *(float*) aux->data = *(float*) aux->data + dat;
		//*(aux->data) = *(aux->data) + *dat;
		next(aux);
	}
	return l;
}

Node* subtract(Node* l, float dat){
	if (l == NULL)
		return NULL;
	Node* aux = l;
	begin(aux);
	while(aux->next != NULL){
        *(float*) aux->data = *(float*) aux->data - dat;
		//aux->data = aux->data - *dat;
		next(aux);
	}
	return l;
}

Node* mult(Node* l, float dat){
	if (l == NULL)
		return NULL;
	Node* aux = l;
	begin(aux);
	while(aux->next != NULL){
        *(float*) aux->data = *(float*) aux->data * dat;
		//aux->data = aux->data * *dat;
		next(aux);
	}
	return l;
}

Node* divi(Node* l, float dat){
	if (l == NULL || dat == 0)
		return NULL;
	Node* aux = l;
	begin(aux);
	while(aux->next != NULL){
        *(float*) aux->data = *(float*) aux->data / dat;
		//aux->data = aux->data * *dat;
		next(aux);
	}
	return l;
}

/*
Node* sum(Node* l, int dat){
	if (l == NULL)
		return NULL;
	Node* aux = l;
	begin(aux);
	while(aux->next != NULL){
        *(int*) aux->data = *(int*) aux->data + dat;
		//*(aux->data) = *(aux->data) + *dat;
		next(aux);
	}
	return l;
}

Node* subtract(Node* l, int dat){
	if (l == NULL)
		return NULL;
	Node* aux = l;
	begin(aux);
	while(aux->next != NULL){
        *(int*) aux->data = *(int*) aux->data - dat;
		//aux->data = aux->data - *dat;
		next(aux);
	}
	return l;
}

Node* mult(Node* l, int dat){
	if (l == NULL)
		return NULL;
	Node* aux = l;
	begin(aux);
	while(aux->next != NULL){
        *(int*) aux->data = *(int*) aux->data * dat;
		//aux->data = aux->data * *dat;
		next(aux);
	}
	return l;
}

Node* div(Node* l, int dat){
	if (l == NULL || *dat == 0)
		return NULL;
	Node* aux = l;
	begin(aux);
	while(aux->next != NULL){
        *(int*) aux->data = *(int*) aux->data / dat;
		//aux->data = aux->data * *dat;
		next(aux);
	}
	return l;
}
*/
