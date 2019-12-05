//typedef int bool;
// Innecesarios creo, pero luego los borro
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#ifdef DOSWINDOWS /* Variable de entorno que indica la plataforma */
	#include "lexyy.c"
#else
	#include "lex.yy.c"
#endif

#define true 1
#define false 0
#define MAX_TS 1000

entradaTS TS[MAX_TS];	/*Pila de la tabla de símbolos*/
long int TOPE = 0;
unsigned int Subprog ;     /*Indicador de comienzo de bloque de un subprog*/
FILE * file;
char * argumento;

typedef enum {marca, funcion, variable, parametro_formal} tipoEntrada ;

typedef enum {entero, real, caracter, booleano, lista, desconocido} dtipo ;

typedef struct {
	tipoEntrada 	entrada ;
	char*			nombre ;
	char* 			valor;
	dtipo 			tipoDato ;
	dtipo			tipoInternoLista ;
	unsigned int 	parametros = 0 ;
	unsigned int	longitud = 0 ;
} entradaTS ;


#define YYSTYPE entradaTS  /*A partir de ahora, cada símbolo tiene*/
							/*una estructura de tipo atributos*/

/*Lista de funciones y procedimientos para manejo de la TS*/


/*Fin de funciones y procedimientos para manejo de la TS*/


// Inserta una entrada en la pila
void insertar (entradaTS s){
   if (TOPE == 1000) {
		printf("\nError: tamanio maximo alcanzado\n");
		exit(-1);
   } else {
		TS[TOPE].nombre=s.nombre;
		TS[TOPE].tipoDato=s.tipoDato;
		TS[TOPE].parametros=s.parametros;
		TS[TOPE].entrada=s.entrada;
		TS[TOPE].longitud=s.longitud;
		++TOPE;
   }
}

// Inserta los "numArgumentos" parametros formales de la funcion "nom" como variables
void insertarArgumentos(char* nom, int numArgumentos){
	int index = buscarFuncion(nom);
	for(int i = numArgumentos; i>0; --i) {
		entradaTS aux;
		aux.nombre = TS[index-i].nombre;
		aux.tipoDato = TS[index-i].tipoDato;
		aux.entrada = variable;
		insertar(aux);
	}	
}

/*
void insertar (tipoEntrada entrada, char* nombre, dtipo tipoDato, unsigned int parametros, unsigned int longitud){
   if (TOPE == 1000) {
		printf("\nError: tamanio maximo alcanzado\n");
		exit(-1);
   } else {
		TS[TOPE].nombre=nombre;
		TS[TOPE].tipoDato=tipoDato;
		TS[TOPE].parametros=parametros;
		TS[TOPE].entrada=entrada;
		TS[TOPE].longitud=longitud;
		++TOPE;
   }
}
*/

// Posiciona el tope de la pila en la última marca, eliminando así todo el bloque
void eliminarBloque(){
   bool encontrada = false;
   int i;
   for (i=TOPE-1; i>0 && !encontrada; --i) {
      if(TS[i].entrada == marca) {
		TOPE = i;
        encontrada = true;
      }
   }
   if(encontrada == false)
	  vaciar();
}

// Posiciona el tope en 0 vaciando así toda la pila
void vaciar(){
	TOPE=0;
}

// Introduce una entrada en la pila de tipo marca de inicio de bloque
void insertarMarca(){
   TS[TOPE].entrada = marca;
   ++TOPE;
}

// Elimina el último elemento de la pila
void sacar(){
   if (TOPE > 0) {
      --TOPE;
   }
}

