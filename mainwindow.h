#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QMainWindow>
#include <QFileDialog>
#include <QMessageBox>
#include <QTextStream>
#include <iostream>
#include <sstream>

/* Generated Headers */
#include "lexer.h"
#include "parser.h"

/* Headers made by user */
#include "expression.h"
#include "interface.h"

namespace Ui {
class MainWindow;
}

class MainWindow : public QMainWindow
{
    Q_OBJECT

public:
    explicit MainWindow(QWidget *parent = 0);
    ~MainWindow();

private slots:
    void on_pushButton_clicked();

    void on_inputLineEdit_returnPressed();

    void on_actionOpen_Input_triggered();

private:
    Ui::MainWindow *ui;

    Calculator *calc;
    beadando::Interface *interface;
    std::stringstream treel_out;

    void parseInput(const QString & input);
};

#endif // MAINWINDOW_H
