.SUFFIXES:

p3: main.o y.tab.o
	gcc -o p3 main.o y.tab.o

y.tab.o: y.tab.c
	gcc -c y.tab.c

main.o: main.c
	gcc -c main.c

y.tab.c: p3.y lex.yy.c
	bison -o y.tab.c p3.y -v

lex.yy.c: p2.l
	flex p2.l

clean:
	rm -f p3 p3.exe main.o y.tab.o y.tab.c lex.yy.c

all:
	make clean
	make p3