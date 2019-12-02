typedef int bool;
#define true 1
#define false 0
#define YYSTYPE atributos_snt //Para redefinir el yylval para que no sea un entero, sino nuestro símbolo
							  //Los $ son de tipo atributo_snt

typedef enum {marca, funcion, variable, parametro_formal} TipoEntrada;

typedef enum {booleano, entero, real, caracter, lista, desconocido, no_asignado} TipoDato;

typedef struct {
   int entrada;
   char * Nombre;
   int dato;
   int parametros;
   int numArgumentos;
   int tamDim1;
   int tamDim2;
   char * contenido;
} TablaSimbolos;

typedef struct {
	char * Nombre;
	int dato;
	int atributo;
	char * valor;
	int tamDim1;
	int tamDim2;
	char * contenido;
}atributos_snt; //atributos símbolo no terminal

TablaSimbolos TS[1000];
long int TOPE = 0;
FILE * file;
char * argumento;

// hay que hacer un limpiar todo

void aniadir (TablaSimbolos s){
   if (TOPE == 1000) {
      printf("\nError: tamanio maximo alcanzado\n");
      exit(-1);
   } else {
	  TS[TOPE].Nombre=s.Nombre;
	  TS[TOPE].dato=s.dato;
	  TS[TOPE].parametros=s.parametros;
	  TS[TOPE].entrada=s.entrada;
	  TS[TOPE].numArgumentos=s.numArgumentos;
	  TS[TOPE].tamDim1=s.tamDim1;
	  TS[TOPE].tamDim2=s.tamDim2;
      TOPE++;
   }
}


void limpiarMarca (){
   bool encontrada = false;
   int i;
   int nArg;
   for (i=TOPE-1; i>0 && !encontrada; i--) {
      if(TS[i].entrada == 1) {
         TOPE = i;
	 nArg = TS[TOPE-1].numArgumentos;
	 for(i=0;i<nArg;i++)	TS[TOPE-i-2].Nombre = "free";
         encontrada = true;
      }
   }
   if(encontrada == false)
	  TOPE = 0;
}

void limpiarTodo(){
	TOPE=0;
}

void aniadirMarca () {
   TS[TOPE].entrada = 1;
   TOPE = TOPE+1;
}


void sacar (){
   if (TOPE > 0) {
      TOPE = TOPE - 1;
   }
}

void imprimirTS(){
	int i;
	
	for(i=0; i < TOPE ; i++){
		if(TS[i].Nombre!="free") {
		if(TS[i].entrada == 3){
			if(TS[i].dato == 1)
				printf("\nLa variable %s es de tipo entero \n",TS[i].Nombre);
			
			if(TS[i].dato == 4)
				printf("\nLa variable %s es de tipo booleano \n",TS[i].Nombre);
			
			if(TS[i].dato == 2)
				printf("\nLa variable %s es de tipo real \n",TS[i].Nombre);
			
			if(TS[i].dato == 3)
				printf("\nLa variable %s es de tipo caracter \n",TS[i].Nombre);
			
			if(TS[i].dato == 5)
				printf("\nLa variable %s es de tipo array \n",TS[i].Nombre);
	
			
		}
		
		if(TS[i].entrada == 1)
			printf("\nINICIO BLOQUE\n");
		
		if(TS[i].entrada == 2){
			if(TS[i].dato == 1)
				printf("\nLa funcion %s tiene %d argumentos y devuelve el tipo entero \n",TS[i].Nombre,TS[i].numArgumentos);
			
			if(TS[i].dato == 4)
				printf("\nLa funcion %s tiene %d argumentos y devuelve el tipo booleano \n",TS[i].Nombre,TS[i].numArgumentos);
			
			if(TS[i].dato == 2)
				printf("\nLa funcion %s tiene %d argumentos y devuelve el tipo real \n",TS[i].Nombre,TS[i].numArgumentos);
			
			if(TS[i].dato == 3)
				printf("\nLa funcion %s tiene %d argumentos y devuelve el tipo caracter \n",TS[i].Nombre,TS[i].numArgumentos);
			
			if(TS[i].dato == 5)
				printf("\nLa funcion %s tiene %d argumentos y devuelve el tipo array \n",TS[i].Nombre,TS[i].numArgumentos);
			
			
		}
	}}
	
}


