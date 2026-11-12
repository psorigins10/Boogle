import keyring
from keyring.errors import KeyringError


SERVICE_NAME = "Boogle"


class SecureStorageError(Exception):
    """Raised when secure credential storage fails."""


def save_token(token: str) -> None:
    if not token:
        raise SecureStorageError("Cannot save an empty token.")

    try:
        keyring.set_password(SERVICE_NAME, "access_token", token)
    except KeyringError as error:
        raise SecureStorageError(
            "Could not securely save your login session."
        ) from error


def get_token() -> str | None:
    try:
        return keyring.get_password(SERVICE_NAME, "access_token")
    except KeyringError as error:
        raise SecureStorageError(
            "Could not access your saved login session."
        ) from error


def delete_token() -> None:
    try:
        keyring.delete_password(SERVICE_NAME, "access_token")
    except keyring.errors.PasswordDeleteError:
        pass
    except KeyringError as error:
        raise SecureStorageError(
            "Could not remove your saved login session."
        ) from error
