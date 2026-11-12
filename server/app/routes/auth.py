from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.database.connection import get_db
from app.schemas.auth import (
    SignupRequest,
    SignupResponse,
    VerifySignupOTPRequest,
    VerifySignupOTPResponse,
    ResendOTPRequest,
    ResendOTPResponse,
    LoginRequest,
    LoginResponse,
    VerifyLoginOTPRequest,
    LoginTokenResponse,
)
from app.services.auth_service import (
    AuthServiceError,
    register_user,
    verify_signup_otp,
    resend_signup_otp,
    login_user,
    verify_login_otp,
    resend_login_otp,
)
from app.services.email_service import (
    email_is_configured,
    send_signup_otp,
    send_login_otp,
)

router = APIRouter(prefix="/auth", tags=["Authentication"])


def raise_auth_error(error: AuthServiceError) -> None:
    status_codes = {
        "email_already_registered": status.HTTP_409_CONFLICT,
        "unverified_registration_exists": status.HTTP_409_CONFLICT,
        "otp_cooldown": status.HTTP_429_TOO_MANY_REQUESTS,
        "otp_expired": status.HTTP_400_BAD_REQUEST,
        "otp_attempts_exceeded": status.HTTP_429_TOO_MANY_REQUESTS,
        "invalid_otp": status.HTTP_400_BAD_REQUEST,
        "invalid_credentials": status.HTTP_401_UNAUTHORIZED,
        "verification_unavailable": status.HTTP_400_BAD_REQUEST,
    }

    raise HTTPException(
        status_code=status_codes.get(
            error.code, status.HTTP_400_BAD_REQUEST
        ),
        detail=error.message,
    )


@router.post(
    "/signup",
    response_model=SignupResponse,
    status_code=status.HTTP_201_CREATED,
)
async def signup(
    payload: SignupRequest,
    db: AsyncSession = Depends(get_db),
):
    if not email_is_configured():
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Email delivery is not configured yet.",
        )

    try:
        user, otp = await register_user(
            db,
            payload.full_name,
            str(payload.email),
            payload.password,
        )

        await send_signup_otp(user.email, otp)

        return SignupResponse(
            message="Account created. Check your email for the verification code.",
            user_id=user.id,
            email=user.email,
        )

    except AuthServiceError as error:
        raise_auth_error(error)

    except Exception:
        raise HTTPException(
            status_code=status.HTTP_502_BAD_GATEWAY,
            detail="We couldn't send the verification email. Please try again later.",
        )


@router.post(
    "/verify-signup-otp",
    response_model=VerifySignupOTPResponse,
)
async def verify_signup(
    payload: VerifySignupOTPRequest,
    db: AsyncSession = Depends(get_db),
):
    try:
        user = await verify_signup_otp(
            db,
            str(payload.email),
            payload.otp,
        )

        return VerifySignupOTPResponse(
            message="Email verified successfully.",
            email=user.email,
        )

    except AuthServiceError as error:
        raise_auth_error(error)


@router.post(
    "/resend-signup-otp",
    response_model=ResendOTPResponse,
)
async def resend_signup(
    payload: ResendOTPRequest,
    db: AsyncSession = Depends(get_db),
):
    if not email_is_configured():
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Email delivery is not configured yet.",
        )

    try:
        otp = await resend_signup_otp(db, str(payload.email))
        await send_signup_otp(str(payload.email), otp)

        return ResendOTPResponse(
            message="If the account is eligible, a verification email has been sent."
        )

    except AuthServiceError as error:
        raise_auth_error(error)

    except Exception:
        raise HTTPException(
            status_code=status.HTTP_502_BAD_GATEWAY,
            detail="We couldn't send the verification email. Please try again later.",
        )


@router.post(
    "/login",
    response_model=LoginResponse,
)
async def login(
    payload: LoginRequest,
    db: AsyncSession = Depends(get_db),
):
    if not email_is_configured():
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Email delivery is not configured yet.",
        )

    try:
        user, otp = await login_user(
            db,
            str(payload.email),
            payload.password,
        )

        await send_login_otp(user.email, otp)

        return LoginResponse(
            message="If your credentials are valid, a login code has been sent.",
            email=user.email,
        )

    except AuthServiceError as error:
        raise_auth_error(error)

    except Exception:
        raise HTTPException(
            status_code=status.HTTP_502_BAD_GATEWAY,
            detail="We couldn't send the login email. Please try again later.",
        )


@router.post(
    "/verify-login-otp",
    response_model=LoginTokenResponse,
)
async def verify_login(
    payload: VerifyLoginOTPRequest,
    db: AsyncSession = Depends(get_db),
):
    try:
        access_token, expires_in = await verify_login_otp(
            db,
            str(payload.email),
            payload.otp,
            payload.remember_me,
        )

        return LoginTokenResponse(
            message="Login successful.",
            access_token=access_token,
            token_type="bearer",
            expires_in=expires_in,
        )

    except AuthServiceError as error:
        raise_auth_error(error)


@router.post(
    "/resend-login-otp",
    response_model=ResendOTPResponse,
)
async def resend_login(
    payload: ResendOTPRequest,
    db: AsyncSession = Depends(get_db),
):
    if not email_is_configured():
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Email delivery is not configured yet.",
        )

    try:
        otp = await resend_login_otp(db, str(payload.email))
        await send_login_otp(str(payload.email), otp)

        return ResendOTPResponse(
            message="If the account is eligible, a login code has been sent."
        )

    except AuthServiceError as error:
        raise_auth_error(error)

    except Exception:
        raise HTTPException(
            status_code=status.HTTP_502_BAD_GATEWAY,
            detail="We couldn't send the login email. Please try again later.",
        )