
from email.message import EmailMessage

import aiosmtplib

from app.core.config import settings


def email_is_configured() -> bool:
    return all(
        [
            settings.SMTP_HOST,
            settings.SMTP_USERNAME,
            settings.SMTP_PASSWORD,
            settings.SMTP_FROM_EMAIL,
        ]
    )


async def send_signup_otp(email: str, otp: str) -> None:
    if not email_is_configured():
        raise RuntimeError("Email delivery is not configured.")

    message = EmailMessage()
    message["From"] = settings.SMTP_FROM_EMAIL
    message["To"] = email
    message["Subject"] = "Your Boogle verification code"

    message.set_content(
        f"""Welcome to Boogle!

Your email verification code is: {otp}

This code expires in {settings.OTP_EXPIRE_MINUTES} minutes.

If you did not request this code, you can ignore this email.
"""
    )

    await aiosmtplib.send(
        message,
        hostname=settings.SMTP_HOST,
        port=settings.SMTP_PORT,
        username=settings.SMTP_USERNAME,
        password=settings.SMTP_PASSWORD,
        start_tls=True,
    )


async def send_login_otp(email: str, otp: str) -> None:
    if not email_is_configured():
        raise RuntimeError("Email delivery is not configured.")

    message = EmailMessage()
    message["From"] = settings.SMTP_FROM_EMAIL
    message["To"] = email
    message["Subject"] = "Your Boogle login code"

    message.set_content(
        f"""Hello!

Your Boogle login verification code is: {otp}

This code expires in {settings.OTP_EXPIRE_MINUTES} minutes.

If you did not attempt to log in, you can ignore this email.
Consider changing your password if you suspect someone else
has access to your account.
"""
    )

    await aiosmtplib.send(
        message,
        hostname=settings.SMTP_HOST,
        port=settings.SMTP_PORT,
        username=settings.SMTP_USERNAME,
        password=settings.SMTP_PASSWORD,
        start_tls=True,
    )
