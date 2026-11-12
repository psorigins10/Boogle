from contextlib import asynccontextmanager

from fastapi import FastAPI

from app.core.config import settings
from app.database.connection import close_db
from app.routes.auth import router as auth_router


@asynccontextmanager
async def lifespan(app: FastAPI):
    yield
    await close_db()


app = FastAPI(
    title=settings.APP_NAME,
    debug=settings.DEBUG,
    lifespan=lifespan,
)

app.include_router(auth_router)


@app.get("/")
async def root():
    return {
        "message": "Welcome to the Boogle API!",
        "status": "running",
    }


@app.get("/health")
async def health_check():
    return {"status": "healthy"}
