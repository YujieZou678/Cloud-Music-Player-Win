#include "mysubthread.h"
#include <QDebug>
#include <QDirIterator>
#include <algorithm>

MySubThread::MySubThread(QObject* parent)
    : QObject(parent)
{
}

bool myCompare(const QString& a, const QString& b) {  //降序函数
    return a > b;
}

void MySubThread::getSongsFromFolders(const QStringList& paths)
{
    QStringList songsList;  //结果

    QStringList nameFilters;  //过滤器
    nameFilters << QString("*.mp3");

    foreach (auto onePath, paths) {  //遍历需要查找的文件夹
        QDirIterator dir_iterator(onePath,  //查找该文件夹所有文件（包括子文件夹）
                                  nameFilters,
                                  QDir::Files,
                                  QDirIterator::Subdirectories);

        while (dir_iterator.hasNext()) {  //遍历在当前文件夹已经得到的文件
            songsList.append(dir_iterator.next());
        }
    }

    //songsList.sort();  //升序
    std::sort(songsList.begin(), songsList.end(), myCompare);  //降序

//    foreach (auto oneSong, songsList) {
//        qDebug() << oneSong;
//    }
//    qDebug() << songsList.length();
    emit closeSub1Signal(songsList);  //在子线程执行完毕,并传递参数
}



