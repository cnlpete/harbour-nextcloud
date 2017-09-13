import QtQuick 2.0
import Sailfish.Silica 1.0
import harbour.nextcloud 1.0


Page {
    id: pageRoot
    anchors.fill: parent

    property string remotePath : "/"
    property string pageHeaderText : "/"

    Component.onCompleted: {
        remotePath = browser.getCurrentPath();
    }

    onRemotePathChanged: {
        if(remotePath === "/") {
            pageHeaderText = "/";
        } else {
            var dirs = remotePath.split("/")
            if(dirs.length > 1) {
                pageHeaderText = dirs[dirs.length - 2]
            }
        }
    }

    property int cancelCounter : 0;

    function refreshListView() {
        listView.model = undefined
        browser.getDirectoryContent(remotePath);
    }

    Connections {
        id: fillListviewConnection
        target: browser
        onDirectoryContentChanged: {
            if(currentPath == remotePath) {
                listView.model = entries;
            }
        }
    }

    Connections {
        target: browser
        onRefreshStarted: {
            if(remotePath === pathToRefresh && cancelCounter === 0) {
                listView.model = undefined;
            }
        }
    }

    Connections {
        target: transfer
        onUploadComplete: {
            /// XXX: Would like to pass `entry` in the signal, but it confuses navigation!
            //remotePath = entry.getRemotePath();
            if(remotePath === pageRoot.remotePath) {
                refreshListView()
            }
        }
    }

    onStatusChanged: {
        if (status === PageStatus.Deactivating) {
            if (_navigation === PageNavigation.Back) {
                fillListviewConnection.destroy()
                listView.model = undefined
                browser.goToParentPath();
            }
        }
    }

    property Item fileContextMenu;
    property EntryInfo selectedEntry;
    property BackgroundItem selectedItem;
    property RemorseItem selectedRemorse;

    SilicaFlickable {
        anchors.fill: parent

        SilicaListView {
            id: listView
            anchors.fill: parent

            header: PageHeader {
                title: pageHeaderText
            }

            PullDownMenu {
                MenuItem {
                    text: qsTr("Refresh")
                    enabled: listView.model !== undefined
                    onClicked: {
                        listView.model = undefined
                        browser.getDirectoryContent(remotePath);
                    }
                }

                MenuItem {
                    text:qsTr("Create directory")
                    enabled: listView.model !== undefined
                    onClicked: {
                        pageStack.push("MkDirDialog.qml")
                    }
                }

                MenuItem {
                    text: qsTr("Upload")
                    enabled: listView.model !== undefined
                    onClicked: {
                        pageStack.push("UploadDialog.qml")
                    }
                }
            }
            PushUpMenu {
                MenuItem {
                    text: qsTr("File transfers")
                    onClicked: {
                        pageStack.push("TransferPage.qml")
                    }
                }

                MenuItem {
                    text: qsTr("Settings")
                    onClicked: {
                        pageStack.push("SettingsPage.qml")
                    }
                }
            }

            delegate: BackgroundItem {
                id: delegate
                property bool menuOpen: fileContextMenu != null && fileContextMenu.parent === delegate
                height: menuOpen ? fileContextMenu.height + bgItem.height : bgItem.height

                RemorseItem {
                    id: remorseItem
                    onCanceled: {
                        console.log("Canceled...")
                        var forceRefresh = false;
                        if(cancelCounter > 0)
                            forceRefresh = true;
                        cancelCounter--;
                        if(forceRefresh) {
                            refreshListView()
                        }
                    }
                }

                BackgroundItem {
                    id: bgItem
                    Image {
                        id: icon
                        source: listView.model[index].isDirectory ?
                                    "image://theme/icon-m-folder" :
                                    getIconFromMime(listView.model[index].mimeType)
                        anchors.left: parent.left
                        anchors.leftMargin: Theme.paddingLarge
                        anchors.top: parent.top
                        anchors.topMargin: 18
                        height: label.height
                        fillMode: Image.PreserveAspectFit
                    }

                    Label {
                        id: label
                        x: icon.x + icon.width + 6
                        y: icon.y - icon.height + 6
                        text: listView.model[index].name
                        anchors.verticalCenter: parent.verticalCenter
                        color: bgItem.highlighted ? Theme.highlightColor : Theme.primaryColor
                    }

                    onClicked: {
                        if(listView.model[index].isDirectory) {
                            var nextDirectory = Qt.createComponent("FileBrowser.qml");
                            browser.getDirectoryContent(remotePath + listView.model[index].name + "/");
                            pageStack.push(nextDirectory)
                        } else {
                            var fileComponent = Qt.createComponent("FileDetails.qml");
                            var fileDetails = fileComponent.createObject(pageRoot, {entry: listView.model[index]});
                            pageStack.push(fileDetails);
                        }
                    }
                    onPressAndHold: {
                        selectedEntry = listView.model[index];
                        selectedItem = delegate
                        selectedRemorse = remorseItem;
                        if (!fileContextMenu)
                            fileContextMenu = contextMenuComponent.createObject(listView)
                        fileContextMenu.show(delegate)
                    }
                }
            }
            VerticalScrollDecorator {}

            BusyIndicator {
                anchors.centerIn: parent
                running: listView.model === undefined
            }

            Component {
                id: contextMenuComponent
                ContextMenu {
                    onClosed: {
                        selectedEntry = null
                        selectedItem = null
                    }

                    MenuItem {
                        text: qsTr("Delete")

                        property EntryInfo tmpEntry;

                        onClicked: {
                            tmpEntry = selectedEntry
                            cancelCounter++;
                            selectedRemorse.execute(selectedItem, qsTr("Deleting", "RemorseItem text"), function() {
                                cancelCounter--;
                                browser.remove(remotePath + tmpEntry.name +
                                               (tmpEntry.isDirectory ? "/" : ""),
                                               cancelCounter == 0);
                            }, 3000)
                        }
                    }
                }
            }
        }
    }
}





