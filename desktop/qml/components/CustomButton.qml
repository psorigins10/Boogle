
import QtQuick
import QtQuick.Controls

Button {
    id: root

    property color gradientStart: "#38BDF8"
    property color gradientEnd: "#8B5CF6"

    property color textColor: "#FFFFFF"

    implicitWidth: 320
    implicitHeight: 54

    hoverEnabled: true

    background: Rectangle {
        radius: 11

        gradient: Gradient {
            GradientStop {
                position: 0.0
                color: root.enabled
                       ? root.gradientStart
                       : "#46516A"
            }

            GradientStop {
                position: 1.0
                color: root.enabled
                       ? root.gradientEnd
                       : "#46516A"
            }
        }

        opacity: root.enabled ? 1.0 : 0.5

        scale: root.down ? 0.97 : root.hovered ? 1.02 : 1.0

        Behavior on scale {
            NumberAnimation {
                duration: 130
                easing.type: Easing.OutCubic
            }
        }

        Behavior on opacity {
            NumberAnimation { duration: 150 }
        }
    }

    contentItem: Text {
        text: root.text

        color: root.textColor

        font.pixelSize: 15
        font.weight: Font.DemiBold

        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }
}
