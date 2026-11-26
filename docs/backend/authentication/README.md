# Authentication

The server implements email-verified registration and email OTP-based login. Authentication logic is in server/app/services/auth_service.py; HTTP routes are in server/app/routes/auth.py.

## Signup

1. The client submits a name, email, and password to POST /auth/signup.
2. The service normalizes the email, hashes the password with Argon2id, creates an unverified user, and issues a signup OTP.
3. The OTP is delivered through the configured SMTP server.
4. The user submits the six-digit code to POST /auth/verify-signup-otp.
5. A valid code is consumed and the user's email is marked verified.

Signup OTPs expire, have a configurable attempt limit, and are subject to a resend cooldown. Stored OTP values are keyed HMAC hashes rather than plaintext codes.

## Login

1. The client submits email and password to POST /auth/login.
2. The service verifies the password and account status, then sends a login OTP.
3. The client submits the code to POST /auth/verify-login-otp.
4. A valid code is consumed and a signed JWT access token is returned.

Login errors use a generic invalid-credentials message for unknown, inactive, unverified, or incorrect-password accounts.

## Access tokens

JWTs are signed with the configured algorithm and secret. The default lifetime is controlled by ACCESS_TOKEN_EXPIRE_MINUTES. The Remember Me option requests a longer token lifetime; the desktop client stores the token using the operating system credential store.

The GET /auth/me endpoint uses the bearer-token dependency to decode the token, resolve the user ID, and confirm the user is active.

## Resending codes

Signup and login each provide a resend endpoint. Issuing a new code consumes the previous active code, and the configured cooldown limits repeated requests.

## Current scope

The desktop includes a forgot-password page, but password-reset endpoints and service workflows are not currently implemented. The desktop also does not yet validate a stored token against a protected endpoint during startup.
