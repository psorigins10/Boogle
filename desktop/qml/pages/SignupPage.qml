
import QtQuick
import QtQuick.Controls

import "../components"

Item {
    id: root

    signal loginRequested()

    property bool termsAccepted: false
    property string validationMessage: ""
    property string signupStage: "form"
    property string pendingEmail: ""

    anchors.fill: parent

    // Backend signals drive the signup stages.
    Connections {
        target: authBackend

        function onSignupSucceeded(email) {
            root.pendingEmail = email
            root.signupStage = "otp"
            root.validationMessage = ""
            otpInput.text = ""
            otpError.text = ""
            otpStatus.text = ""
            otpInput.forceActiveFocus()
        }

        function onOtpVerified(email) {
            root.signupStage = "success"
            otpError.text = ""
            otpStatus.text = ""
        }

        function onOtpResent(message) {
            otpInput.text = ""
            otpError.text = ""
            otpStatus.text = message
            otpInput.forceActiveFocus()
        }

        function onErrorOccurred(message) {
            if (root.signupStage === "form") {
                root.validationMessage = message
            } else if (root.signupStage === "otp") {
                otpError.text = message
            }
        }
    }

    Row {
        anchors.fill: parent
        anchors.margins: 65
        spacing: 70

        // LEFT BRANDING SECTION
        Item {
            width: parent.width * 0.42
            height: parent.height

            Column {
                anchors.centerIn: parent
                width: parent.width * 0.9
                spacing: 22

                Image {
                    width: 85
                    height: 85
                    source: "../assets/boogle-mark.svg"
                    fillMode: Image.PreserveAspectFit
                }

                Text {
                    text: "Join the\nBoogle experience."
                    color: "#FFFFFF"
                    font.pixelSize: 38
                    font.weight: Font.Bold
                    lineHeight: 1.2
                }

                Text {
                    width: parent.width
                    text: "One account. A connected experience. Everything you need, all in one place."
                    color: "#A0AEC0"
                    font.pixelSize: 15
                    wrapMode: Text.WordWrap
                    lineHeight: 1.5
                }

                Rectangle {
                    width: 110
                    height: 4
                    radius: 2

                    gradient: Gradient {
                        GradientStop {
                            position: 0.0
                            color: "#38BDF8"
                        }
                        GradientStop {
                            position: 1.0
                            color: "#8B5CF6"
                        }
                    }
                }
            }
        }

        // RIGHT SIGNUP SECTION
        Item {
            width: parent.width * 0.48
            height: parent.height

            Column {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: -70

                width: Math.min(parent.width, 410)
                spacing: 15

                // HEADING
                Text {
                    width: parent.width

                    text: {
                        if (root.signupStage === "form")
                            return "Create your account"
                        if (root.signupStage === "otp")
                            return "Verify your email"
                        return "Account created!"
                    }

                    color: "#FFFFFF"
                    font.pixelSize: 27
                    font.weight: Font.Bold
                }

                Text {
                    width: parent.width

                    text: {
                        if (root.signupStage === "form")
                            return "Get started with Boogle today."
                        if (root.signupStage === "otp")
                            return "Enter the 6-digit verification code."
                        return "Your Boogle account is ready."
                    }

                    color: "#A0AEC0"
                    font.pixelSize: 14
                    wrapMode: Text.WordWrap
                }

                Item {
                    width: 1
                    height: 2
                }

                // SIGNUP FORM STAGE
                Column {
                    width: parent.width
                    spacing: 15
                    visible: root.signupStage === "form"

                    CustomTextField {
                        id: fullNameField
                        width: parent.width
                        label: "Full name"
                        placeholder: "Enter your full name"
                    }

                    CustomTextField {
                        id: emailField
                        width: parent.width
                        label: "Email address"
                        placeholder: "you@example.com"
                        emailField: true
                    }

                    CustomTextField {
                        id: passwordField
                        width: parent.width
                        label: "Password"
                        placeholder: "Create a password"
                        passwordField: true
                    }

                    CustomTextField {
                        id: confirmPasswordField
                        width: parent.width
                        label: "Confirm password"
                        placeholder: "Re-enter your password"
                        passwordField: true
                    }

                    Row {
                        spacing: 9

                        CheckBox {
                            id: termsCheckbox
                            checked: root.termsAccepted

                            onCheckedChanged: {
                                root.termsAccepted = checked
                            }

                            indicator.width: 19
                            indicator.height: 19
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: "I agree to the Terms & Conditions"
                            color: "#A0AEC0"
                            font.pixelSize: 12
                        }
                    }

                    Text {
                        width: parent.width
                        text: root.validationMessage
                        color: "#F87171"
                        font.pixelSize: 12
                        wrapMode: Text.WordWrap
                        visible: text.length > 0
                    }

                    CustomButton {
                        width: parent.width
                        text: authBackend.busy
                              ? "Creating account..."
                              : "Create Account"

                        enabled: !authBackend.busy

                        onClicked: {
                            root.validationMessage = ""

                            if (fullNameField.text.trim().length === 0) {
                                root.validationMessage =
                                        "Please enter your full name."
                                return
                            }

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

                            if (passwordField.text.length < 8) {
                                root.validationMessage =
                                        "Password must contain at least 8 characters."
                                return
                            }

                            if (confirmPasswordField.text !== passwordField.text) {
                                root.validationMessage =
                                        "Passwords do not match."
                                return
                            }

                            if (!root.termsAccepted) {
                                root.validationMessage =
                                        "Please accept the Terms & Conditions."
                                return
                            }

                            // Send registration request to FastAPI.
                            authBackend.signup(
                                fullNameField.text.trim(),
                                emailField.text.trim(),
                                passwordField.text
                            )
                        }
                    }

                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 5

                        Text {
                            text: "Already have an account?"
                            color: "#A0AEC0"
                            font.pixelSize: 13
                        }

                        Text {
                            text: "Log in"
                            color: "#60A5FA"
                            font.pixelSize: 13
                            font.weight: Font.DemiBold

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.loginRequested()
                            }
                        }
                    }
                }

                // OTP VERIFICATION STAGE
                Column {
                    width: parent.width
                    spacing: 17
                    visible: root.signupStage === "otp"

                    Text {
                        width: parent.width
                        text: "A verification code has been sent to:"
                        color: "#A0AEC0"
                        font.pixelSize: 12
                        horizontalAlignment: Text.AlignHCenter
                    }

                    Text {
                        width: parent.width
                        text: root.pendingEmail
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
                            focus: root.signupStage === "otp" &&
                                   !authBackend.busy

                            maximumLength: 6
                            inputMethodHints: Qt.ImhDigitsOnly

                            validator: RegularExpressionValidator {
                                regularExpression: /[0-9]{0,6}/
                            }

                            enabled: !authBackend.busy
                        }

                        MouseArea {
                            anchors.fill: parent
                            enabled: !authBackend.busy
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

                    Text {
                        id: otpStatus
                        width: parent.width
                        text: ""
                        color: "#4ADE80"
                        font.pixelSize: 12
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                    }

                    CustomButton {
                        width: parent.width
                        height: 52

                        text: authBackend.busy
                              ? "Verifying..."
                              : "Verify & Create Account"

                        enabled: !authBackend.busy

                        onClicked: {
                            otpError.text = ""
                            otpStatus.text = ""

                            if (otpInput.text.length !== 6) {
                                otpError.text =
                                        "Please enter the complete 6-digit code."
                                return
                            }

                            // Verify OTP with FastAPI.
                            authBackend.verifySignupOTP(
                                root.pendingEmail,
                                otpInput.text
                            )
                        }
                    }

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
                                otpStatus.text = ""

                                // Request a fresh code from FastAPI.
                                authBackend.resendSignupOTP(root.pendingEmail)
                            }
                        }
                    }

                    Text {
                        width: parent.width
                        text: "Back to signup"
                        color: "#A0AEC0"
                        font.pixelSize: 12
                        horizontalAlignment: Text.AlignHCenter

                        MouseArea {
                            anchors.fill: parent
                            enabled: !authBackend.busy
                            cursorShape: Qt.PointingHandCursor

                            onClicked: {
                                root.signupStage = "form"
                                otpInput.text = ""
                                otpError.text = ""
                                otpStatus.text = ""
                            }
                        }
                    }
                }

                // SUCCESS STAGE
                Column {
                    width: parent.width
                    spacing: 16
                    visible: root.signupStage === "success"

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
                        text: "Your account has been successfully created!"
                        color: "#A0AEC0"
                        font.pixelSize: 13
                        wrapMode: Text.WordWrap
                        horizontalAlignment: Text.AlignHCenter
                    }

                    CustomButton {
                        width: parent.width
                        height: 52
                        text: "Go to Login"

                        onClicked: root.loginRequested()
                    }
                }
            }
        }
    }
}
