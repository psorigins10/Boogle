
import asyncio
from enum import Enum, auto

from PySide6.QtCore import (
    QObject,
    QRunnable,
    QThreadPool,
    Signal,
    Slot,
    Property,
)

from desktop.backend.api_client import APIClient, APIError
from desktop.backend.secure_storage import (
    save_token,
    get_token,
    delete_token,
    SecureStorageError,
)


class AuthState(Enum):
    INITIALIZING = auto()
    CHECKING_SESSION = auto()
    AUTHENTICATED = auto()
    UNAUTHENTICATED = auto()
    ERROR = auto()


class WorkerSignals(QObject):
    succeeded = Signal(str, object)
    failed = Signal(str, str)


class APIWorker(QRunnable):
    def __init__(self, operation, name, *args):
        super().__init__()
        self.operation = operation
        self.name = name
        self.args = args
        self.signals = WorkerSignals()

    def run(self):
        try:
            result = asyncio.run(self.operation(*self.args))
            self.signals.succeeded.emit(self.name, result)

        except APIError as error:
            self.signals.failed.emit(self.name, error.message)

        except Exception:
            self.signals.failed.emit(
                self.name,
                "Something went wrong. Please try again.",
            )


class AuthBackend(QObject):
    busyChanged = Signal(bool)
    stateChanged = Signal(str)

    signupSucceeded = Signal(str)
    otpVerified = Signal(str)
    otpResent = Signal(str)

    loginOTPSent = Signal(str)
    loginSucceeded = Signal(str)
    loginOTPResent = Signal(str)

    errorOccurred = Signal(str)

    def __init__(self, parent=None):
        super().__init__(parent)

        self.api = APIClient()
        self.thread_pool = QThreadPool.globalInstance()

        self._busy = False
        self._state = AuthState.UNAUTHENTICATED
        self._access_token = None
        self._pending_remember_me = False
        self._workers = set()

        self._set_state(AuthState.CHECKING_SESSION)

        try:
            saved_token = get_token()

            if saved_token:
                # A saved JWT is not trusted until the server validates it.
                # Session validation will be added with the protected API.
                self._access_token = saved_token
                self._set_state(AuthState.AUTHENTICATED)
            else:
                self._set_state(AuthState.UNAUTHENTICATED)

        except SecureStorageError:
            self._set_state(AuthState.UNAUTHENTICATED)

    @Property(bool, notify=busyChanged)
    def busy(self):
        return self._busy

    @Property(str, notify=stateChanged)
    def state(self):
        return self._state.name

    def _set_busy(self, value):
        if self._busy != value:
            self._busy = value
            self.busyChanged.emit(value)

    def _set_state(self, value):
        if self._state != value:
            self._state = value
            self.stateChanged.emit(value.name)

    def _start_request(self, operation, name, *args):
        if self._busy:
            self.errorOccurred.emit(
                "Please wait for the current request to finish."
            )
            return

        self._set_busy(True)

        worker = APIWorker(operation, name, *args)

        self._workers.add(worker)

        worker.signals.succeeded.connect(self._on_success)
        worker.signals.failed.connect(self._on_failure)

        worker.signals.succeeded.connect(
            lambda *_args, w=worker: self._workers.discard(w)
        )
        worker.signals.failed.connect(
            lambda *_args, w=worker: self._workers.discard(w)
        )

        self.thread_pool.start(worker)

    # ---------------- SIGNUP ----------------

    @Slot(str, str, str)
    def signup(self, full_name, email, password):
        self._start_request(
            self.api.signup,
            "signup",
            full_name,
            email,
            password,
        )

    @Slot(str, str)
    def verifySignupOTP(self, email, otp):
        self._start_request(
            self.api.verify_signup_otp,
            "verify_signup",
            email,
            otp,
        )

    @Slot(str)
    def resendSignupOTP(self, email):
        self._start_request(
            self.api.resend_signup_otp,
            "resend_signup",
            email,
        )

    # ---------------- LOGIN ----------------

    @Slot(str, str, bool)
    def login(self, email, password, remember_me=False):
        self._start_request(
            self.api.login,
            "login",
            email,
            password,
            remember_me,
        )

    @Slot(str, str, bool)
    def verifyLoginOTP(self, email, otp, remember_me=False):
        self._pending_remember_me = remember_me

        self._start_request(
            self.api.verify_login_otp,
            "verify_login",
            email,
            otp,
            remember_me,
        )

    @Slot(str)
    def resendLoginOTP(self, email):
        self._start_request(
            self.api.resend_login_otp,
            "resend_login",
            email,
        )

    @Slot()
    def logout(self):
        self._access_token = None

        try:
            delete_token()
        except SecureStorageError:
            self.errorOccurred.emit(
                "Could not remove the saved session from secure storage."
            )

        self._set_state(AuthState.UNAUTHENTICATED)

    # ---------------- API RESULTS ----------------

    @Slot(str, object)
    def _on_success(self, operation, result):
        self._set_busy(False)

        email = result.get("email", "")

        if operation == "signup":
            self.signupSucceeded.emit(email)

        elif operation == "verify_signup":
            # Email verification is not the same as logging in.
            self._set_state(AuthState.UNAUTHENTICATED)
            self.otpVerified.emit(email)

        elif operation == "resend_signup":
            self.otpResent.emit(
                result.get(
                    "message",
                    "Verification email requested.",
                )
            )

        elif operation == "login":
            self.loginOTPSent.emit(email)

        elif operation == "verify_login":
            token = result.get("access_token")
            if not token:
                self._set_state(AuthState.ERROR)
                self.errorOccurred.emit(
                    "The server did not return an access token."
                )
                return

            self._access_token = token

            # Persist the token only when the user opted into Remember Me.
            # The flag is supplied separately by the request callback below.
            remember_me = self._pending_remember_me

            if remember_me:
                try:
                    save_token(token)
                except SecureStorageError:
                    self._access_token = None
                    self._set_state(AuthState.ERROR)
                    self.errorOccurred.emit(
                        "Could not securely save your session. "
                        "Please try again without Remember Me."
                    )
                    return

            self._set_state(AuthState.AUTHENTICATED)
            self.loginSucceeded.emit(email)

        elif operation == "resend_login":
            self.loginOTPResent.emit(
                result.get(
                    "message",
                    "Login verification email requested.",
                )
            )

    @Slot(str, str)
    def _on_failure(self, operation, message):
        self._set_busy(False)
        self.errorOccurred.emit(message)
