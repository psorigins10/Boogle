# API Reference

The FastAPI service defaults to http://127.0.0.1:8000. Interactive OpenAPI documentation is available at /docs while the service is running.

All request and response bodies below use JSON. Email values are normalized to lowercase by the request schemas. Signup and login email delivery require SMTP configuration.

## General

| Method | Path | Description |
| --- | --- | --- |
| GET | / | API welcome message and running status |
| GET | /health | Health status |

## Authentication

| Method | Path | Description |
| --- | --- | --- |
| POST | /auth/signup | Create an unverified account and send a signup code |
| POST | /auth/verify-signup-otp | Verify the signup email code |
| POST | /auth/resend-signup-otp | Request another signup code |
| POST | /auth/login | Validate credentials and send a login code |
| POST | /auth/verify-login-otp | Verify login code and return a JWT |
| POST | /auth/resend-login-otp | Request another login code |
| GET | /auth/me | Return the authenticated user's ID, name, and email |

## Request fields

- **Signup**: full_name (2–100 characters), email, password (8–128 characters)
- **Signup verification**: email, otp (exactly six digits)
- **Resend code**: email
- **Login**: email, password (8–128 characters), optional remember_me boolean
- **Login verification**: email, six-digit otp, optional remember_me boolean

Requests reject extra fields where the schema configures extra="forbid".

## Responses and errors

Successful responses are defined by the Pydantic models in server/app/schemas/auth.py. Authentication errors use HTTP status codes including 400 (invalid/expired code), 401 (invalid credentials or token), 409 (registration conflict), 429 (OTP cooldown or attempt limit), 502 (email delivery failure), and 503 (email delivery not configured).

Protected requests use the Authorization: Bearer <token> header. Password-reset endpoints are not implemented.
