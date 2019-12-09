typedef int bool;

#define true 1
#define false 0
#define MAX_TS 1000

typedef enum {variable, marca, funcion, parametro_formal} tipoEntrada ;

typedef enum {desconocido, entero, real, caracter, booleano, lista} dtipo ;

typedef struct {
	tipoEntrada 	entrada ;
	char*			nombre ;
	char* 			valor;
	dtipo 			tipoDato ;
	dtipo			tipoInternoLista ;
	unsigned int 	parametros ;
} entradaTS ;

entradaTS TS[MAX_TS];	/*Pila de la tabla de símbolos*/
int TOPE = 0;
unsigned int Subprog ;     /*Indicador de comienzo de bloque de un subprog*/
FILE * file;
char * argumento;

int debug=0;


#define YYSTYPE entradaTS  /*A partir de ahora, cada símbolo tiene*/
							/*una estructura de tipo atributos*/


char* toStringEntrada();
char* toStringTipo();

// Inserta una entrada en la pila
void insertar (entradaTS s){
	if(debug) printf("Inserto la %s %s\n", toStringEntrada(s.entrada), s.nombre);

   if (TOPE == 1000) {
		printf("\nError: tamanio maximo alcanzado\n");
		exit(-1);
   } else {
		TS[TOPE].nombre=s.nombre;
		TS[TOPE].valor=s.valor;
		TS[TOPE].tipoDato=s.tipoDato;
		TS[TOPE].tipoInternoLista=s.tipoInternoLista;
		TS[TOPE].parametros=s.parametros;
		TS[TOPE].entrada=s.entrada;
		++TOPE;
   }
}

int buscarFuncion (char* nom) {
	if(debug) printf("buscarFuncion. nom:%s\ttope%d", nom, TOPE);

	for (int i = TOPE-1; i > 0; --i){
		if(debug) printf("i=%d\tTS[i].nombre:%s\tTS[i].entrada:%s\n", i, TS[i].nombre, toStringEntrada(TS[i].entrada));
		if(TS[i].nombre != 0 && nom != 0){
			if(debug) printf("strcmp(TS[i].nombre, nom)==0:%d\tTS[i].entrada == funcion:%d\n", strcmp(TS[i].nombre, nom)==0, TS[i].entrada == funcion);

			if(strcmp(TS[i].nombre, nom)==0 && TS[i].entrada == funcion)
				return i;
		}
	}
	return -1;
}

