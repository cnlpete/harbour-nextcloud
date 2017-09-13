# NOTICE:
#
# Application name defined in TARGET has a corresponding QML filename.
# If name defined in TARGET is changed, the following needs to be done
# to match new name:
#   - corresponding QML filename must be changed
#   - desktop icon filename must be changed
#   - desktop filename must be changed
#   - icon definition filename in desktop file must be changed
#   - translation filenames have to be changed

# The name of your application
TARGET = harbour-nextcloud

CONFIG += sailfishapp
QT += xml dbus

SOURCES += \
    ../common/src/settings.cpp \
    ../common/src/shellcommand.cpp \
    ../common/src/transferentry.cpp \
    ../common/src/webdav_utils.cpp \
    src/daemoncontrol.cpp \
    src/entryinfo.cpp \
    src/localfilebrowser.cpp \
    src/harbour-nextcloud.cpp \
    src/nextcloudbrowser.cpp \
    src/transfermanager.cpp \

HEADERS += \
    ../common/src/settings.h \
    ../common/src/shellcommand.h \
    ../common/src/transferentry.h \
    ../common/src/webdav_utils.h \
    src/daemoncontrol.h \
    src/entryinfo.h \
    src/transfermanager.h \
    src/localfilebrowser.h \
    src/nextcloudbrowser.h \
    src/transfermanager.h \

OTHER_FILES += \
    qml/harbour-nextcloud.qml \
    qml/cover/CoverPage.qml \
    qml/pages/FileBrowser.qml \
    qml/pages/FileDetails.qml \
    qml/pages/Login.qml \
    qml/pages/SSLErrorDialog.qml \
    qml/pages/SettingsPage.qml \
    qml/pages/TransferPage.qml \
    qml/pages/UploadDialog.qml \
    qml/pages/MkDirDialog.qml \
    rpm/harbour-nextcloud.changes.in \
    rpm/harbour-nextcloud.spec \
    rpm/harbour-nextcloud.yaml \
    translations/*.ts \
    harbour-nextcloud.desktop \

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n
TRANSLATIONS += translations/harbour-nextcloud-de.ts


icon86.files += icons/86x86/harbour-nextcloud.png
icon86.path = /usr/share/icons/hicolor/86x86/apps
INSTALLS += icon86

icon108.files += icons/108x108/harbour-nextcloud.png
icon108.path = /usr/share/icons/hicolor/108x108/apps
INSTALLS += icon108

icon128.files += icons/128x128/harbour-nextcloud.png
icon128.path = /usr/share/icons/hicolor/128x128/apps
INSTALLS += icon128

icon256.files += icons/256x256/harbour-nextcloud.png
icon256.path = /usr/share/icons/hicolor/256x256/apps
INSTALLS += icon256

#iconsvg.files += icons/scalable/harbour-nextcloud.svgz
#iconsvg.path = /usr/share/icons/hicolor/scalable/apps

include(../notifications.pri)

LIBS += $$OUT_PWD/../qwebdavlib/qwebdavlib/libqwebdav.so.1

QMAKE_RPATHDIR += /usr/share/harbour-nextcloud/lib

qwebdavlib.path = /usr/share/harbour-nextcloud/lib
qwebdavlib.files += $$OUT_PWD/../qwebdavlib/qwebdavlib/libqwebdav.so.1
INSTALLS += qwebdavlib

INCLUDEPATH += $$PWD/../qwebdavlib/qwebdavlib
DEPENDPATH += $$PWD/../qwebdavlib/qwebdavlib

INCLUDEPATH += $$PWD/../common/src
DEPENDPATH += $$PWD/../common/src

DEFINES += QWEBDAVITEM_EXTENDED_PROPERTIES
