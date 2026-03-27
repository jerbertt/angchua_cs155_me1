%{
#include <stdio.h>
#include <stdlib.h>
#include <math.h>

void yyerror(const char *msg);
int yylex(void);

// created a global depth and helper function 
int depth = 0;
void indent(int d) {
    for (int i = 0; i < d; i++) printf("  ");
}

%}

%union {
int ival;
double fval;
}

%token <ival> NUM
%token <fval> FNUM /* for FNUM support in calc.l */
%token PLUS MINUS TIMES DIVIDE LPAREN RPAREN POW /* added POW */

%left PLUS MINUS
%left TIMES DIVIDE
%right UMINUS
%right POW /* made POW right associative */

%type <ival> expr term factor

%%

program:
    program helper
    | 
    ;

helper:
    /* top root prints first */
    { printf("expr\n"); depth++; } expr '\n' { depth--; }
    | '\n'
    ;

/* each rule starts with printing its own name */
expr:
    { indent(depth++); printf("expr\n"); } term helper_expr { depth--; }
    ;

helper_expr:
    PLUS { indent(depth); printf("+\n"); } expr
    | MINUS { indent(depth); printf("-\n"); } expr
    | 
    ;

term:
    { indent(depth++); printf("term\n"); } factor helper_term { depth--; }
    ;

helper_term:
    TIMES { indent(depth); printf("*\n"); } term
    | DIVIDE { indent(depth); printf("/\n"); } term
    | 
    ;

factor:
    { indent(depth++); printf("factor\n"); } NUM 
    { indent(depth); printf("%d\n", $2); depth--; }
    | { indent(depth++); printf("factor\n"); } FNUM 
    { indent(depth); printf("%g\n", $2); depth--; }
    | LPAREN { indent(depth++); printf("(\n"); } expr RPAREN 
    { indent(depth); printf(")\n"); depth--; }
    | MINUS { indent(depth++); printf("-\n"); } factor 
    { depth--; }
    ;

%%
void yyerror(const char *msg) {
    fprintf(stderr, "Parse error: %s\n", msg);
}

int main(void) {
    return yyparse();
}
