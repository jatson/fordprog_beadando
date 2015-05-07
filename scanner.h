#ifndef SCANNER_H
#define SCANNER_H

// Flex expects the signature of yylex to be defined in the macro YY_DECL, and
// the C++ parser expects it to be declared. We can factor both as follows.

#ifndef YY_DECL

#define YY_DECL                                        \
    asd::Parser::token_type                         \
    asd::Scanner::lex(                              \
        asd::Parser::semantic_type* yylval,         \
        asd::Parser::location_type* yylloc          \
    )
#endif

#ifndef __FLEX_LEXER_H
#define yyFlexLexer asdFlexLexer
#include "FlexLexer.h"
#undef yyFlexLexer
#endif

#include "parser.h"

namespace asd
{

    class Scanner : public asdFlexLexer
    {
    public:
        Scanner(std::istream* arg_yyin = 0,
                std::ostream* arg_yyout = 0);

        virtual ~Scanner();

        virtual Parser::token_type lex(
            Parser::semantic_type* yylval,
            Parser::location_type* yylloc
            );

        void set_debug(bool b);
    };

}


#endif // SCANNER_H
