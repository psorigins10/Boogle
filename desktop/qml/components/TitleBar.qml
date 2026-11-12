
import QtQuick
import QtQuick.Window

Rectangle {
    id: titleBar

    // The window that this title bar controls.
    // Main.qml will pass its ApplicationWindow here.
    property var targetWindow

    height: 64
    color: "#661A2440"

    // Bottom separator.
    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        visible: false
        height: 1
        color: "#334F8BFF"
    }

    // --------------------------------------------------------
    // BOOGLE BRANDING
    // --------------------------------------------------------

    Row {
        id: branding

        anchors.left: parent.left
        anchors.leftMargin: 28
        anchors.verticalCenter: parent.verticalCenter

        spacing: 10

        Image {
            width: 30
            height: 34

            source: "../assets/boogle-mark.svg"
            fillMode: Image.PreserveAspectFit
        }

        Text {
            text: "Boogle"

            color: "#FFFFFF"

            font.pixelSize: 21
            font.weight: Font.DemiBold

            anchors.verticalCenter: parent.verticalCenter
        }
    }

    // --------------------------------------------------------
    // WINDOW CONTROL BUTTONS
    // --------------------------------------------------------

    Row {
        id: windowControls

        anchors.right: parent.right
        anchors.rightMargin: 20
        anchors.verticalCenter: parent.verticalCenter

        spacing: 10

        // MINIMIZE
        Rectangle {
            width: 36
            height: 36
            radius: 8

            color: minimizeArea.containsMouse
                   ? "#334A5B78"
                   : "transparent"

            Text {
                anchors.centerIn: parent

                text: "—"
                color: "#FFFFFF"
                font.pixelSize: 18
            }

            MouseArea {
                id: minimizeArea

                anchors.fill: parent
                hoverEnabled: true

                onClicked: {
                    if (!titleBar.targetWindow ||
                        !titleBar.targetWindow.allowMaximize)
                        return

                    if (titleBar.targetWindow.visibility === Window.Maximized)
                        titleBar.targetWindow.showNormal()
                    else
                        titleBar.targetWindow.showMaximized()
                }
            }

            Behavior on color {
                ColorAnimation { duration: 150 }
            }
        }


        // MAXIMIZE / RESTORE
        Rectangle {
            id: maximizeButton

            width: 36
            height: 36
            radius: 8

            // Is maximizing currently allowed?
            readonly property bool isEnabled: titleBar.targetWindow
                                            && titleBar.targetWindow.allowMaximize

            // No hover color when disabled.
            color: !isEnabled
                ? "transparent"
                : maximizeArea.containsMouse
                    ? "#334A5B78"
                    : "transparent"

            opacity: isEnabled ? 1.0 : 0.4

            Text {
                anchors.centerIn: parent

                text: titleBar.targetWindow
                    && titleBar.targetWindow.visibility === Window.Maximized
                    ? "❐" : "□"

                color: "#FFFFFF"
                font.pixelSize: 17
            }

            MouseArea {
                id: maximizeArea

                anchors.fill: parent

                // Disable all mouse interaction when maximizing is disabled.
                enabled: maximizeButton.isEnabled
                hoverEnabled: enabled

                cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor

                onClicked: {
                    if (!maximizeButton.isEnabled)
                        return

                    if (titleBar.targetWindow.visibility === Window.Maximized)
                        titleBar.targetWindow.showNormal()
                    else
                        titleBar.targetWindow.showMaximized()
                }
            }

            Behavior on color {
                ColorAnimation {
                    duration: 150
                }
            }

            Behavior on opacity {
                NumberAnimation {
                    duration: 150
                }
            }
        }


        // CLOSE
        Rectangle {
            width: 36
            height: 36
            radius: 8

            color: closeArea.containsMouse
                   ? "#DC3545"
                   : "transparent"

            Text {
                anchors.centerIn: parent

                text: "×"
                color: "#FFFFFF"
                font.pixelSize: 25
            }

            MouseArea {
                id: closeArea

                anchors.fill: parent
                hoverEnabled: true

                onClicked: {
                    if (titleBar.targetWindow)
                        titleBar.targetWindow.close()
                }
            }

            Behavior on color {
                ColorAnimation { duration: 150 }
            }
        }
    }

    
    // --------------------------------------------------------
    // WINDOW DRAG AND DOUBLE-CLICK AREA
    // --------------------------------------------------------

    Item {
        id: dragArea

        anchors.left: branding.right
        anchors.leftMargin: 12

        anchors.right: windowControls.left
        anchors.rightMargin: 8

        anchors.top: parent.top
        anchors.bottom: parent.bottom

        // Drag the native window when the user moves the pointer.
        DragHandler {
            target: null

            onActiveChanged: {
                if (active && titleBar.targetWindow) {
                    titleBar.targetWindow.startSystemMove()
                }
            }
        }

        // Double-click to maximize or restore.
        TapHandler {
            acceptedButtons: Qt.LeftButton

            onDoubleTapped: {
                if (!titleBar.targetWindow ||
                    !titleBar.targetWindow.allowMaximize)
                    return

                if (titleBar.targetWindow.visibility === Window.Maximized)
                    titleBar.targetWindow.showNormal()
                else
                    titleBar.targetWindow.showMaximized()
            }
        }
    }
}
