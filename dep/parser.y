%{
        #include <stdio.h>
        #include <string>
        #include <vector>
        #include <math.h>
        #include "expression.h"
        #include "interface.h"
        #include "scanner.h"
        #undef yylex
        #define yylex interface.lexer->lex
%}

/* Bison settings */
%require "2.3"
%debug
%start start
%skeleton "lalr1.cc"
%name-prefix "beadando"
%define "parser_class_name" {Parser}
%locations
%initial-action {
    @$.begin.filename = @$.end.filename = &interface.streamname;
};
%parse-param { class Interface& interface }
%error-verbose

/* Custom variable types ( must be of static size ) */
%union
{
    int                         integerVal;
    double                      doubleVal;
    std::string*                stringVal;
    class CalcNode*             calcnode;
}


/* Tokens defines for the keywords */
%token                  END          0  "end of input"
%token                  EOL             "end of line"
%token <integerVal>     INT         "integer"
%token <doubleVal>      DOUBLE          "double"
%token <stringVal>      STR          "string"
%token                  PI
%token                  SIN
%token                  COS
%token                  SQRT

/* Types defines for terminal expressions */
%type <calcnode> number
%type <calcnode> atom
%type <calcnode> power
%type <calcnode> unary
%type <calcnode> multiple
%type <calcnode> add
%type <calcnode> expr

/* Preventing memory leaks in non-terminal expressions. */
%destructor { delete $$; } STR
%destructor { delete $$; } number
%destructor { delete $$; } atom
%destructor { delete $$; } power
%destructor { delete $$; } unary
%destructor { delete $$; } multiple
%destructor { delete $$; } add
%destructor { delete $$; } expr

/* The rules */
%%
number : INT
           {
               $$ = new Constant($1);
           }
         | DOUBLE
           {
               $$ = new Constant($1);
           }
;

atom : number
        {
            $$ = $1;
        }
        | '(' expr ')'
        {
            $$ = $2;
        }
        | PI
        {
            $$ = new Pi();
        }
;

power : atom
          {
              $$ = $1;
          }
        | atom '^' power
          {
              $$ = new Power($1, $3);
          }
;

unary : power
            {
                $$ = $1;
            }
          | '+' power
            {
                $$ = $2;
            }
          | '-' power
            {
                $$ = new Negate($2);
            }
          | '!' power
            {
                $$ = new Factor($2);
            }
;

multiple : unary
          {
              $$ = $1;
          }
        | multiple '*' unary
          {
              $$ = new Multiply($1, $3);
          }
        | multiple '/' unary
          {
              $$ = new Divide($1, $3);
          }
        | multiple '%' unary
          {
              $$ = new Modulo($1, $3);
          }
;

add : multiple
          {
              $$ = $1;
          }
        | add '+' multiple
          {
              $$ = new Add($1, $3);
          }
        | add '-' multiple
          {
              $$ = new Subtract($1, $3);
          }
;

expr    : add
        {
        $$ = $1;
        }
        | SIN '(' expr ')'
        {
            $$ = new Sin($3);
        }
        | COS '(' expr ')'
        {
            $$ = new Cos($3);
        }
        | SQRT '(' expr ')'
        {
            $$ = new Sqrt($3);
        }
;

start   : /* empty */
        | start ';'
        | start EOL
        | start expr ';'
          {
              interface.calc.expressions.push_back($2);
          }
        | start expr EOL
          {
              interface.calc.expressions.push_back($2);
          }
        | start expr END
          {
              interface.calc.expressions.push_back($2);
          }
;
%%

void beadando::Parser::error(const Parser::location_type& l, const std::string& m)
{
    interface.error(l, m);
}
