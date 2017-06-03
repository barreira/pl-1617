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
%token <str> READ
%token <str> TEXT
%token <str> WRITE

%type <var> Var 
%type <str> Input
%type <str> Output
%type <str> OutArgs


%left '+' '-'
%left '*' '/'

%%

Lines :  { ; }
      |  Var Lines
      |  Input Lines
      |  Output Lines
      ;

Var : NAME ';'            { printf("%s\n", $1); }
    | NAME '=' NUM ';'    { printf("%s - %d\n", $1, $3); } 
    ;


Input : READ '(' TEXT ')' ';'			{ printf("%s\n", $3); }
	  | NAME '=' READ '(' TEXT ')' ';'	{ printf("%s %s\n", $1, $5); }
	  ;

Output : WRITE '(' OutArgs ')' ';' {}
	   ;

OutArgs : OutArgs '+' NAME		{ printf("1 - %s\n", $3); }
		| OutArgs '+' TEXT		{ printf("2 - %s\n", $3); }
		| NAME 					{ printf("3 - %s\n", $1); }
		| TEXT					{ printf("4 - %s\n", $1); }
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
