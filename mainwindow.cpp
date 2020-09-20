#include "mainwindow.h"
#include "ui_mainwindow.h"
#include <QMessageBox>
#include <QPlainTextEdit>
#include <QLabel>
#include <QPushButton>
#include <QVBoxLayout>
#include <QDebug>
#include <QLineEdit>
#include <QFileDialog>
#include <QMenu>
#include <QMenuBar>
#include <QAction>


MainWindow::MainWindow(QWidget *parent) :
    QMainWindow(parent),
    ui(new Ui::MainWindow)
{
    ui->setupUi(this);

    //resize(300,200);
        //菜单栏
    QMenuBar *mBar = menuBar();

        //添加菜单
    //QMenu *pFile = mBar->addMenu("文件(F)");
    QMenu *menu= new QMenu("Document(F)");
    //menu->setIcon(QIcon(QPixmap(":/image/image/dec.png")));
    QAction* load = new QAction(QIcon(QPixmap(":/image/image/load.png")), "load");
    menu->addAction(load);
    QAction* newgraph = new QAction(QIcon(QPixmap(":/image/image/new.png")), "new garph");
    menu->addAction(newgraph);
    QAction* removegraph = new QAction(QIcon(QPixmap(":/image/image/remove.png")), "remove graph");
    menu->addAction(removegraph);
    QAction* save = new QAction(QIcon(QPixmap(":/image/image/save.png")), "save");
    menu->addAction(save);
    mBar->addMenu(menu);


    QWidget *node = new QWidget(this);
    QWidget *relation = new QWidget(this);
    ui->InputTab->setIconSize(QSize(25, 25));//设置图标的大小(选项卡的大小也会改变)
    ui->InputTab ->setTabPosition(QTabWidget::North);//设置选项卡的方位，默认在上方(东南西北)
    ui->InputTab->addTab(node, QIcon(":/image/image/node.png"), tr("node"));//在后面添加带图标的选项卡
    ui->InputTab->addTab(relation, QIcon(":/image/image/relation.png"), tr("relation"));//在后面添加带图标的选项卡

   // ui->InputTab->addTab(tabImage, QIcon(QPixmap("Resources\\a11.png").scaled(150, 120)), NULL);//添加选项卡
    //ui->InputTab->setTabToolTip(1, tr("图像"));//鼠标悬停弹出提示
    ui->InputTab->setTabShape(QTabWidget::Triangular);//设置选项卡的形状 Rounded
    ui->InputTab->setMovable(true);
    ui->InputTab->usesScrollButtons();//选项卡滚动

    QGridLayout *vlayout = new QGridLayout;

    QHBoxLayout *hlayout1 = new QHBoxLayout;
    input_nodename = new QLineEdit();
    hlayout1->addWidget(input_nodename);


    QHBoxLayout *hlayout2 = new QHBoxLayout;
    QLabel *nodename =new QLabel();
    nodename->setText("nodename :");
    hlayout2->addWidget(nodename);

    QHBoxLayout *hlayout1_1 = new QHBoxLayout;
    input_nodelabel = new QLineEdit();
    hlayout1->addWidget(input_nodelabel);


    QHBoxLayout *hlayout2_2 = new QHBoxLayout;
    QLabel *nodelabel =new QLabel();
    nodelabel->setText("nodelabel :");
    hlayout2->addWidget(nodelabel);

    vlayout->addLayout(hlayout2, 0, 0);
    vlayout->addLayout(hlayout1, 1, 0);
    vlayout->addLayout(hlayout2_2, 0, 1);
    vlayout->addLayout(hlayout1_1,1, 1);



    node->setLayout(vlayout);

    QGridLayout *vlayout1 = new QGridLayout;

    QHBoxLayout *hlayout3 = new QHBoxLayout;
    QLineEdit *source = new QLineEdit();
    hlayout3->addWidget(source);

    QHBoxLayout *hlayout4 = new QHBoxLayout;
    QLineEdit *Destination = new QLineEdit();
    hlayout4->addWidget(Destination);

    QHBoxLayout *hlayout5 = new QHBoxLayout;
    QLineEdit *relasion = new QLineEdit();
    hlayout5->addWidget(relasion);

    QHBoxLayout *hlayout6 = new QHBoxLayout;
    QLabel *source_name =new QLabel();
    source_name->setText("source :");
    hlayout6->addWidget(source_name);

    QHBoxLayout *hlayout7 = new QHBoxLayout;
    QLabel *Destination_name =new QLabel();
    Destination_name->setText("Destination :");
    hlayout7->addWidget(Destination_name);

    QHBoxLayout *hlayout8 = new QHBoxLayout;
    QLabel *relasion_name =new QLabel();
    relasion_name->setText("relation ");
    hlayout8->addWidget(relasion_name);

    vlayout1->addLayout(hlayout3 , 1 , 0);
    vlayout1->addLayout(hlayout4 , 1 , 2);
    vlayout1->addLayout(hlayout5 , 1 , 1);
    vlayout1->addLayout(hlayout6 , 0 , 0);
    vlayout1->addLayout(hlayout7 , 0 , 2);
    vlayout1->addLayout(hlayout8 , 0 , 1);

    relation->setLayout(vlayout1);



    QWidget *graph = new QWidget(this);
    QWidget *text = new QWidget(this);


    ui->OutputTab->setIconSize(QSize(20, 20));//设置图标的大小(选项卡的大小也会改变)
    ui->OutputTab ->setTabPosition(QTabWidget::North);//设置选项卡的方位，默认在上方(东南西北)
    ui->OutputTab->addTab(graph, QIcon(":/image/image/graph.png"), tr("Graph"));//在后面添加带图标的选项卡
    ui->OutputTab->addTab(text, QIcon(":/image/image/text.png"), tr("Text"));//在后面添加带图标的选项卡

    QGridLayout *vlayout3 = new QGridLayout;

    output =new QTextEdit();
    QHBoxLayout *hlayout9 = new QHBoxLayout;
    hlayout9->addWidget(output);
    vlayout3->addLayout(hlayout9 , 0 , 0);
    text->setLayout(vlayout3);

    ui->OutputTab->setTabShape(QTabWidget::Triangular);
    ui->OutputTab->setMovable(true);
    ui->OutputTab->usesScrollButtons();

    ui->vlaue_k->setPlaceholderText(tr("k"));

    tabel_text=new QTableWidget(this);


    connect(load,SIGNAL(triggered()),this,SLOT(load()));
    connect(newgraph,SIGNAL(triggered()),this,SLOT(newgraph()));
    connect(removegraph,SIGNAL(triggered()),this,SLOT(removegraph()));
    connect(save,SIGNAL(triggered()),this,SLOT(save()));
}

