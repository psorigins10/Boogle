# Development

## Prerequisites

- Python compatible with the project's dependencies
- PostgreSQL
- SMTP credentials for signup and login email delivery
- A desktop environment supported by PySide6

## Install

From the repository root, create a virtual environment with **python -m venv .venv**. Activate it, then install dependencies with **pip install -r server/requirements.txt** and **pip install -r desktop/requirements.txt**.

## Configure the server

Create server/.env and provide the settings described in [Backend configuration](../backend/README.md). Keep secrets out of source control.

## Initialize the database

From the server/ directory, apply the Alembic migrations with **alembic upgrade head**. The configured database must be reachable and the database URL must use the async SQLAlchemy driver expected by the application.

## Run the API

From the server/ directory, run **uvicorn app.main:app --reload**.

The service exposes interactive API documentation at http://127.0.0.1:8000/docs when running locally.

## Run the desktop client

From the repository root, run **python -m desktop.main**.

The desktop client currently uses http://127.0.0.1:8000 as its API base URL.

## Notes

- The backend loads environment variables from server/.env.
- Email-based signup and login require SMTP configuration.
- Apply migrations before using database-backed endpoints.
- No automated test suite is currently documented in the repository.
