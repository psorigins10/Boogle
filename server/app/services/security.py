import hashlib
import hmac
import secrets
import string

from datetime import datetime, timedelta, timezone

import jwt
from jwt.exceptions import InvalidTokenError

from argon2 import PasswordHasher
from argon2.exceptions import (
    InvalidHashError,
    VerificationError,
    VerifyMismatchError,
)

from app.core.config import settings


password_hasher = PasswordHasher(
    time_cost=3,
    memory_cost=65536,
    parallelism=2,
    hash_len=32,
    salt_len=16,
)


def hash_password(password: str) -> str:
    """Hash a password using Argon2id."""
    return password_hasher.hash(password)


def verify_password(password: str, password_hash: str) -> bool:
    """Verify a password against its stored Argon2id hash."""
    try:
        return password_hasher.verify(password_hash, password)
    except (VerifyMismatchError, VerificationError, InvalidHashError):
        return False


def generate_otp() -> str:
    """Generate a cryptographically secure six-digit OTP."""
    return "".join(
        secrets.choice(string.digits)
        for _ in range(6)
    )


def hash_otp(otp: str, user_id: str, purpose: str) -> str:
    """Create a keyed HMAC hash of an OTP."""
    message = f"{user_id}:{purpose}:{otp}".encode("utf-8")

    return hmac.new(
        settings.OTP_SECRET_KEY.encode("utf-8"),
        message,
        hashlib.sha256,
    ).hexdigest()


def verify_otp(
    otp: str,
    stored_hash: str,
    user_id: str,
    purpose: str,
) -> bool:
    """Compare an OTP with its stored hash safely."""
    calculated_hash = hash_otp(
        otp,
        user_id,
        purpose,
    )

    return hmac.compare_digest(
        calculated_hash,
        stored_hash,
    )

def create_access_token(
    subject: str,
    expires_delta: timedelta | None = None,
) -> str:
    """Create a signed JWT access token."""

    now = datetime.now(timezone.utc)
    expires_at = now + (
        expires_delta
        or timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    )

    payload = {
        "sub": subject,
        "iat": now,
        "exp": expires_at,
    }

    return jwt.encode(
        payload,
        settings.JWT_SECRET_KEY,
        algorithm=settings.JWT_ALGORITHM,
    )


def decode_access_token(token: str) -> dict | None:
    """Decode and validate a JWT access token."""

    try:
        return jwt.decode(
            token,
            settings.JWT_SECRET_KEY,
            algorithms=[settings.JWT_ALGORITHM],
        )
    except InvalidTokenError:
        return None