#include "daemoncontrol.h"

DaemonControl::DaemonControl(QObject *parent) : QObject(parent)
{
    m_uploading = false;
    QDBusConnection::sessionBus().connect("com.github.cnlpete.HarbourNextcloud.Daemon",
                                          "/",
                                          "com.github.cnlpete.HarbourNextcloud.Daemon.Uploader",
                                          "uploadingChanged",
                                          this,
                                          SLOT(setUploading(bool)));
}

bool DaemonControl::daemonInstalled()
{
    return QFile("/usr/bin/harbour-nextcloud-daemon").exists();
}

bool DaemonControl::uploading()
{
    return m_uploading;
}

void DaemonControl::setUploading(bool value)
{
    qDebug() << "Uploading? " << value;
    if(value != m_uploading) {
        m_uploading = value;
        emit uploadingChanged();
    }
}

void DaemonControl::reloadConfig()
{
    QDBusMessage message = QDBusMessage::createMethodCall("com.github.cnlpete.HarbourNextcloud.Daemon",
                                                          "/",
                                                          "com.github.cnlpete.HarbourNextcloud.Daemon.Uploader",
                                                          "reloadConfig");
    QDBusConnection::sessionBus().send(message);
}
