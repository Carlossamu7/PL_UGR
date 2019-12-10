%{
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
//#include "y.tab.h"
#include "practica4.h"
#include "tabla_simbolos.h"

#define YYDEBUG 1
void comprobarVariables(char * Nomb,int numPar,char * dim1,char * dim2);
void comprobarEsBueno(char * Nomb,int dat,int atrib);
void yyerror(char const * msg);
int yylex();
Simbolo aux;
int numPar = 0;
char * nombreFun;
int contBloques = 0;
int linea = 1;
/****/
%}

%error-verbose

/*Declarion de los tokens de nuestro lenguaje*/
%token  CABECERA
%token  TIPO CONDICION SUBCONDICION CICLO OPCION CASO SALIDA
%token  RETURN INIBLOQUE FINBLOQUE INICIOVARIABLES FINVARIABLES CONSTANTES
%token  PARENTESISCERRADO ABRIRCORCHETE CERRARCORCHETE
%token  COMA FINLINEA OPBINARIOS OPSUMARESTA ASIGNACION ENTRADA
%token  DOSPUNTOS ENTERO CADENA IDENTIFICADOR PARENTESISABIERTO
%token  OPUNARIO DEFAULT BREAK

%left  OPBINARIOS_OR
%left  OPBINARIOS_AND
%left  OPBINARIOS_IGUALDAD
%left  OPBINARIOS
%left  OPSUMARESTA
%left  OPBINARIOS_MULTI
%right OPUNARIO



/*Inicio de la sintaxis*/

%start Programa

%%

Programa: {generarFichero();} CABECERA bloque{cerrarFichero();};

bloque: ini_bloque declar_de_variables_locales declar_de_subprogs sentencias fin_bloque
      | ini_bloque declar_de_variables_locales sentencias fin_bloque
      | ini_bloque declar_de_subprogs fin_bloque
      | ini_bloque sentencias fin_bloque;

ini_bloque: INIBLOQUE {aniadirMarca(); contBloques++;};

fin_bloque: FINBLOQUE {contBloques--;/*imprimirTS();*/limpiarMarca();};

declar_de_variables_locales: INICIOVARIABLES variables FINVARIABLES;

variables: cuerpo_de_variables 
         | variables cuerpo_de_variables;

cuerpo_de_variables: TIPO lista_identificador FINLINEA				{agregarVariable($1.dato); asignarTipo($1.dato,$1.atributo);}			
		   | TIPO lista_identificador_array FINLINEA			{agregarVariable($1.dato);asignarTipo($1.dato,$1.atributo);}
		   | error;
	
lista_identificador_array: lista_identificador_array COMA identificador_array
			 | identificador_array;

identificador_array: IDENTIFICADOR ABRIRCORCHETE ENTERO CERRARCORCHETE					   {comprobarVariables($1.Nombre,numPar,$3.valor,"0");}
		   | IDENTIFICADOR ABRIRCORCHETE ENTERO CERRARCORCHETE ABRIRCORCHETE ENTERO CERRARCORCHETE {comprobarVariables($1.Nombre,numPar,$3.valor,$6.valor);};


lista_identificador: lista_identificador COMA IDENTIFICADOR 	 		{comprobarVariables($3.Nombre,numPar,"0","0");}
		   | IDENTIFICADOR						{comprobarVariables($1.Nombre,numPar,"0","0");};

declar_de_subprogs: declar_de_subprogs declar_subprogs
                  | declar_subprogs;

declar_subprogs: cabecera_subprograma {numPar=$1.atributo;fputs("{\n",file);} bloque {fputs("}\n",file);};

cabecera_subprograma:  TIPO IDENTIFICADOR PARENTESISABIERTO lista_de_parametros PARENTESISCERRADO
			{$$.atributo=$2.atributo; 
				if(compruebaMismoNombre($2.Nombre)){
			printf("\nError semantico en la linea %d: la funcion %s ya esta declarada en este bloque\n",linea,$2.Nombre);
			}else{
				aux.entrada=2;
				aux.Nombre=$2.Nombre;
				aux.dato=$1.dato;
				aux.parametros=$1.atributo;
				aux.numArgumentos=$4.atributo;
				aniadir(aux);
				aniadeSubprog(aux.Nombre,aux.dato,aux.numArgumentos);}}
