#define DEBUG_WEBDAV 1
#include "filesystem.h"
#include "uploader.h"
#include "settings.h"
#include "dbushandler.h"
#include "networkmonitor.h"

#include <QCoreApplication>
#include <QDBusConnection>

int main(int argc, char *argv[]) {
    QCoreApplication app(argc, argv);

    Settings::instance()->readSettings();

    Filesystem *fsHandler = Filesystem::instance();
    Uploader *uploader = Uploader::instance();
    DBusHandler *dbusHandler = new DBusHandler(uploader);
    NetworkMonitor *netMonitor = NetworkMonitor::instance();

    QObject::connect(fsHandler, &Filesystem::fileFound, uploader, &Uploader::fileFound);
    QObject::connect(uploader, &Uploader::pokeFilesystemScanner, fsHandler, &Filesystem::localPathChanged);
    QObject::connect(netMonitor, &NetworkMonitor::shouldDownloadChanged, uploader, &Uploader::setOnline);

    // DBus connections
    QObject::connect(netMonitor, &NetworkMonitor::shouldDownloadChanged, dbusHandler, &DBusHandler::setOnline);
    QObject::connect(uploader, &Uploader::fileUploaded, dbusHandler, &DBusHandler::fileUploaded);
    QObject::connect(uploader, &Uploader::connectError, dbusHandler, &DBusHandler::connectError);
    QObject::connect(uploader, &Uploader::uploadError, dbusHandler, &DBusHandler::uploadError);
    QObject::connect(uploader, &Uploader::uploadingChanged, dbusHandler, &DBusHandler::uploadingChanged);
    QObject::connect(dbusHandler, &DBusHandler::configChanged, uploader, &Uploader::settingsChanged);

    // We only need one instance
    if(!QDBusConnection::sessionBus().registerService("com.github.cnlpete.HarbourNextcloud.Daemon") ||
            !QDBusConnection::sessionBus().registerObject("/", uploader)) {
        exit(1);
    }

    netMonitor->recheckNetworks();
    uploader->settingsChanged();

    return app.exec();
}
