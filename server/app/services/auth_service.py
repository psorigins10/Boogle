from datetime import datetime, timedelta, timezone
from sqlalchemy import select
from sqlalchemy.exc import IntegrityError
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.config import settings
from app.models import User, EmailOTP
from app.services.security import (
    generate_otp,
    hash_password,
    hash_otp,
    verify_otp,
    verify_password,
    create_access_token,
)


class AuthServiceError(Exception):
    """Expected authentication service errors."""

    def __init__(self, message: str, code: str):
        self.message = message
        self.code = code
        super().__init__(message)


def utc_now():
    return datetime.now(timezone.utc)


async def issue_otp(
    db: AsyncSession,
    user: User,
    purpose: str,
) -> str:
    """Invalidate the previous OTP and issue a new one."""

    now = utc_now()

    latest_result = await db.execute(
        select(EmailOTP)
        .where(
            EmailOTP.user_id == user.id,
            EmailOTP.purpose == purpose,
        )
        .order_by(EmailOTP.created_at.desc())
        .limit(1)
        .with_for_update()
    )

    latest_otp = latest_result.scalar_one_or_none()

    if latest_otp:
        if latest_otp.consumed_at is None:
            if latest_otp.created_at > now - timedelta(
                seconds=settings.OTP_RESEND_COOLDOWN_SECONDS
            ):
                raise AuthServiceError(
                    "Please wait before requesting another OTP.",
                    "otp_cooldown",
                )

            latest_otp.consumed_at = now

    code = generate_otp()

    otp_record = EmailOTP(
        user_id=user.id,
        purpose=purpose,
        code_hash=hash_otp(code, str(user.id), purpose),
        expires_at=now + timedelta(minutes=settings.OTP_EXPIRE_MINUTES),
        attempts=0,
        max_attempts=settings.OTP_MAX_ATTEMPTS,
    )

    db.add(otp_record)
    await db.flush()

    return code


async def issue_signup_otp(db: AsyncSession, user: User) -> str:
    return await issue_otp(db, user, "signup")


async def register_user(
    db: AsyncSession,
    full_name: str,
    email: str,
    password: str,
) -> tuple[User, str]:

    normalized_email = email.strip().casefold()

    existing_result = await db.execute(
        select(User).where(User.email == normalized_email)
    )
    existing_user = existing_result.scalar_one_or_none()

    if existing_user:
        if existing_user.is_email_verified:
            raise AuthServiceError(
                "An account with this email already exists.",
                "email_already_registered",
            )

        raise AuthServiceError(
            "An unverified registration already exists. "
            "Please request a new verification code.",
            "unverified_registration_exists",
        )

    user = User(
        full_name=full_name.strip(),
        email=normalized_email,
        password_hash=hash_password(password),
        is_email_verified=False,
        is_active=True,
    )

    try:
        db.add(user)
        await db.flush()

        otp = await issue_signup_otp(db, user)

        await db.commit()
        await db.refresh(user)

        return user, otp

    except IntegrityError:
        await db.rollback()
        raise AuthServiceError(
            "An account with this email already exists.",
            "email_already_registered",
        )

    except Exception:
        await db.rollback()
        raise


async def resend_signup_otp(db: AsyncSession, email: str) -> str:

    normalized_email = email.strip().casefold()

    result = await db.execute(
        select(User)
        .where(User.email == normalized_email)
        .with_for_update()
    )

    user = result.scalar_one_or_none()

    if user is None or user.is_email_verified or not user.is_active:
        raise AuthServiceError(
            "Unable to process this verification request.",
            "verification_unavailable",
        )

    try:
        otp = await issue_signup_otp(db, user)
        await db.commit()
        return otp

    except Exception:
        await db.rollback()
        raise


