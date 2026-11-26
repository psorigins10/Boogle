# Desktop Application

The desktop client is built with Python, PySide6, Qt Quick, and QML. It owns the user interface and communicates with the FastAPI service over HTTP.

## Entry point

desktop/main.py creates the QGuiApplication and QQmlApplicationEngine, instantiates AuthBackend, exposes it to QML as authBackend, and loads desktop/qml/Main.qml.

## Interface

The main QML window uses a frameless application window and a StackView for page navigation.

Implemented pages:

- **Welcome** — introduction and navigation to account creation
- **Signup** — registration form and signup verification flow
- **Login** — credentials, email verification code, and Remember Me
- **Forgot password** — password-reset interface; the server-side reset workflow is not yet connected
- **Dashboard** — authenticated home view with navigation and placeholder productivity sections

Reusable QML components include CustomButton, CustomTextField, TitleBar, and WindowResizeHandler.

## Authentication bridge

desktop/backend/auth_backend.py exposes Qt properties, slots, and signals for authentication. Requests run in QRunnable workers on the shared QThreadPool, avoiding blocking the UI during network operations.

APIClient in desktop/backend/api_client.py wraps the implemented authentication endpoints, handles JSON responses, and translates HTTP/network failures into APIError.

## Session storage

desktop/backend/secure_storage.py uses the operating system credential store through Python's keyring package to save, retrieve, and delete the access token when Remember Me is selected.

The current client loads a saved token into its local authentication state at startup. A server-validated session restoration flow is not yet implemented.
