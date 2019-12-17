typedef int bool;

int debug=0;

#define true 1
#define false 0
#define MAX_TS 1000
#define MAX_TF 1000

typedef enum {marca, variable, funcion, parametro_formal} tipoEntrada ;

typedef enum {desconocido, entero, real, caracter, booleano, lista, cadena} dtipo ;

typedef struct {
char* EtiquetaEntrada ;
char* EtiquetaSalida ;
char* EtiquetaElse ;
char* NombreVarControl ;
} etiquetaFlujo ;

typedef struct {
	tipoEntrada 	entrada ;
	char*			nombre ;
	char* 			valor;
	dtipo 			tipoDato ;
	dtipo			tipoInternoLista ;
	unsigned int 	parametros ;
	etiquetaFlujo	ef ;
} entradaTS;

int TOPEFLUJO = 0;
etiquetaFlujo TF[MAX_TF];

entradaTS TS[MAX_TS];	/*Pila de la tabla de símbolos*/
int TOPE = 0;
unsigned int Subprog ;     /*Indicador de comienzo de bloque de un subprog*/
FILE* file;
FILE* file_std;
FILE* file_fun;
char* argumento;


#define YYSTYPE entradaTS  /*A partir de ahora, cada símbolo tiene*/
							/*una estructura de tipo atributos*/

char* tipoDeDato();
char* toStringEntrada();
char* toStringTipo();
void concatenarStrings1(char* destination, char* source1);
char tipoAFormato();
char* strdup(const char *src);
char* numTabs();

char* tabs = NULL;

char *strdup(const char *src) {
    char *dst = malloc(strlen (src) + 1);  // Space for length plus nul
    if (dst == NULL) return NULL;          // No memory
    strcpy(dst, src);                      // Copy the characters
    return dst;                            // Return the new string
}

void copiarEF(etiquetaFlujo *dest, etiquetaFlujo *source){
	if (source->EtiquetaEntrada != NULL) 	dest->EtiquetaEntrada = strdup(source->EtiquetaEntrada) ;
	if (source->EtiquetaSalida != NULL)		dest->EtiquetaSalida = strdup(source->EtiquetaSalida) ;
	if (source->EtiquetaElse != NULL)		dest->EtiquetaElse = strdup(source->EtiquetaElse) ;
	if (source->NombreVarControl != NULL)	dest->NombreVarControl = strdup(source->NombreVarControl) ;
}


// Inserta una entrada en la pila
void insertar (entradaTS s){
	if(debug) printf("Inserto la %s %s\n", toStringEntrada(s.entrada), s.nombre);

   if (TOPE == MAX_TS) {
		printf("\nError: tamanio maximo alcanzado\n");
		exit(-1);
   } else {
		TS[TOPE].nombre=s.nombre;
		TS[TOPE].valor=s.valor;
		TS[TOPE].tipoDato=s.tipoDato;
		TS[TOPE].tipoInternoLista=s.tipoInternoLista;
		TS[TOPE].parametros=s.parametros;
		TS[TOPE].entrada=s.entrada;
		TS[TOPE].ef = s.ef;
		++TOPE;
   }
}

void insertarFlujo (etiquetaFlujo s){
	if (TOPEFLUJO == MAX_TF) {
		printf("\nError: tamanio maximo alcanzado\n");
		exit(-1);
	} else {
		TF[TOPEFLUJO].EtiquetaEntrada=s.EtiquetaEntrada;
		TF[TOPEFLUJO].EtiquetaSalida=s.EtiquetaSalida;
		TF[TOPEFLUJO].EtiquetaElse=s.EtiquetaElse;
		TF[TOPEFLUJO].NombreVarControl=s.NombreVarControl;
		++TOPEFLUJO;
	}
}

int buscarFuncion (char* nom) {
	if(debug) printf("buscarFuncion( %s )\n", nom );
	if( nom != 0 ){
		//if(debug) printf("buscarFuncion. nom:%s\ttope%d", nom, TOPE);

		for (int i = TOPE-1; i > 0; --i){
			//if(debug) printf("i=%d\tTS[i].nombre:%s\tTS[i].entrada:%s\n", i, TS[i].nombre, toStringEntrada(TS[i].entrada));
			if(TS[i].nombre != 0 ){
				//if(debug) printf("strcmp(TS[i].nombre, nom)==0:%d\tTS[i].entrada == funcion:%d\n", strcmp(TS[i].nombre, nom)==0, TS[i].entrada == funcion);

				if(strcmp(TS[i].nombre, nom)==0 && TS[i].entrada == funcion)
					return i;
			}
		}
		return -1;
	}
	return -1;
}

