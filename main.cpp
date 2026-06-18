#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "homemanager.h"
#include "simulationengine.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    // Instantiate C++ singletons/managers
    HomeManager *homeManager = HomeManager::instance();
    SimulationEngine *simEngine = new SimulationEngine(homeManager, &app);

    QQmlApplicationEngine engine;

    // Register HomeManager to context so QML can access it as "backend"
    engine.rootContext()->setContextProperty("backend", homeManager);

    // Register Device and Room types to QML meta-system
    qmlRegisterType<Device>("SmartHome", 1, 0, "Device");
    qmlRegisterType<Room>("SmartHome", 1, 0, "Room");

    const QUrl url(u"qrc:/SmartHome/Main.qml"_qs);
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);

    engine.load(url);

    // Start simulation loop
    simEngine->start();

    return app.exec();
}
