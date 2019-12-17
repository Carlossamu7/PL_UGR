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
	unsigned int contBloquesPrimeraFun = 0;
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

programa						: {generarFichero();} CABECERA {fputs("int main()", file);} bloque {cerrarFichero();} ;

bloque							: INIBLOQUE {	insertarMarca();
												if($0.parametros > 0){
													insertarArgumentos($0.nombre, $0.parametros);
												}
												contBloques++; 
												//printf("INICIO BLOQUE\n");	
												fputs("{\n", file);
											}
					 			  declar_variables_locales
					 			  declar_subprogs
							 	  sentencias
							 	  FINBLOQUE {	//printf("FIN BLOQUE\n");
									   			contBloques--; 
												//imprimirTS(); 
												eliminarBloque();
												char* sent = (char*) malloc(200);
												sprintf(sent, "%s}\n", numTabs());
												fputs(sent, file);
												if (contBloquesPrimeraFun == contBloques){
													file = file_std;
													contBloquesPrimeraFun = 0;
												}
											};

declar_subprogs					: declar_subprogs declar_subprog
								| /* vacío */ ;

declar_subprog					: cabecera_subprog bloque ;

declar_variables_locales		: INIVARIABLES
						 	 		variables_locales
				 				  FINVARIABLES
								| /* vacío */ ;

variables_locales				: variables_locales cuerpo_declar_variables
								| cuerpo_declar_variables ;

cuerpo_declar_variables			: tipo lista_identificadores FINLINEA 	{	char* sent = (char*) malloc(200);
																			sprintf(sent, "%s%s %s;\n", numTabs(), tipoDeDato($1.tipoDato), $2.valor);
																			fputs(sent, file);
																		}
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

lista_identificadores			: lista_identificadores COMA IDENTIFICADOR {	
													$3.tipoDato = $0.tipoDato;
													$3.tipoInternoLista = $0.tipoInternoLista;
													$3.entrada = variable;
													if(!variableExisteBloque($3)) insertar($3);
													else mensajeErrorDeclaradaBloque($3);
													concatenarStrings3($$.valor, $1.valor, $2.valor, $3.valor);
												}
								| IDENTIFICADOR {	$1.tipoDato = $0.tipoDato;
													$1.tipoInternoLista = $0.tipoInternoLista;
													$1.entrada = variable;
													if(!variableExisteBloque($1)) insertar($1);
													else mensajeErrorDeclaradaBloque($1); 
													concatenarStrings1($$.valor, $1.valor);
												} ;

cabecera_subprog				: tipo IDENTIFICADOR PARIZQ lista_parametros PARDER {	
											$2.tipoDato = $1.tipoDato; 
											$2.tipoInternoLista = $1.tipoInternoLista;
											$$.nombre = $2.nombre; 
											$$.parametros = $4.parametros;	
											$2.parametros = $4.parametros;
											$2.entrada = funcion;
											if(!variableExisteBloque($2)) insertar($2);
											else mensajeErrorDeclaradaBloque($2);
											//insertarSubprog($2.nombre, $1.tipoDato, $2.parametros);ç
											if(contBloquesPrimeraFun == 0)
												contBloquesPrimeraFun = contBloques;
											char* sent = (char*) malloc(200);
											sprintf(sent, "%s%s %s(%s)", numTabs(), tipoDeDato($1.tipoDato), $2.nombre, $4.valor);
											fputs(sent, file_fun);
											file = file_fun;
										} ;

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

sentencia_asignacion			: IDENTIFICADOR ASIGNACION exp_cad FINLINEA {	bool error = false;
																				if( variableExiste($1) ){
																					if( $1.entrada == funcion ){
																						mensajeErrorNoVariable($1);
																						error=true;
																					}
																					else {
																						entradaTS aux = getSimboloIdentificador($1.nombre);
																						if( aux.tipoDato != $3.tipoDato ){
																							mensajeErrorAsignacion(aux, $3);
																							error=true;
																						}
																					}
																				} else {
																					mensajeErrorNoDeclarada($1);
																					error=true;
																				}
																				if(error) $$.tipoDato = desconocido;
																				insertarAsignacion($1.nombre, $3.valor);
																			} ;

aux		: {	etiquetaFlujo *aux = malloc(sizeof(etiquetaFlujo));
			aux->EtiquetaElse = generarEtiqueta();
			aux->EtiquetaSalida = generarEtiqueta();
			insertarFlujo(*aux);
			copiarEF(&($$.ef), aux);
			char* sent = (char*) malloc(200);
			sprintf(sent, "%sif(!%s) goto %s;\n", numTabs(), $-1.valor, aux->EtiquetaElse);
			fputs(sent, file);
		} ;

