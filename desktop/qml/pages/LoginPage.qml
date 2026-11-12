
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../components"

Item {
    id: root

    // Navigation signals.
    signal loginRequested(string email, string password, bool keepLoggedIn)
    signal signupRequested()
    signal forgotPasswordRequested()
    signal otpVerified(string email)
    signal loginCompleted(string email)

    // UI state.
    property bool keepLoggedIn: false
    property string validationMessage: ""
    property string loginStage: "credentials"

    // anchors.fill: parent

    // ========================================================
    // BACKEND CONNECTIONS
    // ========================================================

    Connections {
        target: authBackend

        function onLoginOTPSent(email) {
            root.loginStage = "otp"
            otpInput.text = ""
            otpError.text = ""
            root.validationMessage = ""
            otpInput.forceActiveFocus()
        }

        function onLoginSucceeded(email) {
            root.loginStage = "success"
            otpError.text = ""
            root.validationMessage = ""
        }

        function onLoginOTPResent(message) {
            otpInput.text = ""
            otpError.text = message
        }

        function onErrorOccurred(message) {
            if (root.loginStage === "otp") {
                otpError.text = message
            } else {
                root.validationMessage = message
            }
        }
    }

    // ========================================================
    // LOGIN FORM
    // ========================================================

    Column {
        id: loginForm

        width: 390

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: 15

        spacing: 18

        // ----------------------------------------------------
        // BOOGLE LOGO
        // ----------------------------------------------------

        Image {
            width: 65
            height: 65

            anchors.horizontalCenter: parent.horizontalCenter

            source: "../assets/boogle-mark.svg"
            fillMode: Image.PreserveAspectFit
        }

        // ----------------------------------------------------
        // HEADING
        // ----------------------------------------------------

        Column {
            width: parent.width
            spacing: 7

            Text {
                width: parent.width

                text: root.loginStage === "credentials"
                      ? "Welcome back!"
                      : root.loginStage === "otp"
                        ? "Verify your login"
                        : "Login successful!"

                color: "#FFFFFF"

                font.pixelSize: 30
                font.weight: Font.Bold

                horizontalAlignment: Text.AlignHCenter
            }

            Text {
                width: parent.width

                text: root.loginStage === "credentials"
                      ? "Sign in to continue to Boogle."
                      : root.loginStage === "otp"
                        ? "Enter the 6-digit verification code."
                        : "Welcome back to Boogle."

                color: "#A0AEC0"
                font.pixelSize: 14

                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
            }
        }

        Item {
            width: 1
            height: 5
        }

        // ====================================================
        // CREDENTIALS STAGE
        // ====================================================

        Column {
            width: parent.width
            spacing: 18

            visible: root.loginStage === "credentials"

            CustomTextField {
                id: emailField

                width: parent.width

                label: "Email address"
                placeholder: "Enter your email address"

                emailField: true
            }

            CustomTextField {
                id: passwordField

                width: parent.width

                label: "Password"
                placeholder: "Enter your password"

                passwordField: true
            }

            // KEEP LOGGED IN + FORGOT PASSWORD

            Row {
                width: parent.width
                height: 35
                spacing: 4

                CheckBox {
                    id: rememberCheckbox

                    checked: root.keepLoggedIn

                    onCheckedChanged: root.keepLoggedIn = checked

                    indicator.width: 19
                    indicator.height: 19

                    contentItem: Item {}
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter

                    text: "Keep me logged in"

                    color: "#A0AEC0"
                    font.pixelSize: 12

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor

                        onClicked: {
                            rememberCheckbox.checked =
                                    !rememberCheckbox.checked
                        }
                    }
                }

                Item {
                    Layout.fillWidth: true
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter

                    text: "Forgot password?"

                    color: "#60A5FA"
                    font.pixelSize: 12
                    font.weight: Font.DemiBold

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor

                        onClicked: root.forgotPasswordRequested()
                    }
                }
            }

            // VALIDATION MESSAGE

            Text {
                width: parent.width

                text: root.validationMessage

                color: "#F87171"
                font.pixelSize: 12

                wrapMode: Text.WordWrap
                visible: text.length > 0
            }

            // SIGN IN BUTTON

            CustomButton {
                width: parent.width

                text: authBackend.busy ? "Please wait..." : "Sign In"
                enabled: !authBackend.busy

                onClicked: {
                    root.validationMessage = ""

                    if (emailField.text.trim().length === 0) {
                        root.validationMessage =
                                "Please enter your email address."
                        return
                    }

                    if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(
                                emailField.text.trim())) {
                        root.validationMessage =
                                "Please enter a valid email address."
                        return
                    }

                    if (passwordField.text.length === 0) {
                        root.validationMessage =
                                "Please enter your password."
                        return
                    }

                    authBackend.login(
                        emailField.text.trim(),
                        passwordField.text,
                        root.keepLoggedIn
                    )
                }
            }

            // SIGNUP NAVIGATION

            Row {
                anchors.horizontalCenter: parent.horizontalCenter

                spacing: 5

                Text {
                    text: "Don't have an account?"

                    color: "#A0AEC0"
                    font.pixelSize: 13
                }

                Text {
                    text: "Create account"

                    color: "#60A5FA"

                    font.pixelSize: 13
                    font.weight: Font.DemiBold

                    MouseArea {
                        anchors.fill: parent

                        cursorShape: Qt.PointingHandCursor

                        onClicked: root.signupRequested()
                    }
                }
            }
        }

        // ====================================================
        // OTP VERIFICATION STAGE
        // ====================================================

        Column {
            width: parent.width
            spacing: 17

            visible: root.loginStage === "otp"

            Text {
                width: parent.width

                text: "A verification code has been sent to:"
                color: "#A0AEC0"
                font.pixelSize: 12

                horizontalAlignment: Text.AlignHCenter
            }

            Text {
                width: parent.width

                text: emailField.text.trim()
                color: "#FFFFFF"
                font.pixelSize: 13
                font.weight: Font.DemiBold

                horizontalAlignment: Text.AlignHCenter
            }

            // SIX-DIGIT OTP INPUT

            Item {
                id: otpContainer

                width: parent.width
                height: 58

                Row {
                    anchors.fill: parent
                    spacing: 10

                    Repeater {
                        model: 6

                        Rectangle {
                            width: (otpContainer.width - 50) / 6
                            height: 54

                            radius: 9
                            color: "#1A2440"

                            border.width:
                                otpInput.activeFocus &&
                                index === otpInput.text.length &&
                                otpInput.text.length < 6 ? 2 : 1

                            border.color:
                                otpInput.activeFocus &&
                                index === otpInput.text.length &&
                                otpInput.text.length < 6
                                ? "#4F8BFF" : "#334B6D"

                            Text {
                                anchors.centerIn: parent

                                text: index < otpInput.text.length
                                      ? otpInput.text.charAt(index)
                                      : ""

                                color: "#FFFFFF"
                                font.pixelSize: 23
                                font.weight: Font.DemiBold
                            }
                        }
                    }
                }

                TextInput {
                    id: otpInput

                    anchors.fill: parent

                    opacity: 0
                    focus: root.loginStage === "otp"

                    maximumLength: 6
                    inputMethodHints: Qt.ImhDigitsOnly

                    validator: RegularExpressionValidator {
                        regularExpression: /[0-9]{0,6}/
                    }

                    onTextChanged: otpError.text = ""
                }

                MouseArea {
                    anchors.fill: parent

                    onClicked: otpInput.forceActiveFocus()
                }
            }

            Text {
                id: otpError

                width: parent.width

                text: ""
                color: "#F87171"

                font.pixelSize: 12
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
            }

            // VERIFY OTP BUTTON

            CustomButton {
                width: parent.width
                height: 52

                text: authBackend.busy
                      ? "Verifying..."
                      : "Verify & Sign In"

                enabled: !authBackend.busy

                onClicked: {
                    otpError.text = ""

                    if (otpInput.text.length !== 6) {
                        otpError.text =
                                "Please enter the complete 6-digit code."
                        return
                    }

                    authBackend.verifyLoginOTP(
                        emailField.text.trim(),
                        otpInput.text,
                        root.keepLoggedIn
                    )
                }
            }

            // RESEND OTP

            Text {
                width: parent.width

                text: authBackend.busy ? "Please wait..." : "Resend OTP"
                color: authBackend.busy ? "#64748B" : "#60A5FA"

                font.pixelSize: 13
                font.weight: Font.DemiBold

                horizontalAlignment: Text.AlignHCenter

                MouseArea {
                    anchors.fill: parent
                    enabled: !authBackend.busy
                    cursorShape: Qt.PointingHandCursor

                    onClicked: {
                        otpError.text = ""
                        authBackend.resendLoginOTP(
                            emailField.text.trim()
                        )
                    }
                }
            }

            // BACK TO LOGIN

            Text {
                width: parent.width

                text: "Back to login"
                color: "#A0AEC0"

                font.pixelSize: 12
                horizontalAlignment: Text.AlignHCenter

                MouseArea {
                    anchors.fill: parent
                    enabled: !authBackend.busy
                    cursorShape: Qt.PointingHandCursor

                    onClicked: {
                        root.loginStage = "credentials"
                        otpInput.text = ""
                        otpError.text = ""
                        root.validationMessage = ""
                    }
                }
            }
        }

        // ====================================================
        // SUCCESS STAGE
        // ====================================================

        Column {
            width: parent.width
            spacing: 15

            visible: root.loginStage === "success"

            Text {
                width: parent.width

                text: "✓"
                color: "#4ADE80"

                font.pixelSize: 60
                font.weight: Font.Bold

                horizontalAlignment: Text.AlignHCenter
            }

            Text {
                width: parent.width

                text: "You have successfully verified your login."
                color: "#A0AEC0"

                font.pixelSize: 13
                wrapMode: Text.WordWrap

                horizontalAlignment: Text.AlignHCenter
            }

            CustomButton {
                width: parent.width
                height: 52

                text: "Continue"
                enabled: !authBackend.busy

                onClicked: {
                    root.loginCompleted(emailField.text.trim())
                }
            }
        }
    }
}
