#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QMainWindow>
#include <QtWidgets/QMainWindow>
#include <QDebug>
#include <QHBoxLayout>
#include <QPushButton>
#include <QCheckBox>
#include <QRadioButton>
#include <QMessageBox>
#include <QPlainTextEdit>
#include <QLabel>
#include <QPushButton>
#include <QVBoxLayout>
#include <QDebug>
#include <QLineEdit>
#include <QTableWidget>
namespace Ui {
class MainWindow;
}

class MainWindow : public QMainWindow
{
    Q_OBJECT

public:
    explicit MainWindow(QWidget *parent = nullptr);
    ~MainWindow();

private slots:
    void on_makesure_clicked();
    void load();
    void newgraph();
    void removegraph();
    void save();
//signals:
//
//public slots :
   void on_KNN_clicked();

   void on_SSSP_clicked();

   void on_PageRank_clicked();

private:
    Ui::MainWindow *ui;
    QLineEdit *input_nodename;
    QTextEdit *output;
    QLineEdit *input_nodelabel;
    QTableWidget *tabel_text;
};

#endif // MAINWINDOW_H