void asignarTipo(int td,int atributo){
	int i;
	bool fin=false;

	for(i=0; i < TOPE && fin==false; i++){
		if(TS[TOPE-1-i].entrada == 3 && TS[TOPE-1-i].dato == 6){
			TS[TOPE-1-i].dato=td;
			if(td==5)
				TS[TOPE-1-i].parametros=atributo;
		}else{
			fin=true;
		}
	}

}


bool compruebaVar(char * nombre){
		int i;
		bool encontrada=false;
		
		for(i=TOPE-1; i>=0 && encontrada == false ;i--){
			
			if( (TS[i].entrada == 3 || TS[i].entrada == 2) && strcmp(TS[i].Nombre, nombre) == 0){
				encontrada = true;				
			}
		}
		
		return encontrada;
	
}

bool compruebaMismoNombre(char * nombre){
	
	int i;
	bool encontrada=false;
		
	for(i=TOPE-1; i>=0 && TS[i].entrada != 1 && encontrada == false ;i--){
			
		if( (TS[i].entrada == 3 || TS[i].entrada == 2) && strcmp(TS[i].Nombre, nombre) == 0){
			encontrada = true;				
		}
			
	}
		
	return encontrada;
	
}

bool compruebaMismoNombreDeclar(char * nombre, int num){
	
	int i;
	bool encontrada=false;
	int indiceMarca=0;
		
	for(i=TOPE-1; i>=(indiceMarca-num-1) && encontrada == false ;i--){
			
		if( (TS[i].entrada == 3 || TS[i].entrada == 2) && strcmp(TS[i].Nombre, nombre) == 0){
			encontrada = true;				
		}
		
		if(TS[i].entrada==2) {
			indiceMarca=i;
			num = TS[i].numArgumentos;
		}
	}
		
	return encontrada;
	
}

TablaSimbolos tipoDato(char * nombre){
	int i;
		bool encontrada=false;
		TablaSimbolos f;
		
		for(i=TOPE-1; i>=0 && encontrada == false ;i--){
			
			if( (TS[i].entrada == 3 || TS[i].entrada == 2 ) && strcmp(TS[i].Nombre, nombre) == 0){
				encontrada = true;
				f=TS[i];
			}
			
		}
		
		return f;	
}

char * cadenaTipo(int td,int at){
	if(td == 1)
			return "entero";
			
	if(td == 4)
			return "booleano";
			
	if(td == 2)
			return "real";
			
	if(td == 3)
			return "caracter";
	
	if(td == 5)
			return "array";

	
}

TablaSimbolos tipoArg(char * nombreFun,int numPar){
	int i,indiceFun;
	bool encontrada=false;
		
	for(i=TOPE-1; i>=0 && encontrada == false ;i--){
			
		if( TS[i].entrada == 2 && strcmp(TS[i].Nombre, nombreFun) == 0){
			encontrada = true;
			indiceFun=i;
		}
			
	}
	
	if(numPar > TS[indiceFun].numArgumentos){
		TablaSimbolos feo;
		feo.numArgumentos=-1;
		return feo;
	}
	
	return TS[indiceFun-TS[indiceFun].numArgumentos+numPar-1];	
}


int buscarFuncion (char * Nomb) {
	int index = -1;
	int i = TOPE-1;
	while( i > 0){
		if(strcmp(TS[i].Nombre,Nomb)) {
			return i+1;
		}
		i--;
	}
	return index;
}

bool comprobarParametros(char * Nombre,int dato,int nParam) {
	bool esIgual = false;
	int index = buscarFuncion(Nombre);
	int dato2 = TS[index-nParam].dato;
	if(dato2 == dato)
		esIgual = true;
	return esIgual;
}

/******************************************PRACTICA 5******************************/
int temp = 0;

char * generaTemp(){
	char * cadena = (char *) malloc(20);
	sprintf("temp%d",temp);
	temp++;
	return cadena;
}

generarFichero() {
	file = fopen("codigoGenerado.c","w");
	fputs("#include<stdio.h>\n",file);
}

cerrarFichero() {
	fclose(file);
}

int tipoDeDato (int td) {
	if(td == 1)
			return "int";
			
	if(td == 4)
			return "bool";
			
	if(td == 2)
			return "float";
			
	if(td == 3)
			return "char";
	
	if(td == 5)
			return "array";

}

agregarParametros(char * Nomb, int numArgumentos){
	int index;
	for(int i = numArgumentos; i>0; i--) {
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

