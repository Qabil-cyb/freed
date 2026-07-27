from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
import os

from app.config import get_settings
from app.database import engine, Base, async_session
from app.models import ApiKey, Setting
from app.utils.security import hash_api_key, generate_api_key


settings = get_settings()


@asynccontextmanager
async def lifespan(app: FastAPI):
    # Create tables on startup
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)

    # Bootstrap first API key if none exists
    async with async_session() as session:
        from sqlalchemy import select, func
        count = await session.scalar(select(func.count(ApiKey.id)))
        if count == 0:
            raw_key = settings.FIRST_API_KEY
            api_key = ApiKey(
                key_hash=hash_api_key(raw_key),
                owner="admin",
                permissions=["all"],
            )
            session.add(api_key)

            # Create default profile
            from app.models import UserProfile
            from sqlalchemy import select as sel
            from app.models import UserProfile as UP
            existing = await session.scalar(sel(UP).limit(1))
            if not existing:
                session.add(UP(name="Admin", theme="dark"))

            # Create default settings
            existing_settings = await session.scalar(select(func.count(Setting.id)))
            if existing_settings == 0:
                for k, v in [("theme", "dark"), ("ai_api_key", ""), ("ai_model", "gemini-2.0-flash")]:
                    session.add(Setting(key=k, value=v))

            await session.commit()

    yield

    await engine.dispose()


app = FastAPI(
    title="Spider Panel API",
    description="VPS Control Panel Backend for Xray VPN Management",
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc",
    lifespan=lifespan,
)

# CORS - allow all for mobile app
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Create uploads directory
os.makedirs("uploads", exist_ok=True)
os.makedirs("uploads/avatars", exist_ok=True)

# Mount uploads for serving
app.mount("/uploads", StaticFiles(directory="uploads"), name="uploads")

# Import and include routers
from app.auth.router import router as auth_router
from app.users.router import router as users_router
from app.inbounds.router import router as inbounds_router
from app.dashboard.router import router as dashboard_router
from app.news.router import router as news_router
from app.proxy.router import router as proxy_router
from app.settings.router import router as settings_router
from app.telegram.router import router as telegram_router
from app.hermes.router import router as hermes_router
from app.profile.router import router as profile_router
from app.deploy.router import router as deploy_router

app.include_router(auth_router, prefix="/api/auth", tags=["Auth"])
app.include_router(profile_router, prefix="/api/profile", tags=["Profile"])
app.include_router(users_router, prefix="/api/users", tags=["Users"])
app.include_router(inbounds_router, prefix="/api/inbounds", tags=["Inbounds"])
app.include_router(dashboard_router, prefix="/api/dashboard", tags=["Dashboard"])
app.include_router(news_router, prefix="/api/news", tags=["News"])
app.include_router(proxy_router, prefix="/api/proxy", tags=["Proxy"])
app.include_router(settings_router, prefix="/api/settings", tags=["Settings"])
app.include_router(telegram_router, prefix="/api/telegram", tags=["Telegram"])
app.include_router(hermes_router, prefix="/api/hermes", tags=["Hermes AI"])


@app.get("/", tags=["Health"])
async def root():
    return {"message": "Spider Panel API", "version": "1.0.0", "docs": "/docs"}


@app.get("/health", tags=["Health"])
async def health():
    return {"status": "healthy"}