;

lista_de_parametros: lista_de_parametros COMA TIPO IDENTIFICADOR 	{comprobarVariables($4.Nombre,numPar,"0","0");
									asignarTipo($3.dato,$3.atributo);
									$$.atributo=$$.atributo+1;
									}

		    | lista_de_parametros COMA TIPO identificador_array {comprobarVariables($4.Nombre,numPar,"0","0");
									asignarTipo($3.dato,$3.atributo);
									$$.atributo=$$.atributo+1;
									}
		    | TIPO IDENTIFICADOR				{comprobarVariables($2.Nombre,numPar,"0","0");
									asignarTipo($1.dato,$1.atributo);
									$$.atributo=1;
									}
		    | TIPO identificador_array				{comprobarVariables($2.Nombre,numPar,"0","0");
									asignarTipo($1.dato,$1.atributo);
									$$.atributo=1;
									}
		    | error;

sentencias: sentencias sentencia
          | sentencia;

sentencia: {fputs("{\n",file);}bloque{fputs("}\n",file);} 
         | sentencia_asignacion
         | sentencia_if
         | sentencia_while
         | sentencia_entrada
         | sentencia_salida
         | sentencia_return
         | sentencia_switch
	 | error;

sentencia_asignacion: nombre_var ASIGNACION expresion FINLINEA			{comprobarEsBueno($1.Nombre,$3.dato,$3.atributo);agregarAsignacion($1.Nombre,$3.contenido);};

nombre_var: IDENTIFICADOR						{if(compruebaVar($1.Nombre) == 0)
					printf("\nError semantico en la linea %d: la variable %s no esta declarada\n",linea,$1.Nombre);}
	  |IDENTIFICADOR ABRIRCORCHETE expresion CERRARCORCHETE		{if(compruebaVar($1.Nombre) == 0)
					printf("\nError semantico en la linea %d: la variable %s no esta declarada\n",linea,$1.Nombre);
									else{$$.dim1 =0;$1.dim2=0;}}
          |IDENTIFICADOR ABRIRCORCHETE expresion CERRARCORCHETE ABRIRCORCHETE expresion CERRARCORCHETE {if(compruebaVar($1.Nombre) == 0)
					printf("\nError semantico en la linea %d: la variable %s no esta declarada\n",linea,$1.Nombre);
									else{$$.dim1 =0;$1.dim2=0;}};


sentencia_if: CONDICION PARENTESISABIERTO expresion {char * sent=(char *) malloc(200);sprintf(sent,"if(%s)",$3.contenido);fputs(("%s",sent),file);} PARENTESISCERRADO sentencia {if($3.dato != 4) printf("\nError semantico en la linea %d: tipo en if no es booleano",linea);}
	    | CONDICION PARENTESISABIERTO expresion PARENTESISCERRADO {char * sent=(char *) malloc(200);sprintf(sent,"if(%s)",$3.contenido);fputs(("%s",sent),file);} sentencia SUBCONDICION {fputs("\nelse ",file);} sentencia {if($3.dato != 4) printf("\nError semantico en la linea %d: tipo en if no es booleano",linea);}; 

sentencia_while: CICLO PARENTESISABIERTO expresion {char * sent=(char *) malloc(200);sprintf(sent,"while(%s)",$3.contenido);fputs(("%s",sent),file);} PARENTESISCERRADO sentencia{if($3.dato != 4) printf("\nError semantico en la linea %d: tipo en while no es booleano",linea);};

sentencia_entrada: ENTRADA lista_variables FINLINEA {char * sent=(char *) malloc(200);;sprintf(sent,"scanf(%s);\n",$2.contenido);fputs(("%s",sent),file);};

