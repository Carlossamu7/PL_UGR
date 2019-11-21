%{
	#include <stdlib.h>
	#include <stdio.h>
	#include <string.h>

	#define YYDEBUG 0		

	int yylex();  // Para evitar warning al compilar
	void yyerror(const char * msg);

	//unsigned int linea_actual = 1; // La otra opción es usar 'yyleno' e invocar a flex con la opcion -l
%}

/*	COIN
%define parse.error verbose 
*/

%error-verbose	/* Hace que bison (yacc) te de detalles sobre los errores */

%token CABECERA
%token IDENTIFICADOR
%token TIPO
%token ENTERO REAL CONSTANTE_BOOLEANA CONSTANTE_CARACTER CADENA LISTA_DE
%token BUCLE DESDE HASTA PASO
%token CONDICION SUBCONDICION CICLO
%token ASIGNACION
%token ENTRADA SALIDA
%token RETURN
%token INIVARIABLES FINVARIABLES
%token INIBLOQUE FINBLOQUE
%token PARIZQ PARDER
%token ABRIRCORCHETE CERRARCORCHETE
%token FINLINEA COMA DOSPUNTOSIGUAL

/* En el guión de prácticas pone que todos son left menos los unarios, ++ y -- */
%left OPBINARIO
%left OPTERNARIO_1
%left OPTERNARIO_2
%left SIGNO
%left OPUNARIO

/*  COIN
%left OR
%left AND
%left XOR
%left OPIG
%left OPREL
%left MASMENOS
%left OPMUL
%right NOT
*/

%start Programa

%%

Programa						: Cabecera_programa bloque ;

Bloque							: Inicio_de_bloque
					 			  Declar_de_variables_locales
					 			  Declar_de_subprogs
							 	  Sentencias
							 	  Fin_de_bloque ;

Declar_de_subprogs				: /* vacío */
								| Declar_de_subprogs Declar_subprog ;

Declar_subprog					: Cabecera_subprograma bloque ;

Declar_de_variables_locales		: /* vacío */
								| Marca_ini_declar_variables
						 	 		Variables_locales
				 				  Marca_fin_declar_variables ;

Marca_ini_declar_variables		: INIVARIABLES ;

Marca_fin_declar_variables		: FINVARIABLES ;

Cabecera_programa				: CABECERA ;

Inicio_de_bloque				: INIBLOQUE ;

Fin_de_bloque					: FINBLOQUE ;

Variables_locales				: Variables_locales Cuerpo_declar_variables
								| Cuerpo_declar_variables ;

Cuerpo_declar_variables			: TIPO Lista_de_identificadores FINLINEA ;
								| error; 
								/**
								 * 	error es una palabra reservada de yacc 
								 * 	y hace que si se llega a ella, se llama
								 * 	a la funcion yyerror y a través de ella
								 * 	controlamos los errores 
								*/

Lista_de_identificadores		: Lista_de_identificadores COMA Identificador
								| Identificador ;

/* FALTAN AQUI */




lista_parametros				: lista_parametros COMA TIPO IDENTIFICADOR ;

lista_exp_cad					: lista_exp_cad COMA exp_cad
								| exp_cad ;

exp_cad							: expresion
								| CADENA ;

lista_variables					: lista_variables COMA IDENTIFICADOR
								| IDENTIFICADOR ;

lista_expresiones				: lista_expresiones COMA expresion
								| expresion ;

expresion						: PARIZQ expresion PARDER
								| OPUNARIO expresion
								| SIGNO expresion %prec SIGNO /* Le damos mayor precedencia al +/- unario */
								| expresion SIGNO expresion
								| expresion OPBINARIO expresion
								| IDENTIFICADOR
								| constante
								| funcion
								| expresion OPTERNARIO_1 expresion OPTERNARIO_2 expresion ;

funcion							: IDENTIFICADOR PARIZQ lista_expresiones PARDER ;

constante						: ENTERO
								| REAL
								| CONSTANTE_CARACTER
								| CONSTANTE_BOOLEANA ;

lista							: lista_entero
								| lista_real
								| lista_caracter
								| lista_booleana ;

lista_entero					: ABRIRCORCHETE lista_entero CERRARCORCHETE
								| lista_entero COMA signo ENTERO
								| signo ENTERO ;

lista_real						: ABRIRCORCHETE lista_real CERRARCORCHETE
								| lista_real COMA signo REAL
								| signo REAL ;

lista_caracter					: ABRIRCORCHETE lista_caracter CERRARCORCHETE
								| lista_caracter COMA CONSTANTE_CARACTER
								| CONSTANTE_CARACTER ;

lista_booleana					: ABRIRCORCHETE lista_booleana CERRARCORCHETE
								| lista_booleana COMA CONSTANTE_BOOLEANA
								| CONSTANTE_BOOLEANA ;

tipo							: TIPO
								| LISTA_DE TIPO ;

signo							: SIGNO
								| /* vacío */ ;


%%

/** Aqui incluimos el fichero generado por el ’lex’
 *	que implementa la funcion ’yylex’
 **/
#ifdef DOSWINDOWS /* Variable de entorno que indica la plataforma */
#include "lexyy.c"
#else
#include "lex.yy.c"
#endif

/* Lo que teniamos antes
#include "lex.yy.c"
*/

void yyerror(const char * msg) {
  printf("[Línea %d]: %s\n", yylineno, msg);
}
