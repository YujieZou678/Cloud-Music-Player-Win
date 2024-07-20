#include "httprequest.h"
#include "mysubthread.h"

#include <QThread>
#include <QSettings>
#include <QDir>

HttpRequest::HttpRequest(QObject *parent)
    : QObject{parent}
{
    //为manager状态赋值
    for (int i=0; i<3; i++) {
        statusSignal[i] = true;
    }
    //网络请求
    manager[0] = new QNetworkAccessManager(this);
    manager[1] = new QNetworkAccessManager(this);
    manager[2] = new QNetworkAccessManager(this);
    manager[0]->setTransferTimeout(3000);  //设置超时时间
    manager[1]->setTransferTimeout(3000);
    manager[2]->setTransferTimeout(3000);

    connect(manager[0], &QNetworkAccessManager::finished, this, &HttpRequest::replyFinished1);
    connect(manager[1], &QNetworkAccessManager::finished, this, &HttpRequest::replyFinished2);
    connect(manager[2], &QNetworkAccessManager::finished, this, &HttpRequest::replyFinished3);
    //子线程执行某操作
    sub1Thread = new QThread();  //需要手动清理，RAII结构
    classAtSub1Thread = new MySubThread();  //需要手动清理，RAII结构
    classAtSub1Thread->moveToThread(sub1Thread);

    connect(this, &HttpRequest::getSongsFF_Signal, classAtSub1Thread, &MySubThread::getSongsFromFolders);
    connect(classAtSub1Thread, &MySubThread::closeSub1Signal, this, &HttpRequest::closeSub1Thread);

    settings = new QSettings("config/local.ini", QSettings::IniFormat, this);
}

HttpRequest::~HttpRequest()
{
    //析构不允许发生异常，如果有异常就吞掉
    try {
        if (sub1Thread->isRunning()) {  //上保险，如果退出程序而子线程没关闭
            sub1Thread->quit();
            sub1Thread->wait();
            qDebug() << "析构函数: 子线程1号已关闭";
        }
    } catch (std::exception e) {
        qDebug() << "析构函数: 子线程关闭异常！";
    }

    delete sub1Thread;
    delete classAtSub1Thread;
}

//三个槽函数
void HttpRequest::replyFinished1(QNetworkReply *reply)
{
    if (reply->error() != QNetworkReply::NoError) {
        qDebug() << "Reply error: " << reply->errorString();
        //传递一个空，用于判断请求失败
        emit replySignal1("");
    } else {
        emit replySignal1(reply->readAll());
    }

    reply->deleteLater();  //需要手动释放
}
void HttpRequest::replyFinished2(QNetworkReply *reply)
{
    if (reply->error() != QNetworkReply::NoError) {
        qDebug() << "Reply error: " << reply->errorString();
        //传递一个空，用于判断请求失败
        emit replySignal2("");
    } else {
        emit replySignal2(reply->readAll());
    }

    reply->deleteLater();  //需要手动释放
}
void HttpRequest::replyFinished3(QNetworkReply *reply)
{
    if (reply->error() != QNetworkReply::NoError) {
        qDebug() << "Reply error: " << reply->errorString();
        //传递一个空，用于判断请求失败
        emit replySignal3("");
    } else {
        emit replySignal3(reply->readAll());
    }

    reply->deleteLater();  //需要手动释放
}

void HttpRequest::getSongsFF_AtSub1Thread(const QStringList& paths)
{
    sub1Thread->start();  //启动子线程
    emit getSongsFF_Signal(paths);  //在子线程开始执行
}

void HttpRequest::closeSub1Thread(const QStringList& data)
{
    sub1Thread->quit();  //关闭子线程1号
    sub1Thread->wait();
    //qDebug() << "子线程1号已关闭";
    emit getSongsFFEnd_Signal(data);  //将值传递给qml
}

//请求数据
void HttpRequest::getData(QString url, int i)
{
    manager[i]->get(QNetworkRequest(QUrl(BASE_URL + url)));
}

//得到一个空闲的Manager
int HttpRequest::getFreeManager()
{
    //是个死循环，直到找到空闲的Manager
    for (int i = 0; (i+3)%3 < 3; i++) {
        switch ((i+3)%3) {
        case 0:
            if (statusSignal[0] == true) {
                statusSignal[0] = false;
                return 0;
            }
            break;
        case 1:
            if (statusSignal[1] == true) {
                statusSignal[1] = false;
                return 1;
            }
            break;
        case 2:
            if (statusSignal[2] == true) {
                statusSignal[2] = false;
                return 2;
            }
            break;
        }
    }

    return 0;
}

