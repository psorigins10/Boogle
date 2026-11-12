import QtQuick
import QtQuick.Controls

Item {
    id: page

    // Signal emitted when the user clicks Get Started.
    signal getStarted()

    // ========================================================
    // MAIN LAYOUT
    // ========================================================

    Row {
        id: mainLayout

        anchors.fill: parent

        anchors.leftMargin: 75
        anchors.rightMargin: 75

        spacing: page.width * 0.04

        // ====================================================
        // LEFT SIDE - GLASSMORPHISM ILLUSTRATION
        // ====================================================

        Item {
            id: illustration

            width: mainLayout.width * 0.46
            height: mainLayout.height

            // -----------------------------------------------
            // BACK PURPLE GLASS CARD
            // -----------------------------------------------

            Rectangle {
                width: 225
                height: 295

                anchors.centerIn: parent

                anchors.horizontalCenterOffset: -65
                anchors.verticalCenterOffset: 45

                radius: 22

                rotation: -9

                color: "#34216D"

                border.width: 1
                border.color: "#8B5CF6"

                opacity: 0.9

                // Subtle floating rotation.
                SequentialAnimation on rotation {
                    loops: Animation.Infinite

                    NumberAnimation {
                        to: -6
                        duration: 3500
                        easing.type: Easing.InOutSine
                    }

                    NumberAnimation {
                        to: -9
                        duration: 3500
                        easing.type: Easing.InOutSine
                    }
                }
            }

            // -----------------------------------------------
            // MAIN BROWSER CARD
            // -----------------------------------------------

            Rectangle {
                id: browserCard

                width: Math.min(370, illustration.width * 0.88)
                height: 310

                anchors.centerIn: parent

                anchors.horizontalCenterOffset: 10

                radius: 25

                rotation: 5

                clip: true

                border.width: 1.5
                border.color: "#60A5FA"

                gradient: Gradient {
                    GradientStop {
                        position: 0.0
                        color: "#294A91"
                    }

                    GradientStop {
                        position: 0.55
                        color: "#192E63"
                    }

                    GradientStop {
                        position: 1.0
                        color: "#101B3C"
                    }
                }

                // Gentle floating movement.
                SequentialAnimation on rotation {
                    loops: Animation.Infinite

                    NumberAnimation {
                        to: 7
                        duration: 4000
                        easing.type: Easing.InOutSine
                    }

                    NumberAnimation {
                        to: 4
                        duration: 4000
                        easing.type: Easing.InOutSine
                    }
                }

                // -------------------------------------------
                // BROWSER TITLE BAR
                // -------------------------------------------

                Rectangle {
                    id: browserTitleBar

                    width: parent.width
                    height: 52

                    color: "#3158A8"

                    Row {
                        anchors.left: parent.left
                        anchors.leftMargin: 20

                        anchors.verticalCenter: parent.verticalCenter

                        spacing: 10

                        Repeater {
                            model: [
                                "#60A5FA",
                                "#38BDF8",
                                "#A78BFA"
                            ]

                            Rectangle {
                                width: 13
                                height: 13

                                radius: 7

                                color: modelData
                            }
                        }
                    }
                }

                // -------------------------------------------
                // CENTER BOOGLE LOGO
                // -------------------------------------------

                Image {
                    width: 105
                    height: 105

                    anchors.centerIn: parent

                    anchors.verticalCenterOffset: -10

                    source: "../assets/boogle-mark.svg"

                    fillMode: Image.PreserveAspectFit
                    smooth: true
                }

                // -------------------------------------------
                // SEARCH BAR ILLUSTRATION
                // -------------------------------------------

                Rectangle {
                    width: parent.width * 0.79
                    height: 48

                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom

                    anchors.bottomMargin: 35

                    radius: 25

                    color: "#263F79"

                    border.width: 1
                    border.color: "#527BC6"

                    Row {
                        anchors.fill: parent

                        anchors.leftMargin: 16
                        anchors.rightMargin: 14

                        spacing: 12

                        Text {
                            text: "⌕"

                            color: "#FFFFFF"

                            font.pixelSize: 29

                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            text: "Search something..."

                            color: "#B9CCF5"

                            font.pixelSize: 14

                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }
            }

            // -----------------------------------------------
            // FLOATING DECORATIVE ORBS
            // -----------------------------------------------

            Rectangle {
                width: 17
                height: 17

                radius: 9

                color: "#38BDF8"

                x: illustration.width * 0.79
                y: illustration.height * 0.23

                SequentialAnimation on y {
                    loops: Animation.Infinite

                    NumberAnimation {
                        to: illustration.height * 0.20
                        duration: 2200
                    }

                    NumberAnimation {
                        to: illustration.height * 0.23
                        duration: 2200
                    }
                }
            }

            Rectangle {
                width: 12
                height: 12

                radius: 6

                color: "#A855F7"

                x: illustration.width * 0.12
                y: illustration.height * 0.75

                opacity: 0.8
            }
        }

        // ====================================================
        // RIGHT SIDE - WELCOME CONTENT
        // ====================================================

        Column {
            id: welcomeContent

            width: mainLayout.width * 0.44

            anchors.verticalCenter: parent.verticalCenter

            spacing: 22

            // -----------------------------------------------
            // BOOGLE BRANDING
            // -----------------------------------------------

            Row {
                spacing: 14

                Image {
                    width: 50
                    height: 54
                    source: "../assets/boogle-mark.svg"
                    fillMode: Image.PreserveAspectFit
                }

                Text {
                    text: "Boogle"

                    color: "#FFFFFF"

                    font.family: "Poppins"
                    font.pixelSize: 34
                    font.weight: Font.DemiBold

                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            // -----------------------------------------------
            // MAIN HEADING
            // -----------------------------------------------

            Text {
                width: parent.width

                text: "Welcome to Boogle"

                color: "#FFFFFF"

                font.family: "Poppins"
                font.pixelSize: Math.min(
                    50,
                    Math.max(36, page.width * 0.039)
                )

                font.weight: Font.Bold

                wrapMode: Text.WordWrap

                lineHeight: 1.1
            }

            // -----------------------------------------------
            // DESCRIPTION
            // -----------------------------------------------

            Text {
                width: parent.width

                text: "A modern, fast, and secure desktop experience for your daily needs."

                color: "#A0AEC0"

                font.family: "Poppins"
                font.pixelSize: 19

                wrapMode: Text.WordWrap

                lineHeight: 1.4
            }

            // Small gap before the button.
            Item {
                width: 1
                height: 8
            }

            // -----------------------------------------------
            // GET STARTED BUTTON
            // -----------------------------------------------

            Button {
                id: getStartedButton

                width: 260
                height: 56

                text: "Get Started  →"

                font.family: "Poppins"
                font.pixelSize: 18
                font.weight: Font.DemiBold

                onClicked: page.getStarted()

                // Gradient button background.
                background: Rectangle {
                    radius: 28

                    gradient: Gradient {
                        GradientStop {
                            position: 0.0

                            color: getStartedButton.down
                                   ? "#2563EB"
                                   : getStartedButton.hovered
                                     ? "#60A5FA"
                                     : "#4F8BFF"
                        }

                        GradientStop {
                            position: 1.0

                            color: getStartedButton.down
                                   ? "#7C3AED"
                                   : getStartedButton.hovered
                                     ? "#A78BFA"
                                     : "#8B5CF6"
                        }
                    }

                    // Soft glow beneath the button.
                    Rectangle {
                        anchors.fill: parent

                        anchors.topMargin: 7

                        radius: parent.radius

                        color: "#8B5CF6"

                        opacity: getStartedButton.hovered
                                ? 0.32 : 0.12

                        z: -1
                    }
                }

                // Custom button typography.
                contentItem: Text {
                    text: getStartedButton.text

                    color: "#FFFFFF"

                    font: getStartedButton.font

                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                // Small hover scale animation.
                scale: hovered ? 1.035 : 1.0

                Behavior on scale {
                    NumberAnimation {
                        duration: 160
                        easing.type: Easing.OutCubic
                    }
                }
            }
        }
    }
}