lista_variables: lista_variables COMA IDENTIFICADOR {if(compruebaVar($3.Nombre) == 0)
					printf("\nError semantico en la linea %d: la variable %s no esta declarada\n",linea,$3.Nombre);
						     else{
							char * sent=(char *) malloc(200);
							char * nombre = $3.Nombre;
							int dato = $3.dato;char tipo = raizTipo(dato);
							sprintf(sent,"\"%s%c\",&%s","%",tipo,nombre);$$.contenido = sent;
							$$.contenido = sent;}}	
		| IDENTIFICADOR		    {if(compruebaVar($1.Nombre) == 0)
					printf("\nError semantico en la linea %d: la variable %s no esta declarada\n",linea,$1.Nombre);
						else{
							char * sent=(char *) malloc(200);
							char * nombre = $1.Nombre;
							int dato = $1.dato;char tipo = raizTipo(dato);
							sprintf(sent,"\"%s%c\",&%s","%",tipo,nombre);$$.contenido = sent;
							$$.contenido = sent;}};
							
sentencia_salida: SALIDA lista_exp_cadena FINLINEA {char * sent=(char *) malloc(200);sprintf(sent,"printf(%s);\n",$2.contenido);fputs(("%s",sent),file);};

sentencia_return: RETURN expresion FINLINEA;

sentencia_switch: OPCION PARENTESISABIERTO expresion PARENTESISCERRADO ini_bloque sentencia_case fin_bloque
		| OPCION PARENTESISABIERTO expresion PARENTESISCERRADO ini_bloque sentencia_case default fin_bloque;

sentencia_case: sentencia_case CASO DOSPUNTOS constante sentencia 
		| CASO DOSPUNTOS constante sentencia
		| sentencia_case CASO DOSPUNTOS constante sentencia BREAK FINLINEA 
		| CASO DOSPUNTOS constante sentencia BREAK FINLINEA;

default: DEFAULT DOSPUNTOS sentencia;

constante: ENTERO		{$$.dato = $1.dato;$$.atributo = $1.atributo;}
	 | CONSTANTES		{$$.dato = $1.dato;$$.atributo = $1.atributo;};

lista_exp: expresion COMA lista_exp 	{$$.atributo=$3.atributo+1;if(!comprobarParametros(nombreFun,$1.dato,$$.atributo)) printf("\nparametros erroneos en linea %d",linea);}
	 | expresion			{$$.atributo=1;if(!comprobarParametros(nombreFun,$1.dato,$$.atributo)) printf("\nparametro erroneos en linea %d",linea);};

lista_exp_cadena: lista_exp_cadena COMA exp_cadena {$$.contenido=$1.contenido;}
	        | exp_cadena {$$.contenido=$1.contenido;};

exp_cadena: expresion {char * sent=(char *) malloc(200);char * nombre = $1.Nombre;int dato = $1.dato;char tipo = raizTipo(dato);sprintf(sent,"\"%s%c\",%s","%",tipo,nombre);$$.contenido = sent;}
	  | CADENA {$$.contenido=$1.valor;};

