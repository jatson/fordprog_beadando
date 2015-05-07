%{ /*** C/C++ Deklarációk ***/

        #include <stdio.h>
        #include <string>
        #include <vector>

        #include "expression.h"

%}

/*** yacc/bison Deklarációk ***/

/* Szükséges: bison 2.3 vagy későbbi */
%require "2.3"

/* Debug hozzáadása */
%debug

/* Kezdő szimbólum a "start" */
%start start

/* Használjuk az újabb C++ "váz" fájlt */
%skeleton "lalr1.cc"

/* Namespace, amiben a parser elhelyezkedik */
%name-prefix "asd"

/* A Parser osztály nevének beállítása */
%define "parser_class_name" {Parser}

/* kövessük nyomon a jelenlegi pozíciót a bemenetben */
%locations
%initial-action {
    // a kezdeti pozíció-objektum inicializálása
    @$.begin.filename = @$.end.filename = &driver.streamname;
};

/* A drivert referenciaként adjuk a parsernek és a scannernek,
 * ezáltal egyszerű és hatékony tiszta interfészt használunk és
 * nem hagyatkozunk globális változókra. */
%parse-param { class Driver& driver }

/* Verbose hibaüzenetek */
%error-verbose

%union {
    int                         integerVal;
    double                      doubleVal;
    std::string*                stringVal;
    class CalcNode*             calcnode;
}

// Tokenek:

%token                  END          0  "end of input"
%token                  EOL             "end of line"
%token <integerVal>     INTEGER         "integer"
%token <doubleVal>      DOUBLE          "double"
%token <stringVal>      STRING          "string"

%type <calcnode>        constant
%type <calcnode>        atomexpr powexpr unaryexpr mulexpr addexpr expr

%destructor { delete $$; } STRING
%destructor { delete $$; } constant
%destructor { delete $$; } atomexpr powexpr unaryexpr mulexpr addexpr expr

%{

#include "driver.h"
#include "scanner.h"

/* "Összekötjük" a bison parser-t a diver-ből a flex scanner osztállyal.
 *  Definiáljuk a yylex() függvényhívást, hogy húzza be a következő tokent
 *  a driver lexer részéből. */
#undef yylex
#define yylex driver.lexer->lex

%}
%%

constant : INTEGER
           {
               $$ = new Constant($1);
           }
         | DOUBLE
           {
               $$ = new Constant($1);
           }

atomexpr : constant
           {
               $$ = $1;
           }
         | '(' expr ')'
           {
               $$ = $2;
           }

powexpr : atomexpr
          {
              $$ = $1;
          }
        | atomexpr '^' powexpr
          {
              $$ = new Power($1, $3);
          }

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

expr    : addexpr
          {
              $$ = $1;
          }

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

%%

void asd::Parser::error(const Parser::location_type& l, const std::string& m) {
    driver.error(l, m);
}
