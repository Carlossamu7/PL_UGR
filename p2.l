%{
	//#include "tabla_simbolos.h" // Lo incluimos en el yacc, y éste (lex) lo incluimosal final del yacc
	#include <stdlib.h>
	#include <string.h>
%}

%option yylineno

/** La siguiente declaración indica que no se va a escribir la función ’yywrap’
 * evita que se tenga que enlazar con -lfl, o que se tenga que escribir ’yywrap’
 **/
%option noyywrap

letra			([a-zA-Z])
digito			([0-9])
alfanumerico	[a-zA-Z_0-9]
identificador	{letra}+{alfanumerico}*
entero			{digito}+
cadena			(\"[^\"]*\")
real			{entero}*[.]{entero}+
caracter		(\'[^\']\')
blanco			[ \t]
otros			.

%%

"PRINCIPAL"				return CABECERA;
"ENTERO"				{	 
						yylval.tipoDato = entero;
						return TIPO;
						}
"REAL"					{	
						yylval.tipoDato = real;
						return TIPO;
						}
"BOOLEANO"				{	
						yylval.tipoDato = booleano;
						return TIPO;
						}
"CARACTER"				{	
						yylval.tipoDato = caracter;
						return TIPO;
						}
"LISTA DE" 				{
						yylval.tipoDato = lista;
						return TIPO;
						}
"PARA" 					return BUCLE;
"HASTA"					return HASTA;
"PASO"					return PASO;
"SI"					return CONDICION;
"SINO"					return SUBCONDICION;
"MIENTRAS"				return CICLO;
"LEER"					return ENTRADA;
"IMPRIMIR"				return SALIDA;
"DEVOLVER"				return RETURN;
"VAR"					return INIVARIABLES;
"FINVAR"				return FINVARIABLES;
"VERDADERO"				{
						yylval.tipoDato = booleano;
						return CONSTANTE_BOOLEANA;
						}
"FALSO"					{
						yylval.tipoDato = booleano;
						return CONSTANTE_BOOLEANA;
						}
{caracter}				{
						yylval.tipoDato = caracter;
						yylval.valor = strdup(yytext);
						return CONSTANTE_CARACTER;
						}
{cadena}				{
						yylval.valor = strdup(yytext);
						return CADENA;
						}
{entero}				{
						yylval.tipoDato = entero;
						yylval.valor = strdup(yytext);
						return ENTERO;
						}	
{real}					{
						yylval.tipoDato = real;
						yylval.valor = strdup(yytext);
						return REAL;
						}
","						{
						yylval.valor = strdup(yytext);
						return COMA;
						}
";"						{
						yylval.valor = strdup(yytext);
						return FINLINEA;
						}
"("						{
						yylval.valor = strdup(yytext);
						return PARIZQ;
						}
")"						{
						yylval.valor = strdup(yytext);
						return PARDER; 
						}
"{"						{
						yylval.valor = strdup(yytext);
						return INIBLOQUE;
						}
"}"						{
						yylval.valor = strdup(yytext);
						return FINBLOQUE;
						}
"["						{
						yylval.valor = strdup(yytext);
						return ABRIRCORCHETE;
						}
"]"						{
						yylval.valor = strdup(yytext);
						return CERRARCORCHETE;
						}
"="						{
						yylval.valor = strdup(yytext);
						return ASIGNACION;	
						}
"||"					{
						yylval.valor = strdup(yytext);
						return OPORLOGICO;
						}
"&&"					{
						yylval.valor = strdup(yytext);
						return OPANDLOGICO;
						}
"^"						{
						yylval.valor = strdup(yytext);
						return OPEXCLUSIVEOR;
						}
"=="					{
						yylval.valor = strdup(yytext);
						return OPIGUALDAD;
						}
"!="					{
						yylval.valor = strdup(yytext);
						return OPIGUALDAD;
						}
"<"						{
						yylval.valor = strdup(yytext);
						return OPRELACION;
						}
">"						{
						yylval.valor = strdup(yytext);
						return OPRELACION;
						}
"<="					{
						yylval.valor = strdup(yytext);
						return OPRELACION;
						}
">="					{
						yylval.valor = strdup(yytext);
						return OPRELACION;
						}
"+"						{
						yylval.valor = strdup(yytext);
						return SIGNO;
						}
"-"						{
						yylval.valor = strdup(yytext);
						return SIGNO;
						}
"*"						{
						yylval.valor = strdup(yytext);
						return OPMULTIPLICATIVOS;
						}
"/"						{
						yylval.valor = strdup(yytext);
						return OPMULTIPLICATIVOS;
						}
"%"						{
						yylval.valor = strdup(yytext);
						return OPMULTIPLICATIVOS;
						}
"!"						{
						yylval.valor = strdup(yytext);
						return OPUNARIO;
						}
"#"						{
						yylval.valor = strdup(yytext);
						return OPUNARIOLISTAS;
						}
"?"						{
						yylval.valor = strdup(yytext);
						return OPUNARIOLISTAS;
						}
"$"						{
						yylval.valor = strdup(yytext);
						return OPDOLAR;
						}
"**"					{
						yylval.valor = strdup(yytext);
						return OPCONCATENAR;
						}
"--"					{
						yylval.valor = strdup(yytext);
						return OPDECREMENTO;
						}
">>"					{
						yylval.valor = strdup(yytext);
						return OPUNARIOPOST;
						}
"<<"					{
						yylval.valor = strdup(yytext);
						return OPUNARIOPOST;
						}
"++"					{
						yylval.valor = strdup(yytext);
						return OPINCREMENTO;
						}
"@"						{
						yylval.valor = strdup(yytext);
						return OPARROBA;
						}
":="					{
						yylval.valor = strdup(yytext);
						return DOSPUNTOSIGUAL;
						}
{identificador} 		{
						yylval.nombre=strdup(yytext);
						return IDENTIFICADOR;
						}

[\n]					/*printf("\n")*/;
{blanco}				;
{otros}					printf("\n(Linea %d) Error lexico: token %s\n", yylineno, yytext);

%%

/*
void parse( const int aux, char ret[] ){
	switch(aux){
		case 257: strcpy( ret, "Cabecera\0" ); break;
		case 258: strcpy( ret, "Identificador\0" ); break;
		case 259: strcpy( ret, "OpBinario\0" ); break;			    
		case 260: strcpy( ret, "OpTernario_1\0" ); break;	
		case 261: strcpy( ret, "OpTernario_2\0" ); break;	
		case 262: strcpy( ret, "Signo\0" ); break;	
		case 263: strcpy( ret, "Entero\0" ); break;
		case 264: strcpy( ret, "Real\0" ); break;
		case 265: strcpy( ret, "Tipo\0" ); break;
		case 266: strcpy( ret, "Bucle\0" ); break;
		case 267: strcpy( ret, "Hasta\0" ); break;
		case 268: strcpy( ret, "Paso\0" ); break;
		case 269: strcpy( ret, "Condicion\0" ); break;
		case 270: strcpy( ret, "Subcondicion\0" ); break;
		case 271: strcpy( ret, "Ciclo\0" ); break;
		case 272: strcpy( ret, "Asignacion\0" ); break;
		case 273: strcpy( ret, "Entrada\0" ); break;
		case 274: strcpy( ret, "Salida\0" ); break;
		case 275: strcpy( ret, "Return\0" ); break;
		case 276: strcpy( ret, "Inibloque\0" ); break;
		case 277: strcpy( ret, "FinBloque\0" ); break;
		case 278: strcpy( ret, "IniVariables\0" ); break;
		case 279: strcpy( ret, "FinVariables\0" ); break;
		case 280: strcpy( ret, "Constante_Booleana\0" ); break;
		case 281: strcpy( ret, "Cadena\0" ); break;
		case 282: strcpy( ret, "Constante_Caracter\0" ); break;
		case 283: strcpy( ret, "ParIzq\0" ); break;
		case 284: strcpy( ret, "ParDer\0" ); break;
		case 285: strcpy( ret, "Coma\0" ); break;
		case 286: strcpy( ret, "FinLinea\0" ); break;
		case 287: strcpy( ret, "DosPuntosIgual\0" ); break;
		case 288: strcpy( ret, "AbrirCorchete\0" ); break;
		case 289: strcpy( ret, "CerrarCorchete\0" ); break;
		case 290: strcpy( ret, "OpUnario\0" ); break;
		case 291: strcpy( ret, "Lista_De\0" ); break;
	}
}

int main(){
	int val;
	val = yylex();
	while (val != 0)
	{
		char aux[100];
		parse(val, aux);
		printf("%s ", aux);
		//printf (" %d\n", val);
		val = yylex();
	}
	exit (1);
}
*/


