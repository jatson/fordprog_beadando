#ifndef EXPRESSION_H
#define EXPRESSION_H

#include <map>
#include <vector>
#include <ostream>
#include <stdexcept>
#include <cmath>
#include <math.h>
#include <qmath.h>

class CalcNode
{
public:
    virtual ~CalcNode() {}
    virtual double evaluate() const = 0;
    virtual void print(std::ostream &os, unsigned int depth=0) const = 0;
    static inline std::string indent(unsigned int d) { return std::string(d * 2, ' '); }
};

class Constant : public CalcNode
{
    double value;

public:
    explicit Constant(double _value):CalcNode(), value(_value){}
    virtual double evaluate() const { return value; }
    virtual void print(std::ostream &os, unsigned int depth) const { os << indent(depth) << value << std::endl; }
};

class Pi: public CalcNode
{
    double value;

public:
    explicit Pi():CalcNode(), value(M_PI){}
    virtual double evaluate() const { return value; }
    virtual void print(std::ostream &os, unsigned int depth) const { os << indent(depth) << value << std::endl; }
};

class Sin : public CalcNode
{
    CalcNode* node;

public:
    explicit Sin(CalcNode* _node) : CalcNode(), node(_node) {}
    virtual ~Sin() { delete node; }
    virtual double evaluate() const { return qSin(node->evaluate()); }
    virtual void print(std::ostream &os, unsigned int depth) const
    {
        os << indent(depth) << "sin() szinus" << std::endl;
        node->print(os, depth+1);
    }
};

class Cos : public CalcNode
{
    CalcNode* node;

public:
    explicit Cos(CalcNode* _node) : CalcNode(), node(_node) {}
    virtual ~Cos() { delete node; }
    virtual double evaluate() const { return qCos(node->evaluate()); }
    virtual void print(std::ostream &os, unsigned int depth) const
    {
        os << indent(depth) << "cos() koszinus" << std::endl;
        node->print(os, depth+1);
    }
};

class Sqrt : public CalcNode
{
    CalcNode* node;

public:
    explicit Sqrt(CalcNode* _node) : CalcNode(), node(_node) {}
    virtual ~Sqrt() { delete node; }
    virtual double evaluate() const { return qSqrt(node->evaluate()); }
    virtual void print(std::ostream &os, unsigned int depth) const
    {
        os << indent(depth) << "sqrt() négyzetgyök" << std::endl;
        node->print(os, depth+1);
    }
};


class Negate : public CalcNode
{
    CalcNode* node;

public:
    explicit Negate(CalcNode* _node) : CalcNode(), node(_node) {}
    virtual ~Negate() { delete node; }
    virtual double evaluate() const { return - node->evaluate(); }
    virtual void print(std::ostream &os, unsigned int depth) const
    {
        os << indent(depth) << "- negálás" << std::endl;
        node->print(os, depth+1);
    }
};

class Factor : public CalcNode
{
    CalcNode* node;
    inline double factorial(double x) const { return (x == 1 ? x : x * factorial(x - 1)); }

public:
    explicit Factor(CalcNode * _node) : CalcNode(), node(_node) {}
    virtual ~Factor() { delete node; }
    virtual double evaluate() const { return factorial(node->evaluate()); }
    virtual void print(std::ostream &os, unsigned int depth) const
    {
        os << indent(depth) << "! faktor" << std::endl;
        node->print(os, depth+1);
    }
};

class Add : public CalcNode
{
    CalcNode*   left;
    CalcNode*   right;
public:
    explicit Add(CalcNode* _left, CalcNode* _right) : CalcNode(), left(_left), right(_right) {}
    virtual ~Add()
    {
        delete left;
        delete right;
    }
    virtual double evaluate() const { return left->evaluate() + right->evaluate(); }
    virtual void print(std::ostream &os, unsigned int depth) const
    {
        os << indent(depth) << "+ összeadás" << std::endl;
        left->print(os, depth+1);
        right->print(os, depth+1);
    }
};

class Subtract : public CalcNode
{
    CalcNode*   left;
    CalcNode*   right;

public:
    explicit Subtract(CalcNode* _left, CalcNode* _right) : CalcNode(), left(_left), right(_right) {}
    virtual ~Subtract()
    {
        delete left;
        delete right;
    }
    virtual double evaluate() const { return left->evaluate() - right->evaluate(); }
    virtual void print(std::ostream &os, unsigned int depth) const
    {
        os << indent(depth) << "- kivonás" << std::endl;
        left->print(os, depth+1);
        right->print(os, depth+1);
    }
};

class Multiply : public CalcNode
{
    CalcNode*   left;
    CalcNode*   right;

public:
    explicit Multiply(CalcNode* _left, CalcNode* _right) : CalcNode(), left(_left), right(_right) {}
    virtual ~Multiply()
    {
        delete left;
        delete right;
    }
    virtual double evaluate() const { return left->evaluate() * right->evaluate(); }
    virtual void print(std::ostream &os, unsigned int depth) const
    {
        os << indent(depth) << "* szorzás" << std::endl;
        left->print(os, depth+1);
        right->print(os, depth+1);
    }
};

class Divide : public CalcNode
{
    CalcNode*   left;
    CalcNode*   right;

public:
    explicit Divide(CalcNode* _left, CalcNode* _right) : CalcNode(), left(_left), right(_right) {}
    virtual ~Divide()
    {
        delete left;
        delete right;
    }
    virtual double evaluate() const { return left->evaluate() / right->evaluate(); }
    virtual void print(std::ostream &os, unsigned int depth) const
    {
        os << indent(depth) << "/ osztás" << std::endl;
        left->print(os, depth+1);
        right->print(os, depth+1);
    }
};

class Modulo : public CalcNode
{
    CalcNode*   left;
    CalcNode*   right;

public:
    explicit Modulo(CalcNode* _left, CalcNode* _right) : CalcNode(), left(_left), right(_right) {}
    virtual ~Modulo()
    {
        delete left;
        delete right;
    }
    virtual double evaluate() const { return std::fmod(left->evaluate(), right->evaluate()); }
    virtual void print(std::ostream &os, unsigned int depth) const
    {
        os << indent(depth) << "% moduló" << std::endl;
        left->print(os, depth+1);
        right->print(os, depth+1);
    }
};

class Power : public CalcNode
{
    CalcNode*   left;
    CalcNode*   right;

public:
    explicit Power(CalcNode* _left, CalcNode* _right) : CalcNode(), left(_left), right(_right) {}
    virtual ~Power()
    {
        delete left;
        delete right;
    }
    virtual double evaluate() const { return std::pow(left->evaluate(), right->evaluate()); }
    virtual void print(std::ostream &os, unsigned int depth) const
    {
        os << indent(depth) << "^ hatványozás" << std::endl;
        left->print(os, depth+1);
        right->print(os, depth+1);
    }
};

class CalcContext
{
public:
    std::vector<CalcNode*> expressions;
    ~CalcContext() { clearExpressions(); }
    void clearExpressions()
    {
        for(unsigned int i = 0; i < expressions.size(); ++i) delete expressions[i];
        expressions.clear();
    }
};

#endif // EXPRESSION_H
