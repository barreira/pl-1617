V=test
$V: $V.fl $V.y 
	flex $V.fl
	yacc $V.y
	cc -g y.tab.c -o $V `pkg-config --cflags --libs glib-2.0`
clean:
	rm lex.yy.c $V