sentencia_if					: CONDICION PARIZQ expresion PARDER aux sentencia 	{	
																		char* sent = (char*) malloc(200);
																		sprintf(sent, "%sgoto %s;\n", numTabs(), TF[TOPEFLUJO-1].EtiquetaSalida);
																		fputs(sent, file);
																	}
									SUBCONDICION 	{	char* sent = (char*) malloc(200);
														sprintf(sent, "%s%s:\n;\n", numTabs(), TF[TOPEFLUJO-1].EtiquetaElse);
														fputs(sent, file);
													}
									sentencia 	{	if( $3.tipoDato != booleano ) mensajeErrorTipo1($3, booleano); 
													char* sent = (char*) malloc(200);
													sprintf(sent, "%s%s:\n;\n", numTabs(), TF[TOPEFLUJO-1].EtiquetaSalida);
													fputs(sent, file);
													sacarTF();
												}
								| CONDICION PARIZQ expresion PARDER aux sentencia 	{	
													if( $3.tipoDato != booleano ) mensajeErrorTipo1($3, booleano);	
													char* sent = (char*) malloc(200);
													sprintf(sent, "%sgoto %s;\n", numTabs(), TF[TOPEFLUJO-1].EtiquetaSalida);
													fputs(sent, file);
													sprintf(sent, "%s%s:\n", numTabs(), TF[TOPEFLUJO-1].EtiquetaElse);
													fputs(sent, file);
													sprintf(sent, "%s%s:\n;\n", numTabs(), TF[TOPEFLUJO-1].EtiquetaSalida);
													fputs(sent, file);
													sacarTF();
												} ;

sentencia_while					: CICLO PARIZQ {	etiquetaFlujo *aux = malloc(sizeof(etiquetaFlujo));
													aux->EtiquetaEntrada = generarEtiqueta();
													aux->EtiquetaSalida = generarEtiqueta();
													insertarFlujo(*aux);
													char* sent = (char*) malloc(200);
													sprintf(sent, "%s%s:\n;\n", numTabs(), aux->EtiquetaEntrada);
													fputs(sent, file);
												}
									expresion	{	char* sent = (char*) malloc(200);
													sprintf(sent, "%sif (!%s) goto %s;\n", numTabs(), $4.valor ,TF[TOPEFLUJO-1].EtiquetaSalida);
													fputs(sent, file);
												} 
									PARDER sentencia {	if( $4.tipoDato != booleano ) mensajeErrorTipo1($4, booleano);	
														char* sent = (char*) malloc(200);
														sprintf(sent, "%sgoto %s;\n", numTabs(), TF[TOPEFLUJO-1].EtiquetaEntrada);
														fputs(sent, file);
														sprintf(sent, "%s%s:\n;\n", numTabs(), TF[TOPEFLUJO-1].EtiquetaSalida);
														fputs(sent, file);
														sacarTF();
													} ;

sentencia_entrada				: ENTRADA lista_variables FINLINEA 	{	char* sent = (char*) malloc(200);
																		sprintf(sent, "\", %s);\n", $2.valor);
																		fputs(sent, file);
																	} ;

sentencia_salida				: SALIDA lista_exp_cadena FINLINEA 	{	char* sent = (char*) malloc(200);
																		sprintf(sent, "\", %s);\n", $2.valor);
																		fputs(sent, file);
																	} ;

sentencia_return				: RETURN expresion FINLINEA {	char* sent = (char*) malloc(200);
																sprintf(sent, "%sreturn %s;\n", numTabs(), $2.valor);
																fputs(sent, file);
															} ;

sentencia_for					: BUCLE IDENTIFICADOR DOSPUNTOSIGUAL expresion {	
													etiquetaFlujo *aux = malloc(sizeof(etiquetaFlujo));
													aux->EtiquetaEntrada = generarEtiqueta();
													aux->EtiquetaSalida = generarEtiqueta();
													insertarFlujo(*aux);
													char* sent = (char*) malloc(200);
													/*sprintf(sent, "%sint %s;\n", numTabs(), $2.nombre);
													fputs(sent, file);*/
													sprintf(sent, "%s%s = %s;\n", numTabs(), $2.nombre, $4.valor);
													fputs(sent, file);
													sprintf(sent, "%s%s:\n;\n", numTabs(), aux->EtiquetaEntrada);
													fputs(sent, file);
												} HASTA expresion {
													char* sent = (char*) malloc(200);
													sprintf(sent, "%s%s = %s<%s;\n", numTabs(), generarTemp(booleano), $2.nombre, $7.valor);
													fputs(sent, file);
													sprintf(sent, "%sif (!temp%d) goto %s;\n", numTabs(), temp ,TF[TOPEFLUJO-1].EtiquetaSalida);
													fputs(sent, file);
												} PASO expresion sentencia
									{	
										if( !variableExiste($2) ) mensajeErrorNoDeclarada($2);
										else{
											entradaTS aux = getSimboloIdentificador($2.nombre);
											if( aux.tipoDato != entero ) mensajeErrorTipo1(aux, entero);
										}
										if( $4.tipoDato != entero ) mensajeErrorTipo1($4, entero);
										if( $7.tipoDato != entero ) mensajeErrorTipo1($7, entero);
										if( $10.tipoDato != entero ) mensajeErrorTipo1($10, entero);

										char* sent = (char*) malloc(200);
										sprintf(sent, "%s%s = %s+%s;\n", numTabs(), generarTemp(entero), $2.nombre, $10.valor);
										fputs(sent, file);
										sprintf(sent, "%s%s = temp%d;\n", numTabs(), $2.nombre, temp);
										fputs(sent, file);
										sprintf(sent, "%sgoto %s;\n", numTabs(), TF[TOPEFLUJO-1].EtiquetaEntrada);
										fputs(sent, file);
										sprintf(sent, "%s%s:\n;\n", numTabs(), TF[TOPEFLUJO-1].EtiquetaSalida);
										fputs(sent, file);
										sacarTF();
									};

