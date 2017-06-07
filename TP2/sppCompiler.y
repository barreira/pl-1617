%{
	#include <stdio.h>
	#include <string.h>
     #include <stdint.h>
	#include <glib.h>
	#include "intStack.h"

	
	gint comp(gconstpointer, gconstpointer);
	void writeStart(void);
	void insertVarsTree(char*, int, int);
	void readInput(char*, char*);

	typedef struct var {
        int value;
        char* name;
	} var;

	GTree* varsTree;
	int start = 0;
	int error = 0;
	int reg = 0;
	int cond = 0;
	int condLabelWrited = 0;
	FILE* fp;
	IntStack condStack = NULL;
	
	char* arit = "";
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
%token <str> CASE
%token <str> OTHERWISE
%token <str> LOOP

%type <var> Var 
%type <str> Input
%type <str> Output
%type <str> OutArgs
%type <str> Cond
%type <str> OtherCond
%type <str> CondExp
%type <str> AritExp
%type <str> Loop

%left OTHERWISE
%left '{' 
%left '|'
%left '&'
%left '+' '-'
%left '*' '/'

%%

Lines :  { ; }
      |  Var ';' Lines
      |  Input Lines
      |  Output Lines
      |  Cond Lines   { fprintf(fp, "endCond%d:\n", top(condStack)); condStack = pop(condStack); }
      |  Loop Lines
      ;

Var : NAME              { insertVarsTree($1, reg++, 0); }
    | NAME '[' NUM ']'  { }
    | NAME '=' NUM      { insertVarsTree($1, reg++, $3); } 
    | NAME '[' NUM ']' '=' NUM  { printf("%s[%d]\n", $1, $3); }
    | NAME '=' AritExp  { }
    | NAME '[' NUM ']' '=' AritExp  { printf("%s[%d]\n", $1, $3); }
    | NAME '[' NAME ']' '=' AritExp { printf("%s[%s]\n", $1, $3); }
    ;


Input : READ '(' TEXT ')' ';'			{ readInput("", $3); }
	 | NAME '=' READ '(' TEXT ')' ';'	{ readInput($1, $5); } 
                                          
                                          
	 ;

Output : WRITE '(' OutArgs ')' ';' {}
	  ;

OutArgs : OutArgs '+' NAME { writeOutput($3, ""); }
	   | OutArgs '+' TEXT { writeOutput("", $3); }
	   | NAME 		  { writeOutput($1, ""); }
	   | TEXT	            { writeOutput("", $1); }
	   ;


Loop : LOOP '(' Var ';' CondExp ';' Var ')' '{' Lines '}' { }
     | LOOP '(' CondExp ';' Var ')' '{' Lines '}' { }
     | LOOP '(' CondExp ')' '{' Lines '}' { }
     ; 
     


Cond : CASE '(' CondExp ')' '{' Lines '}' { fprintf(fp, "\tjz otherCond%d\n", top(condStack)); fprintf($3); }
     | Cond OtherCond                     {  }
     ;

OtherCond : OTHERWISE '{' Lines '}' { writeOtherCond(); }
          | OTHERWISE Cond          { }
          ;

CondExp : AritExp '<' AritExp     { }
        | AritExp '>' AritExp     { }
        | AritExp '<' '=' AritExp { }
        | AritExp '>' '=' AritExp { } 
        | AritExp '=' '=' AritExp { writeCond(); }
        | AritExp '!' '=' AritExp { }
        | CondExp '&' CondExp     { }
        | CondExp '|' CondExp     { }
        ;

AritExp : AritExp '+' AritExp  { }
        | AritExp '-' AritExp  { }
        | AritExp '*' AritExp  { }
        | AritExp '/' AritExp  { }
        | '-' AritExp          { }
        | '(' AritExp ')'      { }
        | NAME                 { }
        | NUM                  { } 
        ;

%%

#include "lex.yy.c"


gint comp(gconstpointer a, gconstpointer b)
{
	return strcmp(a, b);
}


void writeStart(void)
{
	if (start == 0) {
		fprintf(fp, "\tstart\n");
		start = 1;
	}
}


void insertVarsTree(char* key, int value, int pushValue)
{
	if (g_tree_lookup_extended(varsTree, key, NULL, NULL) == FALSE) {
     	g_tree_insert(varsTree, key, (gpointer*)(intptr_t)value);
		fprintf(fp, "\tpushi %d\n", pushValue);
	}
	else {
		printf("error: multiple declarations of var %s\n", key);
		exit(1);
	}
}


void readInput(char* var, char* text) 
{
	int r = 0;

	writeStart();
	fprintf(fp, "\tpushs %s\n\twrites\n", text);
	
	if (strcmp(var, "") != 0) {
		if (g_tree_lookup_extended(varsTree, var, NULL, (gpointer*)&r) == TRUE) {
			fprintf(fp, "\tread\n\tatoi\n");
			fprintf(fp, "\tstoreg %d\n", r); 
		}
		else {
			printf("error: unrecognized token '%s'\n", var);
			exit(1); 
		}
	}
}


void writeOutput(char* var, char* text)
{
	int r = 0;

	writeStart();

	if (strcmp(var, "") != 0) {
		if (g_tree_lookup_extended(varsTree, var, NULL, (gpointer*)&r) == TRUE) {
			fprintf(fp, "\tpushg %d\n", r); 
			fprintf(fp, "\twritei\n");
		}
		else {
			printf("error: unrecognized token '%s'\n", var);
			exit(1); 
		}
	}
	else {
		fprintf(fp, "\tpushs \"%s\"\n", text);
		fprintf(fp, "\twrites\n");
	}
}


void writeCondLabel(void)
{
	if (condLabelWrited == 0) {
		fprintf(fp, "cond%d:\n", cond);
		condStack = push(condStack, cond++);
		condLabelWrited = 1;
	}
}


void writeCond(void)
{
	writeStart();
	writeCondLabel();
}


void writeOtherCond(void)
{
	writeStart();
	
	fprintf(fp, "otherCond%d: \n", top(condStack));
}


int yyerror(char* s)
{
	printf("error: %s\n", s);
	error = 1;
}


int main(int argc, char** argv)
{
	char* output;

	varsTree = g_tree_new(comp);

	if (argc == 2) {
		yyin = fopen(argv[1], "r");

		output = strtok(argv[1], ".");
		strcat(output, ".vm");
		fp = fopen(output, "w");
	}

	yyparse();

	if (error == 0) {
		fprintf(fp, "end:\tstop\n");
	}

	fclose(fp);
	g_tree_destroy(varsTree);
	destroyIntStack(condStack);

	return 0;
}
