
#include <QtQuick>
#include <sailfishapp.h>

#include "nextcloudbrowser.h"
#include "entryinfo.h"
#include "settings.h"
#include "transfermanager.h"
#include "transferentry.h"
#include "localfilebrowser.h"
#include "daemoncontrol.h"

#include <notification.h>

Q_DECLARE_METATYPE(EntryInfo*)
Q_DECLARE_METATYPE(TransferEntry*)
Q_DECLARE_METATYPE(NextCloudBrowser*)
Q_DECLARE_METATYPE(LocalFileBrowser*)

int main(int argc, char *argv[])
{
    qmlRegisterType<EntryInfo>("harbour.nextcloud", 1, 0, "EntryInfo");
    qmlRegisterType<NextCloudBrowser>("harbour.nextcloud", 1, 0, "OwnCloudBrowser");
    qmlRegisterType<TransferManager>("harbour.nextcloud", 1, 0, "TransferManager");
    qmlRegisterType<TransferEntry>("harbour.nextcloud", 1, 0, "TransferEntry");
    qmlRegisterType<LocalFileBrowser>("harbour.nextcloud", 1, 0, "LocalFileBrowser");
    qmlRegisterType<DaemonControl>("harbour.nextcloud", 1, 0, "DaemonControl");
    qmlRegisterType<Notification>("harbour.nextcloud", 1, 0, "Notification");

    QGuiApplication *app = SailfishApp::application(argc, argv);
    app->setOrganizationName("harbour-nextcloud");
    app->setOrganizationDomain("harbour-nextcloud");
    app->setApplicationName("harbour-nextcloud");
    QQuickView *view = SailfishApp::createView();

    Settings *settings = Settings::instance();
    NextCloudBrowser *browser = new NextCloudBrowser(NULL, settings);
    TransferManager *transfer = new TransferManager(0, browser);
    DaemonControl *daemonCtrl = new DaemonControl();

    view->rootContext()->setContextProperty("browser", browser);
    view->rootContext()->setContextProperty("settings", settings);
    view->rootContext()->setContextProperty("transfer", transfer);
    view->rootContext()->setContextProperty("daemonCtrl", daemonCtrl);

    view->setSource(SailfishApp::pathTo("qml/harbour-nextcloud.qml"));
    view->showFullScreen();

    return app->exec();
}