MainWindow::~MainWindow()
{
    delete ui;
}

void MainWindow::on_makesure_clicked()
{
    output->clear();
    QString token = input_nodename->text();
    output->append(token);
  /*int function;
    function=ui->item->currentIndex();
    switch(function){
    case 0:;break;
    case 1:;break;
    case 2:;break;
    case 3:;break;
    }*/

}
void MainWindow::newgraph()
{}
void MainWindow::removegraph()
{}
void MainWindow::save()
{}

void MainWindow::load()
{
    //QStringList filenames = QFileDialog::getOpenFileNames(this,tr("选择数据集"),"D:\\",tr("Image(*.png)"));
    QFileDialog *fileDialog = new QFileDialog(this);
    fileDialog->setWindowTitle(tr("Open Image"));
    fileDialog->setDirectory(".");
    fileDialog->setNameFilter(tr("Image Files(*.jpg *.png)"));
    if(fileDialog->exec() == QDialog::Accepted) {
            QString path = fileDialog->selectedFiles()[0];
            QMessageBox::information(nullptr, tr("Path"), tr("You selected ") + path);
    } else {
            QMessageBox::information(nullptr, tr("Path"), tr("You didn't select any files."));
    }
}

void MainWindow::on_KNN_clicked()
{

    const int k = ui->vlaue_k->text().toInt();
    //Knn(k);
}

void MainWindow::on_SSSP_clicked()
{
    //Sssp();
}

void MainWindow::on_PageRank_clicked()
{
    //PageRank();
}