// Imprime el contenido de la pila 
void imprimirTS(){
	int i;
	
	for(i=0; i < TOPE ; ++i){
		if(TS[i].entrada == variable){
			if(TS[i].tipoDato == entero)
				printf("\nLa variable %s es de tipo entero \n", TS[i].nombre);
			
			if(TS[i].tipoDato == booleano)
				printf("\nLa variable %s es de tipo booleano \n", TS[i].nombre);
			
			if(TS[i].tipoDato == real)
				printf("\nLa variable %s es de tipo real \n", TS[i].nombre);
			
			if(TS[i].tipoDato == caracter)
				printf("\nLa variable %s es de tipo caracter \n", TS[i].nombre);
			
			if(TS[i].tipoDato == lista)
				printf("\nLa variable %s es de tipo lista \n", TS[i].nombre);
		}
		
		if(TS[i].entrada == marca)
			printf("\nINICIO BLOQUE\n");
		
		if(TS[i].entrada == funcion){
			if(TS[i].tipoDato == entero)
				printf("\nLa funcion %s tiene %d argumentos y devuelve el tipo entero \n", TS[i].nombre, TS[i].parametros);
			
			if(TS[i].tipoDato == booleano)
				printf("\nLa funcion %s tiene %d argumentos y devuelve el tipo booleano \n", TS[i].nombre, TS[i].parametros);
			
			if(TS[i].tipoDato == real)
				printf("\nLa funcion %s tiene %d argumentos y devuelve el tipo real \n", TS[i].nombre, TS[i].parametros);
			
			if(TS[i].tipoDato == caracter)
				printf("\nLa funcion %s tiene %d argumentos y devuelve el tipo caracter \n", TS[i].nombre, TS[i].parametros);
			
			if(TS[i].tipoDato == lista)
				printf("\nLa funcion %s tiene %d argumentos y devuelve el tipo lista \n", TS[i].nombre, TS[i].parametros);	
		}
	}	
}

// Comprueba si la variable se ha declarado anteriormente en el mismo bloque
bool variableExisteBloque(entradaTS ts){
	bool encontrada = false;
	
	for(int i=TOPE-1; i>=0 && !encontrada; --i){
		if( (TS[i].entrada == variable || TS[i].entrada == funcion) && strcmp(TS[i].nombre, ts.nombre) == 0)
			encontrada = true;		
		if(TS[i].entrada==marca)
			return encontrada;
	}
	return encontrada;
}

// Comprueba si la variable se ha declarado anteriormente
bool variableExiste(entradaTS ts){
	bool encontrada = false;
	
	for(int i=TOPE-1; i>=0 && !encontrada; --i){
		if( (TS[i].entrada == variable || TS[i].entrada == funcion) && strcmp(TS[i].nombre, ts.nombre) == 0)
			encontrada = true;
	}
	return encontrada;
}

// Comprueba si hay otro parámetro con el mismo nombre en la misma función
bool parametroExiste(entradaTS ts){
	int i = TOPE-1;

	while( TS[i].entrada == parametro_formal ){
		if( strcmp(TS[i].nombre, ts.nombre) == 0 )
			return true;
		--i;
	}

	return false;
}

// Devuelve la ultima entrada de la pila asociada a la función o variable con nombre "nombre"
entradaTS getSimboloIdentificador(char* nombre){
	int i;
	bool encontrada=false;
	entradaTS ret;
	
	for(i=TOPE-1; i>=0 && !encontrada; --i){
		if( (TS[i].entrada == variable || TS[i].entrada == funcion ) && strcmp(TS[i].nombre, nombre) == 0){
			encontrada = true;
			ret=TS[i];
		}
	}
	return ret;	
}

// Devuelve la entrada de la pila asociada al argumento número "numPar" de la funcion con nombre "nombreFun"
entradaTS getSimboloArgumento(char* nombreFun, int numPar){
	int i, indiceFun;
	bool encontrada=false;
		
	for(i=TOPE-1; i>=0 && !encontrada; --i){
		if( TS[i].entrada == funcion && strcmp(TS[i].nombre, nombreFun) == 0){
			encontrada = true;
			indiceFun=i;
		}	
	}
	
	if(numPar > TS[indiceFun].parametros){
		entradaTS ret;
		ret.parametros=-1;
		return ret;
	}
	
	return TS[indiceFun-TS[indiceFun].parametros+numPar-1];	
}

/****************************		FUNCIONES AUXILIARES		**************************/

