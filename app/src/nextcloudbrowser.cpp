#include "nextcloudbrowser.h"

NextCloudBrowser::NextCloudBrowser(QObject *parent, Settings *settings) :
    QObject(parent)
{
    this->webdav = 0;
    this->settings = settings;
    this->abortIntended = false;
    connect(settings, &Settings::settingsChanged, this, &NextCloudBrowser::reloadSettings);

    resetWebdav();
}

NextCloudBrowser::~NextCloudBrowser()
{
    if(webdav)
        delete webdav;
}

QWebdav* NextCloudBrowser::getWebdav()
{
    return webdav;
}

void NextCloudBrowser::resetWebdav()
{
    if(webdav) {
        disconnect(webdav, &QWebdav::errorChanged, this, &NextCloudBrowser::proxyHandleLoginFailed);
        disconnect(&parser, 0, 0, 0);
        delete webdav;
    }
    webdav = new QWebdav();
    connect(webdav, &QWebdav::errorChanged, this, &NextCloudBrowser::proxyHandleLoginFailed, Qt::DirectConnection);
    connect(&parser, &QWebdavDirParser::errorChanged, this, &NextCloudBrowser::proxyHandleLoginFailed, Qt::DirectConnection);
}

QWebdav* NextCloudBrowser::getNewWebdav()
{
    return getNewWebDav(this->settings);
}

void NextCloudBrowser::reloadSettings()
{
    applySettingsToWebdav(this->settings, webdav);
}

void NextCloudBrowser::testConnection()
{
    connect(webdav, &QWebdav::checkSslCertifcate, this, &NextCloudBrowser::proxyHandleSslError);
    connect(webdav, &QNetworkAccessManager::finished, this, &NextCloudBrowser::testConnectionFinished, Qt::DirectConnection);

    parser.listDirectory(webdav, "/");
}

void NextCloudBrowser::testConnectionFinished()
{
    qDebug() << "BEIDL Finished";

    disconnect(webdav, &QWebdav::checkSslCertifcate, this, &NextCloudBrowser::proxyHandleSslError);
    disconnect(webdav, &QNetworkAccessManager::finished, this, &NextCloudBrowser::testConnectionFinished);

    connect(&parser, &QWebdavDirParser::finished, this, &NextCloudBrowser::handleResponse);
    emit loginSucceeded();
}

void NextCloudBrowser::proxyHandleSslError(const QList<QSslError>& errors)
{
    QSslCertificate cert = errors[0].certificate();
    emit sslCertifcateError(webdav->digestToHex(cert.digest(QCryptographicHash::Md5)),
                            webdav->digestToHex(cert.digest(QCryptographicHash::Sha1)));
}

void NextCloudBrowser::proxyHandleLoginFailed()
{
    if(!abortIntended) {
        qDebug() << "BEIDL Failed";
        disconnect(&parser, &QWebdavDirParser::finished, this, &NextCloudBrowser::handleResponse);

        emit loginFailed();
    } else {
        abortIntended = false;
    }
}

void NextCloudBrowser::handleResponse()
{
    deleteMutex.lock();
    QList<QWebdavItem> list = parser.getList();

    entries.clear();
    QList<EntryInfo*> deletables;

    QWebdavItem item;
    foreach(item, list) {
        EntryInfo *entry = new EntryInfo();
        entry->setPath(item.path());
        entry->setName(item.name());
        entry->setDirectory(item.isDir());
        entry->setSize(item.size());
        if(!item.isDir()) {
            entry->setMimeType(item.mimeType());
            entry->setModTime(item.lastModified());
        }

        QVariant tmpVariant;
        tmpVariant.setValue(entry);
        entries.append(tmpVariant);

        deletables.append(entry);
    }
    entryStack.push(deletables);
    emit directoryContentChanged(parser.path(), entries);
    deleteMutex.unlock();
}

void NextCloudBrowser::printError(QString msg)
{
    qDebug() << "ERROR: " << msg;
}

QString NextCloudBrowser::getCurrentPath()
{
    return currentPath;
}

void NextCloudBrowser::goToParentPath()
{
    // Called when navigating back in the browser
    // Keeping path and UI in sync
    QString tmpPath = currentPath.mid(0, currentPath.length() - 1);
    currentPath = tmpPath.mid(0, tmpPath.lastIndexOf('/') + 1);

    // Delete old EntryInfo objects
    abortIntended = true;
    bool busy = parser.isBusy();
    parser.abort();

    deleteMutex.lock();
    if(!busy) {
        QList<EntryInfo*> deletables = entryStack.pop();
        for(int i = 0; i < deletables.length(); i++) {
            deletables.at(i)->deleteLater();
        }
        deletables.clear();
    }
    deleteMutex.unlock();
}

void NextCloudBrowser::getDirectoryContent(QString path)
{
    currentPath = path;
    parser.listDirectory(webdav, path);
}

void NextCloudBrowser::refreshDirectoryContent()
{
    deleteMutex.lock();
    QList<EntryInfo*> deletables = entryStack.pop();
    for(int i = 0; i < deletables.length(); i++) {
        deletables.at(i)->deleteLater();
    }
    deletables.clear();
    deleteMutex.unlock();
    parser.listDirectory(webdav, currentPath);
}

void NextCloudBrowser::makeDirectory(QString dirName)
{
    QWebdav* mkdirWebdav = getNewWebdav();
    connect(mkdirWebdav, &QNetworkAccessManager::finished, this, &NextCloudBrowser::refreshDirectoryContent, Qt::DirectConnection);
    connect(mkdirWebdav, &QNetworkAccessManager::finished, mkdirWebdav, &QObject::deleteLater, Qt::DirectConnection);
    mkdirWebdav->mkdir(currentPath + dirName);

    emit refreshStarted(currentPath);
}

void NextCloudBrowser::remove(QString name, bool refresh)
{
    qDebug() << "Removing " << name;
    QWebdav* rmWebdav = getNewWebdav();
    if(refresh)
        connect(rmWebdav, &QNetworkAccessManager::finished, this, &NextCloudBrowser::refreshDirectoryContent, Qt::DirectConnection);
    connect(rmWebdav, &QNetworkAccessManager::finished, rmWebdav, &QObject::deleteLater, Qt::DirectConnection);
    rmWebdav->remove(name);

    if(refresh)
        emit refreshStarted(currentPath);
}
