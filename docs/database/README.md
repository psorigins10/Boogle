# Database

Boogle uses PostgreSQL with asynchronous SQLAlchemy sessions. The connection and session factory are defined in server/app/database/connection.py.

## Models

### users

Defined in server/app/models/user.py.

| Column | Description |
| --- | --- |
| id | UUID primary key |
| full_name | User display name |
| email | Unique, indexed email address |
| password_hash | Argon2id password hash |
| is_email_verified | Email verification status |
| is_active | Account active status |
| created_at, updated_at | UTC-aware timestamps |

### email_otps

Defined in server/app/models/email_otp.py.

| Column | Description |
| --- | --- |
| id | UUID primary key |
| user_id | Foreign key to users.id, cascading on user deletion |
| purpose | OTP purpose: signup, login, or password_reset |
| code_hash | HMAC-SHA256 digest of the code |
| expires_at | Code expiration time |
| attempts, max_attempts | Verification attempt tracking |
| consumed_at | Timestamp marking code as used |
| created_at | UTC-aware creation timestamp |

An index on (user_id, purpose) supports retrieving codes for a user and workflow.

## Migrations

Alembic configuration is in server/alembic.ini; migration scripts are in server/migrations/versions/.

Apply migrations from the server/ directory with **alembic upgrade head**.

The current migration creates the users and email OTP tables and their indexes.
