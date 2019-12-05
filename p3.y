%{
	#include <stdlib.h>
	#include <stdio.h>
	#include <string.h>
	/** Aqui incluimos el fichero generado por el ’lex’
	 *	que implementa la funcion ’yylex’
	 **/

	#ifdef DOSWINDOWS /* Variable de entorno que indica la plataforma */
	#include "lexyy.c"
	#else
	#include "lex.yy.c"
	#endif
	#include "p4.h"

	int yydebug = 1;	

	int yylex();  // Para evitar warning al compilar
	void yyerror(const char * msg);

	unsigned int contBloques = 0;
	// unsigned int numPar = 0;
	//char* nombreFun;
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
%token OPUNARIOLISTAS
%token OPDECREMENTO
%token OPINCREMENTO
%token OPDOLAR
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
%right OPUNARIOLISTAS
%left OPDECREMENTO
%left ABRIRCORCHETE
%left CERRARCORCHETE


//%right PARDER 
//%right SUBCONDICION


%start programa

%%

programa						: CABECERA bloque ;

bloque							: INIBLOQUE {	insertarMarca();
												if($0.parametros > 0) insertarArgumentos($0.nombre, $0.parametros); 
												contBloques++; }
					 			  declar_variables_locales
					 			  declar_subprogs
							 	  sentencias
							 	  FINBLOQUE {	contBloques--; 
												imprimirTS(); 
												eliminarBloque(); };

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
								| error ; 
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

lista_identificadores			: lista_identificadores COMA IDENTIFICADOR {	$3.tipoDato = $0.tipoDato;
																				$3.entrada = variable;
																				if(!variableExisteBloque($3)) insertar($3);
																				else mensajeErrorDeclaradaBloque($3);	}
								| IDENTIFICADOR {	$1.tipoDato = $0.tipoDato;
													$1.entrada = variable;
													if(!variableExisteBloque($1)) insertar($1);
													else mensajeErrorDeclaradaBloque($1);} ;

cabecera_subprog				: tipo IDENTIFICADOR PARIZQ lista_parametros PARDER {	$2.tipoDato = $1.tipoDato; 
																						$$.nombre = $2.nombre; 
																						$$.parametros = $4.parametros;	
																						$2.parametros = $4.parametros;
																						$2.entrada = funcion;
																						if(!variableExisteBloque($2)) insertar($2);
																						else mensajeErrorDeclaradaBloque($2);} ;

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
								| setencia_reset_cursor
								| funcion FINLINEA 
								| error ;

sentencia_asignacion			: IDENTIFICADOR ASIGNACION exp_cad FINLINEA {	if( $1.entrada =! funcion ) mensajeErrorNoVariable($1);
																				else if( $1.tipoDato != $3.tipoDato ) mensajeErrorAsignacion($1,$3);	};

sentencia_if					: CONDICION PARIZQ expresion PARDER sentencia
									SUBCONDICION sentencia {	if( $3.tipoDato != booleano ) mensajeErrorTipo($3, booleano);	}
								| CONDICION PARIZQ expresion PARDER sentencia {	if( $3.tipoDato != booleano ) mensajeErrorTipo($3, booleano);	};

sentencia_while					: CICLO PARIZQ expresion PARDER sentencia {	if( $3.tipoDato != booleano ) mensajeErrorTipo($3, booleano);	};

sentencia_entrada				: ENTRADA lista_variables FINLINEA {	if ( !variableExiste(/* TODO: Rip */) );	};

sentencia_salida				: SALIDA lista_exp_cadena FINLINEA {	if ( !variableExiste(/* TODO: Rip */) );	};

sentencia_return				: RETURN expresion FINLINEA {	
																if( $2.entrada == variable || $2.entrada == funcion )
																	if( !variableExiste($2) ) 
																		mensajeErrorNoDeclarada();	
															};

sentencia_for					: BUCLE IDENTIFICADOR DOSPUNTOSIGUAL expresion HASTA expresion PASO expresion sentencia 
									{	
										if( !variableExiste($2) ) mensajeErrorNoDeclarada($2);
										else if( $2.tipoDato != entero ) mensajeErrorTipo($2, entero);
										if( $4.tipoDato != entero ) mensajeErrorTipo($4, entero);
										if( $6.tipoDato != entero ) mensajeErrorTipo($6, entero);
										if( $8.tipoDato != entero ) mensajeErrorTipo($8, entero);
									};

sentencia_iterar				: IDENTIFICADOR OPUNARIOPOST FINLINEA {	if( $1.tipoDato != lista ) mensajeErrorTipo($1, lista);	};

setencia_reset_cursor			: OPDOLAR IDENTIFICADOR FINLINEA {	if( $2.tipoDato != lista ) mensajeErrorTipo($1, lista);	};

lista_parametros				: lista_parametros COMA tipo IDENTIFICADOR {	$$.parametros++; 
																				$4.tipoDato = $3.tipoDato;
																				$4.entrada = parametro_formal;
																				if( !parametroExiste($4) ) insertar($4);
																				else mensajeErrorParametro($4);			}
								| tipo IDENTIFICADOR {	$$.parametros++; 
														$2.tipoDato = $1.tipoDato; 
														$2.entrada = parametro_formal;
														if( !parametroExiste($4) ) insertar($2);
														else mensajeErrorParametro($2);			} ;

lista_exp_cadena				: lista_exp_cadena COMA exp_cad
								| exp_cad ;

exp_cad							: expresion	{	$$.tipoDato = $1.tipoDato;	}
								| CADENA {	$$.tipoDato = caracter;	} ;	/*TODO: Cadena es tipo caracter? */

lista_variables					: lista_variables COMA IDENTIFICADOR
								| IDENTIFICADOR ;

lista_expresiones				: lista_expresiones COMA expresion	{	$$.parametros++;	}
								| expresion {	$$.parametros++;	} ;

expresion						: PARIZQ expresion PARDER	{	$$ = $2;	} /*TODO: Se pueden igualar structs a pelo?*/
								| OPUNARIO expresion	{	if( $2.tipoDato != booleano ) mensajeErrorTipo($2, booleano);
															$$.tipoDato = $2.tipoDato;
															concatenarStrings($$.valor, $1.valor, $2.valor); }
								| OPUNARIOLISTAS expresion	{	if( $2.tipoDato != lista ) mensajeErrorTipo($2, lista);
																$$.tipoDato = $2.tipoDato;
																concatenarStrings($$.valor, $1.valor, $2.valor);	}
								| SIGNO expresion	{	if( $2.tipoDato != entero && $2.tipoDato != real ) mensajeErrorTipo($2, entero, real);
														$$.tipoDato = $2.tipoDato;
														concatenarStrings($$.valor, $1.valor, $2.valor);	}
								| expresion SIGNO expresion	{	if( $1.tipoDato != entero && $1.tipoDato != real ) mensajeErrorTipo($1, entero, real);
																if( $3.tipoDato != entero && $3.tipoDato != real ) mensajeErrorTipo($3, entero, real);
																if( $1.tipoDato == real || $2.tipoDato == real ) $$.tipoDato = real;
																concatenarStrings($$.valor, $1.valor, $2.valor. $3.valor);
																/*TODO: Y si es una lista? A parte, no sabemos el tipo de dato de los elementos
																 * 	dentro de la lista, deberiamos crear otra variable en el struct entradaTS? */		
															}
								| expresion OPORLOGICO expresion	{	if( $1.tipoDato != booleano ) mensajeErrorTipo($1, booleano);
																		if( $3.tipoDato != booleano ) mensajeErrorTipo($3, booleano);
																		$$.tipoDato = $1.tipoDato;
																		concatenarStrings($$.valor, $1.valor, $2.valor, $3.valor);	}
								| expresion OPANDLOGICO expresion	{	if( $1.tipoDato != booleano ) mensajeErrorTipo($1, booleano);
																		if( $3.tipoDato != booleano ) mensajeErrorTipo($3, booleano);
																		$$.tipoDato = $1.tipoDato;
																		concatenarStrings($$.valor, $1.valor, $2.valor, $3.valor);	}
								| expresion OPEXCLUSIVEOR expresion	{	if( $1.tipoDato != booleano ) mensajeErrorTipo($1, booleano);
																		if( $3.tipoDato != booleano ) mensajeErrorTipo($3, booleano);
																		$$.tipoDato = $1.tipoDato;
																		concatenarStrings($$.valor, $1.valor, $2.valor, $3.valor);	}
								| expresion OPIGUALDAD expresion	{	if( $1.tipoDato != $3.tipoDato ) mensajeErrorComparacion($1, $3);
																		$$.tipoDato = booleano;
																		concatenarStrings($$.valor, $1.valor, $2.valor, $3.valor);	}
								| expresion OPRELACION expresion	{	if( $1.tipoDato != $3.tipoDato ) mensajeErrorComparacion($1, $3);
																		$$.tipoDato = booleano;
																		concatenarStrings($$.valor, $1.valor, $2.valor, $3.valor);	}
								| expresion OPMULTIPLICATIVOS expresion	{	if( $1.tipoDato != entero && $1.tipoDato != real ) mensajeErrorTipo($1, entero, real);
																			if( $3.tipoDato != entero && $3.tipoDato != real ) mensajeErrorTipo($3, entero, real);
																			if( $1.tipoDato == real || $2.tipoDato == real ) $$.tipoDato = real;
																			concatenarStrings($$.valor, $1.valor, $2.valor, $3.valor);	}
								| expresion OPDECREMENTO expresion	{	if( $1.tipoDato != lista ) mensajeErrorTipo($1, lista);
																		if( $3.tipoDato != entero ) mensajeErrorTipo($3, entero);
																		$$.tipoDato = lista;
																		concatenarStrings($$.valor, $1.valor, $2.valor, $3.valor);	}
								| expresion OPPORCENTAJE expresion	{	if( $1.tipoDato != lista ) mensajeErrorTipo($1, lista);
																		if( $3.tipoDato != entero ) mensajeErrorTipo($3, entero);
																		$$.tipoDato = lista;
																		concatenarStrings($$.valor, $1.valor, $2.valor, $3.valor);	}
								| expresion OPCONCATENAR expresion	{	if( $1.tipoDato != lista ) mensajeErrorTipo($1, lista);
																		if( $3.tipoDato != lista ) mensajeErrorTipo($3, lista);
																		$$.tipoDato = lista;
																		concatenarStrings($$.valor, $1.valor, $2.valor, $3.valor);	}
								| expresion OPARROBA expresion	{	if( $1.tipoDato != lista ) mensajeErrorTipo($1, lista);
																	if( $3.tipoDato != entero ) mensajeErrorTipo($3, entero);
																	$$.tipoDato = /*TODO: Devolver tipo dato de dentro de la lista*/;
																	concatenarStrings($$.valor, $1.valor, $2.valor, $3.valor);	}
								| expresion OPINCREMENTO expresion OPARROBA expresion	{	if( $1.tipoDato != lista ) mensajeErrorTipo($1, lista);
																							if( $3.tipoDato != /*TODO:TipoDatoDentroLista*/ ) mensajeErrorTipo($3, /*TODO*/);
																							if( $5.tipoDato != entero ) mensajeErrorTipo($3, entero);
																							$$.tipoDato = lista;
																							concatenarStrings($$.valor, $1.valor, $2.valor, $3.valor, $4.valor, $5.valor);	}
								| IDENTIFICADOR	{	if( !variableExiste($1) ) mensajeErrorNoDeclarada($1);
													$$.entrada = variable;
													$$.tipoDato = $1.tipoDato	}
								| lista	{	$$.tipoDato = lista;	}
								| constante	{	$$.tipoDato = $1.tipoDato;	}
								| funcion	{	$$.tipoDato = $1.tipoDato;	}
								| error ;

funcion							: IDENTIFICADOR PARIZQ lista_expresiones PARDER	
									{	if( !variableExiste($1) ) mensajeErrorNoDeclarada($1);
										else if( getSimboloIdentificador($1).entrada != funcion ) mensajeErrorSeEsperabaFuncion($1);
										else if( $3.parametros != getSimboloIdentificador($1).parametros ) mensajeErrorNumParametros($1,$3)	};
									/*TODO: Como comprobamos que cada parametro es del tipo esperado?*/

constante						: ENTERO	{	$$.tipoDato = entero;	}
								| REAL	{	$$.tipoDato = real;	}
								| CONSTANTE_CARACTER	{	$$.tipoDato = caracter;	}
								| CONSTANTE_BOOLEANA 	{	$$.tipoDato = booleano;	} ;

lista							: ABRIRCORCHETE lista2 ;

lista2							: exp_cad COMA lista2
								| exp_cad CERRARCORCHETE ;

tipo							: TIPO	{	$$.tipoDato = $1.tipoDato;	}
								| LISTA_DE TIPO	{	$$.tipoDato = $1.tipoDato;	
													/*TODO:TipoDatoDentroLista*/};

%%

/* Lo que teniamos antes
#include "lex.yy.c"
*/

void yyerror(const char * msg) {
  printf("[Línea %d]: %s\n", yylineno, msg);
}
