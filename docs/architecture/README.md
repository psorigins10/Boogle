# Architecture

Boogle is organized as a desktop client and a separately run HTTP API.

## Components

| Component | Responsibility |
| --- | --- |
| Desktop client | Qt application startup, QML screens, user interaction, and client-side authentication state |
| Desktop backend bridge | Exposes authentication operations to QML and runs API calls off the UI thread |
| FastAPI service | HTTP routing, request validation, authentication workflows, and response serialization |
| PostgreSQL | Persistent user and email verification-code records |
| SMTP provider | Delivery of signup and login verification codes |

## Request flow

1. The desktop UI collects user input and calls a slot on AuthBackend.
2. AuthBackend dispatches the operation through a QRunnable in Qt's thread pool.
3. The worker calls APIClient, which sends an HTTP request to the FastAPI service.
4. The route validates the request and delegates authentication logic to the service layer.
5. The service reads or updates PostgreSQL through an asynchronous SQLAlchemy session.
6. The API returns a JSON response; the worker emits a success or failure signal for the UI.

## Source layout

- desktop/ — application entry point, QML interface, API client, and desktop authentication bridge
- server/app/ — FastAPI application, configuration, database, models, routes, schemas, and services
- server/migrations/ — Alembic environment and schema revisions

The dashboard currently presents a home overview and placeholder sections for future productivity features. Password-reset UI elements are present, but password-reset API workflows are not implemented in the current server routes.