sentencia_iterar				: IDENTIFICADOR OPUNARIOPOST FINLINEA {	
										if( !variableExiste($1) ) mensajeErrorNoDeclarada($1);
										else{
											entradaTS aux = getSimboloIdentificador($1.nombre);
											if( aux.tipoDato != lista ) mensajeErrorTipo1(aux, lista); 
										}
										char* sent = (char*) malloc(200);
										if (strcmp($2.valor, ">>") == 0)
											sprintf(sent, "%snext(&%s);\n", numTabs(), $1.nombre);
										else
											sprintf(sent, "%sprevious(&%s);\n", numTabs(), $1.nombre);
										fputs(sent, file);
									};
																		
sentencia_reset_cursor			: OPDOLAR IDENTIFICADOR FINLINEA {	
										if( !variableExiste($2) ) mensajeErrorNoDeclarada($2); 
										else{
												entradaTS aux = getSimboloIdentificador($2.nombre);
												if( aux.tipoDato != lista ) mensajeErrorTipo1(aux, lista); }	
										char* sent = (char*) malloc(200);
										sprintf(sent, "%sbegin(&%s);\n", numTabs(), $2.nombre);
										fputs(sent, file);
									};

lista_parametros				: lista_parametros COMA tipo IDENTIFICADOR {	
												$$.parametros++; 
												$4.tipoDato = $3.tipoDato;
												$4.tipoInternoLista = $3.tipoInternoLista;
												$4.entrada = parametro_formal;
												if( !parametroExiste($4) ) insertar($4);
												else mensajeErrorParametro($4);	
												concatenarStrings5($$.valor, $1.valor, $2.valor, tipoDeDato($3.tipoDato), " ", $4.nombre);
											}
								| tipo IDENTIFICADOR {	$$.parametros = 1; 
														$2.tipoDato = $1.tipoDato; 
														$2.tipoInternoLista = $1.tipoInternoLista;
														$2.entrada = parametro_formal;
														if( !parametroExiste($2) ) insertar($2);
														else mensajeErrorParametro($2);
														concatenarStrings3($$.valor, tipoDeDato($1.tipoDato), " ", $2.nombre);		
													} ;

