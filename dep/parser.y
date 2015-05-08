%{
        #include <stdio.h>
        #include <string>
        #include <vector>
        #include <math.h>
        #include "expression.h"
        #include "driver.h"
        #include "scanner.h"
        #undef yylex
        #define yylex driver.lexer->lex
%}

/* Bison settings */
%require "2.3"
%debug
%start start
%skeleton "lalr1.cc"
%name-prefix "asd"
%define "parser_class_name" {Parser}
%locations
%initial-action {
    @$.begin.filename = @$.end.filename = &driver.streamname;
};
%parse-param { class Driver& driver }
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
%token <integerVal>     INTEGER         "integer"
%token <doubleVal>      DOUBLE          "double"
%token <stringVal>      STRING          "string"
%token                  PI
%token                  SIN
%token                  COS
%token                  SQRT

/* Types defines for terminal expressions */
%type <calcnode> constant
%type <calcnode> atomexpr
%type <calcnode> powexpr
%type <calcnode> unaryexpr
%type <calcnode> mulexpr
%type <calcnode> addexpr
%type <calcnode> expr

/* Preventing memory leaks in non-terminal expressions. */
%destructor { delete $$; } STRING
%destructor { delete $$; } constant
%destructor { delete $$; } atomexpr
%destructor { delete $$; } powexpr
%destructor { delete $$; } unaryexpr
%destructor { delete $$; } mulexpr
%destructor { delete $$; } addexpr
%destructor { delete $$; } expr

/* The rules */
%%
constant : INTEGER
           {
               $$ = new Constant($1);
           }
         | DOUBLE
           {
               $$ = new Constant($1);
           }
;

atomexpr : constant
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

powexpr : atomexpr
          {
              $$ = $1;
          }
        | atomexpr '^' powexpr
          {
              $$ = new Power($1, $3);
          }
;

unaryexpr : powexpr
            {
                $$ = $1;
            }
          | '+' powexpr
            {
                $$ = $2;
            }
          | '-' powexpr
            {
                $$ = new Negate($2);
            }
          | '!' powexpr
            {
                $$ = new Factor($2);
            }
;

mulexpr : unaryexpr
          {
              $$ = $1;
          }
        | mulexpr '*' unaryexpr
          {
              $$ = new Multiply($1, $3);
          }
        | mulexpr '/' unaryexpr
          {
              $$ = new Divide($1, $3);
          }
        | mulexpr '%' unaryexpr
          {
              $$ = new Modulo($1, $3);
          }
;

addexpr : mulexpr
          {
              $$ = $1;
          }
        | addexpr '+' mulexpr
          {
              $$ = new Add($1, $3);
          }
        | addexpr '-' mulexpr
          {
              $$ = new Subtract($1, $3);
          }
;

expr    : addexpr
          {
              $$ = $1;
          }
;

start   : /* empty */
        | start ';'
        | start EOL
        | start expr ';'
          {
              driver.calc.expressions.push_back($2);
          }
        | start expr EOL
          {
              driver.calc.expressions.push_back($2);
          }
        | start expr END
          {
              driver.calc.expressions.push_back($2);
          }
;
%%

void asd::Parser::error(const Parser::location_type& l, const std::string& m)
{
    driver.error(l, m);
}
