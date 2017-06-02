%{
	#include <stdio.h>
	#include <string.h>
	#include <glib.h>

	
	gint comp(gconstpointer, gconstpointer);


	typedef struct var {
        int value;
        char* name;
    	} var;

	GTree* varsTree;
%}

%union { 
	char* str;
	int n;
}

%token <n> NUM
%token <str> NAME

%type <var> Var 

%left '+' '-'
%left '*' '/'

%%

Lines :  { ; }
      |  Var Lines
      ;

Var : NAME ';'            { printf("%s\n", $1); }
    | NAME '=' NUM ';'    { printf("%s - %d\n", $1, $3); } 
    ;

%%

#include "lex.yy.c"


gint comp(gconstpointer a, gconstpointer b)
{
	return (strcmp(((var*)a)->name, ((var*)b)->name));
}


int yyerror(char* s)
{
	printf("error: %s\n", s);
}


int main(int argc, char** argv)
{
	varsTree = g_tree_new(comp);

	yyparse();
	return 0;
}
