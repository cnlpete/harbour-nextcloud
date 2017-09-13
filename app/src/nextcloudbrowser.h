#ifndef NEXTCLOUDBROWSER_H
#define NEXTCLOUDBROWSER_H

#include <QObject>

#include "../common/src/webdav_utils.h"
#include <qwebdavdirparser.h>
#include <qwebdavitem.h>
#include <QVariant>

#include "entryinfo.h"

class NextCloudBrowser : public QObject
{
    Q_OBJECT

public:
    NextCloudBrowser(QObject* parent = 0, Settings* settings = 0);
    ~NextCloudBrowser();

    Q_INVOKABLE void testConnection();
    Q_INVOKABLE QString getCurrentPath();
    Q_INVOKABLE void goToParentPath();
    Q_INVOKABLE void getDirectoryContent(QString path);
    Q_INVOKABLE void makeDirectory(QString dirName);
    Q_INVOKABLE void remove(QString name, bool refresh);
    Q_INVOKABLE void resetWebdav();

    QWebdav* getWebdav();
    QWebdav* getNewWebdav();

private:
    Settings *settings;
    QWebdav *webdav;
    QWebdavDirParser parser;
    QString currentPath;
    QVariantList entries;
    QStack<QList<EntryInfo*> > entryStack;
    QMutex deleteMutex;
    bool abortIntended;

signals:
    void directoryContentChanged(QString currentPath, QVariantList entries);
    void sslCertifcateError(QString md5Digest, QString sha1Digest);
    void loginFailed();
    void loginSucceeded();
    void refreshStarted(QString pathToRefresh);

public slots:
    void handleResponse();
    void printError(QString errorMsg);
    void reloadSettings();
    void testConnectionFinished();
    void proxyHandleSslError(const QList<QSslError> &errors);
    void proxyHandleLoginFailed();
    void refreshDirectoryContent();

public:
    void start();

};

#endif // NEXTCLOUDBROWSER_H
