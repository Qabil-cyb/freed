import os
from pydantic_settings import BaseSettings
from functools import lru_cache
from typing import Optional


class Settings(BaseSettings):
    # Database
    DATABASE_URL: str = "sqlite+aiosqlite:///./spider_panel.db"
    
    # Redis (optional for dev, required for prod)
    REDIS_URL: str = "redis://localhost:6379"
    
    # JWT
    JWT_SECRET_KEY: str = "change-me-in-production"
    JWT_ALGORITHM: str = "HS256"
    JWT_EXPIRE_MINUTES: int = 15
    
    # First API key for bootstrapping
    FIRST_API_KEY: str = "spider-panel-admin-key"
    
    # Server
    HOST: str = "0.0.0.0"
    PORT: int = 8000
    
    # Xray
    XRAY_CONFIG_PATH: str = "/usr/local/etc/xray/config.json"
    XRAY_API_PORT: int = 10085
    
    # Hermes AI
    HERMES_INSTALL_PATH: str = "/opt/hermes"
    
    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"
        extra = "allow"


@lru_cache()
def get_settings() -> Settings:
    return Settings()
