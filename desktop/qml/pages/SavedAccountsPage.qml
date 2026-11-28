import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root

    // The Python backend will provide this list.
    // Each account: { account_id: string, email: string }
    property var accounts: []

    signal backRequested()
    signal refreshRequested()
    signal removeAccountRequested(string accountId)

    Rectangle {
        anchors.fill: parent
        color: "#080D1B"
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 36
        spacing: 22

        // PAGE HEADER

        RowLayout {
            Layout.fillWidth: true
            spacing: 16

            Rectangle {
                width: 48
                height: 48
                radius: 14

                gradient: Gradient {
                    GradientStop {
                        position: 0
                        color: "#38BDF8"
                    }

                    GradientStop {
                        position: 1
                        color: "#8B5CF6"
                    }
                }

                Text {
                    anchors.centerIn: parent
                    text: "⌘"
                    color: "white"
                    font.pixelSize: 25
                    font.bold: true
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4

                Text {
                    text: "Saved Accounts"
                    color: "#FFFFFF"
                    font.pixelSize: 25
                    font.bold: true
                }

                Text {
                    text: "Accounts stored on this computer"
                    color: "#7185A8"
                    font.pixelSize: 13
                }
            }

            Button {
                text: "Refresh"
                onClicked: root.refreshRequested()

                background: Rectangle {
                    radius: 9
                    color: parent.hovered
                           ? "#263D68"
                           : "#17233B"
                    border.color: "#334C75"
                    border.width: 1
                }

                contentItem: Text {
                    text: parent.text
                    color: "#DCE5F5"
                    font.pixelSize: 12
                    font.weight: Font.DemiBold
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }

            Button {
                text: "Back"
                onClicked: root.backRequested()

                background: Rectangle {
                    radius: 9
                    color: parent.hovered
                           ? "#263653"
                           : "#10182B"
                    border.color: "#263653"
                    border.width: 1
                }

                contentItem: Text {
                    text: parent.text
                    color: "#A0AEC0"
                    font.pixelSize: 12
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }

        // DESCRIPTION CARD

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 82

            radius: 12
            color: "#10182B"
            border.color: "#263653"
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.margins: 18
                spacing: 14

                Text {
                    text: "ⓘ"
                    color: "#8AB8FF"
                    font.pixelSize: 23
                }

                Text {
                    Layout.fillWidth: true

                    text: "These accounts are saved in your computer's secure storage. "
                          + "This list does not verify whether their tokens are valid."
                    color: "#A0AEC0"
                    font.pixelSize: 12
                    wrapMode: Text.WordWrap
                }
            }
        }

        // ACCOUNT COUNT

        RowLayout {
            Layout.fillWidth: true

            Text {
                text: "LOCAL ACCOUNTS"
                color: "#7185A8"
                font.pixelSize: 10
                font.bold: true
                font.letterSpacing: 1.4
            }

            Item {
                Layout.fillWidth: true
            }

            Text {
                text: root.accounts.length + " saved"
                color: "#8AB8FF"
                font.pixelSize: 12
                font.weight: Font.DemiBold
            }
        }

        // ACCOUNT LIST

        ListView {
            id: accountList

            Layout.fillWidth: true
            Layout.fillHeight: true

            clip: true
            spacing: 12

            model: root.accounts

            delegate: Rectangle {
                required property var modelData

                width: accountList.width
                height: 88

                radius: 12
                color: "#10182B"
                border.color: "#263653"
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 14

                    // ACCOUNT ICON

                    Rectangle {
                        Layout.preferredWidth: 46
                        Layout.preferredHeight: 46

                        radius: 13
                        color: "#202C49"
                        border.color: "#3B4E78"
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: "●"
                            color: "#8AB8FF"
                            font.pixelSize: 20
                        }
                    }

                    // ACCOUNT DETAILS

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 5

                        Text {
                            Layout.fillWidth: true

                            text: modelData.email
                            color: "#FFFFFF"
                            font.pixelSize: 14
                            font.weight: Font.DemiBold
                            elide: Text.ElideRight
                        }

                        Text {
                            text: "Saved on this device"
                            color: "#7185A8"
                            font.pixelSize: 11
                        }
                    }

                    // REMOVE ACCOUNT

                    Button {
                        text: "Remove"
                        onClicked: root.removeAccountRequested(
                                       modelData.account_id
                                   )

                        background: Rectangle {
                            radius: 8
                            color: parent.hovered
                                   ? "#512B45"
                                   : "#2B2036"
                            border.color: "#75415F"
                            border.width: 1
                        }

                        contentItem: Text {
                            text: parent.text
                            color: "#F0A8D0"
                            font.pixelSize: 11
                            font.weight: Font.DemiBold
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }
            }

            // EMPTY STATE

            Column {
                anchors.centerIn: parent
                spacing: 10

                visible: root.accounts.length === 0

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "◇"
                    color: "#4F6388"
                    font.pixelSize: 38
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "No saved accounts"
                    color: "#DCE5F5"
                    font.pixelSize: 16
                    font.bold: true
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Accounts saved with Remember Me will appear here."
                    color: "#7185A8"
                    font.pixelSize: 12
                }
            }
        }
    }
}
