# Backend Service

The backend is a FastAPI application located in server/app/.

## Application

app/main.py creates the FastAPI instance, registers the authentication router, exposes root and health endpoints, and disposes the database engine during application shutdown.

## Configuration

Settings are defined in app/core/config.py using Pydantic Settings. The application reads server/.env.

| Setting | Purpose |
| --- | --- |
| APP_NAME | API title |
| DEBUG | FastAPI debug mode and SQLAlchemy SQL logging |
| DATABASE_URL | Async PostgreSQL connection URL |
| JWT_SECRET_KEY, JWT_ALGORITHM | JWT signing configuration |
| ACCESS_TOKEN_EXPIRE_MINUTES | Default access-token lifetime |
| OTP_SECRET_KEY | HMAC key used to hash verification codes |
| OTP_EXPIRE_MINUTES | Verification-code lifetime |
| OTP_MAX_ATTEMPTS | Maximum code verification attempts |
| OTP_RESEND_COOLDOWN_SECONDS | Minimum interval between code requests |
| SMTP_HOST, SMTP_PORT, SMTP_USERNAME, SMTP_PASSWORD, SMTP_FROM_EMAIL | SMTP delivery settings |

Use strong, unique secret values and do not commit .env files.

## Application layers

- routes/ — HTTP endpoints and HTTP error mapping
- schemas/ — Pydantic request and response models
- services/ — authentication rules, cryptographic helpers, and email delivery
- models/ — SQLAlchemy persistence models
- database/connection.py — async engine, session factory, and dependency
- dependencies.py — bearer-token authentication and current-user lookup

## Runtime

Run from the server/ directory with **uvicorn app.main:app --reload**.

The API uses async SQLAlchemy with the PostgreSQL asyncpg driver. Database schema changes are managed with Alembic.
