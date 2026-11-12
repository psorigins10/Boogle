
import QtQuick
import QtQuick.Window

Item {
    id: resizeHandler

    // The ApplicationWindow that will be resized.
    property var targetWindow

    // Thickness of the invisible resize zones.
    property int thickness: 6

    // Don't allow manual resizing while maximized.
    readonly property bool canResize: targetWindow
                                      && targetWindow.visibility !== Window.Maximized
    enabled: canResize

    // --------------------------------------------------------
    // LEFT EDGE
    // --------------------------------------------------------

    MouseArea {
        width: resizeHandler.thickness

        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom

        cursorShape: Qt.SizeHorCursor
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton

        onPressed: {
            if (resizeHandler.canResize)
                resizeHandler.targetWindow.startSystemResize(Qt.LeftEdge)
        }
    }

    // --------------------------------------------------------
    // RIGHT EDGE
    // --------------------------------------------------------

    MouseArea {
        width: resizeHandler.thickness

        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom

        cursorShape: Qt.SizeHorCursor
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton

        onPressed: {
            if (resizeHandler.canResize)
                resizeHandler.targetWindow.startSystemResize(Qt.RightEdge)
        }
    }

    // --------------------------------------------------------
    // TOP EDGE
    // --------------------------------------------------------

    MouseArea {
        height: resizeHandler.thickness

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right

        cursorShape: Qt.SizeVerCursor
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton

        onPressed: {
            if (resizeHandler.canResize)
                resizeHandler.targetWindow.startSystemResize(Qt.TopEdge)
        }
    }

    // --------------------------------------------------------
    // BOTTOM EDGE
    // --------------------------------------------------------

    MouseArea {
        height: resizeHandler.thickness

        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right

        cursorShape: Qt.SizeVerCursor
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton

        onPressed: {
            if (resizeHandler.canResize)
                resizeHandler.targetWindow.startSystemResize(Qt.BottomEdge)
        }
    }

    // --------------------------------------------------------
    // TOP-LEFT CORNER
    // --------------------------------------------------------

    MouseArea {
        width: resizeHandler.thickness
        height: resizeHandler.thickness

        anchors.top: parent.top
        anchors.left: parent.left

        cursorShape: Qt.SizeFDiagCursor
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton

        onPressed: {
            if (resizeHandler.canResize) {
                resizeHandler.targetWindow.startSystemResize(
                    Qt.TopEdge | Qt.LeftEdge
                )
            }
        }
    }

    // --------------------------------------------------------
    // TOP-RIGHT CORNER
    // --------------------------------------------------------

    MouseArea {
        width: resizeHandler.thickness
        height: resizeHandler.thickness

        anchors.top: parent.top
        anchors.right: parent.right

        cursorShape: Qt.SizeBDiagCursor
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton

        onPressed: {
            if (resizeHandler.canResize) {
                resizeHandler.targetWindow.startSystemResize(
                    Qt.TopEdge | Qt.RightEdge
                )
            }
        }
    }

    // --------------------------------------------------------
    // BOTTOM-LEFT CORNER
    // --------------------------------------------------------

    MouseArea {
        width: resizeHandler.thickness
        height: resizeHandler.thickness

        anchors.bottom: parent.bottom
        anchors.left: parent.left

        cursorShape: Qt.SizeBDiagCursor
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton

        onPressed: {
            if (resizeHandler.canResize) {
                resizeHandler.targetWindow.startSystemResize(
                    Qt.BottomEdge | Qt.LeftEdge
                )
            }
        }
    }

    // --------------------------------------------------------
    // BOTTOM-RIGHT CORNER
    // --------------------------------------------------------

    MouseArea {
        width: resizeHandler.thickness
        height: resizeHandler.thickness

        anchors.bottom: parent.bottom
        anchors.right: parent.right

        cursorShape: Qt.SizeFDiagCursor
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton

        onPressed: {
            if (resizeHandler.canResize) {
                resizeHandler.targetWindow.startSystemResize(
                    Qt.BottomEdge | Qt.RightEdge
                )
            }
        }
    }
}
