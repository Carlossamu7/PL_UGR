%{
	#include <stdlib.h>
	#include <stdio.h>
	#include <string.h>
	/** Aqui incluimos el fichero generado por el ’lex’
	 *	que implementa la funcion ’yylex’
	 **/
	int yydebug = 1;	

	int yylex();  // Para evitar warning al compilar
	void yyerror(const char * msg);

	unsigned int contBloques = 0;
	unsigned int numLinea = 1;
	//Una vez declarada numLinea, puedo incluir p4.h
	#include "p4.h"
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
																				$3.tipoInternoLista = $0.tipoInternoLista;
																				$3.entrada = variable;
																				if(!variableExisteBloque($3)) insertar($3);
																				else mensajeErrorDeclaradaBloque($3);	}
								| IDENTIFICADOR {	$1.tipoDato = $0.tipoDato;
													$1.tipoInternoLista = $0.tipoInternoLista;
													$1.entrada = variable;
													if(!variableExisteBloque($1)) insertar($1);
													else mensajeErrorDeclaradaBloque($1);} ;

cabecera_subprog				: tipo IDENTIFICADOR PARIZQ lista_parametros PARDER {	$2.tipoDato = $1.tipoDato; 
																						$2.tipoInternoLista = $1.tipoInternoLista;
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
								| sentencia_reset_cursor
								| funcion FINLINEA 
								| error ;

sentencia_asignacion			: IDENTIFICADOR ASIGNACION exp_cad FINLINEA {	if( variableExiste($1) ){
																					if( $1.entrada == funcion ) mensajeErrorNoVariable($1);
																					else if( $1.tipoDato != $3.tipoDato ) 																							mensajeErrorAsignacion($1, $3);
																				} else mensajeErrorNoDeclarada($1);	};

sentencia_if					: CONDICION PARIZQ expresion PARDER sentencia
									SUBCONDICION sentencia {	if( $3.tipoDato != booleano ) mensajeErrorTipo1($3, booleano);	}
								| CONDICION PARIZQ expresion PARDER sentencia {	if( $3.tipoDato != booleano ) mensajeErrorTipo1($3, 																					booleano);	};

sentencia_while					: CICLO PARIZQ expresion PARDER sentencia {	if( $3.tipoDato != booleano ) mensajeErrorTipo1($3, booleano);	};

sentencia_entrada				: ENTRADA lista_variables FINLINEA ;

sentencia_salida				: SALIDA lista_exp_cadena FINLINEA ;

sentencia_return				: RETURN expresion FINLINEA ;

sentencia_for					: BUCLE IDENTIFICADOR DOSPUNTOSIGUAL expresion HASTA expresion PASO expresion sentencia 
									{	
										if( !variableExiste($2) ) mensajeErrorNoDeclarada($2);
										else if( $2.tipoDato != entero ) mensajeErrorTipo1($2, entero);
										if( $4.tipoDato != entero ) mensajeErrorTipo1($4, entero);
										if( $6.tipoDato != entero ) mensajeErrorTipo1($6, entero);
										if( $8.tipoDato != entero ) mensajeErrorTipo1($8, entero);
									};

sentencia_iterar				: IDENTIFICADOR OPUNARIOPOST FINLINEA {	if( !variableExiste($1) ) mensajeErrorNoDeclarada($1);
																		else if( $1.tipoDato != lista ) mensajeErrorTipo1($1, lista);	};

sentencia_reset_cursor			: OPDOLAR IDENTIFICADOR FINLINEA {	if( !variableExiste($2) ) mensajeErrorNoDeclarada($2); 
																	else if( $2.tipoDato != lista ) mensajeErrorTipo1($1, lista);	};

lista_parametros				: lista_parametros COMA tipo IDENTIFICADOR {	$$.parametros++; 
																				$4.tipoDato = $3.tipoDato;
																				$4.tipoInternoLista = $3.tipoInternoLista;
																				$4.entrada = parametro_formal;
																				if( !parametroExiste($4) ) insertar($4);
																				else mensajeErrorParametro($4);			}
								| tipo IDENTIFICADOR {	$$.parametros = 1; 
														$2.tipoDato = $1.tipoDato; 
														$2.tipoInternoLista = $1.tipoInternoLista;
														$2.entrada = parametro_formal;
														if( !parametroExiste($2) ) insertar($2);
														else mensajeErrorParametro($2);			} ;

lista_exp_cadena				: lista_exp_cadena COMA exp_cad
								| exp_cad ;

exp_cad							: expresion	{	$$.tipoDato = $1.tipoDato;
												$$.tipoInternoLista = $1.tipoInternoLista; }
								| CADENA {	$$.tipoDato = caracter;	} ;

lista_variables					: lista_variables COMA IDENTIFICADOR  {	if ( !variableExiste($3) ) mensajeErrorNoDeclarada($3);	}
								| IDENTIFICADOR {	if ( !variableExiste($1) ) mensajeErrorNoDeclarada($1);	};

lista_expresiones				: lista_expresiones COMA expresion	{	$$.parametros++;	}
								| expresion {	$$.parametros = 1;	} ;

expresion						: PARIZQ expresion PARDER	{	$$.tipoDato = $2.tipoDato;
																$$.tipoInternoLista = $2.tipoInternoLista;
																concatenarStrings3($$.valor, $1.valor, $2.valor, $3.valor);	}
								| OPUNARIO expresion	{	if( $2.tipoDato != booleano ) mensajeErrorTipo1($2, booleano);
															$$.tipoDato = $2.tipoDato;
															$$.tipoInternoLista = $2.tipoInternoLista;
															concatenarStrings2($$.valor, $1.valor, $2.valor); }
								| OPUNARIOLISTAS expresion	{	if( $2.tipoDato != lista ) mensajeErrorTipo1($2, lista);
																$$.tipoDato = $2.tipoDato;
																$$.tipoInternoLista = $2.tipoInternoLista;
																concatenarStrings2($$.valor, $1.valor, $2.valor);	}
								| SIGNO expresion	{	if( $2.tipoDato != entero && $2.tipoDato != real && 
															$2.tipoInternoLista != entero && $2.tipoInternoLista != real )
																mensajeErrorTipo2($2, entero, real);
															$$.tipoDato = $2.tipoDato;
															$$.tipoInternoLista = $2.tipoInternoLista;
															concatenarStrings2($$.valor, $1.valor, $2.valor);	}
								| expresion SIGNO expresion	{	if( $1.tipoDato != entero && $1.tipoDato != real && 
																	$1.tipoInternoLista != entero && $1.tipoInternoLista != real )
																		mensajeErrorTipo2($1, entero, real);
																if( $3.tipoDato != entero && $3.tipoDato != real &&
																	$3.tipoInternoLista != entero && $3.tipoInternoLista != real )
																		mensajeErrorTipo2($3, entero, real);
																if( $1.tipoDato == lista && $3.tipoDato == lista)
																	mensajeErrorNoTipo($1);
																if( $1.tipoDato == lista || $3.tipoDato == lista )   $$.tipoDato = lista;
																else if( $1.tipoDato == real || $3.tipoDato == real ) $$.tipoDato = real;
																else $$.tipoDato = $1.tipoDato;
																if( $1.tipoInternoLista == real || $3.tipoInternoLista == real ) 
																	$$.tipoInternoLista = real;
																else $$.tipoInternoLista = $1.tipoInternoLista;
																concatenarStrings3($$.valor, $1.valor, $2.valor, $3.valor);	}
								| expresion OPORLOGICO expresion	{	if( $1.tipoDato != booleano ) mensajeErrorTipo1($1, booleano);
																		if( $3.tipoDato != booleano ) mensajeErrorTipo1($3, booleano);
																		$$.tipoDato = $1.tipoDato;
																		concatenarStrings3($$.valor, $1.valor, $2.valor, $3.valor);	}
								| expresion OPANDLOGICO expresion	{	if( $1.tipoDato != booleano ) mensajeErrorTipo1($1, booleano);
																		if( $3.tipoDato != booleano ) mensajeErrorTipo1($3, booleano);
																		$$.tipoDato = $1.tipoDato;
																		concatenarStrings3($$.valor, $1.valor, $2.valor, $3.valor);	}
								| expresion OPEXCLUSIVEOR expresion	{	if( $1.tipoDato != booleano ) mensajeErrorTipo1($1, booleano);
																		if( $3.tipoDato != booleano ) mensajeErrorTipo1($3, booleano);
																		$$.tipoDato = $1.tipoDato;
																		concatenarStrings3($$.valor, $1.valor, $2.valor, $3.valor);	}
								| expresion OPIGUALDAD expresion	{	if( $1.tipoDato == lista) mensajeErrorNoTipo($1);
																		if( $3.tipoDato == lista) mensajeErrorNoTipo($3);
																		if( $1.tipoDato != $3.tipoDato ) mensajeErrorComparacion($1, $3);
																		$$.tipoDato = booleano;
																		concatenarStrings3($$.valor, $1.valor, $2.valor, $3.valor);	}
								| expresion OPRELACION expresion	{	if( $1.tipoDato == lista) mensajeErrorNoTipo($1);
																		if( $3.tipoDato == lista) mensajeErrorNoTipo($3);
																		if( $1.tipoDato != $3.tipoDato ) mensajeErrorComparacion($1, $3);
																		$$.tipoDato = booleano;
																		concatenarStrings3($$.valor, $1.valor, $2.valor, $3.valor);	}
								| expresion OPMULTIPLICATIVOS expresion	{	if( $1.tipoDato != entero && $1.tipoDato != real && 
																				$1.tipoInternoLista != entero && $1.tipoInternoLista != real )
																				mensajeErrorTipo2($1, entero, real);
																			if( $3.tipoDato != entero && $3.tipoDato != real && 
																				$3.tipoInternoLista != entero && $3.tipoInternoLista != real )
																				mensajeErrorTipo2($3, entero, real);
																			if( $1.tipoDato == real || $3.tipoDato == real ) 
																				$$.tipoDato = real;
																			if( $1.tipoDato == lista && $3.tipoDato == lista)
																				mensajeErrorNoTipo($1);
																			concatenarStrings3($$.valor, $1.valor, $2.valor, $3.valor);	}
								| expresion OPDECREMENTO expresion	{	if( $1.tipoDato != lista ) mensajeErrorTipo1($1, lista);
																		if( $3.tipoDato != entero ) mensajeErrorTipo1($3, entero);
																		$$.tipoDato = lista;
																		$$.tipoInternoLista = $1.tipoInternoLista;
																		concatenarStrings3($$.valor, $1.valor, $2.valor, $3.valor);	}
								| expresion OPPORCENTAJE expresion	{	if( $1.tipoDato != lista ) mensajeErrorTipo1($1, lista);
																		if( $3.tipoDato != entero ) mensajeErrorTipo1($3, entero);
																		$$.tipoDato = lista;
																		$$.tipoInternoLista = $1.tipoInternoLista;
																		concatenarStrings3($$.valor, $1.valor, $2.valor, $3.valor);	}
								| expresion OPCONCATENAR expresion	{	if( $1.tipoDato != lista ) mensajeErrorTipo1($1, lista);
																		if( $3.tipoDato != lista ) mensajeErrorTipo1($3, lista);
																		if( $1.tipoInternoLista != $3.tipoInternoLista) 
																			mensajeErrorTiposInternosNoCoinciden($1, $3);
																		$$.tipoDato = lista;
																		$$.tipoInternoLista = $1.tipoInternoLista;
																		concatenarStrings3($$.valor, $1.valor, $2.valor, $3.valor);	}
								| expresion OPARROBA expresion	{	if( $1.tipoDato != lista ) mensajeErrorTipo1($1, lista);
																	if( $3.tipoDato != entero ) mensajeErrorTipo1($3, entero);
																	$$.tipoDato = $1.tipoInternoLista;
																	concatenarStrings3($$.valor, $1.valor, $2.valor, $3.valor);	}
								| expresion OPINCREMENTO expresion OPARROBA expresion	{	
												if( $1.tipoDato != lista ) mensajeErrorTipo1($1, lista);
												if( $3.tipoDato != $1.tipoInternoLista ) mensajeErrorTipo1($3, $1.tipoInternoLista);
												if( $5.tipoDato != entero ) mensajeErrorTipo1($3, entero);
												$$.tipoDato = lista;
												$$.tipoInternoLista = $1.tipoInternoLista;
												concatenarStrings5($$.valor, $1.valor, $2.valor, $3.valor, $4.valor, $5.valor);	}
								| IDENTIFICADOR	{	if( !variableExiste($1) ) mensajeErrorNoDeclarada($1);
													$$.entrada = variable;
													$$.tipoDato = $1.tipoDato;
													$$.tipoInternoLista = $1.tipoInternoLista;
													concatenarStrings1($$.valor, $1.nombre);	}
								| lista	{	$$.tipoDato = lista;
											$$.tipoInternoLista = $1.tipoInternoLista;
											concatenarStrings1($$.valor, $1.valor);	}
								| constante	{	$$.tipoDato = $1.tipoDato;
												concatenarStrings1($$.valor, $1.valor);	}
								| funcion	{	$$.tipoDato = $1.tipoDato;
												concatenarStrings1($$.valor, $1.valor);	}
								| error ;

funcion							: IDENTIFICADOR PARIZQ lista_expresiones PARDER	
									{	if( !variableExiste($1) ) mensajeErrorNoDeclarada($1);
										else if( getSimboloIdentificador($1.nombre).entrada != funcion ) mensajeErrorSeEsperabaFuncion($1);
										else if( $3.parametros != getSimboloIdentificador($1.nombre).parametros )	
												mensajeErrorNumParametros($1,$3);
										concatenarStrings4($$.valor, $1.valor, $2.valor, $3.valor, $4.valor);	};
									/*TODO: Como comprobamos que cada parametro es del tipo esperado?*/

constante						: ENTERO	{	$$.tipoDato = entero;
												concatenarStrings1($$.valor, $1.valor);	}
								| REAL	{	$$.tipoDato = real;
											concatenarStrings1($$.valor, $1.valor);	}
								| CONSTANTE_CARACTER	{	$$.tipoDato = caracter;
															concatenarStrings1($$.valor, $1.valor);	}
								| CONSTANTE_BOOLEANA 	{	$$.tipoDato = booleano;
															concatenarStrings1($$.valor, $1.valor);	} ;

lista							: ABRIRCORCHETE lista2 {	$$.tipoInternoLista = $1.tipoDato;
															$$.tipoDato = lista;
															concatenarStrings2($$.valor, $1.valor, $2.valor);	};

lista2							: lista2 COMA exp_cad 	{	if( $1.tipoInternoLista != $3.tipoDato ) 
																mensajeErrorTipo1($3, $1.tipoInternoLista); 
															$$.tipoInternoLista = $1.tipoInternoLista;
															$$.tipoDato = lista;
															concatenarStrings2($$.valor, $2.valor, $3.valor);	}
								| exp_cad CERRARCORCHETE {	$$.tipoInternoLista = $1.tipoDato;
															$$.tipoDato = lista;
															concatenarStrings2($$.valor, $1.valor, $2.valor);	};

tipo							: TIPO	{	$$.tipoDato = $1.tipoDato;	}
								| LISTA_DE TIPO	{	$$.tipoDato = $1.tipoDato;	
													$$.tipoInternoLista = $2.tipoDato;	};

%%

/* Lo que teniamos antes
#include "lex.yy.c"
*/

#ifdef DOSWINDOWS /* Variable de entorno que indica la plataforma */
#include "lexyy.c"
#else
#include "lex.yy.c"
#endif


void yyerror(const char * msg) {
  printf("[Línea %d]: %s\n", numLinea, msg);
}
