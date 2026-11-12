# ============================================================
# BOOGLE - Desktop Application
# Main Python Entry Point
# ============================================================

import sys
from pathlib import Path

from PySide6.QtCore import QUrl
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine

from desktop.backend.auth_backend import AuthBackend


def main():
    # Create the Qt GUI application.
    app = QGuiApplication(sys.argv)
    app.setApplicationName("Boogle")
    app.setOrganizationName("Boogle")

    # Create the QML engine.
    engine = QQmlApplicationEngine()

    # Create the authentication backend.
    auth_backend = AuthBackend(app)

    # Expose the backend to QML.
    engine.rootContext().setContextProperty(
        "authBackend",
        auth_backend,
    )

    # Locate the main QML file.
    project_directory = Path(__file__).resolve().parent
    qml_file = project_directory / "qml" / "Main.qml"

    # Check whether the main QML file exists.
    if not qml_file.is_file():
        print(f"ERROR: Main QML file not found: {qml_file}")
        return -1

    # Load the QML application.
    engine.load(QUrl.fromLocalFile(str(qml_file)))

    # Stop if the QML interface failed to load.
    if not engine.rootObjects():
        print("ERROR: Failed to load the Boogle interface.")
        return -1

    # Start the Qt event loop.
    return app.exec()


if __name__ == "__main__":
    sys.exit(main())