//重置Manager的状态
void HttpRequest::reSetStatus(int i)
{
    statusSignal[i] = true;
}

void HttpRequest::saveLocalCache(const QList<QVariant>& data)
{
    for (int i=0; i<data.length(); i++) {
        settings->setValue("localMusic/"+QString::number(i), data[i]);
    }

    qDebug() << "本地音乐数据缓存成功。";
}

//bool myCompare(const QVariantMap& a, const QVariantMap& b) {  //降序函数
//    return a.value("id").toString() > b.value("id").toString();
//}

QList<QVariantMap> HttpRequest::getLocalCache()
{
    QList<QVariantMap> data;

    settings->beginGroup("localMusic");  //进入localMusic目录。注意该类共用一个settings，记得退出！！！
    QStringList keys = settings->childKeys();
    for (int i=0; i<keys.length(); i++) {
        data.append(settings->value(QString::number(i)).toMap());
    }

    //std::sort(data.begin(), data.end(), myCompare);  //排序
    qDebug() << "已加载本地音乐缓存数据。";
    settings->endGroup();  //退出localMusic目录
    return data;
}

void HttpRequest::clearLocalCache()
{
    settings->remove("localMusic");
    qDebug() << "已清除本地音乐缓存数据。";
}

void HttpRequest::saveHistoryCache(const QList<QVariant>& data)
{
    for (int i=0; i<data.length(); i++) {
        settings->setValue("historyMusic/"+QString::number(i), data[i]);
    }

    qDebug() << "播放历史数据缓存成功。";
}

QList<QVariantMap> HttpRequest::getHistoryCache()
{
    QList<QVariantMap> data;

    settings->beginGroup("historyMusic");  //进入historyMusic目录。注意该类共用一个settings，记得退出！！！
    QStringList keys = settings->childKeys();
    for (int i=0; i<keys.length(); i++) {
        data.append(settings->value(QString::number(i)).toMap());
    }

    //std::sort(data.begin(), data.end(), myCompare);  //排序
    qDebug() << "已加载播放历史缓存数据。";
    settings->endGroup();  //退出historyMusic目录
    return data;
}

void HttpRequest::clearHistoryCache()
{
    settings->remove("historyMusic");
    qDebug() << "已清除播放历史缓存数据。";
}

void HttpRequest::saveFavoriteCache(const QList<QVariant>& data)
{
    settings->remove("favoriteMusic");  //先清除再添加

    for (int i=0; i<data.length(); i++) {
        settings->setValue("favoriteMusic/"+QString::number(i), data[i]);
    }

    qDebug() << "我喜欢数据缓存成功。";
}

QList<QVariantMap> HttpRequest::getFavoriteCache()
{
    QList<QVariantMap> data;

    settings->beginGroup("favoriteMusic");  //进入favoriteMusic目录。注意该类共用一个settings，记得退出！！！
    QStringList keys = settings->childKeys();
    for (int i=0; i<keys.length(); i++) {
        data.append(settings->value(QString::number(i)).toMap());
    }

    //std::sort(data.begin(), data.end(), myCompare);  //排序
    qDebug() << "已加载我喜欢缓存数据。";
    settings->endGroup();  //退出historyMusic目录
    return data;
}

void HttpRequest::clearFavoriteCache()
{
    settings->remove("favoriteMusic");
    qDebug() << "已清除我喜欢缓存数据。";
}

QStringList HttpRequest::getCurrentFolderList(const QString &path)
{
    QDir dir(path);
    return dir.entryList(QDir::AllDirs|QDir::NoDotAndDotDot, QDir::NoSort);
}

//得到分秒标准格式时间
QString HttpRequest::getTime(int total)
{
    int hh = total / (60 * 60);
    int mm = (total- (hh * 60 * 60)) / 60;
    int ss = (total - (hh * 60 * 60)) - mm * 60;

    QString hour = QString::number(hh, 10);  //转字符串，十进制
    QString min = QString::number(mm, 10);
    QString sec = QString::number(ss, 10);

    if (hour.length() == 1)
        hour = "0" + hour;
    if (min.length() == 1)
        min = "0" + min;
    if (sec.length() == 1)
        sec = "0" + sec;

    QString strTime = min + ":" + sec;
    return strTime;
}