async def verify_signup_otp(
    db: AsyncSession,
    email: str,
    otp: str,
) -> User:

    normalized_email = email.strip().casefold()

    try:
        result = await db.execute(
            select(User)
            .where(User.email == normalized_email)
            .with_for_update()
        )
        user = result.scalar_one_or_none()

        if user is None or user.is_email_verified or not user.is_active:
            raise AuthServiceError(
                "Invalid or expired verification code.",
                "invalid_otp",
            )

        otp_result = await db.execute(
            select(EmailOTP)
            .where(
                EmailOTP.user_id == user.id,
                EmailOTP.purpose == "signup",
                EmailOTP.consumed_at.is_(None),
            )
            .order_by(EmailOTP.created_at.desc())
            .limit(1)
            .with_for_update()
        )

        otp_record = otp_result.scalar_one_or_none()

        if otp_record is None:
            raise AuthServiceError(
                "Invalid or expired verification code.",
                "invalid_otp",
            )

        now = utc_now()

        if otp_record.expires_at <= now:
            otp_record.consumed_at = now
            await db.commit()
            raise AuthServiceError(
                "Verification code has expired.",
                "otp_expired",
            )

        if otp_record.attempts >= otp_record.max_attempts:
            otp_record.consumed_at = now
            await db.commit()
            raise AuthServiceError(
                "Too many incorrect attempts. Request a new code.",
                "otp_attempts_exceeded",
            )

        if not verify_otp(
            otp,
            otp_record.code_hash,
            str(user.id),
            "signup",
        ):
            otp_record.attempts += 1

            if otp_record.attempts >= otp_record.max_attempts:
                otp_record.consumed_at = now

            await db.commit()
            raise AuthServiceError(
                "Invalid verification code.",
                "invalid_otp",
            )

        otp_record.consumed_at = now
        user.is_email_verified = True

        await db.commit()
        await db.refresh(user)

        return user

    except AuthServiceError:
        raise

    except Exception:
        await db.rollback()
        raise


async def login_user(
    db: AsyncSession,
    email: str,
    password: str,
) -> tuple[User, str]:

    normalized_email = email.strip().casefold()

    result = await db.execute(
        select(User).where(User.email == normalized_email)
    )
    user = result.scalar_one_or_none()

    # Keep the response generic to avoid revealing whether an account exists.
    if (
        user is None
        or not verify_password(password, user.password_hash)
        or not user.is_active
        or not user.is_email_verified
    ):
        raise AuthServiceError(
            "Invalid email or password.",
            "invalid_credentials",
        )

    try:
        otp = await issue_otp(db, user, "login")
        await db.commit()
        return user, otp

    except Exception:
        await db.rollback()
        raise

async def resend_login_otp(
    db: AsyncSession,
    email: str,
) -> str:
    """Issue another login OTP for an eligible account."""

    normalized_email = email.strip().casefold()

    try:
        result = await db.execute(
            select(User)
            .where(User.email == normalized_email)
            .with_for_update()
        )

        user = result.scalar_one_or_none()

        if (
            user is None
            or not user.is_active
            or not user.is_email_verified
        ):
            raise AuthServiceError(
                "Unable to process this login request.",
                "verification_unavailable",
            )

        otp = await issue_otp(db, user, "login")
        await db.commit()

        return otp

    except Exception:
        await db.rollback()
        raise

async def verify_login_otp(
    db: AsyncSession,
    email: str,
    otp: str,
    remember_me: bool = False,
) -> tuple[str, int]:

    normalized_email = email.strip().casefold()

    try:
        result = await db.execute(
            select(User)
            .where(User.email == normalized_email)
            .with_for_update()
        )
        user = result.scalar_one_or_none()

        if user is None or not user.is_active or not user.is_email_verified:
            raise AuthServiceError(
                "Invalid or expired verification code.",
                "invalid_otp",
            )

        otp_result = await db.execute(
            select(EmailOTP)
            .where(
                EmailOTP.user_id == user.id,
                EmailOTP.purpose == "login",
                EmailOTP.consumed_at.is_(None),
            )
            .order_by(EmailOTP.created_at.desc())
            .limit(1)
            .with_for_update()
        )

        otp_record = otp_result.scalar_one_or_none()

        if otp_record is None:
            raise AuthServiceError(
                "Invalid or expired verification code.",
                "invalid_otp",
            )

        now = utc_now()

        if otp_record.expires_at <= now:
            otp_record.consumed_at = now
            await db.commit()
            raise AuthServiceError(
                "Login code has expired.",
                "otp_expired",
            )

        if otp_record.attempts >= otp_record.max_attempts:
            otp_record.consumed_at = now
            await db.commit()
            raise AuthServiceError(
                "Too many incorrect attempts. Request a new code.",
                "otp_attempts_exceeded",
            )

        if not verify_otp(
            otp,
            otp_record.code_hash,
            str(user.id),
            "login",
        ):
            otp_record.attempts += 1

            if otp_record.attempts >= otp_record.max_attempts:
                otp_record.consumed_at = now

            await db.commit()
            raise AuthServiceError(
                "Invalid verification code.",
                "invalid_otp",
            )

        otp_record.consumed_at = now

        if remember_me:
            expires_in = settings.ACCESS_TOKEN_EXPIRE_MINUTES * 60 * 24 * 30
        else:
            expires_in = settings.ACCESS_TOKEN_EXPIRE_MINUTES * 60

        access_token = create_access_token(
            str(user.id),
            expires_delta=timedelta(seconds=expires_in),
        )

        await db.commit()

        return access_token, expires_in

    except AuthServiceError:
        raise

    except Exception:
        await db.rollback()
        raise
