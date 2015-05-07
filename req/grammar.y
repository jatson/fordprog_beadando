%baseclass-preinclude <iostream>

%token IDENTIFIER COMMA OPENING_PAREN CLOSING_PAREN SEMICOLON

%%

start:
        declarationList         { std::cout << "Processing start symbol." << std::endl; }
;

declarationList:

|
        declaration declarationList
;

declaration:
        IDENTIFIER IDENTIFIER OPENING_PAREN parameterList CLOSING_PAREN SEMICOLON
|
        IDENTIFIER IDENTIFIER OPENING_PAREN error CLOSING_PAREN SEMICOLON
        {
                std::cout << "Error in parameter list." << std::endl;
        }
;

parameterList:

|
        parameter parameterTail
;

parameterTail:

|
        COMMA parameter parameterTail
;

parameter:
        IDENTIFIER IDENTIFIER
;