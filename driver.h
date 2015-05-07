#ifndef DRIVER_H
#define DRIVER_H

#include <string>
#include <vector>
#include <QDebug>

class CalcContext;

namespace asd
{

    class Driver
    {
    public:
        Driver(class CalcContext& calc);

        bool trace_scanning;
        bool trace_parsing;
        std::string streamname;

        bool parse_stream(std::istream& in, const std::string& sname = "stream input");
        bool parse_string(const std::string& input, const std::string& sname = "string stream");
        bool parse_file(const std::string& filename);

        QString error(const class location& l, const std::string& m);
        QString error(const std::string& m);

        class Scanner* lexer;
        class CalcContext& calc;
    };

}

#endif // DRIVER_H
