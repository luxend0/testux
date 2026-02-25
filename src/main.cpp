#include <QGuiApplication>
#include <QIcon>
#include <QLocale>
#include <QQmlApplicationEngine>
#include <QQuickStyle>
#include <QTranslator>

int main(int argc, char* argv[])
{
    QGuiApplication app(argc, argv);
    app.setOrganizationName("Testux");
    app.setApplicationName("Testux");
    app.setApplicationVersion(TESTUX_VERSION);
    app.setWindowIcon(QIcon(":/qt/qml/Testux/assets/testux.svg"));

    QTranslator translator;
    if (translator.load(QLocale(), "testux", "_", ":/i18n"))
        app.installTranslator(&translator);

    QQuickStyle::setStyle("Basic");

    QQmlApplicationEngine engine;
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreationFailed, &app,
                     [] { QCoreApplication::exit(1); }, Qt::QueuedConnection);
    engine.loadFromModule("Testux", "Main");

    return app.exec();
}
