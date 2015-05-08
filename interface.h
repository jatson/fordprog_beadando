#ifndef DRIVER_H
#define DRIVER_H

#include <string>
#include <vector>
#include <QDebug>

class Calculator;

namespace beadando
{

    class Interface
    {
    public:
        Interface(class Calculator& calc);

        bool trace_scanning;
        bool trace_parsing;
        std::string streamname;

        bool parse_stream(std::istream& in, const std::string& sname = "stream input");
        bool parse_string(const std::string& input, const std::string& sname = "string stream");
        bool parse_file(const std::string& filename);

        QString error(const class location& l, const std::string& m);
        QString error(const std::string& m);

        class Scanner* lexer;
        class Calculator& calc;
    };

}

#endif // DRIVER_H