lista_exp_cadena				: lista_exp_cadena COMA exp_cad {	$$.parametros++;
																	if (strcmp($0.valor, "(") == 0 ){		// Funcion
																		entradaTS aux = getSimboloIdentificador($-1.nombre);
																		if( !comprobarParametro(aux.nombre, $$.parametros, $3.tipoDato) )
																			mensajeErrorTipoArgumento(aux.nombre, $$.parametros,
																				getSimboloArgumento(aux.nombre, $$.parametros).tipoDato);
																		concatenarStrings4($$.valor, $1.valor, $2.valor, " ", $3.valor);
																	}
																	else if(strcmp($0.valor, "[") == 0){	// Lista
																		if( $3.tipoDato != $1.tipoDato ){
																			mensajeErrorTipo1($3, $1.tipoDato); 
																			$$.tipoDato = desconocido;
																			$$.tipoInternoLista = desconocido;
																		}
																		else{																
																			$$.tipoDato = $1.tipoDato;
																			$$.tipoInternoLista = $1.tipoDato;
																		}
																		char* sent = (char*) malloc(200);
																		sprintf(sent, "%spush(&%s, %s);\n", numTabs(), $1.valor, $3.valor);/*TODO: Quiza */
																		fputs(sent, file);
																		concatenarStrings1($$.valor, $1.valor);
																	}
																	else if(strcmp($0.valor, "IMPRIMIR") == 0){
																		char* sent = (char*) malloc(200);
																		sprintf(sent, "%%%c", tipoAFormato($3.tipoDato));
																		fputs(sent, file);
																		concatenarStrings4($$.valor, $1.valor, $2.valor, " ", $3.valor);
																	}
																}
								| exp_cad {	$$.parametros = 1;
											if (strcmp($0.valor, "(") == 0 ){		// Funcion
												entradaTS aux = getSimboloIdentificador($-1.nombre);
												if( !comprobarParametro(aux.nombre, $$.parametros, $1.tipoDato) )
													mensajeErrorTipoArgumento(aux.nombre, $$.parametros,
														getSimboloArgumento(aux.nombre, $$.parametros).tipoDato);
												concatenarStrings1($$.valor, $1.valor);	
											}else if(strcmp($0.valor, "[") == 0){	// Lista																
												$$.tipoDato = $1.tipoDato;
												$$.tipoInternoLista = $1.tipoDato;
												char* sent = (char*) malloc(200);
												sprintf(sent, "%s%s = temp%d;\n", numTabs(), generarTemp(lista), temp);
												fputs(sent, file);
												sprintf(sent, "%spush(&temp%d, %s);\n", numTabs(), temp, $1.valor);
												fputs(sent, file);
												char* aux = (char*) malloc(20);
												sprintf(aux, "temp%d", temp);
												concatenarStrings1($$.valor, aux);
											}
											else if(strcmp($0.valor, "IMPRIMIR") == 0){
												char* sent = (char*) malloc(200);
												sprintf(sent, "%sprintf(\"%%%c", numTabs(), tipoAFormato($1.tipoDato));
												fputs(sent, file);
												concatenarStrings1($$.valor, $1.valor);
											}
										} ;

exp_cad							: expresion	{	$$.tipoDato = $1.tipoDato;
												$$.tipoInternoLista = $1.tipoInternoLista;
												concatenarStrings1($$.valor, $1.valor); }
								| CADENA {	$$.tipoDato = cadena;	
											concatenarStrings1($$.valor, $1.valor); } ;

lista_variables					: lista_variables COMA IDENTIFICADOR  	{	if ( !variableExiste($3) ) mensajeErrorNoDeclarada($3);	
																			entradaTS aux = getSimboloIdentificador($3.nombre);
																			if(strcmp($0.valor, "LEER") == 0){
																				char* sent = (char*) malloc(200);
																				sprintf(sent, "%%%c",tipoAFormato(aux.tipoDato));
																				fputs(sent, file);
																			}
																			concatenarStrings4($$.valor, $1.valor, $2.valor, tipoAPuntero(aux.tipoDato), $3.nombre); 
																		}
								| IDENTIFICADOR {	if ( !variableExiste($1) ) mensajeErrorNoDeclarada($1);	
													entradaTS aux = getSimboloIdentificador($1.nombre);
													if(strcmp($0.valor, "LEER") == 0){
														char* sent = (char*) malloc(200);
														sprintf(sent, "%sscanf(\"%%%c", numTabs(), tipoAFormato(aux.tipoDato));
														fputs(sent, file);
													}
													concatenarStrings2($$.valor, tipoAPuntero(aux.tipoDato), $1.nombre);
												};

