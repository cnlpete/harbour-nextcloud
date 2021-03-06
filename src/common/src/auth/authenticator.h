#ifndef AUTHENTICATOR_H
#define AUTHENTICATOR_H

#include <QObject>

#include <settings/nextcloudsettingsbase.h>

class Authenticator : public QObject
{
    Q_OBJECT

    Q_PROPERTY(AccountBase* settings READ settings WRITE setSettings NOTIFY settingsChanged)
    Q_PROPERTY(bool running READ running WRITE setRunning NOTIFY runningChanged)

public:
    explicit Authenticator(QObject *parent = Q_NULLPTR,
                           AccountBase* settings = Q_NULLPTR);

public slots:
    virtual void authenticate() = 0;
    virtual void abort() = 0;

protected:
    virtual void updateClientSettings() = 0;

    AccountBase* settings();
    void setSettings(AccountBase* v);
    bool running();
    void setRunning(bool v);

private:
    AccountBase* m_settings = Q_NULLPTR;
    bool m_running = false;

signals:
    void authenticationFailed();
    void sslError(QString certMd5, QString certSha1);
    void authenticationSuccessful();
    void settingsChanged();
    void runningChanged();
};
Q_DECLARE_METATYPE(Authenticator*)

#endif // AUTHENTICATOR_H