void concatenarStrings(char* destination, const char* source1, const char* source2){
	if( destination == NULL)
		destination = (char *) malloc(200);
	sprintf(destination, "%s%s", source1, source2);
}

void concatenarStrings(char* destination, const char* source1, const char* source2, const char* source3){
	if( destination == NULL)
		destination = (char *) malloc(200);
	sprintf(destination, "%s%s%s", source1, source2, source3);
}

void concatenarStrings(char* destination, const char* s1, const char* s2, const char* s3, const char* s4){
	if( destination == NULL)
		destination = (char *) malloc(200);
	sprintf(destination, "%s%s%s%s", s1, s2, s3, s4);
}

void concatenarStrings(char* destination, const char* s1, const char* s2, const char* s3, const char* s4, const char* s5){
	if( destination == NULL)
		destination = (char *) malloc(200);
	sprintf(destination, "%s%s%s%s%s", s1, s2, s3, s4, s5);
}

char* toString(dtipo td){
	if(td == entero) 	return "entero";		
	if(td == booleano) 	return "booleano";	
	if(td == real) 		return "real";
	if(td == caracter)	return "caracter";
	if(td == lista)		return "lista";
}

char* toString(tipoEntrada te){
	if(te == marca) 			return "marca";		
	if(te == funcion) 			return "funcion";	
	if(te == variable) 			return "variable";
	if(te == parametro_formal)	return "parametro_formal";
}

void mensajeErrorDeclaradaBloque(entradaTS ts){
	printf("\nError semantico en la linea %d: La %s %s ya esta declarada en este bloque\n", yylineno, toString(ts.entrada), ts.nombre);
}

void mensajeErrorNoDeclarada(entradaTS ts){
	printf("\nError semantico en la linea %d: La %s %s no ha sido declarada\n", yylineno, toString(ts.entrada), ts.nombre);
}

void mensajeErrorParametro(entradaTS ts){
	printf("\nError semantico en la linea %d: Hay mas de un parametro con el mismo nombre \"%s\"\n", yylineno, ts.nombre);
}

void mensajeErrorNoVariable(entradaTS ts){
	printf("\nError semantico en la linea %d: La %s %s no es una variable\n", yylineno, toString(ts.entrada), ts.nombre);
}

void mensajeErrorAsignacion(entradaTS ts1, entradaTS ts2){
	printf("\nError semantico en la linea %d: Los tipos de la asignacion %s y %s no coinciden\n", 
										yylineno, 		toString(ts1.tipoDato), toString(ts2.tipoDato));
}

void mensajeErrorComparacion(entradaTS ts1, entradaTS ts2){
	printf("\nError semantico en la linea %d: No se pueden comparar los tipos %s y %s\n", 
										yylineno, 		toString(ts1.tipoDato), toString(ts2.tipoDato));
}

void mensajeErrorTipo(entradaTS ts, dtipo esperado){
	if( ts.tipoDato == variable )
		printf("\nError semantico en la linea %d: La variable %s no es de tipo %s\n", yylineno, ts.nombre, toString(esperado));
	else if( ts.tipoDato == funcion )
		printf("\nError semantico en la linea %d: La funcion %s no devuelve valores de tipo %s\n", yylineno, ts.nombre, toString(esperado));
	else printf("\nError semantico en la linea %d: La expresion %s no es de tipo %s\n", yylineno, ts.valor  toString(esperado));
}

void mensajeErrorTipo(entradaTS ts, dtipo esperado1, dtipo esperado2){
	if( ts.tipoDato == variable )
		printf("\nError semantico en la linea %d: La variable %s no es de tipo %s o %s\n", yylineno, ts.nombre, toString(esperado1), toString(esperado2));
	else if( ts.tipoDato == funcion )
		printf("\nError semantico en la linea %d: La funcion %s no devuelve valores de tipo %s o %s\n", yylineno, ts.nombre, toString(esperado1), toString(esperado2));
	else printf("\nError semantico en la linea %d: La expresion %s no es de tipo %s o %s\n", yylineno, ts.valor  toString(esperado1), toString(esperado2));
}

