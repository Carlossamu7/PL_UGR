.SUFFIXES:

p3: main.o y.tab.o
	gcc -o p3 main.o y.tab.o -g

y.tab.o: y.tab.c
	gcc -c y.tab.c -std=c11 -g

main.o: main.c
	gcc -c main.c -g

y.tab.c: p3.y lex.yy.c p4.h
	bison -o y.tab.c p3.y -v

lex.yy.c: p2.l
	flex p2.l 

clean:
	rm -f p3 p3.exe main.o y.tab.o y.tab.c lex.yy.c y.output

all:
	make clean
	make p3
