bison -d Strings.y
flex Strings.l
g++ Strings.tab.c lex.yy.c -lfl -o Strings