void mensajeErrorSeEsperabaFuncion(entradaTS ts){
	printf("\nError semantico en la linea %d: Se ha encontrado %s y se esperaba una funcion\n", yylineno, toString(ts.entrada));
}

void mensajeErrorNumParametros(entradaTS ts1, entradaTS ts2){
	printf("\nError semantico en la linea %d: La %s %s esperaba %d argumentos y se han encontrado %d\n", 
			yylineno, toString(ts1.entrada), ts1.nombre, ts1.parametros, ts2.parametros);
}















int buscarFuncion (char* Nomb) {
	for (int i = TOPE-1; i > 0; --i){
		if(strcmp(TS[i].nombre,Nomb))
			return i+1;
	}
	return -1;
}

bool comprobarParametros(char* nombre, dtipo dato, int nParam) {
	bool esIgual = false;
	int index = buscarFuncion(nombre);
	if(TS[index-nParam].tipoDato == dato)
		esIgual = true;
	return esIgual;
}

void insertarVariable(char* nom, int numPar, int longitud){
	if(compruebaMismoNombreDeclar(nom, numPar)){
		printf("\nError semantico en la linea %d: la variable %s ya esta declarada en este bloque\n", yylineno, nom);
	}else{ 
		entradaTS aux;
		aux.entrada = variable;
		aux.nombre = nom;
		aux.tipoDato = desconocido;
		aux.longitud = longitud;
		insertar(aux);
	}
}




void comprobarEsBueno(char* nom, dtipo dat) {
	if(compruebaVar(nom) == 0) 
		printf("\nError semantico en la linea %d: la variable %s no esta declarada\n", yylineno, nom);
	else {
		aux=getSimboloIdentificador(nom);
		if(aux.tipoDato != dat) {			
			printf("\nError semantico en la linea %d: se intento asignar a la variable %s el tipo %s\n", yylineno, nom, toString(dat));
		}
	}
}

void insertarParametros(entradaTS* argumentos, int numArg){
	for (int i = 0; i < numArg; ++i)
		insertar(argumentos);
}





/*
agregarParametros(char * Nomb, int numArgumentos){
	int index;
	for(int i = numArgumentos; i>0; --i) {
		if(i!=numArgumentos)
			fputs(",",file);
		index = buscarFuncion(Nomb);
		char * Nombre = TS[index-i].Nombre;
		char * midato = tipoDeDato(TS[index-i].dato);
		char * sent;
		sent =(char *) malloc(200);;
		sprintf(sent,"%s %s",midato,Nombre);
		fputs(sent,file);
	}	
}


aniadeSubprog(char * Nombre,int dato,int numArgumentos){
	char * sent;
	sent =(char *) malloc(200);
	char * midato = tipoDeDato(dato);
	sprintf(sent,"%s %s (",midato,Nombre);
	fputs(sent,file);
	agregarParametros(Nombre,numArgumentos);
	fputs(")",file);
}
agregarVariable(int dato){
	int i;
	bool fin=false;
	bool coma=false;
	char * sent;
	sent =(char *) malloc(200);
	sprintf(sent,"%s ",tipoDeDato(dato));
	for(i=0; i < TOPE && fin==false; i++){
		if(TS[TOPE-1-i].entrada == 3 && TS[TOPE-1-i].dato == 6){
			if(coma)	sprintf(sent,"%s,",sent);
			sprintf(sent,"%s %s",sent,TS[TOPE-1-i].Nombre);
			coma = true;
		}else{
			fin=true;
		}
	}
	sprintf(sent,"%s;\n",sent);
	fputs(("%s",sent),file);

}

agregarAsignacion(char * Nombre,char * valor) {
	char * sent;
	sent =(char *) malloc(200);
	sprintf(sent,"%s = %s;\n",Nombre,valor);
	fputs(("%s",sent),file);
}

char raizTipo(int dato) {
	if(dato==1)	return 'd';
	else if(dato==2)	return 'f';
	else if(dato==3)	return 'c';
	else if(dato==4)	return 'b';
	else return 'a';
}
*/


