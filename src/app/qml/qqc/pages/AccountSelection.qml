import QtQuick 2.0
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import harbour.owncloud 1.0
import "qrc:/qml/qqc"
import "qrc:/qml-ui-set"

Item {
    id: accountsSelectionRoot
    property AccountWorkerGenerator accountGenerator : null
    property Component browserPage : null
    property QmlMap dirContents : null
    property StackView detailStack : null

    onDirContentsChanged: {
        console.log("AccountSelection.dirContents: " + dirContents)
    }

    readonly property var providerTypeNames : ["Nextcloud/ownCloud", "WebDav"]

    property CommandEntity __listCommand : null

    property var selectedAccountWorkers : null

    BrowserCommandPageFlow {
        id: pageFlow
        accountWorkers: selectedAccountWorkers
        directoryContents: accountsSelectionRoot.dirContents
        detailsStack: detailStack
        onNotificationRequest: notify(summary, body)
        onTransientNotificationRequest: notifyTransient(summary)
        onAvatarFetchRequest: selectedAccountWorkers.avatarFetcher.fetch()
        onUserInfoUpdateRequest: selectedAccountWorkers.accountInfoCommandQueue.userInfoRequest()
    }

    Menu {
        id: rightClickMenu

        MenuItem {
            text: qsTr("Delete")
            font.pixelSize: fontSizeSmall
            onClicked: {
                console.log("Deleting " + selectedAccountWorkers.account)
                var deleteSuccess =
                        accountGenerator.database.removeAccount(selectedAccountWorkers.account)
                console.log("deleteSuccess: " + deleteSuccess)
            }
        }
    }

    ListView {
        id: accountsList
        anchors.fill: parent
        model: accountGenerator.accountWorkers
        spacing: paddingSmall

        delegate: Item {
            width: parent.width

            readonly property var delegateAccountWorkers : accountGenerator.accountWorkers[index]

            Column {
                id: listEntry
                width: parent.width

                Column {
                    Label {
                        text: providerTypeNames[delegateAccountWorkers.account.providerType]
                        font.bold: true
                        font.pixelSize: fontSizeSmall
                        enabled: __listCommand == null
                    }
                    Label {
                        text: delegateAccountWorkers.account.username
                              + " on "
                              + delegateAccountWorkers.account.hoststring
                        font.pixelSize: fontSizeSmall
                        enabled: __listCommand == null
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        width: accountsList.width
                    }
                    MenuSeparator { width: accountsList.width }
                }
            }
            MouseArea {
                anchors.fill: listEntry
                enabled: __listCommand == null
                acceptedButtons: Qt.LeftButton | Qt.RightButton

                onClicked: {
                    selectedAccountWorkers = delegateAccountWorkers

                    if (mouse.button === Qt.RightButton) {
                        //settingsPage.accountWorkers = selectedAccountWorkers
                        //settingsPage.accountDb = accountGenerator.database
                        rightClickMenu.popup(accountsList, mouseX, mouseY)
                        return;
                    }

                    var nextPath = "/";
                    pageFlow.targetRemotePath = nextPath
                    __listCommand = selectedAccountWorkers.browserCommandQueue.directoryListingRequest(nextPath, false)

                    console.debug("onClicked: __listCommand " + __listCommand)
                }
            }
        }
    }

    AbortableBusyIndicator {
        anchors.centerIn: parent
        running: __listCommand != null
        buttonVisibiltyDelay: 5000
        onAbort: {
            if (!__listCommand)
                return
            __listCommand.abort(true)
        }
    }
}
