#include <fstream>
#include <sstream>

#include "driver.h"
#include "scanner.h"

namespace asd
{

    Driver::Driver(class CalcContext& _calc) : trace_scanning(false),trace_parsing(false),calc(_calc) {}

    bool Driver::parse_stream(std::istream& in, const std::string& sname)
    {
        streamname = sname;

        Scanner scanner(&in);
        scanner.set_debug(trace_scanning);
        this->lexer = &scanner;

        Parser parser(*this);
        parser.set_debug_level(trace_parsing);
        return (parser.parse() == 0);
    }

    bool Driver::parse_file(const std::string &filename)
    {
        std::ifstream in(filename.c_str());
        if (!in.good()) return false;
        return parse_stream(in, filename);
    }

    bool Driver::parse_string(const std::string &input, const std::string& sname)
    {
        std::istringstream iss(input);
        return parse_stream(iss, sname);
    }

    QString Driver::error(const class location& l, const std::string& m)
    {
        std::string err_str = (int) l.begin.column + ": " + m;
        qDebug() << QString::fromStdString(err_str);
        return QString::fromStdString(err_str);
    }

    QString Driver::error(const std::string& m)
    {
        std::string err_str = m;
        qDebug() << QString::fromStdString(err_str);
        return QString::fromStdString(err_str);
    }

}