expresion						: PARIZQ expresion PARDER	{	$$.tipoDato = $2.tipoDato;
																$$.tipoInternoLista = $2.tipoInternoLista;
																char* aux = (char*) malloc(20);
																sprintf(aux, "temp%d", temp);
																concatenarStrings1($$.valor, aux);
															}
								| OPUNARIO expresion	{	if( $2.tipoDato != booleano){
																mensajeErrorTipo1($2, booleano);
																$$.tipoDato = desconocido;
															}
															else $$.tipoDato = $2.tipoDato;
															$$.tipoInternoLista = $2.tipoInternoLista;
															char* sent = (char*) malloc(200);
															sprintf(sent, "%s%s = %s%s;\n", numTabs(), generarTemp($$.tipoDato), $1.valor, $2.valor);
															fputs(sent, file);
															char* aux = (char*) malloc(20);
															sprintf(aux, "temp%d", temp);
															concatenarStrings1($$.valor, aux);
														}
								| OPUNARIOLISTAS expresion	{	
									if( $2.tipoDato != lista ){
										mensajeErrorTipo1($2, lista);
										$$.tipoDato = desconocido;
									} else {
										if( strcmp($1.valor, "#") == 0)$$.tipoDato = entero;
										else $$.tipoDato = $2.tipoInternoLista;
									}
									$$.tipoInternoLista = desconocido;
									char* sent = (char*) malloc(200);
									if (strcmp($1.nombre, "#") == 0) 
										sprintf(sent, "%s%s = length(%s);\n", numTabs(), generarTemp(entero), $2.valor);
									else
										sprintf(sent, "%s%s = currentData(%s);\n", numTabs(), generarTemp($2.tipoInternoLista), $2.valor);
									fputs(sent, file);
									char* aux = (char*) malloc(20);
									sprintf(aux, "temp%d", temp);
									concatenarStrings1($$.valor, aux);
								}
								| SIGNO expresion %prec OPUNARIO	{	if( $2.tipoDato != entero && $2.tipoDato != real && 
																			$2.tipoInternoLista != entero && $2.tipoInternoLista != real ){
																			mensajeErrorTipo2($2, entero, real);
																			$$.tipoDato = desconocido;
																		} else $$.tipoDato = $2.tipoDato;
																		$$.tipoInternoLista = $2.tipoInternoLista;
																		char* sent = (char*) malloc(200);
																		sprintf(sent, "%s%s = %s%s;\n", numTabs(), generarTemp($2.tipoDato), $1.valor, $2.valor);
																		fputs(sent, file);
																		char* aux = (char*) malloc(20);
																		sprintf(aux, "temp%d", temp);
																		concatenarStrings1($$.valor, aux);
																	}
								| expresion SIGNO expresion	{	
									char* sent = (char*) malloc(200);
									char* aux = (char*) malloc(20);
									if ($1.tipoDato == lista && $3.tipoDato == $1.tipoInternoLista){
										$$.tipoDato = lista;
										$$.tipoInternoLista = $1.tipoInternoLista;
										if (strcmp($2.nombre, "+") == 0) 
											sprintf(sent, "%s%s = sum(%s, %s);\n", numTabs(), generarTemp(lista), $1.valor, $3.valor);
										else
											sprintf(sent, "%s%s = subtract(%s, %s);\n", numTabs(), generarTemp(lista), $1.valor, $3.valor);
										fputs(sent, file);
										sprintf(aux, "temp%d", temp);
										concatenarStrings1($$.valor, aux);
									}
									else if ($3.tipoDato == lista && $1.tipoDato == $3.tipoInternoLista){
										$$.tipoDato = lista;
										$$.tipoInternoLista = $3.tipoInternoLista;
										if (strcmp($2.nombre, "+") == 0) 
											sprintf(sent, "%s%s = sum(%s, %s);\n", numTabs(), generarTemp(lista), $3.valor, $1.valor);
										else
											sprintf(sent, "%s%s = subtract(%s, %s);\n", numTabs(), generarTemp(lista), $3.valor, $1.valor);
										fputs(sent, file);
										sprintf(aux, "temp%d", temp);
										concatenarStrings1($$.valor, aux);
									}
									else if( $1.tipoDato == $3.tipoDato){
										$$.tipoDato = $1.tipoDato;
										$$.tipoInternoLista = desconocido;
										sprintf(sent, "%s%s = %s %s %s;\n", numTabs(), generarTemp($$.tipoDato), $1.valor, $2.valor, $3.valor);
										fputs(sent, file);
										sprintf(aux, "temp%d", temp);
										concatenarStrings1($$.valor, aux);
									}
									else {
										mensajeErrorOperarTipos($1, $3);
										$$.tipoDato = desconocido;
										sprintf(sent, "%s%s = %s %s %s;\n", numTabs(), generarTemp($$.tipoDato), $1.valor, $2.valor, $3.valor);
										fputs(sent, file);
										sprintf(aux, "temp%d", temp);
										concatenarStrings1($$.valor, aux);
									}
								}
								| expresion OPORLOGICO expresion	{	bool error=false;
																		if( $1.tipoDato != booleano ){
																			mensajeErrorTipo1($1, booleano);
																			error = true;
																		}
																		if( $3.tipoDato != booleano ){
																			mensajeErrorTipo1($3, booleano);
																			error = true;
																		}
																		if (error) $$.tipoDato = desconocido;
																		else $$.tipoDato = $1.tipoDato;
																		char* sent = (char*) malloc(200);
																		sprintf(sent, "%s%s = %s %s %s;\n", numTabs(), generarTemp($$.tipoDato), $1.valor, $2.valor, $3.valor);
																		fputs(sent, file);
																		char* aux = (char*) malloc(20);
																		sprintf(aux, "temp%d", temp);
																		concatenarStrings1($$.valor, aux);
																	}
								| expresion OPANDLOGICO expresion	{	bool error=false;
																		if( $1.tipoDato != booleano ){
																			mensajeErrorTipo1($1, booleano);
																			error = true;
																		}
																		if( $3.tipoDato != booleano ){
																			mensajeErrorTipo1($3, booleano);
																			error = true;
																		}
																		if (error) $$.tipoDato = desconocido;
																		else $$.tipoDato = $1.tipoDato;
																		char* sent = (char*) malloc(200);
																		sprintf(sent, "%s%s = %s %s %s;\n", numTabs(), generarTemp($$.tipoDato), $1.valor, $2.valor, $3.valor);
																		fputs(sent, file);
																		char* aux = (char*) malloc(20);
																		sprintf(aux, "temp%d", temp);
																		concatenarStrings1($$.valor, aux);
																	}
								| expresion OPEXCLUSIVEOR expresion	{	bool error=false;
																		if( $1.tipoDato != booleano ){
																			mensajeErrorTipo1($1, booleano);
																			error = true;
																		}
																		if( $3.tipoDato != booleano ){
																			mensajeErrorTipo1($3, booleano);
																			error = true;
																		}
																		if (error) $$.tipoDato = desconocido;
																		else $$.tipoDato = $1.tipoDato;
																		char* sent = (char*) malloc(200);
																		sprintf(sent, "%s%s = %s %s %s;\n", numTabs(), generarTemp($$.tipoDato), $1.valor, $2.valor, $3.valor);
																		fputs(sent, file);
																		char* aux = (char*) malloc(20);
																		sprintf(aux, "temp%d", temp);
																		concatenarStrings1($$.valor, aux);
																	}
								| expresion OPIGUALDAD expresion	{	bool error=false;
																		if( $1.tipoDato == lista){
																			mensajeErrorNoTipo($1);
																			error = true;
																		}
																		if( $3.tipoDato == lista){
																			mensajeErrorNoTipo($3);
																			error = true;
																		}
																		if( $1.tipoDato != $3.tipoDato ){ 
																			mensajeErrorComparacion($1, $3);
																			error = true;
																		}
																		if (error) $$.tipoDato = desconocido;
																		else $$.tipoDato = booleano;
																		char* sent = (char*) malloc(200);
																		sprintf(sent, "%s%s = %s %s %s;\n", numTabs(), generarTemp($$.tipoDato), $1.valor, $2.valor, $3.valor);
																		fputs(sent, file);
																		char* aux = (char*) malloc(20);
																		sprintf(aux, "temp%d", temp);
																		concatenarStrings1($$.valor, aux);
																	}
								| expresion OPRELACION expresion	{	bool error=false;
																		if( $1.tipoDato == lista){
																			mensajeErrorNoTipo($1);
																			error = true;
																		}
																		if( $3.tipoDato == lista){
																			mensajeErrorNoTipo($3);
																			error = true;
																		}
																		if( $1.tipoDato != $3.tipoDato ){ 
																			mensajeErrorComparacion($1, $3);
																			error = true;
																		}
																		if (error) $$.tipoDato = desconocido;
																		else $$.tipoDato = booleano;
																		char* sent = (char*) malloc(200);
																		sprintf(sent, "%s%s = %s %s %s;\n", numTabs(), generarTemp($$.tipoDato), $1.valor, $2.valor, $3.valor);
																		fputs(sent, file);
																		char* aux = (char*) malloc(20);
																		sprintf(aux, "temp%d", temp);
																		concatenarStrings1($$.valor, aux);
																	}
								| expresion OPMULTIPLICATIVOS expresion	{	
									char* sent = (char*) malloc(200);
									char* aux = (char*) malloc(20);
									if ($1.tipoDato == lista && $3.tipoDato == $1.tipoInternoLista){
										$$.tipoDato = lista;
										$$.tipoInternoLista = $1.tipoInternoLista;
										if (strcmp($2.nombre, "*") == 0) 
											sprintf(sent, "%s%s = mult(%s, %s);\n", numTabs(), generarTemp(lista), $1.valor, $3.valor);
										else
											sprintf(sent, "%s%s = divi(%s, %s);\n", numTabs(), generarTemp(lista), $1.valor, $3.valor);
										fputs(sent, file);
										sprintf(aux, "temp%d", temp);
										concatenarStrings1($$.valor, aux);
									}
									else if ($3.tipoDato == lista && $1.tipoDato == $3.tipoInternoLista){
										$$.tipoDato = lista;
										$$.tipoInternoLista = $3.tipoInternoLista;
										if (strcmp($2.nombre, "*") == 0) 
											sprintf(sent, "%s%s = mult(%s, %s);\n", numTabs(), generarTemp(lista), $3.valor, $1.valor);
										else
											sprintf(sent, "%s%s = divi(%s, %s);\n", numTabs(), generarTemp(lista), $3.valor, $1.valor);
										fputs(sent, file);
										sprintf(aux, "temp%d", temp);
										concatenarStrings1($$.valor, aux);
									}
									else if( $1.tipoDato == $3.tipoDato){
										$$.tipoDato = $1.tipoDato;
										$$.tipoInternoLista = desconocido;
										sprintf(sent, "%s%s = %s %s %s;\n", numTabs(), generarTemp($$.tipoDato), $1.valor, $2.valor, $3.valor);
										fputs(sent, file);
										sprintf(aux, "temp%d", temp);
										concatenarStrings1($$.valor, aux);
									}
									else {
										mensajeErrorOperarTipos($1, $3);
										$$.tipoDato = desconocido;
										sprintf(sent, "%s%s = %s %s %s;\n", numTabs(), generarTemp($$.tipoDato), $1.valor, $2.valor, $3.valor);
										fputs(sent, file);
										sprintf(aux, "temp%d", temp);
										concatenarStrings1($$.valor, aux);
									}
								}
								| expresion OPDECREMENTO expresion	{	
											bool error=false;
											if( $1.tipoDato != lista ){ 
												mensajeErrorTipo1($1, lista);
												error = true;
											}
											if( $3.tipoDato != entero ) {
												mensajeErrorTipo1($3, entero);
												error = true;
											}
											if (error) $$.tipoDato = desconocido;
											else $$.tipoDato = lista;
											$$.tipoInternoLista = $1.tipoInternoLista;
											char* sent = (char*) malloc(200);
											sprintf(sent, "%s%s = deleteAt(%s, %s);\n", numTabs(), generarTemp(lista), $1.valor, $3.valor);
											fputs(sent, file);
											char* aux = (char*) malloc(20);
											sprintf(aux, "temp%d", temp);
											concatenarStrings1($$.valor, aux);
										}
								| expresion OPPORCENTAJE expresion	{	
										bool error=false;
										if( $1.tipoDato != lista ){ 
											mensajeErrorTipo1($1, lista);
											error = true;
										}
										if( $3.tipoDato != entero ) {
											mensajeErrorTipo1($3, entero);
											error = true;
										}
										if (error) $$.tipoDato = desconocido;
										else $$.tipoDato = lista;
										$$.tipoInternoLista = $1.tipoInternoLista;
										char* sent = (char*) malloc(200);
										sprintf(sent, "%s%s = deleteSince(%s, %s);\n", numTabs(), generarTemp(lista), $1.valor, $3.valor);
										fputs(sent, file);
										char* aux = (char*) malloc(20);
										sprintf(aux, "temp%d", temp);
										concatenarStrings1($$.valor, aux);
										}
								| expresion OPCONCATENAR expresion	{	
										bool error=false;
										if( $1.tipoDato != lista ){
											mensajeErrorTipo1($1, lista);
											error = true;
										}
										if( $3.tipoDato != lista ){
											mensajeErrorTipo1($3, lista);
											error = true;
										}
										if( $1.tipoInternoLista != $3.tipoInternoLista){
											mensajeErrorTiposInternosNoCoinciden($1, $3);
											error = true;
										} 
										if (error){ 
											$$.tipoDato = desconocido;
											$$.tipoInternoLista = desconocido;
										}
										else{
											$$.tipoDato = lista;
											$$.tipoInternoLista = $1.tipoInternoLista;
										}
										char* sent = (char*) malloc(200);
										sprintf(sent, "%s%s = concatenate(%s, %s);\n", numTabs(), generarTemp(lista), $1.valor, $3.valor);
										fputs(sent, file);
										char* aux = (char*) malloc(20);
										sprintf(aux, "temp%d", temp);
										concatenarStrings1($$.valor, aux);
									}
								| expresion OPARROBA expresion	{	
										bool error=false;
										if( $1.tipoDato != lista ){ 
											mensajeErrorTipo1($1, lista);
											error = true;
										}
										if( $3.tipoDato != entero ) {
											mensajeErrorTipo1($3, entero);
											error = true;
										}
										if (error) $$.tipoDato = desconocido;
										else $$.tipoDato = $1.tipoInternoLista;
										$$.tipoInternoLista = desconocido;
										char* sent = (char*) malloc(200);
										sprintf(sent, "%s%s = dataAt(%s, %s);\n", numTabs(), generarTemp($1.tipoInternoLista), $1.valor, $3.valor);
										fputs(sent, file);
										char* aux = (char*) malloc(20);
										sprintf(aux, "temp%d", temp);
										concatenarStrings1($$.valor, aux);
									}
								| expresion OPINCREMENTO expresion OPARROBA expresion	{
									bool error = false;	
									if( $1.tipoDato != lista ){ 
										mensajeErrorTipo1($1, lista);
										error = true;
									}
									if( $3.tipoDato != $1.tipoInternoLista ){
										mensajeErrorTipo1($3, $1.tipoInternoLista);
										error = true;
									}
									if( $5.tipoDato != entero ){ 
										mensajeErrorTipo1($5, entero);
										error = true;
									}
									if (error){ 
										$$.tipoDato = desconocido;
										$$.tipoInternoLista = desconocido;
									}
									else{
										$$.tipoDato = lista;
										$$.tipoInternoLista = $1.tipoInternoLista;
									}
									char* sent = (char*) malloc(200);
									sprintf(sent, "%s%s = addAt(%s, %s, %s);\n", numTabs(), generarTemp(lista), $1.valor, $5.valor, $3.valor);
									fputs(sent, file);
									char* aux = (char*) malloc(20);
									sprintf(aux, "temp%d", temp);
									concatenarStrings1($$.valor, aux);
								}
								| IDENTIFICADOR	{	if( !variableExiste($1) ){
														mensajeErrorNoDeclarada($1);
														$$.tipoDato = desconocido;
														$$.tipoInternoLista = desconocido;
													}
													else{
														entradaTS aux = getSimboloIdentificador($1.nombre);
														$$.tipoDato = aux.tipoDato;
														$$.tipoInternoLista = aux.tipoInternoLista;
													}
													$$.entrada = variable;
													concatenarStrings1($$.valor, $1.nombre);
												}
								| lista	{	$$.tipoDato = lista;
											$$.tipoInternoLista = $1.tipoInternoLista;
											concatenarStrings1($$.valor, $1.valor);
											// TODO FOR BONUS
										}
								| constante	{	$$.tipoDato = $1.tipoDato;
												concatenarStrings1($$.valor, $1.valor);
											}
								| funcion	{	if( !variableExiste($1) ){
													mensajeErrorNoDeclarada($1);
													$$.tipoDato = desconocido;
													$$.tipoInternoLista = desconocido;
												}
												else{
													entradaTS aux = getSimboloIdentificador($1.nombre);
													$$.tipoDato = aux.tipoDato;
													$$.tipoInternoLista = aux.tipoInternoLista;
												}
												$$.entrada = funcion;
												concatenarStrings1($$.valor, $1.valor);
											}
								| error ;