expresion: PARENTESISABIERTO expresion PARENTESISCERRADO		
	 | OPSUMARESTA expresion %prec OPUNARIO				{if($2.dato == 1 || $2.dato == 2) {
										$$.dato=$2.dato;
										char * sent = (char * ) malloc(200);
										sprintf(sent,"%s%s",$1.valor,$2.contenido);
										fputs(("%s",sent),file);
										
									} else
							printf("\nError semantico en la linea %d: se esperaba entero o real en el operador unario + -\n",linea);}
	 | OPUNARIO expresion						{if($2.dato == 4) 
										$$.dato=4;
									else
							printf("\nError semantico en la linea %d: se esperaba booleano en NOT\n",linea);}
	 | expresion OPBINARIOS expresion				{Simbolo aux = tipoDato($1.Nombre);
									Simbolo aux2 = tipoDato($3.Nombre);
									char * signo = $2.valor;
									char * nombre1 = $1.Nombre;
									char * nombre2 = $3.Nombre;
									char * sent = (char*) malloc(200);
									if(compruebaVar(nombre1)) nombre1 = $1.Nombre;
									else nombre1=$1.contenido;
									if(compruebaVar(nombre2)) nombre2 = $3.Nombre;
									else nombre2=$3.contenido;
									if((aux.dato == aux2.dato) && (aux.dato == 1 || aux.dato == 2)) {
										$$.dato=4;
										sprintf(sent,"%s %s %s",nombre1,signo,nombre2);
										$$.contenido = sent; 	
									} else if(($1.dato == $3.dato) && ($1.atributo == $3.atributo)){
										$$.dato=4;
									}else
							printf("\nError semantico en la linea %d: se esperaba tipos compatibles en el operador relacional %s y %s\n",linea,cadenaTipo($1.dato,$1.atributo),cadenaTipo($3.dato,$3.atributo));}								
	 | expresion OPSUMARESTA expresion				{int dato,dato2,dim11,dim12,dim21,dim22;
									char * nombre1 = $1.Nombre;
									char * nombre2 = $3.Nombre;
									char * signo = $2.valor;
									char * sent=(char *) malloc(200);
									if(compruebaVar(nombre1)) {
										dato = tipoDato($1.Nombre).dato;
										dim11 = tipoDato($1.Nombre).dim1;
										dim12 = tipoDato($1.Nombre).dim2;
										nombre1 = $1.Nombre;
									} else {dato = $1.dato;
										dim11 = 0;
										dim12 = 0;
										nombre1=$1.contenido;
									}
									if(compruebaVar(nombre2)) {
										dato2 = tipoDato($3.Nombre).dato;
										dim21 = tipoDato($3.Nombre).dim1;
										dim22 = tipoDato($3.Nombre).dim2;
										nombre2=$3.Nombre;
									} else {dato2 = $3.dato;
										dim21 = 0;
										dim22 = 0;
										nombre2=$3.contenido;
									}
									if(dato == dato2 && (dato == 1 || dato == 2) && dim11 == dim21 && dim12 == dim22) {
										$$.dato=dato;
										sprintf(sent,"%s %s %s",nombre1,signo,nombre2);
										$$.contenido = sent;
									} else if(dato == dato2 && $1.atributo==$3.atributo && $2.atributo==0  && dim11 == dim21 && dim12 == dim22){
										$$.dato=aux.dato;
										$$.atributo=$1.atributo;
										sprintf(sent,"%s %s %s",nombre1,signo,nombre2);
										$$.contenido = sent;
									}else
							printf("\nError semantico en la linea %d: se esperaba tipos compatibles en el operador binario + -, se encontro: (%s(+-)%s)\n",linea,cadenaTipo($1.dato,$1.atributo),cadenaTipo($3.dato,$3.atributo));}
	 | expresion OPBINARIOS_MULTI expresion				{int dato,dato2,dim11,dim12,dim21,dim22;
									char * nombre1 = $1.Nombre;
									char * nombre2 = $3.Nombre;
									char * signo = $2.valor;
									char * sent=(char *) malloc(200);
									if(compruebaVar(nombre1)) {
										dato = tipoDato($1.Nombre).dato;
										dim11 = tipoDato($1.Nombre).dim1;
										dim12 = tipoDato($1.Nombre).dim2;
										nombre1 = $1.Nombre;
									} else {dato = $1.dato;
										dim11 = 0;
										dim12 = 0;
										nombre1 = $1.contenido;
									}
									if(compruebaVar(nombre2)) {
										dato2 = tipoDato($3.Nombre).dato;
										dim21 = tipoDato($3.Nombre).dim1;
										dim22 = tipoDato($3.Nombre).dim2;
										nombre2 = $3.Nombre;
									} else {dato2 = $3.dato;
										dim21 = 0;
										dim22 = 0;
										nombre2 = $3.contenido;
									}
									if(dato == dato2 && ((dato == 1 || dato == 2) && ((dim11 == dim21 && dim12 == dim22)||(dim11==dim22&&dim12==dim21)))){
										$$.dato=dato;
										char * sent =(char*) malloc(200);
										sprintf(sent,"%s %s %s",nombre1,signo,nombre2);
										$$.contenido = sent;
									} else if(dato == dato2 && $1.atributo==$3.atributo && $3.atributo==0 && ((dim11 == dim21 && dim12 == dim22)||(dim11==dim22&&dim12==dim21))){
										$$.dato=aux.dato;
										$$.atributo=$1.atributo;
										char * sent =(char*) malloc(200);
										sprintf(sent,"%s %s %s",nombre1,signo,nombre2);
										$$.contenido = sent;
									}else
							printf("\nError semantico en la linea %d: se esperaba tipos compatibles en el operador binario * /\n",linea);}
	 | expresion OPBINARIOS_IGUALDAD expresion			{Simbolo aux = tipoDato($1.Nombre);
									Simbolo aux2 = tipoDato($3.Nombre);
									if(aux.dato == aux2.dato) {
										$$.dato=4;
										char * signo = $2.valor;
										char * nombre1 = $1.contenido;
										char * nombre2 = $3.contenido;
										char * sent =(char*) malloc(200);
										sprintf(sent,"%s %s %s",nombre1,signo,nombre2);
										$$.contenido = sent;
									}else
							printf("\nError semantico en la linea %d: se esperaba tipo %s en operador ==\n",linea,cadenaTipo($1.dato,$1.atributo));}
	 | expresion OPBINARIOS_OR expresion				{if($1.dato == 4 && $3.dato == 4)
										$$.dato=4;
									else
							printf("\nError semantico en la linea %d: se esperaba booleano en AND\n",linea);}
	 | expresion OPBINARIOS_AND expresion				{if($1.dato == 4 && $3.dato == 4)
										$$.dato=4;
									else
							printf("\nError semantico en la linea %d: se esperaba booleano en AND\n",linea);}
	 | nombre_var					{$$.dato = $1.dato;$$.atributo = $1.atributo;$$.Nombre = $1.Nombre;$$.contenido =$1.Nombre;}		
	 | constante					{$$.Nombre = ""; $$.dato = $1.dato;$$.atributo = $1.atributo;$$.contenido = $1.valor;}				
	 | funcion					{$$.dato = $1.dato;$$.atributo = $1.atributo;$$.Nombre = $1.Nombre;};			

