#ifndef HTTPREQUEST_H
#define HTTPREQUEST_H

#include <QObject>
#include <QNetworkRequest>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QVariant>

class QThread;
class MySubThread;
class QSettings;

class HttpRequest : public QObject
{
    Q_OBJECT
public:
    explicit HttpRequest(QObject *parent = nullptr);
    ~HttpRequest();
    //暴露给qml的函数
    Q_INVOKABLE void getData(QString, int);
    Q_INVOKABLE QString getTime(int);
    Q_INVOKABLE int getFreeManager();
    Q_INVOKABLE void reSetStatus(int);

    Q_INVOKABLE void saveLocalCache(const QList<QVariant>&);  //本地音乐数据缓存
    Q_INVOKABLE QList<QVariantMap> getLocalCache();  //获取本地音乐缓存数据
    Q_INVOKABLE void clearLocalCache();  //清空本地音乐缓存数据

    Q_INVOKABLE void saveHistoryCache(const QList<QVariant>&);  //播放历史数据缓存
    Q_INVOKABLE QList<QVariantMap> getHistoryCache();  //获取播放历史缓存数据
    Q_INVOKABLE void clearHistoryCache();  //清空播放历史缓存数据

    Q_INVOKABLE void saveFavoriteCache(const QList<QVariant>&);  //我喜欢数据缓存
    Q_INVOKABLE QList<QVariantMap> getFavoriteCache();  //获取我喜欢缓存数据
    Q_INVOKABLE void clearFavoriteCache();  //清空我喜欢缓存数据

    Q_INVOKABLE QStringList getCurrentFolderList(const QString&);  //得到当前文件夹的其它dirs

    //请求数据完成后执行的函数
    void replyFinished1(QNetworkReply *reply);
    void replyFinished2(QNetworkReply *reply);
    void replyFinished3(QNetworkReply *reply);

    Q_INVOKABLE void getSongsFF_AtSub1Thread(const QStringList&);  //启动子线程1号并执行遍历文件夹得到音乐文件的操作
    void closeSub1Thread(const QStringList&);  //关闭子线程1号

signals:
    //传递给qml的信号
    void replySignal1(QString data);
    void replySignal2(QString data);
    void replySignal3(QString data);

    void getSongsFF_Signal(const QStringList&);  //执行子线程查找音乐的操作的信号
    void getSongsFFEnd_Signal(const QStringList&);  //传递给qml的信号

private:
    QString BASE_URL{"http://139.9.0.64:3000"};
    QNetworkAccessManager *manager[3];
    bool statusSignal[3];

    QThread* sub1Thread;  //子线程1号
    MySubThread* classAtSub1Thread;  //在子线程1号的类对象

    QSettings* settings;  //缓存设置对象

};

#endif // HTTPREQUEST_H
