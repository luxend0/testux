#pragma once

#include <QObject>
#include <QProcess>
#include <QtQml/qqmlregistration.h>

class Launcher : public QObject
{
    Q_OBJECT
    QML_ELEMENT

public:
    explicit Launcher(QObject *parent = nullptr);

    Q_INVOKABLE void start(const QString &isoPath);

private:
    QProcess m_qemu;
};
