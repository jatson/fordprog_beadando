#include "mainwindow.h"
#include "ui_mainwindow.h"

MainWindow::MainWindow(QWidget *parent) :
    QMainWindow(parent),
    ui(new Ui::MainWindow)
{
    ui->setupUi(this);

    calc = new CalcContext();
    driver = new asd::Driver(*calc);

}

MainWindow::~MainWindow()
{
    delete ui;
}

void MainWindow::on_pushButton_clicked()
{
   QString input = ui->inputLineEdit->text();
   if(input.isEmpty() || input.isNull()) ui->outputTextEdit->append("Input is null or empty.");
   else
   {
       calc->clearExpressions();
       if(driver->parse_string(input.toStdString(), "input"))
       {
           for (unsigned int i = 0; i < calc->expressions.size(); ++i)
           {
               treel_out.str("");
               calc->expressions[i]->print(treel_out);
               qDebug() << "Latest:\n" << QString::fromStdString(treel_out.str());

               ui->outputTextEdit->append(QString("Result: ").append(QString::number(calc->expressions[i]->evaluate())));
           }
       }
   }
}

void MainWindow::on_inputLineEdit_returnPressed()
{
    on_pushButton_clicked();
}
