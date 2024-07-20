#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QIcon>
#include <QQmlContext>
#include "httprequest.h"


int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    //添加程序icon
    app.setWindowIcon(QIcon(":/images/music.png"));

    QQmlApplicationEngine engine;
    //添加C++类,直接使用其方法
    HttpRequest request;
    engine.rootContext()->setContextObject(&request);
    const QUrl url(u"qrc:/Cloud_Music_Player/Main.qml"_qs);
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreationFailed,
        &app, []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