funcion: IDENTIFICADOR {nombreFun=$1.Nombre;} PARENTESISABIERTO lista_exp PARENTESISCERRADO	{nombreFun=$1.Nombre; numPar=$4.atributo;if(compruebaVar($1.Nombre) == 0){ 
							printf("\nError semantico en la linea %d: la funcion %s no esta declarada\n",linea,$1.Nombre);
										nombreFun=NULL;
									}else{ aux=tipoDato(nombreFun);
										if(numPar != aux.numArgumentos)
										printf("\nError semantico en la linea %d: numero de argumentos incorrecto\n",linea);	
										else{
										
										$$.dato=aux.dato;
										$$.atributo=aux.parametros;
									}}
									};


%%

#include "lex.yy.c"

void comprobarVariables(char * Nomb,int numPar,char * dim1, char * dim2){
	if(compruebaMismoNombreDeclar(Nomb,numPar)){
		printf("\nError semantico en la linea %d: la variable %s ya esta declarada en este bloque\n",linea,Nomb);
	}else{ 
		aux.entrada=3;
		aux.Nombre=Nomb;
		aux.dato=6;
		aux.dim1 = atoi(dim1);
		aux.dim2 = atoi(dim2);
		aniadir(aux);
	}
}


void comprobarEsBueno(char * Nomb,int dat,int atrib) {
	if(compruebaVar(Nomb) == 0) 
		printf("\nError semantico en la linea %d: la variable %s no esta declarada\n",linea,Nomb);
	else {
		aux=tipoDato(Nomb);
		if(aux.dato != dat && aux.parametros != atrib) {			
			printf("\nError semantico en la linea %d: se intento asignar a la variable %s el tipo %s\n",linea,Nomb,cadenaTipo(dat,atrib));
		}
	}
}


void yyerror(char const * msg) {
	fprintf(stderr, "Error en la linea %d: %s\n",linea,msg);
}
