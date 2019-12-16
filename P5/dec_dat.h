#include<stdio.h>
#include<stdlib.h>
#include "p4.h"
typedef int bool;
typedef Node* List;

struct Node { 
    void* data; 
    struct Node* next;
	struct Node* previous;
}; 

void push(struct List* inicial, void *new_data, size_t data_size) 
{ 
	struct Node* new_node = (struct Node*)malloc(sizeof(struct Node)); 
	new_node->data  = malloc(data_size); 
	new_node->next = (*inicial); 
	
	for (int i=0; i<data_size; ++i) 
		*(char*) (new_node->data + i) = *(char*) (new_data + i); 

	(*inicial) = new_node; 
} 

void printList(struct Node *node, dtipo td) 
{ 
	printf("[");
    while (node != NULL) 
    { 
		if (td == entero || td == real)
			if (node->next != NULL)
				printf("%d, ", node->data);
			else
				printf("%d", node->data);
		else
			if (node->next != NULL)
				printf("%s, ", node->data);
			else
				printf("%s", node->data);
        node = node->next; 
    }
	printf("]");
}

void next(List* l){
	if (l->next != NULL)
		l = l->next;
} 

void previous(List* l){
	if (l->previous != NULL)
		l = l->previous;
}

void begin(List* l){
	while (l->previous != NULL)
		previous(l);
}

void end(List* l){
	while (l->next != NULL)
		next(l);
}


unsigned int length(List* l){
	if (l == NULL)
		return 0;
	unsigned int count = 1;
	List* aux = l;
	begin(aux);
	while(l->next != NULL){
		next(aux);
		++count;
	}
	return count;
}

void* currentData(List* l){
	return l->data;
}

void* dataAt(List* l, int pos){
	if (l == NULL)
		return 0;
	if (pos >= length(l))
		return 0;
	List* aux = l;
	begin(aux);
	for(int i = 0; i < pos; ++i){
		next(aux);
	}
	return currentData(aux);
}

List addAt(List* l, unsigned int pos, void* dat){
	if (l == NULL)
		return;
	if (pos >= length(l))
		pos = length(l)-1;
	List* aux = l;
	begin(aux);
	for(int i = 0; i < pos; ++i){
		next(aux);
	}
	Node* n = malloc(sizeof(struct Node));
	n->previous = aux->previous;
	n->next = *aux;
	(aux->previous).next = *n;
	aux->previous = *n;
	n->data = dat;
	return *l;
}

List deleteAt(List* l, unsigned int pos){
	if (l == NULL)
		return;
	if (pos >= length(l))
		return;
	List* aux = l;
	begin(aux);
	for(int i = 0; i < pos; ++i){
		next(aux);
	}
	(aux->previous).next = aux->next;
	(aux->next).previous = aux->previous;
	if (aux == l)
		l = aux->next;
	free(aux);
	return *l;
}

List deleteSince(List* l, unsigned int pos){
	if (l == NULL)
		return;
	if (pos >= length(l))
		return;
	List* aux = l;
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

List concatenate(List* l1, List* l2){
	if (l1 == NULL)
		return l2;
	else if (l2 == NULL)
		return l1;
	
	end(l1);
	begin(l2);
	l1->next = *l2;
	l2->previous = *l1;
	begin(l1);
	return l1;
}

List sum(List* l, void* dat){
	if (l == NULL)
		return NULL;
	Node* aux = l;
	begin(aux);
	while(aux->next != NULL){
		aux->data = aux->data + *dat;
		next(aux);
	}
	return l;
} 

List subtract(List* l, void* dat){
	if (l == NULL)
		return NULL;
	Node* aux = l;
	begin(aux);
	while(aux->next != NULL){
		aux->data = aux->data - *dat;
		next(aux);
	}
	return l;
} 

List mult(List* l, void* dat){
	if (l == NULL)
		return NULL;
	Node* aux = l;
	begin(aux);
	while(aux->next != NULL){
		aux->data = aux->data * *dat;
		next(aux);
	}
	return l;
}

List div(List* l, void* dat){
	if (l == NULL || *dat == 0)
		return NULL;
	Node* aux = l;
	begin(aux);
	while(aux->next != NULL){
		aux->data = aux->data * *dat;
		next(aux);
	}
	return l;
}


