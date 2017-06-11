%{
	#include <stdio.h>
	#include <string.h>
     #include <stdint.h>
	#include <glib.h>
	#include "intStack.h"
	#include "stringStack.h"


	#define EXP_SIZE 1024
	

	gint comp(gconstpointer, gconstpointer);
	void writeStart(void);
	void insertVarsTree(char*, int, int);
	void readInput(char*, char*);
	void writeOtherCond(void);
	char* getAritVar(char*);

	typedef struct var {
        int value;
        char* name;
	} var;

	GTree* varsTree;
	int start = 0;
	int error = 0;
	int reg = 0;
	int cond = 0;
	int loop = 0;
	int loopExpressions = 0;
	FILE* fp;
	IntStack condStack = NULL;
	IntStack loopStack = NULL;
	StringStack lExpStack = NULL;	

	char aritExpression[EXP_SIZE] = "";
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
%token <str> MOD

%type <str> Var 
%type <str> Input
%type <str> Output
%type <str> OutArgs
%type <str> Cond
%type <str> OtherCond
%type <str> CondExp
%type <str> LoopExp;
%type <str> AritExp
%type <str> Loop
%type <str> LoopBegin
%type <str> CondBegin
%type <str> OtherCondBegin
%type <str> ModExp

%left '(' 
%left '|'
%left '&'
%left '+' '-'
%left '*' '/'

%%

Lines :  { }
      |  Var ';' Lines
      |  Input Lines
      |  Output Lines
      |  Cond Lines 
      |  Loop Lines
      ;

Var : NAME              { insertVarsTree($1, reg++, 0); }
    | NAME '[' NUM ']'  { fprintf(fp, "\tpushn %d\n", $3); }
    | NAME '=' NUM      { if (start == 0) { 
                          	insertVarsTree($1, reg++, $3);
                          }
                          else {
                          	fprintf(fp, "\tpushi %d\n\tstoreg %d\n", $3, getVarReg($1));
	                     }
		              }
    | NAME '[' NUM ']' '=' NUM  {  }
    | NAME '=' AritExp  { if (loopExpressions < loop) {
						loopExpressions++;
                          	lExpStack = pushString(lExpStack, getAtrib($3, getVarReg($1)));
                              $$ = strdup(getAtrib($3, getVarReg($1)));
					 }
					 else { 
						fprintf(fp, "%s", getAtrib($3, getVarReg($1))); 
                          } 
                        }
    | NAME '[' NUM ']' '=' AritExp  {  }
    | NAME '[' NAME ']' '=' AritExp { fprintf(fp, "\tpushgp\n\tpushi 2\n\tpadd\n\tpushg %d\n%s\tstoren\n", getVarReg($3), $6); }
    ;

Input : READ '(' TEXT ')' ';'			{ readInput("", $3); }
	 | NAME '=' READ '(' TEXT ')' ';'	{ readInput($1, $5); }  
      | NAME '[' NAME ']' '=' READ '(' TEXT ')' ';' { 
                 fprintf(fp, "\tpushgp\n\tpushi 2\n\tpadd\n\tpushg %d\n", getVarReg($3));
                 fprintf(fp, "\tpushs %s\n\twrites\n\tread\n\tatoi\n\tstoren\n", $8);              
      }              
	 ;

Output : WRITE '(' OutArgs ')' ';' { }
	  ;

OutArgs : OutArgs '+' OutArgs { }
        | NAME '[' NAME ']'   { fprintf(fp, "\tpushgp\n\tpushi 2\n\tpadd\n\tpushg %d\n\tloadn\n\twritei\n", getVarReg($3)); }
	   | NAME 		     { writeOutput($1, ""); }
	   | TEXT	               { writeOutput("", $1); }
	   ;


Loop : LoopBegin '(' Var ';' LoopExp ';' Var ')' '{' Lines '}' { fprintf(fp, "%s%s%s\tjz endLoop%d\n\tjump loop%d\nendLoop%d:\n", $3, $7, $5, topInt(loopStack), topInt(loopStack), topInt(loopStack)); loopStack = popInt(loopStack); lExpStack = popString(lExpStack); }
     | LoopBegin '(' LoopExp ';' Var ')' '{' Lines '}' { fprintf(fp, "%s%s\tjz endLoop%d\n\tjump loop%d\nendLoop%d:\n", $5, $3, topInt(loopStack), topInt(loopStack), topInt(loopStack)); loopStack = popInt(loopStack); lExpStack = popString(lExpStack); }
     | LoopBegin '(' LoopExp ')' '{' Lines '}' { fprintf(fp, "%s\tjz endLoop%d\n\tjump loop%d\nendLoop%d:\n", $3, topInt(loopStack), topInt(loopStack), topInt(loopStack)); loopStack = popInt(loopStack); lExpStack = popString(lExpStack); }
     ; 
     

LoopBegin : LOOP { writeStart(); fprintf(fp, "loop%d:\n", loop); loopStack = pushInt(loopStack, loop++); }
          ;


Cond : CondBegin '(' CondExp ')' '{' Lines '}' { fprintf(fp, "\tjump endCond%d\n", topInt(condStack)); }
     | Cond OtherCond                          { }
     ;

CondBegin : CASE { writeCondLabel(); }
          ;


OtherCond : OtherCondBegin '{' Lines '}' { fprintf(fp, "endCond%d:\n", topInt(condStack)); condStack = popInt(condStack); }
          | OtherCondBegin Cond          { }
          ;


OtherCondBegin : OTHERWISE { writeOtherCond(); }
               ;

CondExp : AritExp '<' AritExp     { fprintf(fp, "%s%s\tinf\n\tjz otherCond%d\n", $1, $3, topInt(condStack)); }
        | AritExp '>' AritExp     { fprintf(fp, "%s%s\tsup\n\tjz otherCond%d\n", $1, $3, topInt(condStack)); }
        | AritExp '<' '=' AritExp { fprintf(fp, "%s%s\tinfeq\n\tjz otherCond%d\n", $1, $4, topInt(condStack)); }
        | AritExp '>' '=' AritExp { fprintf(fp, "%s%s\tsupeq\n\tjz otherCond%d\n", $1, $4, topInt(condStack)); } 
        | AritExp '=' '=' AritExp { fprintf(fp, "%s%s\tequal\n\tjz otherCond%d\n", $1, $4, topInt(condStack)); }
        | AritExp '!' '=' AritExp { fprintf(fp, "%s%s\tequal\n\tjnz otherCond%d\n", $1, $4, topInt(condStack)); }
        | ModExp                  { fprintf(fp, "%s\tjz otherCond%d\n", $1, topInt(condStack)); }
        | CondExp '&' CondExp     { }
        | CondExp '|' CondExp     { }
        ;

LoopExp : AritExp '<' AritExp     { strcpy($$, getLoopExp("\tinf\n", $1, $3)); }
        | AritExp '>' AritExp     { strcpy($$, getLoopExp("\tsup\n", $1, $3)); }
        | AritExp '<' '=' AritExp { strcpy($$, getLoopExp("\tinfeq\n", $1, $4)); }
        | AritExp '>' '=' AritExp { strcpy($$, getLoopExp("\tsupeq\n", $1, $4)); } 
        | AritExp '=' '=' AritExp { strcpy($$, getLoopExp("\tequal\n", $1, $4)); }
        | AritExp '!' '=' AritExp { strcpy($$, getLoopExp("\tdiff\n", $1, $4)); }
        | LoopExp '&' LoopExp     { }
        | LoopExp '|' LoopExp     { }
        ;

AritExp : AritExp '+' AritExp  { sprintf($$, "%s%s\tadd\n", $1, $3); }
        | AritExp '-' AritExp  { sprintf($$, "%s%s\tsub\n", $1, $3); }
        | AritExp '*' AritExp  { sprintf($$, "%s%s\tmul\n", $1, $3); }
        | AritExp '/' AritExp  { sprintf($$, "%s%s\tdiv\n", $1, $3); }
        | '-' AritExp          { }
        | '(' AritExp ')'      { }
        | NAME                 { $$ = strdup(getAritVar($1)); }
        | NUM                  { $$ = strdup(getAritNum($1)); } 
        | NAME '[' NAME ']'    { $$ = strdup(getArrayVar($3)); }
        ;

ModExp: | AritExp MOD AritExp  { sprintf($$, "%s%s\tmod\n", $1, $3); }
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
	fprintf(fp, "cond%d:\n", cond);
	condStack = pushInt(condStack, cond++);
}