// Inserta los "numArgumentos" parametros formales de la funcion "nom" como variables
void insertarArgumentos(char* nom, int numArgumentos){
	if(debug) printf("insertarArgumentos. nom:%s\tnumArgumentos:%d\n", nom, numArgumentos);

	int index = buscarFuncion(nom);
	if(debug) printf("%d", index);

	for(int i = numArgumentos; i > 0; --i) {
		entradaTS aux;
		aux.nombre = TS[index-i].nombre;
		aux.valor = TS[index-i].valor;
		aux.tipoDato = TS[index-i].tipoDato;
		aux.tipoInternoLista = TS[index-i].tipoInternoLista;
		aux.parametros = TS[index-i].parametros;
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

// Posiciona el tope en 0 vaciando así toda la pila
void vaciar(){
	TOPE=0;
}

// Posiciona el tope de la pila en la última marca, eliminando así todo el bloque
void eliminarBloque(){
	if(debug) printf("Elimino bloque\n");

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


// Introduce una entrada en la pila de tipo marca de inicio de bloque
void insertarMarca(){
	if(debug) printf("Inserto marca\n");

   TS[TOPE].entrada = marca;
   ++TOPE;
}

// Elimina el último elemento de la pila
void sacar(){
   if (TOPE > 0) {
      --TOPE;
   }
}



/*
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
*/

// Comprueba si la variable se ha declarado anteriormente en el mismo bloque
bool variableExisteBloque(entradaTS ts){
	if( ts.nombre != 0 ){
		bool encontrada = false;
		
		for(int i=TOPE-1; i>=0 && !encontrada; --i){
			if( TS[i].nombre != 0 ){
				if( (TS[i].entrada == variable || TS[i].entrada == funcion) && strcmp(TS[i].nombre, ts.nombre) == 0)
					encontrada = true;		
				if(TS[i].entrada==marca)
					return encontrada;
			}
		}
		return encontrada;
	}
	return false;
}

// Comprueba si la variable se ha declarado anteriormente
bool variableExiste(entradaTS ts){
	bool encontrada = false;
	
	for(int i=TOPE-1; i>=0 && !encontrada; --i){
		if( TS[i].nombre != 0 && ts.nombre != 0 ){
			if( (TS[i].entrada == variable || TS[i].entrada == funcion) && strcmp(TS[i].nombre, ts.nombre) == 0)
				encontrada = true;
		}
	}
	return encontrada;
}

// Comprueba si hay otro parámetro con el mismo nombre en la misma función
bool parametroExiste(entradaTS ts){
	int i = TOPE-1;

	while( TS[i].entrada == parametro_formal ){
		if( TS[i].nombre != 0 && ts.nombre != 0 ){
			if( strcmp(TS[i].nombre, ts.nombre) == 0 )
				return true;
		}
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
		if( (TS[i].entrada == variable || TS[i].entrada == funcion ) && TS[i].nombre != 0
				&& nombre != 0 && strcmp(TS[i].nombre, nombre) == 0){
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
		if( TS[i].nombre != 0 && nombreFun != 0 ){
			if( TS[i].entrada == funcion && strcmp(TS[i].nombre, nombreFun) == 0){
				encontrada = true;
				indiceFun=i;
			}
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

void concatenarStrings1(char* destination, char* source1){
	if( destination == NULL)
		destination = (char *) malloc(200);
	sprintf(destination, "%s", source1);
}

void concatenarStrings2(char* destination, char* source1, char* source2){
	if( destination == NULL)
		destination = (char *) malloc(200);
	sprintf(destination, "%s%s", source1, source2);
}

void concatenarStrings3(char* destination, char* source1, char* source2, char* source3){
	if( destination == NULL)
		destination = (char *) malloc(200);
	sprintf(destination, "%s%s%s", source1, source2, source3);
}

void concatenarStrings4(char* destination, char* s1, char* s2, char* s3, char* s4){
	if( destination == NULL)
		destination = (char *) malloc(200);
	sprintf(destination, "%s%s%s%s", s1, s2, s3, s4);
}

void concatenarStrings5(char* destination, char* s1, char* s2, char* s3, char* s4, char* s5){
	if( destination == NULL)
		destination = (char *) malloc(200);
	sprintf(destination, "%s%s%s%s%s", s1, s2, s3, s4, s5);
}

char* toStringTipo(dtipo td){
	if(td == entero) 	return "entero";		
	if(td == booleano) 	return "booleano";	
	if(td == real) 		return "real";
	if(td == caracter)	return "caracter";
	if(td == lista)		return "lista";
	return "";
}

char* toStringEntrada(tipoEntrada te){
	if(te == marca) 			return "marca";		
	if(te == funcion) 			return "funcion";	
	if(te == variable) 			return "variable";
	if(te == parametro_formal)	return "parametro_formal";
	return "";
}

// Imprime el contenido de la pila 
void imprimirTS(){
	int i;
	char tabs[50] = "\0";
	
	for(i=0; i < TOPE ; ++i){
		if(TS[i].entrada == marca)
			printf("\nINICIO BLOQUE\n");
		else{
			if( TS[i].parametros > 0 && TS[i].tipoInternoLista != desconocido )
				printf("%s%s\t%s\t%s\t%s\t%d\n", tabs, toStringEntrada(TS[i].entrada), TS[i].nombre, 
						toStringTipo(TS[i].tipoDato), toStringTipo(TS[i].tipoInternoLista) ,TS[i].parametros );
			else if( TS[i].parametros > 0 )
				printf("%s%s\t%s\t%s\t%d\n", tabs, toStringEntrada(TS[i].entrada), TS[i].nombre, 
						toStringTipo(TS[i].tipoDato) ,TS[i].parametros );
			else printf("%s%s\t%s\t%s\n", tabs, toStringEntrada(TS[i].entrada), TS[i].nombre, toStringTipo(TS[i].tipoDato));
		}
	}
	printf("**********************************************************************************\n\n\n");
}

void mensajeErrorDeclaradaBloque(entradaTS ts){
	printf("Error semantico en la linea %d: La %s %s ya esta declarada en este bloque\n", numLinea, toStringEntrada(ts.entrada), ts.nombre);
}

void mensajeErrorNoDeclarada(entradaTS ts){
	printf("Error semantico en la linea %d: La %s %s no ha sido declarada\n", numLinea, toStringEntrada(ts.entrada), ts.nombre);
}

void mensajeErrorParametro(entradaTS ts){
	printf("Error semantico en la linea %d: Hay mas de un parametro con el mismo nombre \"%s\"\n", numLinea, ts.nombre);
}

void mensajeErrorNoVariable(entradaTS ts){
	printf("Error semantico en la linea %d: La %s %s no es una variable\n", numLinea, toStringEntrada(ts.entrada), ts.nombre);
}

void mensajeErrorAsignacion(entradaTS ts1, entradaTS ts2){
	printf("Error semantico en la linea %d: Los tipos de la asignacion %s y %s no coinciden\n", numLinea, toStringTipo(ts1.tipoDato),
				toStringTipo(ts2.tipoDato));
}

void mensajeErrorTiposInternosNoCoinciden(entradaTS ts1, entradaTS ts2){
	printf("Error semantico en la linea %d: Los tipos %s y %s no coinciden\n", numLinea, toStringTipo(ts1.tipoInternoLista),
				toStringTipo(ts2.tipoInternoLista));
}

void mensajeErrorComparacion(entradaTS ts1, entradaTS ts2){
	printf("Error semantico en la linea %d: No se pueden comparar los tipos %s y %s\n", 
										numLinea, 		toStringTipo(ts1.tipoDato), toStringTipo(ts2.tipoDato));
}

void mensajeErrorTipo1(entradaTS ts, dtipo esperado){
	if( ts.entrada == variable )
		printf("Error semantico en la linea %d: La variable %s no es de tipo %s\n", numLinea, ts.nombre, toStringTipo(esperado));
	else if( ts.entrada == funcion )
		printf("Error semantico en la linea %d: La funcion %s no devuelve valores de tipo %s\n", numLinea, ts.nombre,
					toStringTipo(esperado));
	else printf("Error semantico en la linea %d: La expresion %s no es de tipo %s\n", numLinea, ts.valor, toStringTipo(esperado));
}

void mensajeErrorTipo2(entradaTS ts, dtipo esperado1, dtipo esperado2){
	if( ts.entrada == variable )
		printf("Error semantico en la linea %d: La variable %s no es de tipo %s o %s\n", numLinea, ts.nombre, toStringTipo(esperado1),
					toStringTipo(esperado2));
	else if( ts.entrada == funcion )
		printf("Error semantico en la linea %d: La funcion %s no devuelve valores de tipo %s o %s\n", numLinea, ts.nombre, 
					toStringTipo(esperado1), toStringTipo(esperado2));
	else printf("Error semantico en la linea %d: La expresion %s no es de tipo %s o %s\n", numLinea, ts.valor,  toStringTipo(esperado1),
					toStringTipo(esperado2));
}

void mensajeErrorSeEsperabaFuncion(entradaTS ts){
	printf("Error semantico en la linea %d: Se ha encontrado %s y se esperaba una funcion\n", numLinea, toStringEntrada(ts.entrada));
}

void mensajeErrorNoTipo(entradaTS ts){
	if( ts.entrada == variable )
		printf("Error semantico en la linea %d: No se esperaba que el tipo de la variable %s fuese %s\n", numLinea, ts.nombre,
					toStringTipo(ts.tipoDato));
	else if( ts.entrada == funcion )
		printf("Error semantico en la linea %d: No se esperaba que la funcion %s devolviese valores de tipo %s\n", numLinea, ts.nombre,
					toStringTipo(ts.tipoDato));
	else printf("Error semantico en la linea %d: No se esperaba que la expresion %s fuese de tipo %s\n", numLinea, ts.valor, 
					toStringTipo(ts.tipoDato));
}

void mensajeErrorNumParametros(entradaTS ts1, entradaTS ts2){
	printf("Error semantico en la linea %d: La %s %s esperaba %d argumentos y se han encontrado %d\n", 
			numLinea, toStringEntrada(ts1.entrada), ts1.nombre, ts1.parametros, ts2.parametros);
}





bool comprobarParametros(char* nombre, dtipo dato, int nParam) {
	bool esIgual = false;
	int index = buscarFuncion(nombre);
	if(TS[index-nParam].tipoDato == dato)
		esIgual = true;
	return esIgual;
}

char *strdup(const char *src) {
    char *dst = malloc(strlen (src) + 1);  // Space for length plus nul
    if (dst == NULL) return NULL;          // No memory
    strcpy(dst, src);                      // Copy the characters
    return dst;                            // Return the new string
}

/*
void insertarVariable(char* nom, int numPar, int longitud){
	if(compruebaMismoNombreDeclar(nom, numPar)){
		printf("\nError semantico en la linea %d: la variable %s ya esta declarada en este bloque\n", numLinea, nom);
	}else{ 
		entradaTS aux;
		aux.entrada = variable;
		aux.nombre = nom;
		aux.tipoDato = desconocido;
		insertar(aux);
	}
}






void comprobarEsBueno(char* nom, dtipo dat) {
	if(compruebaVar(nom) == 0) 
		printf("\nError semantico en la linea %d: la variable %s no esta declarada\n", numLinea, nom);
	else {
		aux=getSimboloIdentificador(nom);
		if(aux.tipoDato != dat) {			
			printf("\nError semantico en la linea %d: se intento asignar a la variable %s el tipo %s\n", numLinea, nom, toStringTipo(dat));
		}
	}
}



void insertarParametros(entradaTS* argumentos, int numArg){
	for (int i = 0; i < numArg; ++i)
		insertar(argumentos);
}






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


