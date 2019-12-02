%{
/*#include "tabla_simbolos.h"
#include <stdlib.h>
#include <string.h>*/



%}

%option noyywrap


letra	([a-zA-Z])
digito	([0-9])
alfanumerico	[a-zA-Z_0-9]
identificador		{letra}{alfanumerico}+
entero {digito}+
cadena (\"[^\"]*\")
real {entero}[.]{entero}
caracter (\'[^\']*\')
blanco [ \t]
otros			.

%%
"PRINCIPAL"				return CABECERA;
"ENTERO"				{	 
					yylval.dato = 1;
					yylval.atributo = 1;
					return TIPO;
					}
"REAL"					{	
					yylval.dato = 2;
					yylval.atributo = 0;
					return TIPO;
					}
"BOOLEANO"				{	
					yylval.dato = 4;
					yylval.atributo = 1;
					return TIPO;
					}
"CARACTER"				{	
					yylval.dato = 3;
					yylval.atributo = 1;
					return TIPO;
					}
"SI"					return CONDICION;
"SINO"					return SUBCONDICION;
"MIENTRAS"				return CICLO;
"OPCION"				return OPCION;
"CASO"					return CASO;
"ENTRADA"				return ENTRADA;
"SALIDA"				return SALIDA;
"DEVOLVER"				return RETURN;
"VAR"					return INICIOVARIABLES;
"FINVAR"				return FINVARIABLES;
"VERDADERO"				{
					yylval.dato = 4;
					yylval.atributo = 1;
					return CONSTANTES;
					}
"FALSO"					{
					yylval.dato = 4;
					yylval.atributo = 0;
					return CONSTANTES;
					}
{caracter}				{
					yylval.dato = 3;
					yylval.valor = strdup(yytext);					
					yylval.atributo = 1;
					return CONSTANTES;
					}
{entero}				{
					yylval.dato = 1;
					yylval.valor = strdup(yytext);
					yylval.atributo = 1;					
					return ENTERO;
					}
{real}					{
					yylval.dato = 2;
					yylval.valor = strdup(yytext);
					yylval.atributo = 0;
					return CONSTANTES;
					}
","					return COMA;
";"					return FINLINEA;
"("					return PARENTESISABIERTO ;
")"					return PARENTESISCERRADO ; 
"{"					return INIBLOQUE;
"}"					return FINBLOQUE;
"="					return ASIGNACION ;
"=="					{yylval.valor = strdup(yytext);
					return OPBINARIOS_IGUALDAD;}
"<="					{yylval.valor = strdup(yytext);					
					return OPBINARIOS ;}
">="					{yylval.valor = strdup(yytext);					
					return OPBINARIOS ;}
"<"					{yylval.valor = strdup(yytext);					
					return OPBINARIOS ;}
">"					{yylval.valor = strdup(yytext);					
					return OPBINARIOS ;}
"||"					{yylval.valor = strdup(yytext);					
					return OPBINARIOS ;}
"*"					{yylval.valor = strdup(yytext);					
					return OPBINARIOS_MULTI ;}
"/"					{yylval.valor = strdup(yytext);					
					return OPBINARIOS_MULTI ;}
"!="					{yylval.valor = strdup(yytext);					
					return OPBINARIOS ;}
"**"					{yylval.valor = strdup(yytext);					
					return OPBINARIOS ;}
"+"					{yylval.valor = strdup(yytext);
					return OPSUMARESTA ;}
"-"					{yylval.valor = strdup(yytext);
					return OPSUMARESTA ;}
":"					return DOSPUNTOS;
"["					return ABRIRCORCHETE;
"]"					return CERRARCORCHETE;	
"!"					return OPUNARIO;
"&&"					return OPBINARIOS_AND;
"^"					return OPBINARIOS_OR;
{cadena}				{yylval.valor = strdup(yytext);				
					return CADENA;}
"PREDETERMINADO"			return DEFAULT;
"FINCASO"				return BREAK;				 
[ ]					
{identificador} 			{yylval.Nombre=strdup(yytext);return IDENTIFICADOR;}
[\n]					++linea;
[\t]
{otros}					printf("\n(Linea %d) Error lexico: token %s\n",linea,yytext);

%%

