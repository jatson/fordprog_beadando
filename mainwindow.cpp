#include "mainwindow.h"
#include "ui_mainwindow.h"

MainWindow::MainWindow(QWidget *parent) :
    QMainWindow(parent),
    ui(new Ui::MainWindow)
{
    ui->setupUi(this);

    calc = new Calculator();
    interface = new beadando::Interface(*calc);

}

MainWindow::~MainWindow()
{
    delete ui;
}

void MainWindow::on_pushButton_clicked()
{
   QString input = ui->inputLineEdit->text();
   parseInput(input);
}

void MainWindow::on_inputLineEdit_returnPressed()
{
    on_pushButton_clicked();
}

void MainWindow::on_actionOpen_Input_triggered()
{
    QString path = QDir::homePath();
    QString fn = QFileDialog::getOpenFileName(
                this,
                tr("Open Text File"),
                path,
                tr("Text files (*.txt);;All files (*.*)"));

    if(!fn.isEmpty())
    {
        QFile file(fn);
        if (!file.open(QFile::ReadOnly | QFile::Text))
        {
            QMessageBox mb(QMessageBox::Critical, tr("Unable to Open"), tr("Unable to open the text file!"));
            mb.exec();
        }
        else
        {
            QTextStream in(&file);
            QString text;
            text = in.readAll();
            file.close();

            parseInput(text);
        }
    }
    else
    {
        QMessageBox mb(QMessageBox::Critical, tr("Unable to Open"), tr("Unable to open the text file!"));
        mb.exec();
    }
}

void MainWindow::parseInput(const QString &input)
{
    if(input.isEmpty() || input.isNull()) ui->outputTextEdit->append("Input is null or empty.");
    else
    {
        calc->clearExpressions();
        if(interface->parse_string(input.toStdString(), "input"))
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
