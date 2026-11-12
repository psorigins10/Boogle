
import QtQuick
import QtQuick.Controls
import "../components"

Item {
    id: root

    signal backToLogin()
    signal resetRequested(string email)
    signal verifyOtpRequested(string email, string otp)
    signal passwordResetRequested(string email, string otp, string newPassword)

    property string stage: "email"
    property string emailAddress: ""
    property string otpCode: ""
    property string validationMessage: ""

    function goToEmail() {
        stage = "email"
        otpCode = ""
        otpInput.text = ""
        validationMessage = ""
    }

    Column {
        id: resetForm

        width: 390
        spacing: 17

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter

        Image {
            source: "../assets/boogle-mark.svg"
            width: 66
            height: 66
            fillMode: Image.PreserveAspectFit
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Text {
            width: parent.width
            text: {
                if (root.stage === "email") return "Forgot your password?"
                if (root.stage === "otp") return "Verify your email"
                if (root.stage === "password") return "Create new password"
                return "Password reset!"
            }
            color: "#FFFFFF"
            font.pixelSize: 27
            font.weight: Font.Bold
            horizontalAlignment: Text.AlignHCenter
        }

        Text {
            width: parent.width
            text: {
                if (root.stage === "email")
                    return "Enter your email address and we'll send you a verification code."
                if (root.stage === "otp")
                    return "Enter the 6-digit code sent to " + root.emailAddress
                if (root.stage === "password")
                    return "Choose a strong new password for your Boogle account."
                return "Your password has been reset. You can now sign in with your new password."
            }
            color: "#A0AEC0"
            font.pixelSize: 13
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
            lineHeight: 1.35
        }

        Item {
            width: 1
            height: 5
        }

        // EMAIL STAGE
        Column {
            width: parent.width
            spacing: 14
            visible: root.stage === "email"

            CustomTextField {
                id: emailField
                width: parent.width
                label: "Email address"
                placeholder: "Enter your email"
                emailField: true
            }

            Text {
                width: parent.width
                visible: root.validationMessage !== ""
                text: root.validationMessage
                color: "#F87171"
                font.pixelSize: 12
                wrapMode: Text.WordWrap
            }

            CustomButton {
                width: parent.width
                height: 52
                text: "Send OTP"

                onClicked: {
                    const email = emailField.text.trim()

                    if (email.length === 0) {
                        root.validationMessage = "Please enter your email address."
                    } else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
                        root.validationMessage = "Please enter a valid email address."
                    } else {
                        root.validationMessage = ""
                        root.emailAddress = email
                        root.resetRequested(email)
                        root.stage = "otp"
                    }
                }
            }
        }

        // OTP STAGE
        Column {
            width: parent.width
            spacing: 16
            visible: root.stage === "otp"

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

                            border.width: otpInput.activeFocus &&
                                        index === otpInput.text.length &&
                                        otpInput.text.length < 6 ? 2 : 1

                            border.color: otpInput.activeFocus &&
                                        index === otpInput.text.length &&
                                        otpInput.text.length < 6
                                        ? "#4F8BFF" : "#334B6D"

                            Text {
                                anchors.centerIn: parent
                                text: index < otpInput.text.length
                                    ? otpInput.text.charAt(index) : ""
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
                    focus: root.stage === "otp"
                    activeFocusOnTab: true

                    maximumLength: 6
                    inputMethodHints: Qt.ImhDigitsOnly
                    validator: RegularExpressionValidator {
                        regularExpression: /[0-9]{0,6}/
                    }

                    onTextChanged: root.otpCode = text

                    Keys.onPressed: function(event) {
                        if (event.key === Qt.Key_Backspace) {
                            event.accepted = false
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        otpInput.forceActiveFocus()
                    }
                }
            }

            Text {
                width: parent.width
                visible: root.validationMessage !== ""
                text: root.validationMessage
                color: "#F87171"
                font.pixelSize: 12
                horizontalAlignment: Text.AlignHCenter
            }

            CustomButton {
                width: parent.width
                height: 52
                text: "Verify OTP"

                onClicked: {
                    if (otpInput.text.length !== 6) {
                        root.validationMessage =
                            "Please enter the complete 6-digit code."
                    } else {
                        root.validationMessage = ""
                        root.otpCode = otpInput.text
                        root.verifyOtpRequested(
                            root.emailAddress,
                            root.otpCode
                        )
                        root.stage = "password"
                    }
                }
            }

            Text {
                width: parent.width
                text: "Resend OTP"
                color: "#60A5FA"
                font.pixelSize: 13
                font.weight: Font.DemiBold
                horizontalAlignment: Text.AlignHCenter

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor

                    onClicked: {
                        otpInput.text = ""
                        otpInput.forceActiveFocus()
                        root.otpCode = ""
                        root.validationMessage = ""
                        root.resetRequested(root.emailAddress)
                    }
                }
            }
        }


        // NEW PASSWORD STAGE
        Column {
            width: parent.width
            spacing: 14
            visible: root.stage === "password"

            CustomTextField {
                id: newPasswordField
                width: parent.width
                label: "New password"
                placeholder: "Enter your new password"
                passwordField: true
            }

            CustomTextField {
                id: confirmPasswordField
                width: parent.width
                label: "Confirm password"
                placeholder: "Confirm your new password"
                passwordField: true
            }

            Text {
                width: parent.width
                visible: root.validationMessage !== ""
                text: root.validationMessage
                color: "#F87171"
                font.pixelSize: 12
                wrapMode: Text.WordWrap
            }

            CustomButton {
                width: parent.width
                height: 52
                text: "Reset Password"

                onClicked: {
                    const password = newPasswordField.text
                    const confirmation = confirmPasswordField.text

                    if (password.length < 8) {
                        root.validationMessage = "Password must be at least 8 characters."
                    } else if (password !== confirmation) {
                        root.validationMessage = "Passwords do not match."
                    } else {
                        root.validationMessage = ""
                        root.passwordResetRequested(
                            root.emailAddress,
                            root.otpCode,
                            password
                        )
                        root.stage = "success"
                    }
                }
            }
        }

        // SUCCESS STAGE
        Column {
            width: parent.width
            spacing: 14
            visible: root.stage === "success"

            Text {
                width: parent.width
                text: "✓"
                color: "#4ADE80"
                font.pixelSize: 54
                font.weight: Font.Bold
                horizontalAlignment: Text.AlignHCenter
            }

            CustomButton {
                width: parent.width
                height: 52
                text: "Back to Login"
                onClicked: root.backToLogin()
            }
        }

        Text {
            width: parent.width
            text: "Back to Login"
            color: "#A0AEC0"
            font.pixelSize: 12
            horizontalAlignment: Text.AlignHCenter
            visible: root.stage !== "success"

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: root.backToLogin()
            }
        }
    }
}
