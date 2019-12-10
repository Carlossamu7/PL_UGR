all: EXE

# OBJ

LEX:
	flex -l -8i practica2.lex
YACC:
	bison -y -d -v -k practica3.y

# BIN

MAIN: LEX YACC
	gcc -g -c y.tab.c 

ARCHIVO: 
	gcc -g -c main.c 

EXE: MAIN ARCHIVO
	gcc y.tab.o main.o -g -o p4
	


	
# ************ Limpieza ************

clean :
	-rm p4 *.o lex.yy.c y.tab.c y.tab.h

