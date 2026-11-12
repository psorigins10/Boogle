import QtQuick
import QtQuick.Controls
import QtQuick.Window

// Reusable components and application pages.
import "pages"
import "components"


ApplicationWindow {
    id: root

    // ========================================================
    // WINDOW STATE
    // ========================================================

    property bool allowMaximize: false
    property string currentUserEmail: ""

    onVisibilityChanged: function(visibility) {
        if (!allowMaximize && visibility === Window.Maximized) {
            showNormal()
        }
    }

    // ========================================================
    // WINDOW CONFIGURATION
    // ========================================================

    width: 1280
    height: 720

    minimumWidth: allowMaximize ? 1024 : 1280
    minimumHeight: allowMaximize ? 576 : 720

    maximumWidth: allowMaximize ? 16777215 : 1280
    maximumHeight: allowMaximize ? 16777215 : 720

    visible: true
    title: "Boogle"

    flags: Qt.Window | Qt.FramelessWindowHint
    color: "transparent"


    // ========================================================
    // MAIN WINDOW BACKGROUND
    // ========================================================

    Rectangle {
        id: windowBackground

        anchors.fill: parent

        radius: 16
        clip: true

        color: "#0B1020"

        border.width: 1
        border.color: "#4B4A91"

        gradient: Gradient {
            GradientStop {
                position: 0.0
                color: "#10132B"
            }

            GradientStop {
                position: 0.5
                color: "#0B1020"
            }

            GradientStop {
                position: 1.0
                color: "#11132F"
            }
        }


        // ====================================================
        // ANIMATED PURPLE BACKGROUND GLOW
        // ====================================================

        Rectangle {
            id: purpleGlow

            width: 650
            height: 500

            x: -300
            y: -310

            radius: 250

            gradient: Gradient {
                GradientStop {
                    position: 0.0
                    color: "#8B5CF6"
                }

                GradientStop {
                    position: 0.65
                    color: "#5424A8"
                }

                GradientStop {
                    position: 1.0
                    color: "#00000000"
                }
            }

            opacity: 0.38

            NumberAnimation on x {
                from: -300
                to: -180
                duration: 7000
                loops: Animation.Infinite
                easing.type: Easing.InOutSine
            }

            NumberAnimation on y {
                from: -310
                to: -250
                duration: 8500
                loops: Animation.Infinite
                easing.type: Easing.InOutSine
            }
        }


        // ====================================================
        // ANIMATED BLUE BACKGROUND GLOW
        // ====================================================

        Rectangle {
            id: blueGlow

            width: 650
            height: 450

            x: parent.width - 280
            y: parent.height - 220

            radius: 225

            gradient: Gradient {
                GradientStop {
                    position: 0.0
                    color: "#2563EB"
                }

                GradientStop {
                    position: 0.65
                    color: "#3730A3"
                }

                GradientStop {
                    position: 1.0
                    color: "#00000000"
                }
            }

            opacity: 0.32

            NumberAnimation on x {
                from: 1000
                to: 850
                duration: 9000
                loops: Animation.Infinite
                easing.type: Easing.InOutSine
            }

            NumberAnimation on y {
                from: 500
                to: 440
                duration: 7500
                loops: Animation.Infinite
                easing.type: Easing.InOutSine
            }
        }


        // ====================================================
        // SUBTLE AMBIENT LIGHT
        // ====================================================

        Rectangle {
            width: 350
            height: 350

            anchors.centerIn: parent

            radius: 175

            color: "#4338CA"
            opacity: 0.045

            SequentialAnimation on opacity {
                loops: Animation.Infinite

                NumberAnimation {
                    to: 0.09
                    duration: 3500
                    easing.type: Easing.InOutSine
                }

                NumberAnimation {
                    to: 0.035
                    duration: 3500
                    easing.type: Easing.InOutSine
                }
            }
        }


        // ====================================================
        // CUSTOM TITLE BAR
        // ====================================================

        TitleBar {
            id: titleBar

            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right

            targetWindow: root

            z: 10
        }


        // ====================================================
        // WELCOME PAGE COMPONENT
        // ====================================================

        Component {
            id: welcomePageComponent

            WelcomePage {

                onGetStarted: {
                    pageStack.push(signupPageComponent)
                }
            }
        }


        // ====================================================
        // SIGNUP PAGE COMPONENT
        // ====================================================

        Component {
            id: signupPageComponent

            SignupPage {
                onLoginRequested: {
                    pageStack.replace(loginPageComponent)
                }
            }
        }

        // ========================================================
        // LOGIN PAGE COMPONENT
        // ========================================================

        Component {
            id: loginPageComponent

            LoginPage {

                onLoginCompleted: function(email) {
                    root.currentUserEmail = email
                    root.allowMaximize = true
                    pageStack.replace(dashboardPageComponent)
                }

                onSignupRequested: {
                    pageStack.replace(signupPageComponent)
                }

                onForgotPasswordRequested: {
                    pageStack.push(forgotPasswordPageComponent)
                }
            }
        }

        // ========================================================
        // DASHBOARD PAGE COMPONENT
        // ========================================================

        Component {
            id: dashboardPageComponent

            DashboardPage {
                userEmail: root.currentUserEmail

                onLogoutRequested: {
                    root.currentUserEmail = ""
                    root.allowMaximize = false
                    pageStack.replace(loginPageComponent)
                }
            }
        }

        // ====================================================
        // FORGOT PASSWORD PAGE COMPONENT
        // ====================================================
    
        Component {
            id: forgotPasswordPageComponent

            ForgotPasswordPage {
                onBackToLogin: pageStack.replace(loginPageComponent)

                onResetRequested: function(email) {
                    console.log("OTP requested for:", email)
                    // Your backend will send the OTP.
                }

                onVerifyOtpRequested: function(email, otp) {
                    console.log("OTP verification requested for:", email)
                    // Your backend will verify the OTP.
                }

                onPasswordResetRequested: function(email, otp, newPassword) {
                    console.log("Password reset requested for:", email)
                    // Your backend will verify and update the password.
                }
            }
        }


        // ====================================================
        // PAGE NAVIGATION
        // ====================================================

        StackView {
            id: pageStack

            anchors {
                top: titleBar.bottom
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }

            clip: true

            initialItem: welcomePageComponent

            // ------------------------------------------------
            // PUSH ENTER
            // ------------------------------------------------

            pushEnter: Transition {
                ParallelAnimation {
                    NumberAnimation {
                        property: "x"
                        from: pageStack.width * 0.15
                        to: 0

                        duration: 300
                        easing.type: Easing.OutCubic
                    }

                    NumberAnimation {
                        property: "opacity"
                        from: 0
                        to: 1

                        duration: 300
                    }
                }
            }


            // ------------------------------------------------
            // PUSH EXIT
            // ------------------------------------------------

            pushExit: Transition {
                ParallelAnimation {
                    NumberAnimation {
                        property: "x"
                        from: 0
                        to: -pageStack.width * 0.08

                        duration: 250
                        easing.type: Easing.OutCubic
                    }

                    NumberAnimation {
                        property: "opacity"
                        from: 1
                        to: 0.5

                        duration: 250
                    }
                }
            }


            // ------------------------------------------------
            // POP ENTER
            // ------------------------------------------------

            popEnter: Transition {
                ParallelAnimation {
                    NumberAnimation {
                        property: "x"
                        from: -pageStack.width * 0.08
                        to: 0

                        duration: 300
                        easing.type: Easing.OutCubic
                    }

                    NumberAnimation {
                        property: "opacity"
                        from: 0.5
                        to: 1

                        duration: 300
                    }
                }
            }


            // ------------------------------------------------
            // POP EXIT
            // ------------------------------------------------

            popExit: Transition {
                ParallelAnimation {
                    NumberAnimation {
                        property: "x"
                        from: 0
                        to: pageStack.width * 0.15

                        duration: 250
                        easing.type: Easing.OutCubic
                    }

                    NumberAnimation {
                        property: "opacity"
                        from: 1
                        to: 0

                        duration: 250
                    }
                }
            }


            // ------------------------------------------------
            // REPLACE ENTER
            // ------------------------------------------------

            replaceEnter: Transition {
                ParallelAnimation {
                    NumberAnimation {
                        property: "x"
                        from: pageStack.width * 0.10
                        to: 0

                        duration: 280
                        easing.type: Easing.OutCubic
                    }

                    NumberAnimation {
                        property: "opacity"
                        from: 0
                        to: 1

                        duration: 280
                    }
                }
            }


            // ------------------------------------------------
            // REPLACE EXIT
            // ------------------------------------------------

            replaceExit: Transition {
                NumberAnimation {
                    property: "opacity"
                    from: 1
                    to: 0

                    duration: 180
                }
            }
        }


        // ====================================================
        // WINDOW RESIZE HANDLER
        // ====================================================

        WindowResizeHandler {
            anchors.fill: parent

            targetWindow: root

            z: 1000
        }
    }
}
