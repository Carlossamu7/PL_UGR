#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern FILE *yyin ;
int yyparse(void) ;

FILE *abrir_entrada( int argc, char *argv[] ){
    FILE *f= NULL ;
    if ( argc > 1 ){
        f= fopen(argv[1],"r");
        if (f==NULL){
            fprintf(stderr,"fichero '%s' no encontrado\n",argv[1]);
            exit(1);
        }
        else
            printf("leyendo fichero '%s'.\n",argv[1]);
    }
    else
        printf("leyendo entrada estándar.\n");

    return f ;
}

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
		case 267: strcpy( ret, "Desde\0" ); break;
		case 268: strcpy( ret, "Hasta\0" ); break;
		case 269: strcpy( ret, "Paso\0" ); break;
		case 270: strcpy( ret, "Condicion\0" ); break;
		case 271: strcpy( ret, "Subcondicion\0" ); break;
		case 272: strcpy( ret, "Ciclo\0" ); break;
		case 273: strcpy( ret, "Asignacion\0" ); break;
		case 274: strcpy( ret, "Entrada\0" ); break;
		case 275: strcpy( ret, "Salida\0" ); break;
		case 276: strcpy( ret, "Return\0" ); break;
		case 277: strcpy( ret, "Inibloque\0" ); break;
		case 278: strcpy( ret, "FinBloque\0" ); break;
		case 279: strcpy( ret, "IniVariables\0" ); break;
		case 280: strcpy( ret, "FinVariables\0" ); break;
		case 281: strcpy( ret, "Constante_Booleana\0" ); break;
		case 282: strcpy( ret, "Cadena\0" ); break;
		case 283: strcpy( ret, "Constante_Caracter\0" ); break;
		case 284: strcpy( ret, "ParIzq\0" ); break;
		case 285: strcpy( ret, "ParDer\0" ); break;
		case 286: strcpy( ret, "Coma\0" ); break;
		case 287: strcpy( ret, "FinLinea\0" ); break;
		case 288: strcpy( ret, "DosPuntosIgual\0" ); break;
		case 289: strcpy( ret, "AbrirCorchete\0" ); break;
		case 290: strcpy( ret, "CerrarCorchete\0" ); break;
		case 291: strcpy( ret, "OpUnario\0" ); break;
		case 292: strcpy( ret, "Lista_De\0" ); break;
	}
}

/************************************************************/
int main( int argc, char *argv[] ){
    yyin = abrir_entrada(argc,argv) ;
	int ret = yyparse();
	printf("***** Valor devuelto por yyparse(): %d\n",ret);
    return ret ;
}
