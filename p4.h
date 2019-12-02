typedef int bool;
#define true 1
#define false 0
#define YYSTYPE atributos_snt //Para redefinir el yylval para que no sea un entero, sino nuestro símbolo
							  //Los $ son de tipo atributo_snt
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
	dtipo 			tipoDato ;
	unsigned int 	parametros ;
	unsigned int	longitud ;
} entradaTS ;

typedef struct {
		char*	valor ;			/*Nombre del lexema*/
		dtipo 	tipoDato ;		/*Tipo del símbolo*/
		char*	nombre;
} atributos ;


#define YYSTYPE atributos  /*A partir de ahora, cada símbolo tiene*/
							/*una estructura de tipo atributos*/

/*Lista de funciones y procedimientos para manejo de la TS*/


/*Fin de funciones y procedimientos para manejo de la TS*/


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

void limpiarMarca(){
   bool encontrada = false;
   int i;
   for (i=TOPE-1; i>0 && !encontrada; --i) {
      if(TS[i].entrada == marca) {
		TOPE = i;
        encontrada = true;
      }
   }
   if(encontrada == false)
	  limpiarTodo();
}

void limpiarTodo(){
	TOPE=0;
}

void insertarMarca(){
   TS[TOPE].entrada = marca;
   ++TOPE;
}


void sacar(){
   if (TOPE > 0) {
      --TOPE;
   }
}

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

//Comprueba si la variable se ha declarado anteriormente
bool compruebaVar(char* nombre){
		int i;
		bool encontrada=false;
		
		for(i=TOPE-1; i>=0 && !encontrada; --i){
			if( (TS[i].entrada == variable || TS[i].entrada == funcion) && strcmp(TS[i].nombre, nombre) == 0)
				encontrada = true;				
		}
		return encontrada;
}

tipoDato getTipoDato(char* nombre){
	int i;
	bool encontrada=false;
	tipoDato ret;
	
	for(i=TOPE-1; i>=0 && !encontrada; --i){
		if( (TS[i].entrada == variable || TS[i].entrada == funcion ) && strcmp(TS[i].nombre, nombre) == 0){
			encontrada = true;
			ret=TS[i].tipoDato;
		}
	}
	return ret;	
}

tipoDato getTipoArg(char* nombreFun, int numPar){
	int i, indiceFun;
	bool encontrada=false;
		
	for(i=TOPE-1; i>=0 && !encontrada; --i){
		if( TS[i].entrada == funcion && strcmp(TS[i].nombre, nombreFun) == 0){
			encontrada = true;
			indiceFun=i;
		}	
	}
	
	if(numPar > TS[indiceFun].parametros){
		return -1;
	}
	
	return TS[indiceFun-TS[indiceFun].parametros+numPar-1].tipoDato;	
}


int buscarFuncion (char* Nomb) {
	for (int i = TOPE-1; i > 0; --i){
		if(strcmp(TS[i].nombre,Nomb))
			return i+1;
	}
	return -1;
}

bool comprobarParametros(char* nombre, tipoDato dato, int nParam) {
	bool esIgual = false;
	int index = buscarFuncion(nombre);
	if(TS[index-nParam].tipoDato == dato)
		esIgual = true;
	return esIgual;
}

