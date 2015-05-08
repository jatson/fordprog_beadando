%{
    #include <string>
    #include "scanner.h"
    #include <QString>

    typedef asd::Parser::token token;
    typedef asd::Parser::token_type token_type;

    /* Some settings wich needed for correct run */
    #define yyterminate() return token::END
    #define YY_NO_UNISTD_H
    #define YY_USER_ACTION  yylloc->columns(yyleng);
%}

/* Flex settings */
%option c++
%option prefix="asd"
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
    return token::INTEGER;
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
    return token::STRING;
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

 /* a többi karaktert adjuk át a "kedves" bison-nak. */
. {
    return static_cast<token_type>(*yytext);
 }

%%

 namespace asd {

     // Scanner Osztályhoz tartozik még:

     Scanner::Scanner(std::istream* in, std::ostream* out) : asdFlexLexer(in, out) {}

     Scanner::~Scanner() {}

     void Scanner::set_debug(bool b) {
         yy_flex_debug = b;
     }

 }

 /* Ez a ExampleFlexLexer::yylex() implementáció szükséges ahhoz, hogy bekerüljön az asdFlexLexer osztály
  * virtuális függvénytáblájába helyesen. Definiáljuk a scanner fő yylex függvényét egy YY_DECL-el
  * hogy a Scanner osztályban maradjon. */

#ifdef yylex
#undef yylex
#endif

 int asdFlexLexer::yylex() {
     std::cerr << "in asdFlexLexer::yylex() !" << std::endl;
     return 0;
 }

 /* Amikor a scanner enf-of-file jelzést kap a YY_INPUT-ról, megnézi a yywrap() függvényt.
  * Ha a yywrap() hamisat ad vissza (0), akkor a függvény már előre beállította a 'yyin'-t hogy
  * egy következő bemeneti fájlra mutasson, majd a szkennelés folytatódik. Ha igazat ad vissza (nem 0),
  * akkor a szkennelés megszakad, 0-t adva vissza a hívójának. */
 int asdFlexLexer::yywrap() {
     return 1;
 }
