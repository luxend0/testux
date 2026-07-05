#pragma once

#include "catalog/distro.h"

#include <QHash>
#include <QObject>

#include <memory>

class QNetworkAccessManager;
class QNetworkReply;

class IsoDownload : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_UNCREATABLE("Obtained from IsoLibrary.iso()")
    Q_PROPERTY(State state READ state NOTIFY stateChanged)
    Q_PROPERTY(qint64 received READ received NOTIFY progressChanged)
    Q_PROPERTY(qint64 total READ total NOTIFY progressChanged)
    Q_PROPERTY(QString error READ error NOTIFY stateChanged)
    Q_PROPERTY(QString path READ path CONSTANT)

public:
    enum State { Missing, Downloading, Verifying, Ready, Failed };
    Q_ENUM(State)

    IsoDownload(const Distro &distro, const QString &path, QNetworkAccessManager *network,
                QObject *parent);

    State state() const { return m_state; }
    qint64 received() const { return m_received; }
    qint64 total() const { return m_total; }
    QString error() const { return m_error; }
    QString path() const { return m_path; }

    Q_INVOKABLE void start();  // no-op while Downloading/Verifying or when Ready
    Q_INVOKABLE void cancel(); // keeps the .part file for resuming
    Q_INVOKABLE void remove(); // deletes ISO and .part, back to Missing

signals:
    void stateChanged();
    void progressChanged();

private:
    struct Part; // the .part file and the SHA-256 of what it holds, see isolibrary.cpp

    void download();
    void receive();
    void transferFinished();
    void verify(const QString &actualSha256);
    void complete(const QString &actualSha256, const QString &expectedSha256);
    void setState(State state, const QString &error = {});

    Distro m_distro;
    QString m_path;
    QNetworkAccessManager *m_network;
    QNetworkReply *m_reply = nullptr;
    std::shared_ptr<Part> m_part; // transfer in progress, shared with the hashing thread
    State m_state = Missing;
    qint64 m_received = 0;
    qint64 m_total = 0;
    QString m_error;
};

class IsoLibrary : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON
    Q_PROPERTY(qint64 usedBytes READ usedBytes NOTIFY usedBytesChanged)

public:
    explicit IsoLibrary(QObject *parent = nullptr);

    // Same object for the same ISO for the lifetime of the app (C++ ownership).
    Q_INVOKABLE IsoDownload *iso(const Distro &distro);
    Q_INVOKABLE void removeAll();

    qint64 usedBytes() const;

signals:
    void usedBytesChanged();

private:
    QString m_dir;
    QNetworkAccessManager *m_network;
    QHash<QString, IsoDownload *> m_isos;
};
