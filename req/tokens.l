%option noyywrap c++

%{
#include "Parser.h"
%}

LETTER          [a-zA-Z]
NUMBER          [0-9]
WHITESPACE      [ \t\n]

%%
("_"|{LETTER})("_"|{LETTER}|{NUMBER})*          return Parser::IDENTIFIER;
","                                             return Parser::COMMA;
"("                                             return Parser::OPENING_PAREN;
")"                                             return Parser::CLOSING_PAREN;
";"                                             return Parser::SEMICOLON;

{WHITESPACE}+                                   // Skip.

%%