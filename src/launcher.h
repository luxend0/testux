#pragma once

#include <QObject>
#include <QProcess>
#include <QtQml/qqmlregistration.h>

class Launcher : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    Q_PROPERTY(bool running READ running NOTIFY runningChanged)

public:
    explicit Launcher(QObject *parent = nullptr);

    bool running() const;

    Q_INVOKABLE void start(const QString &isoPath, int ramMb);
    Q_INVOKABLE void stop();

signals:
    void runningChanged();

private:
    QProcess m_qemu;
};
