
import QtQuick
import QtQuick.Controls

Item {
    id: root

    // Public properties
    property string label: "Label"
    property string placeholder: "Enter text"
    property string text: ""

    property bool passwordField: false
    property bool emailField: false
    // property bool enabled: true

    property int fieldHeight: 54

    // Expose input validity and focus state.
    property alias inputField: textInput
    readonly property bool focused: textInput.activeFocus

    implicitHeight: 82
    implicitWidth: 320

    // Label above the input.
    Text {
        id: fieldLabel

        anchors.top: parent.top
        anchors.left: parent.left

        text: root.label
        color: "#DCE5F5"

        font.pixelSize: 13
        font.weight: Font.DemiBold
    }

    // Input background.
    Rectangle {
        id: fieldBackground

        anchors.top: fieldLabel.bottom
        anchors.topMargin: 9

        width: parent.width
        height: root.fieldHeight

        radius: 10

        color: root.enabled ? "#151D35" : "#101729"

        border.width: root.focused ? 1.5 : 1
        border.color: root.focused ? "#4F8BFF" : "#33415F"

        Behavior on border.color {
            ColorAnimation { duration: 160 }
        }

        Behavior on border.width {
            NumberAnimation { duration: 160 }
        }

        TextInput {
            id: textInput

            anchors.left: parent.left
            anchors.leftMargin: 16

            anchors.right: visibilityButton.left
            anchors.rightMargin: root.passwordField ? 8 : 16

            anchors.verticalCenter: parent.verticalCenter

            height: parent.height - 4

            verticalAlignment: TextInput.AlignVCenter

            color: "#FFFFFF"
            selectionColor: "#4F8BFF"
            selectedTextColor: "#FFFFFF"

            font.pixelSize: 14

            text: root.text
            enabled: root.enabled

            clip: true

            echoMode: root.passwordField && !showPassword.checked
                      ? TextInput.Password
                      : TextInput.Normal

            inputMethodHints: root.emailField
                              ? Qt.ImhEmailCharactersOnly | Qt.ImhNoAutoUppercase
                              : Qt.ImhNone

            onTextChanged: root.text = text
        }

        Text {
            anchors.left: textInput.left
            anchors.verticalCenter: parent.verticalCenter

            text: root.placeholder

            color: "#71809D"
            font.pixelSize: 14

            visible: textInput.text.length === 0
                     && !textInput.activeFocus

            z: 1
        }

        // Password visibility button.
        Rectangle {
            id: visibilityButton

            width: 38
            height: 38

            anchors.right: parent.right
            anchors.rightMargin: 8
            anchors.verticalCenter: parent.verticalCenter

            radius: 8

            color: visibilityArea.containsMouse
                   ? "#263653"
                   : "transparent"

            visible: root.passwordField

            Text {
                anchors.centerIn: parent

                text: showPassword.checked ? "Hide" : "Show"

                color: "#9BAFD0"
                font.pixelSize: 11
            }

            MouseArea {
                id: visibilityArea

                anchors.fill: parent
                hoverEnabled: true

                onClicked: showPassword.checked = !showPassword.checked
            }

            CheckBox {
                id: showPassword
                visible: false
            }
        }
    }
}
