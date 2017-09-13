TARGET = harbour-nextcloud-daemon

CONFIG = qt c++11
QT = dbus network xml
DEFINES += QWEBDAVITEM_EXTENDED_PROPERTIES

SOURCES += main.cpp \
    ../common/src/settings.cpp \
    ../common/src/shellcommand.cpp \
    ../common/src/transferentry.cpp \
    ../common/src/webdav_utils.cpp \
    dbushandler.cpp \
    filesystem.cpp \
    networkmonitor.cpp \
    uploader.cpp

HEADERS += \
    ../common/src/settings.h \
    ../common/src/shellcommand.h \
    ../common/src/transferentry.h \
    ../common/src/webdav_utils.h \
    dbushandler.h \
    filesystem.h \
    networkmonitor.h \
    uploader.h

OTHER_FILES += harbour-nextcloud-daemon.service

LIBS += $$OUT_PWD/../qwebdavlib/qwebdavlib/libqwebdav.so.1

QMAKE_RPATHDIR += /usr/share/harbour-nextcloud/lib

service.path = /usr/lib/systemd/user/
service.files += harbour-nextcloud-daemon.service
INSTALLS += service

binary.path = /usr/bin/
binary.files += $$OUT_PWD/harbour-nextcloud-daemon
INSTALLS += binary

INCLUDEPATH += $$PWD/../common/src
DEPENDPATH += $$PWD/../common/src

INCLUDEPATH += $$PWD/../qwebdavlib/qwebdavlib
DEPENDPATH += $$PWD/../qwebdavlib/qwebdavlib
