%{ /*** C/C++ Deklarációk ***/

    #include <string>
    #include "scanner.h"
    #include <QString>

    /* behúzzuk a parser tokenjeit lokális típusokként */
    typedef asd::Parser::token token;
    typedef asd::Parser::token_type token_type;

    /* Alapértelmezésként a yylex() int-et ad vissza, de mi token_type-ot használunk.
         * Sajnos a yyterminate() alapértelmezésként 0-t ad vissza, de nekünk
         * token::END kell. */
    #define yyterminate() return token::END

    /* Kikapcsoljuk az unistd.h behúzását, amely nem elérhető Visual C++ alatt Windows platformon.
         * A C++ scanner használjon STL streameket! */
    #define YY_NO_UNISTD_H

%}

/*** Flex Deklarációk és beállítások ***/

/* Engedélyezzük a C++ scanner osztály generálását */
%option c++

/* Változtassuk meg a scanner osztály nevét, ezzel a beállítással "ExampleFlexLexer" nevű osztályt eredményezve. */
%option prefix="asd"

/* A flex manual-ja szerint, ez az opció végrehajt némi optimalizálást. */
%option batch

%option debug

/* no support for include files is planned */
%option yywrap nounput

/* Engedélyezi a kezdési feltételek stack-jét */
%option stack

/* A következő define gondoskodik a pozíciók pontos nyomonkövetéséről. Minden alkalommal,
* amikor az yylex() meghívódik, a kezdési pozíciót a végződési pozícióhoz mozgatjuk. */
%{
    #define YY_USER_ACTION  yylloc->columns(yyleng);
%}

%%/*** Reguláris kifejezések ***/


%{/* ez a kódrészlet a yylex() elejére kerül */
    // pozíció alaphelyzetbe állítása
    yylloc->step();
%}


[0-9]+ {
    yylval->integerVal = atoi(yytext);
    return token::INTEGER;
}

[0-9]+"."[0-9]* {
    yylval->doubleVal = QString(yytext).toDouble();
    return token::DOUBLE;
}

[A-Za-z][A-Za-z0-9_,.-]* {
    yylval->stringVal = new std::string(yytext, yyleng);
    return token::STRING;
}

 /* kezeljük le a white-spaceket */
[ \t\r]+ {
    yylloc->step();
}

 /* kezeljük le a sor végi lezárásokat */
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