#ifndef MYSUBTHREAD_H
#define MYSUBTHREAD_H

#include <QObject>

class MySubThread  : public QObject
{
    Q_OBJECT

public:
    MySubThread(QObject* parent = nullptr);
    void getSongsFromFolders(const QStringList&);  //在子线程中执行并给歌曲列表赋值

signals:
    void closeSub1Signal(QStringList);  //关闭子线程1号的信号,并传递参数

private:
    QStringList m_songsFromFolders;  //歌曲列表的值

};

#endif // MYSUBTHREAD_H
