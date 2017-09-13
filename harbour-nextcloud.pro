DEFINES += QWEBDAVITEM_EXTENDED_PROPERTIES
QMAKE_CXXFLAGS += -std=gnu++0x

TEMPLATE = subdirs

SUBDIRS += qwebdavlib/qwebdavlib
SUBDIRS += app
SUBDIRS += daemon

OTHER_FILES += \
    rpm/* \
    CONTRIBUTORS \
    LICENSE \
    TODO
