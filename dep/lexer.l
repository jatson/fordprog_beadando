%{
    #include <string>
    #include "scanner.h"
    #include <QString>

    typedef beadando::Parser::token token;
    typedef beadando::Parser::token_type token_type;

    /* Some settings wich needed for correct run */
    #define yyterminate() return token::END
    #define YY_NO_UNISTD_H
    #define YY_USER_ACTION  yylloc->columns(yyleng);
%}

/* Flex settings */
%option c++
%option prefix="beadando"
%option debug
%option yywrap nounput
%option stack

/* Regular expr. */
%%


%{/* ez a kódrészlet a yylex() elejére kerül */
    // pozíció alaphelyzetbe állítása
    yylloc->step();
%}

 /* Int */
[0-9]+ {
    yylval->integerVal = atoi(yytext);
    return token::INT;
}

 /* Float num */
-?([0-9]+\.[0-9]+|\.[0-9]+|[0-9]+\.) {
    yylval->doubleVal = QString(yytext).toDouble();
    return token::DOUBLE;
}

"pi" {
    return token::PI;
}

"PI" {
    return token::PI;
}

"sqrt" {
    return token::SQRT;
}

"SQRT" {
    return token::SQRT;
}

"sin" {
    return token::SIN;
}

"cos" {
    return token::COS;
}

"SIN" {
    return token::SIN;
}

"COS" {
    return token::COS;
}

[A-Za-z][A-Za-z0-9_,.-]* {
    yylval->stringVal = new std::string(yytext, yyleng);
    return token::STR;
}

 /* Whitespace */
[ \t\r]+ {
    yylloc->step();
}

 /* line endings */
\n {
     yylloc->lines(yyleng); yylloc->step();
     return token::EOL;
 }

 /* other characters */
. {
    return static_cast<token_type>(*yytext);
 }

%%

 namespace beadando
 {
     Scanner::Scanner(std::istream* in, std::ostream* out) : beadandoFlexLexer(in, out) {}
     Scanner::~Scanner() {}
     void Scanner::set_debug(bool b) { yy_flex_debug = b; }

 }

 /* add beadandoFlexLexer to the virtual function table */

#ifdef yylex
#undef yylex
#endif

 int beadandoFlexLexer::yylex() {
     std::cerr << "in beadandoFlexLexer::yylex() !" << std::endl;
     return 0;
 }

 int beadandoFlexLexer::yywrap() {
     return 1;
 }
