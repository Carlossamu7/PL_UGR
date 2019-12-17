.SUFFIXES:

p3: main.o y.tab.o
	gcc -o p3 main.o y.tab.o -Wall -g

y.tab.o: y.tab.c
	gcc -c y.tab.c -std=c11 -Wall -g

main.o: main.c
	gcc -c main.c -Wall -g

y.tab.c: p3.y lex.yy.c p4.h
	bison -o y.tab.c p3.y -v

lex.yy.c: p2.l
	flex p2.l 

cod1: p3 codigo1 p3.y p4.h
	./p3 codigo1
	gcc -o p5 codigoGenerado.c -std=c99 -g

cod2: p3 codigo2 p3.y p4.h
	./p3 codigo2
	gcc -o p5 codigoGenerado.c -std=c99 -g

cod3: p3 codigo3 p3.y p4.h
	./p3 codigo3
	gcc -o p5 codigoGenerado.c -std=c99 -g

cod4: p3 codigo4 p3.y p4.h
	./p3 codigo4
	gcc -o p5 codigoGenerado.c -std=c99 -g

cod5: p3 codigo5 p3.y p4.h
	./p3 codigo5
	gcc -o p5 codigoGenerado.c -std=c99 -g

cod6: p3 codigo6 p3.y p4.h
	./p3 codigo6
	gcc -o p5 codigoGenerado.c -std=c99 -g

clean:
	rm -f p3 p5 prueba1 test_list prueba1.exe p3.exe main.o y.tab.o y.tab.c lex.yy.c y.output codigoGenerado.c p5.exe

all:
	make clean
	make p3
