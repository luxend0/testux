#pragma once

#include "catalog/distro.h"

#include <QObject>

class QNetworkAccessManager;

// The distro catalog. Loads, in order of preference: the copy on GitHub, the last copy
// that was downloaded successfully (AppLocalDataLocation/catalog.json), the copy built
// into the binary (:/qt/qml/Testux/catalog/catalog.json). Shows something immediately
// from cache/embedded, then swaps in the remote one when it arrives.
class Catalog : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON
    Q_PROPERTY(QList<Category> categories READ categories NOTIFY changed)
    Q_PROPERTY(QList<Distro> distros READ distros NOTIFY changed)
    Q_PROPERTY(QList<ChecklistItem> checklist READ checklist NOTIFY changed)
    Q_PROPERTY(QString latestAppVersion READ latestAppVersion NOTIFY changed)
    Q_PROPERTY(QString latestAppUrl READ latestAppUrl NOTIFY changed)
    Q_PROPERTY(bool loading READ loading NOTIFY loadingChanged)
    Q_PROPERTY(QString error READ error NOTIFY changed)

public:
    static constexpr auto RemoteUrl =
        "https://raw.githubusercontent.com/luxend0/testux/main/catalog/catalog.json";

    explicit Catalog(QObject *parent = nullptr);

    QList<Category> categories() const { return m_categories; }
    QList<Distro> distros() const { return m_distros; }
    QList<ChecklistItem> checklist() const { return m_checklist; }
    QString latestAppVersion() const { return m_latestAppVersion; }
    QString latestAppUrl() const { return m_latestAppUrl; }
    bool loading() const { return m_loading; }
    QString error() const { return m_error; }

    Q_INVOKABLE Distro distro(const QString &id) const;
    Q_INVOKABLE void refresh();

signals:
    void changed();
    void loadingChanged();

private:
    bool apply(const QByteArray &json);
    void setLoading(bool loading);

    QNetworkAccessManager *m_network;
    QList<Category> m_categories;
    QList<Distro> m_distros;
    QList<ChecklistItem> m_checklist;
    QString m_latestAppVersion;
    QString m_latestAppUrl;
    QString m_error;
    bool m_loading = false;
};