// Inserta los "numArgumentos" parametros formales de la funcion "nom" como variables
void insertarArgumentos(char* nom, int numArgumentos){
	if(debug) printf("insertarArgumentos( %s , %d )\n", nom, numArgumentos);

	int index = buscarFuncion(nom);
	if(debug) printf("Indice de la funcion %s: %d\n", nom, index);

	if( index > 0 ){
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
	if(debug) printf("vaciar()\n");
	TOPE=0;
}

// Posiciona el tope de la pila en la última marca, eliminando así todo el bloque
void eliminarBloque(){
	if(debug) printf("eliminarBloque()\n");

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

	if(strlen(tabs) > 0)
		tabs[strlen(tabs)-1] = '\0';
}


// Introduce una entrada en la pila de tipo marca de inicio de bloque
void insertarMarca(){
	if(debug) printf("insertarMarca()\n");

	if (TOPE == 1000) {
		printf("\nError: tamanio maximo alcanzado\n");
		exit(-1);
	} else {
		TS[TOPE].entrada = marca;
		++TOPE;

		if( tabs == NULL ){
			tabs = (char*) malloc(50);
			tabs[0] = '\0';
		}
		if (contBloques > 0)	concatenarStrings1(tabs, "\t");
	}
}

// Elimina el último elemento de la pila
void sacar(){
	if(debug) printf("sacar()\n");
   if (TOPE > 0) {
      --TOPE;
   }
}

void sacarTF(){
	if(debug) printf("sacar()\n");
   if (TOPEFLUJO > 0) {
      --TOPEFLUJO;
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
	if(debug) printf("variableExisteBloque( %s )\n", ts.nombre);
	if( ts.nombre != 0 ){
		bool encontrada = false;

		for(int i=TOPE-1; i>=0 && !encontrada; --i){
				if( (TS[i].entrada == variable || TS[i].entrada == funcion) && TS[i].nombre != 0 && strcmp(TS[i].nombre, ts.nombre) == 0)
					encontrada = true;
				if(TS[i].entrada==marca)
					return encontrada;
		}
		return encontrada;
	}
	return false;
}

// Comprueba si la variable se ha declarado anteriormente
bool variableExiste(entradaTS ts){
	if(debug) printf("variableExiste( %s )\n", ts.nombre);
	if( ts.nombre != 0 ){
		bool encontrada = false;

		for(int i=TOPE-1; i>=0 && !encontrada; --i){
			if( (TS[i].entrada == variable || TS[i].entrada == funcion) && TS[i].nombre != 0 && strcmp(TS[i].nombre, ts.nombre) == 0 )
				encontrada = true;
		}
		return encontrada;
	}
	return false;
}

// Comprueba si hay otro parámetro con el mismo nombre en la misma función
bool parametroExiste(entradaTS ts){
	if(debug) printf("parametroExiste( %s )\n", ts.nombre);
	if( ts.nombre != 0 ){
		int i = TOPE-1;

		while( TS[i].entrada == parametro_formal ){
			if( TS[i].nombre != 0 && strcmp(TS[i].nombre, ts.nombre) == 0 )
				return true;
			--i;
		}
		return false;
	}
	return false;
}

// Devuelve la ultima entrada de la pila asociada a la función o variable con nombre "nombre"
entradaTS getSimboloIdentificador(char* nombre){
	if(debug) printf("getSimboloIdentificador( %s )\n", nombre);
	entradaTS ret = { 0, 0, 0, 0, 0, 0};
	if( nombre != 0 ){
		int i;
		bool encontrada=false;

		for(i=TOPE-1; i>=0 && !encontrada; --i){
			if( (TS[i].entrada == variable || TS[i].entrada == funcion ) && TS[i].nombre != 0
					&& strcmp(TS[i].nombre, nombre) == 0){
				encontrada = true;
				ret=TS[i];
			}
		}
		return ret;
	}
	return ret;
}

// Devuelve la entrada de la pila asociada al argumento número "numPar" de la funcion con nombre "nombreFun"
entradaTS getSimboloArgumento(char* nombreFun, int numPar){
	if(debug) printf("getSimboloArgumento( %s , %d )\n", nombreFun, numPar);
	entradaTS ret;
	ret.parametros=-1;

	if( nombreFun != 0 ){
		int indiceFun = -1;
		bool encontrada=false;

		for(int i=TOPE-1; i>=0 && !encontrada; --i){
			if( TS[i].entrada == funcion && TS[i].nombre != 0 && strcmp(TS[i].nombre, nombreFun) == 0){
				encontrada = true;
				indiceFun=i;
			}
		}

		if( indiceFun >0 && numPar > TS[indiceFun].parametros){
			return ret;
		}

		return TS[indiceFun-TS[indiceFun].parametros+numPar-1];
	}
	return ret;
}

/****************************		FUNCIONES AUXILIARES		**************************/

/*
void concatenarStrings(char* destination, char* format, ...){
	_G_va_list argptr;

	sprintf(destination, format, argptr);
}
*/

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
	char* tabs;

	for(i=0; i < TOPE ; ++i){
		if(TS[i].entrada == marca){
			printf("\nINICIO BLOQUE\n");
			concatenarStrings1(tabs, "\t");
		}
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
	if (ts.tipoDato != desconocido)
		printf("Error semantico en la linea %d: La %s %s ya esta declarada en este bloque\n", numLinea, toStringEntrada(ts.entrada), ts.nombre);
}

void mensajeErrorNoDeclarada(entradaTS ts){
	if (ts.tipoDato != desconocido)
		printf("Error semantico en la linea %d: La %s %s no ha sido declarada\n", numLinea, toStringEntrada(ts.entrada), ts.nombre);
}

void mensajeErrorParametro(entradaTS ts){
	if (ts.tipoDato != desconocido)
		printf("Error semantico en la linea %d: Hay mas de un parametro con el mismo nombre \"%s\"\n", numLinea, ts.nombre);
}

void mensajeErrorNoVariable(entradaTS ts){
	if (ts.tipoDato != desconocido)
		printf("Error semantico en la linea %d: La %s %s no es una variable\n", numLinea, toStringEntrada(ts.entrada), ts.nombre);
}

void mensajeErrorAsignacion(entradaTS ts1, entradaTS ts2){
	if (ts1.tipoDato != desconocido && ts2.tipoDato != desconocido )
		printf("Error semantico en la linea %d: Los tipos de la asignacion %s y %s no coinciden\n", numLinea, toStringTipo(ts1.tipoDato),
				toStringTipo(ts2.tipoDato));
}

void mensajeErrorTiposInternosNoCoinciden(entradaTS ts1, entradaTS ts2){
	if (ts1.tipoDato != desconocido && ts2.tipoDato != desconocido )
		printf("Error semantico en la linea %d: Los tipos %s y %s no coinciden\n", numLinea, toStringTipo(ts1.tipoInternoLista),
				toStringTipo(ts2.tipoInternoLista));
}

void mensajeErrorComparacion(entradaTS ts1, entradaTS ts2){
	if (ts1.tipoDato != desconocido && ts2.tipoDato != desconocido )
		printf("Error semantico en la linea %d: No se pueden comparar los tipos %s y %s\n",
										numLinea, 		toStringTipo(ts1.tipoDato), toStringTipo(ts2.tipoDato));
}

void mensajeErrorTipoArgumento(char * nombre, int nParam, dtipo tipo){
	printf("Error semantico en la linea %d: Se esperaba que el argumento %d de la funcion %s fuera de tipo %s\n",
										numLinea, 		nParam, nombre, toStringTipo(tipo));
}

void mensajeErrorTipo1(entradaTS ts, dtipo esperado){
	if (ts.tipoDato != desconocido && esperado != desconocido){
		if( ts.entrada == variable )
			printf("Error semantico en la linea %d: La variable %s no es de tipo %s\n", numLinea, ts.nombre, toStringTipo(esperado));
		else if( ts.entrada == funcion )
			printf("Error semantico en la linea %d: La funcion %s no devuelve valores de tipo %s\n", numLinea, ts.nombre,
						toStringTipo(esperado));
		else printf("Error semantico en la linea %d: La expresion %s no es de tipo %s\n", numLinea, ts.valor, toStringTipo(esperado));
	}
}

void mensajeErrorTipo2(entradaTS ts, dtipo esperado1, dtipo esperado2){
	if (ts.tipoDato != desconocido && esperado1 != desconocido && esperado2 != desconocido){
		if( ts.entrada == variable )
			printf("Error semantico en la linea %d: La variable %s no es de tipo %s o %s\n", numLinea, ts.valor, toStringTipo(esperado1),
						toStringTipo(esperado2));
		else if( ts.entrada == funcion )
			printf("Error semantico en la linea %d: La funcion %s no devuelve valores de tipo %s o %s\n", numLinea, ts.valor,
						toStringTipo(esperado1), toStringTipo(esperado2));
		else printf("Error semantico en la linea %d: La expresion %s no es de tipo %s o %s\n", numLinea, ts.valor,  toStringTipo(esperado1),
						toStringTipo(esperado2));
	}
}

void mensajeErrorOperarTipos(entradaTS ts1, entradaTS ts2){
	if (ts1.tipoDato != desconocido && ts2.tipoDato != desconocido){
		if (ts1.tipoDato == lista)
			printf("Error semantico en la linea %d: No se pueden operar los tipos %s de %s y %s\n", numLinea,
						toStringTipo(ts1.tipoDato), toStringTipo(ts1.tipoInternoLista), toStringTipo(ts2.tipoDato));
		else if (ts2.tipoDato == lista)
			printf("Error semantico en la linea %d: No se pueden operar los tipos %s y %s de %s\n", numLinea,
						toStringTipo(ts1.tipoDato), toStringTipo(ts2.tipoDato), toStringTipo(ts2.tipoInternoLista));
		else printf("Error semantico en la linea %d: No se pueden operar los tipos %s (%s) y %s (%s)\n", numLinea,
						toStringTipo(ts1.tipoDato), ts1.valor , toStringTipo(ts2.tipoDato), ts2.valor);
	}
}

void mensajeErrorSeEsperabaFuncion(entradaTS ts){
	if (ts.tipoDato != desconocido){
		printf("Error semantico en la linea %d: Se ha encontrado %s y se esperaba una funcion\n", numLinea, toStringEntrada(ts.entrada));
	}
}

void mensajeErrorNoTipo(entradaTS ts){
	if (ts.tipoDato != desconocido){
		if( ts.entrada == variable )
			printf("Error semantico en la linea %d: No se esperaba que el tipo de la variable %s fuese %s\n", numLinea, ts.nombre,
						toStringTipo(ts.tipoDato));
		else if( ts.entrada == funcion )
			printf("Error semantico en la linea %d: No se esperaba que la funcion %s devolviese valores de tipo %s\n", numLinea, ts.nombre,
						toStringTipo(ts.tipoDato));
		else printf("Error semantico en la linea %d: No se esperaba que la expresion %s fuese de tipo %s\n", numLinea, ts.valor,
						toStringTipo(ts.tipoDato));
	}
}

void mensajeErrorNumParametros(entradaTS ts1, entradaTS ts2){
	if (ts1.tipoDato != desconocido && ts2.tipoDato != desconocido )
		printf("Error semantico en la linea %d: La %s %s esperaba %d argumentos y se han encontrado %d\n",
				numLinea, toStringEntrada(ts1.entrada), ts1.nombre, ts1.parametros, ts2.parametros);
}


bool comprobarParametro(char* nombre, int nParam, dtipo dato) {
	if(debug) printf("comprobarParametro( %s, %d, %s )\n", nombre, nParam, toStringTipo(dato) );
	bool esIgual = false;
	int index = buscarFuncion(nombre);
	int nArgs = getSimboloIdentificador(nombre).parametros;
	if (nParam > nArgs) return true;
	if(TS[index-nArgs+nParam-1].tipoDato == dato)
		esIgual = true;
	return esIgual;
}



/* PRÁCTICA 5 */

int temp = -1;
int etiqueta = -1;

char* generarTemp(dtipo tipo){
	char* cadena = (char*) malloc(30);
	++temp;
	if(tipo == lista)
		sprintf(cadena, "%s temp%d = NULL;\n%stemp%d", tipoDeDato(tipo), temp, numTabs(), temp);
	else
		sprintf(cadena, "%s temp%d;\n%stemp%d", tipoDeDato(tipo), temp, numTabs(), temp);
	return cadena;
}

char* generarEtiqueta() {
	char* cadena = (char*) malloc(20);
	++etiqueta;
	sprintf(cadena, "etiqueta%d", etiqueta);
	return cadena;
}

void generarFicheroFunciones() {
	file_fun = fopen("dec_fun.h", "w");
	fputs("#include<stdio.h>\n", file_fun);
	fputs("#include \"dec_dat.h\"\n\n", file_fun);
	fputs("typedef int bool;\n", file_fun);
}

void generarFichero() {
	file_std = fopen("codigoGenerado.c", "w");
	file = file_std;
	fputs("#include<stdio.h>\n", file);
	fputs("#include \"dec_fun.h\"\n", file);
	//fputs("#include \"dec_dat.h\"\n\n", file);
	fputs("typedef int bool;\n\n", file);
	generarFicheroFunciones();
}

void cerrarFichero() {
	fclose(file);
	fclose(file_fun);
}

char* tipoDeDato (dtipo td) {
	if(td == entero)	return "int";
	if(td == booleano)	return "bool";
	if(td == real)		return "float";
	if(td == caracter)	return "char";
	if(td == lista)		return "List";
	return "Error de tipo";
}

void insertarParametros(char* nom, int numArgumentos){
	int index;

	for(int i=numArgumentos; i>0; --i) {
		if(i!=numArgumentos)
			fputs(",",file);
		index = buscarFuncion(nom);
		char* nombre = TS[index-i].nombre;
		char* midato = tipoDeDato(TS[index-i].tipoDato);
		char* sent;
		sent = (char*) malloc(200);;
		sprintf(sent, "%s %s", midato, nombre);
		fputs(sent, file);
	}
}

/*
void insertarSubprog(char* nom, dtipo dato, int numArgumentos){
	char* sent;
	sent = (char*) malloc(200);
	sprintf(sent,"%s %s (", tipoDeDato(dato), nom);
	fputs(sent, file);
	insertarParametros(nom, numArgumentos);
	fputs(")", file);
}


void insertarVariables(dtipo dato){
	int i;
	bool fin = false;
	bool coma = false;
	char* sent;
	sent = (char*) malloc(200);
	sprintf(sent, "%s%s ", tabs, tipoDeDato(dato));

	for(i=0; i<TOPE && fin==false; ++i){
		if(TS[TOPE-1-i].entrada == 3 && TS[TOPE-1-i].tipoDato == dato){
			if(coma) sprintf(sent,"%s,",sent);
			sprintf(sent, "%s %s", sent, TS[TOPE-1-i].nombre);
			coma = true;
		}
		else{
			fin=true;
		}
	}

	sprintf(sent, "%s;\n", sent);
	fputs(sent, file);
}

*/

void insertarAsignacion(char* nom, char* valor) {
	char* sent = (char*) malloc(200);
	sprintf(sent, "%s%s = %s;\n", tabs, nom, valor);
	fputs(sent, file);
}

void insertarCadena(char* cad){
	fputs(cad, file);
}

char tipoAFormato(dtipo dato) {
	if(dato == desconocido)		return 's';
	else if(dato == real)		return 'f';
	else if(dato == entero)		return 'd';
	else if(dato == caracter)	return 'c';
	else if(dato == cadena )	return 's';
	else if(dato == booleano)	return 'd';
	else 						return 'l';
}

char* tipoAPuntero(dtipo dato){
	if(dato == desconocido)		return " s";
	else if(dato == real)		return " &";
	else if(dato == entero)		return " &";
	else if(dato == caracter)	return " &";
	else if(dato == cadena )	return " ";
	else if(dato == booleano)	return " &";
	else 						return " ";
}

char* numTabs(){
	char* aux = (char*) malloc(50);
	sprintf(aux, "");
	for( int i=0; i<contBloques-contBloquesPrimeraFun; ++i )
		sprintf(aux, "%s\t", aux);
	return aux;
}