void writeOtherCond(void)
{
	fprintf(fp, "otherCond%d:\n", topInt(condStack));
}


char* getAritVar(char* key)
{
	int r = 0;

	aritExpression[0] = '\0';

	if (g_tree_lookup_extended(varsTree, key, NULL, (gpointer*)&r) == TRUE) {
		sprintf(aritExpression, "\tpushg %d\n", r);
	}
	else {
		printf("error: unrecognized token '%s'\n", key);
		exit(1);
	}

	return aritExpression;
}


char* getAritNum(int n)
{
	aritExpression[0] = '\0';

	sprintf(aritExpression, "\tpushi %d\n", n);

	return aritExpression;
}


int getVarReg(char* var)
{
	int r = 0;

	if (g_tree_lookup_extended(varsTree, var, NULL, (gpointer*)&r) == TRUE);
	
	return r;
}


char* getAtrib(char* op, int n)
{
	aritExpression[0] = '\0';

	sprintf(aritExpression, "%s\tstoreg %d\n", op, n);

	return aritExpression;
}


char* getArrayVar(char* key)
{
	int r = 0;

	aritExpression[0] = '\0';

	if (g_tree_lookup_extended(varsTree, key, NULL, (gpointer*)&r) == TRUE) {
		sprintf(aritExpression, "\tpushgp\n\tpushi 2\n\tpadd\n\tpushg %d\n\tloadn\n", r);
	}
	else {
		printf("error: unrecognized token '%s'\n", key);
		exit(1);
	}

	return aritExpression;
}


char* getLoopExp(char* op, char* exp1, char* exp2)
{
	aritExpression[0] = '\0';

	strcat(aritExpression, exp1);
	strcat(aritExpression, exp2);
	strcat(aritExpression, op);

	return aritExpression;
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
	destroyStringStack(lExpStack);

	return 0;
}