funcion							: IDENTIFICADOR PARIZQ lista_exp_cadena PARDER	
									{	$1.entrada = getSimboloIdentificador($1.nombre).entrada;
										if( !variableExiste($1) ){
											mensajeErrorNoDeclarada($1);
											$$.tipoDato = desconocido;
										}
										else if( getSimboloIdentificador($1.nombre).entrada != funcion ){
											mensajeErrorSeEsperabaFuncion($1);
											$$.tipoDato = desconocido;
										}
										else if( $3.parametros != getSimboloIdentificador($1.nombre).parametros ){
											mensajeErrorNumParametros(getSimboloIdentificador($1.nombre),$3);
											$$.tipoDato = desconocido;
										}
										$$.tipoDato = getSimboloIdentificador($1.nombre).tipoDato;
										$$.tipoInternoLista = getSimboloIdentificador($1.nombre).tipoInternoLista;
										char* sent = (char*) malloc(200);
										sprintf(sent, "%s%s = %s(%s);\n", numTabs(), generarTemp($$.tipoDato), $1.valor, $3.valor);
										fputs(sent, file);
										char* aux = (char*) malloc(20);
										sprintf(aux, "temp%d", temp);
										concatenarStrings1($$.valor, aux);	
									};

constante						: ENTERO	{	$$.tipoDato = entero;
												$$.tipoInternoLista = desconocido;
												concatenarStrings1($$.valor, $1.valor);	}
								| REAL	{	$$.tipoDato = real;
											$$.tipoInternoLista = desconocido;
											concatenarStrings1($$.valor, $1.valor);	}
								| CONSTANTE_CARACTER	{	$$.tipoDato = caracter;
															$$.tipoInternoLista = desconocido;
															concatenarStrings1($$.valor, $1.valor);	}
								| CONSTANTE_BOOLEANA 	{	$$.tipoDato = booleano;
															$$.tipoInternoLista = desconocido;
													concatenarStrings1($$.valor, (strcmp($1.valor, "VERDADERO") == 0) ? "1" : "0" );	} ;

lista							: ABRIRCORCHETE lista_exp_cadena CERRARCORCHETE {	$$.tipoInternoLista = $2.tipoDato;
																					$$.tipoDato = lista;
																					concatenarStrings1($$.valor, $2.valor);	};

tipo							: TIPO	{	$$.tipoDato = $1.tipoDato;
											concatenarStrings1($$.valor, $1.valor);
										}
								| LISTA_DE TIPO	{	$$.tipoDato = $1.tipoDato;	
													$$.tipoInternoLista = $2.tipoDato;	
													concatenarStrings3($$.valor, $1.valor," ", $2.valor);
												};

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
