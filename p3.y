%{
	#include <stdlib.h>
	#include <stdio.h>
	#include <string.h>

	int yydebug = 1;	

	int yylex();  // Para evitar warning al compilar
	void yyerror(const char * msg);

	//unsigned int linea_actual = 1; // La otra opción es usar 'yyleno' e invocar a flex con la opcion -l
%}

%error-verbose	/* Hace que bison (yacc) te de detalles sobre los errores */

%token CABECERA
%token IDENTIFICADOR
%token OPCONCATENAR
%token OPPORCENTAJE
%token OPORLOGICO
%token OPANDLOGICO
%token OPEXCLUSIVEOR
%token OPIGUALDAD
%token OPRELACION
%token SIGNO
%token OPMULTIPLICATIVOS
%token OPUNARIO
%token OPDECREMENTO
%token OPINCREMENTO
%token ABRIRCORCHETE
%token CERRARCORCHETE
%token OPARROBA
%token ENTERO
%token REAL
%token TIPO
%token BUCLE
%token HASTA
%token PASO
%token CONDICION
%token SUBCONDICION
%token CICLO
%token ASIGNACION
%token ENTRADA
%token SALIDA
%token RETURN
%token INIBLOQUE
%token FINBLOQUE
%token INIVARIABLES
%token FINVARIABLES
%token CONSTANTE_BOOLEANA
%token CADENA
%token CONSTANTE_CARACTER
%token PARIZQ
%token PARDER
%token COMA
%token FINLINEA
%token DOSPUNTOSIGUAL
%token LISTA_DE
%token OPUNARIOPOST

%nonassoc OPARROBA
%nonassoc OPINCREMENTO

%left OPCONCATENAR
%left OPPORCENTAJE
%left OPORLOGICO
%left OPANDLOGICO
%left OPEXCLUSIVEOR
%left OPIGUALDAD
%left OPRELACION
%left SIGNO
%left OPMULTIPLICATIVOS
%right OPUNARIO
%left OPDECREMENTO
%left ABRIRCORCHETE
%left CERRARCORCHETE

//%right PARDER 
//%right SUBCONDICION


%start programa

%%

programa						: CABECERA bloque ;

bloque							: INIBLOQUE
					 			  declar_variables_locales
					 			  declar_subprogs
							 	  sentencias
							 	  FINBLOQUE ;

declar_subprogs					: declar_subprogs declar_subprog
								| /* vacío */ ;

declar_subprog					: cabecera_subprog bloque ;

declar_variables_locales		: INIVARIABLES
						 	 		variables_locales
				 				  FINVARIABLES
								| /* vacío */ ;

variables_locales				: variables_locales cuerpo_declar_variables
								| cuerpo_declar_variables ;

cuerpo_declar_variables			: tipo lista_identificadores FINLINEA 
								| tipo sentencia_asignacion 
								| error; 
								/**
								 * 	error es una palabra reservada de yacc 
								 * 	y hace que si se llega a ella, se llama
								 * 	a la funcion yyerror y a través de ella
								 * 	controlamos los errores. Es recomendable
								 *  ponerla es las reglas más simples, no en 
								 *  las compuestas pq por ejemplo si la pones 
								 *	en bloque y falla el analizador en la
								 *	declaración de variables, ignora el bloque
								 *	completo y perdemos esa información
								*/

lista_identificadores			: lista_identificadores COMA IDENTIFICADOR
								| IDENTIFICADOR ;

cabecera_subprog				: tipo IDENTIFICADOR PARIZQ lista_parametros PARDER ;

sentencias						: sentencias sentencia
								| sentencia ;

sentencia						: bloque
								| sentencia_asignacion
								| sentencia_if
								| sentencia_while
								| sentencia_entrada
								| sentencia_salida
								| sentencia_return
								| sentencia_for
								| sentencia_iterar 
								| funcion FINLINEA 
								| error ;

sentencia_asignacion			: IDENTIFICADOR ASIGNACION exp_cad FINLINEA ;

sentencia_if					: CONDICION PARIZQ expresion PARDER sentencia
									SUBCONDICION sentencia
								| CONDICION PARIZQ expresion PARDER sentencia ;

sentencia_while					: CICLO PARIZQ expresion PARDER sentencia ;

sentencia_entrada				: ENTRADA lista_variables FINLINEA ;

sentencia_salida				: SALIDA lista_exp_cadena FINLINEA ;

sentencia_return				: RETURN expresion FINLINEA ;

sentencia_for					: BUCLE IDENTIFICADOR DOSPUNTOSIGUAL expresion HASTA expresion PASO expresion sentencia ;

sentencia_iterar				: IDENTIFICADOR OPUNARIOPOST FINLINEA ;

lista_parametros				: lista_parametros COMA tipo IDENTIFICADOR 
								| tipo IDENTIFICADOR ;

lista_exp_cadena				: lista_exp_cadena COMA exp_cad
								| exp_cad ;

exp_cad							: expresion
								| CADENA ;

lista_variables					: lista_variables COMA IDENTIFICADOR
								| IDENTIFICADOR ;

lista_expresiones				: lista_expresiones COMA expresion
								| expresion ;

expresion						: PARIZQ expresion PARDER
								| OPUNARIO expresion
								| SIGNO expresion
								| expresion SIGNO expresion
								| expresion OPORLOGICO expresion
								| expresion OPANDLOGICO expresion
								| expresion OPEXCLUSIVEOR expresion
								| expresion OPIGUALDAD expresion
								| expresion OPRELACION expresion
								| expresion OPMULTIPLICATIVOS expresion
								| expresion OPDECREMENTO expresion
								| expresion OPPORCENTAJE expresion
								| expresion OPCONCATENAR expresion
								| IDENTIFICADOR
								| lista
								| constante
								| funcion
								| expresion OPARROBA expresion
								| expresion OPINCREMENTO expresion OPARROBA expresion 
								| error ;

funcion							: IDENTIFICADOR PARIZQ lista_expresiones PARDER ;

constante						: ENTERO
								| REAL
								| CONSTANTE_CARACTER
								| CONSTANTE_BOOLEANA ;

lista							: ABRIRCORCHETE lista2 ;

lista2							: exp_cad COMA lista2
								| exp_cad CERRARCORCHETE ;

tipo							: TIPO
								| LISTA_DE TIPO ;

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
