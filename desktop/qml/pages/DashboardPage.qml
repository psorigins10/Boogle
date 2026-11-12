import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root

    signal logoutRequested()

    property string userEmail: ""
    property string currentSection: "Home"

    property date today: new Date()

    readonly property int currentYear: today.getFullYear()
    readonly property int daysInYear:
        (new Date(currentYear, 1, 29).getMonth() === 1) ? 366 : 365

    readonly property int dayOfYear:
        Math.floor((Date.UTC(today.getFullYear(), today.getMonth(),
                            today.getDate()) -
                    Date.UTC(today.getFullYear(), 0, 1)) / 86400000) + 1

    readonly property int daysRemaining: daysInYear - dayOfYear
    readonly property real yearProgress: dayOfYear / daysInYear * 100

    readonly property string formattedDate:
        Qt.formatDate(today, "dddd, d MMMM yyyy")

    readonly property var navigationItems: [
        { name: "Home", symbol: "⌂" },
        { name: "File Manager", symbol: "▤" },
        { name: "Notes", symbol: "▧" },
        { name: "Tasks", symbol: "✓" },
        { name: "Online Messages", symbol: "✉" },
        { name: "Yearbook", symbol: "▦" },
        { name: "Settings", symbol: "⚙" }
    ]


    Timer {
        interval: 60000
        running: true
        repeat: true

        onTriggered: root.today = new Date()
    }

    Rectangle {
        anchors.fill: parent
        color: "#080D1B"
    }

    RowLayout {
        anchors.fill: parent
        spacing: 0

        // ====================================================
        // SIDEBAR
        // ====================================================

        Rectangle {
            Layout.preferredWidth: 235
            Layout.fillHeight: true

            color: "#10182B"
            border.color: "#263653"
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 12

                // BRAND

                RowLayout {
                    Layout.fillWidth: true
                    Layout.topMargin: 8
                    spacing: 10

                    Rectangle {
                        Layout.preferredWidth: 38
                        Layout.preferredHeight: 38
                        radius: 11

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
                            text: "B"
                            color: "white"
                            font.pixelSize: 23
                            font.bold: true
                        }
                    }

                    Column {
                        spacing: 1

                        Text {
                            text: "Boogle"
                            color: "white"
                            font.pixelSize: 19
                            font.bold: true
                        }

                        Text {
                            text: "YOUR WORKSPACE"
                            color: "#7185A8"
                            font.pixelSize: 9
                            font.letterSpacing: 1.5
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.topMargin: 8
                    height: 1
                    color: "#263653"
                }

                Text {
                    text: "WORKSPACE"
                    color: "#7185A8"
                    font.pixelSize: 10
                    font.bold: true
                    font.letterSpacing: 1.3
                    Layout.topMargin: 8
                    Layout.leftMargin: 8
                }

                // NAVIGATION

                Repeater {
                    model: root.navigationItems

                    delegate: Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 43

                        radius: 9

                        color: root.currentSection === modelData.name
                               ? "#263D68" : "transparent"

                        border.width:
                            root.currentSection === modelData.name ? 1 : 0
                        border.color: "#416DB4"

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            anchors.rightMargin: 10
                            spacing: 12

                            Text {
                                text: modelData.symbol
                                color: root.currentSection === modelData.name
                                       ? "#8AB8FF" : "#91A2BF"
                                font.pixelSize: 19
                                Layout.preferredWidth: 22
                                horizontalAlignment: Text.AlignHCenter
                            }

                            Text {
                                text: modelData.name
                                color: root.currentSection === modelData.name
                                       ? "#FFFFFF" : "#A0AEC0"
                                font.pixelSize: 12
                                font.weight:
                                    root.currentSection === modelData.name
                                    ? Font.DemiBold : Font.Normal

                                Layout.fillWidth: true
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor

                            onClicked: {
                                root.currentSection = modelData.name
                            }
                        }

                        Behavior on color {
                            ColorAnimation { duration: 140 }
                        }
                    }
                }

                Item {
                    Layout.fillHeight: true
                }

                // USER PROFILE

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: "#263653"
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    Rectangle {
                        Layout.preferredWidth: 36
                        Layout.preferredHeight: 36
                        radius: 18
                        color: "#293D68"

                        Text {
                            anchors.centerIn: parent
                            text: root.userEmail.length > 0
                                  ? root.userEmail.charAt(0).toUpperCase()
                                  : "U"
                            color: "white"
                            font.bold: true
                        }
                    }

                    Column {
                        Layout.fillWidth: true
                        spacing: 3

                        Text {
                            text: "Your account"
                            color: "white"
                            font.pixelSize: 12
                            font.bold: true
                        }

                        Text {
                            text: root.userEmail
                            color: "#8293B0"
                            font.pixelSize: 9
                            elide: Text.ElideMiddle
                            width: 135
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 38
                    radius: 8
                    color: logoutMouse.containsMouse
                           ? "#482637" : "transparent"

                    Row {
                        anchors.centerIn: parent
                        spacing: 9

                        Text {
                            text: "↪"
                            color: "#FCA5A5"
                            font.pixelSize: 17
                        }

                        Text {
                            text: "Sign out"
                            color: "#FCA5A5"
                            font.pixelSize: 12
                        }
                    }

                    MouseArea {
                        id: logoutMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor

                        onClicked: root.logoutRequested()
                    }
                }
            }
        }

        // ====================================================
        // MAIN CONTENT
        // ====================================================

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true

            color: "transparent"

            ScrollView {
                anchors.fill: parent
                clip: true

                ScrollBar.vertical.policy: ScrollBar.AsNeeded

                Column {
                    width: Math.max(implicitWidth, 0)
                    spacing: 22
                    padding: 30

                    // TOP HEADER

                    RowLayout {
                        width: parent.width
                        spacing: 12

                        Column {
                            Layout.fillWidth: true
                            spacing: 5

                            Text {
                                text: root.currentSection === "Home"
                                      ? "Welcome to Boogle"
                                      : root.currentSection

                                color: "#FFFFFF"
                                font.pixelSize: 27
                                font.bold: true
                            }

                            Text {
                                text: root.currentSection === "Home"
                                      ? "Your space. Your plans. Your progress."
                                      : "Your Boogle " +
                                        root.currentSection.toLowerCase() +
                                        " workspace."

                                color: "#91A2BF"
                                font.pixelSize: 12
                            }
                        }

                        Rectangle {
                            Layout.preferredWidth: 155
                            Layout.preferredHeight: 42
                            radius: 9
                            color: "#17233A"
                            border.color: "#2A3D5D"

                            Text {
                                anchors.centerIn: parent
                                text: Qt.formatDate(root.today, "d MMM yyyy")
                                color: "#C6D5EA"
                                font.pixelSize: 11
                            }
                        }
                    }

                    // HOME CONTENT

                    Column {
                        width: parent.width
                        spacing: 20

                        visible: root.currentSection === "Home"

                        // YEAR PROGRESS CARD

                        Rectangle {
                            width: parent.width
                            height: 190
                            radius: 17
                            clip: true

                            gradient: Gradient {
                                GradientStop {
                                    position: 0
                                    color: "#1D3765"
                                }
                                GradientStop {
                                    position: 1
                                    color: "#34245F"
                                }
                            }

                            Rectangle {
                                width: 220
                                height: 220
                                radius: 110
                                color: "#4F8BFF"
                                opacity: 0.08
                                x: parent.width - 130
                                y: -100
                            }

                            Column {
                                anchors.fill: parent
                                anchors.margins: 23
                                spacing: 10

                                Text {
                                    text: "YOUR YEAR, YOUR JOURNEY"
                                    color: "#B5CFFF"
                                    font.pixelSize: 10
                                    font.bold: true
                                    font.letterSpacing: 1.4
                                }

                                RowLayout {
                                    width: parent.width

                                    Column {
                                        Layout.fillWidth: true
                                        spacing: 3

                                        Text {
                                            text: root.currentYear.toString()
                                            color: "white"
                                            font.pixelSize: 31
                                            font.bold: true
                                        }

                                        Text {
                                            text: root.daysRemaining +
                                                  " days remaining"
                                            color: "#D2DDF5"
                                            font.pixelSize: 12
                                        }
                                    }

                                    Text {
                                        text: root.yearProgress.toFixed(1) + "%"
                                        color: "white"
                                        font.pixelSize: 27
                                        font.bold: true
                                    }
                                }

                                Rectangle {
                                    width: parent.width
                                    height: 10
                                    radius: 5
                                    color: "#554F668D"
                                    clip: true

                                    Rectangle {
                                        width: parent.width *
                                               root.yearProgress / 100
                                        height: parent.height
                                        radius: 5
                                        color: "#8BC5FF"
                                    }
                                }

                                Text {
                                    text: "Day " + root.dayOfYear +
                                          " of " + root.daysInYear
                                    color: "#D2DDF5"
                                    font.pixelSize: 10
                                }
                            }
                        }

                        // QUICK OVERVIEW

                        GridLayout {
                            width: parent.width
                            columns: width >= 700 ? 3 : 1
                            columnSpacing: 14
                            rowSpacing: 14

                            Repeater {
                                model: [
                                    {
                                        title: "Today's tasks",
                                        value: "Get started",
                                        detail: "Plan your day",
                                        symbol: "✓"
                                    },
                                    {
                                        title: "Notes",
                                        value: "Your ideas",
                                        detail: "Capture a thought",
                                        symbol: "▧"
                                    },
                                    {
                                        title: "Messages",
                                        value: "Stay connected",
                                        detail: "Your conversations",
                                        symbol: "✉"
                                    }
                                ]

                                delegate: Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 125

                                    radius: 13
                                    color: "#141F35"
                                    border.color: "#293B5A"

                                    Column {
                                        anchors.fill: parent
                                        anchors.margins: 16
                                        spacing: 8

                                        Text {
                                            text: modelData.symbol
                                            color: "#75A9FF"
                                            font.pixelSize: 21
                                        }

                                        Text {
                                            text: modelData.title
                                            color: "white"
                                            font.pixelSize: 13
                                            font.bold: true
                                        }

                                        Text {
                                            text: modelData.detail
                                            color: "#91A2BF"
                                            font.pixelSize: 10
                                        }
                                    }
                                }
                            }
                        }

                        // DAILY FOCUS CARD

                        Rectangle {
                            width: parent.width
                            height: 125
                            radius: 13
                            color: "#141F35"
                            border.color: "#293B5A"

                            Column {
                                anchors.fill: parent
                                anchors.margins: 18
                                spacing: 8

                                Text {
                                    text: "Make today count."
                                    color: "white"
                                    font.pixelSize: 17
                                    font.bold: true
                                }

                                Text {
                                    width: parent.width
                                    text: "Your daily tasks, progress check-ins and " +
                                          "end-of-day snapshots will live here."
                                    color: "#91A2BF"
                                    font.pixelSize: 11
                                    wrapMode: Text.WordWrap
                                }

                                Text {
                                    text: "Open Tasks  →"
                                    color: "#75A9FF"
                                    font.pixelSize: 11
                                    font.bold: true

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: root.currentSection = "Tasks"
                                    }
                                }
                            }
                        }
                    }

                    // PLACEHOLDER FOR OTHER SECTIONS

                    Rectangle {
                        width: parent.width
                        height: 230
                        radius: 15
                        color: "#141F35"
                        border.color: "#293B5A"

                        visible: root.currentSection !== "Home"

                        Column {
                            anchors.centerIn: parent
                            width: parent.width - 50
                            spacing: 12

                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: root.currentSection === "Yearbook"
                                      ? "▦" : "✦"
                                color: "#75A9FF"
                                font.pixelSize: 38
                            }

                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: root.currentSection
                                color: "white"
                                font.pixelSize: 20
                                font.bold: true
                            }

                            Text {
                                width: parent.width
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: "This section is ready for development. " +
                                      "We'll build its features and connect " +
                                      "them to your Boogle account next."
                                color: "#91A2BF"
                                font.pixelSize: 12
                                wrapMode: Text.WordWrap
                                horizontalAlignment: Text.AlignHCenter
                            }

                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: "Back to Home"
                                color: "#75A9FF"
                                font.pixelSize: 12

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: root.currentSection = "Home"
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
