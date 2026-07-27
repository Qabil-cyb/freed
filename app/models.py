from datetime import datetime
from sqlalchemy import (
    Column, Integer, String, Text, Boolean, DateTime, BigInteger, Float,
    ForeignKey, JSON
)
from sqlalchemy.orm import relationship
from app.database import Base


class ApiKey(Base):
    __tablename__ = "api_keys"

    id = Column(Integer, primary_key=True, index=True)
    key_hash = Column(String(256), unique=True, nullable=False, index=True)
    owner = Column(String(100), default="admin")
    created_at = Column(DateTime, default=datetime.utcnow)
    expire_at = Column(DateTime, nullable=True)
    last_used = Column(DateTime, nullable=True)
    device_id = Column(String(256), nullable=True)
    enabled = Column(Boolean, default=True)
    permissions = Column(JSON, default=lambda: ["all"])


class UserProfile(Base):
    __tablename__ = "user_profiles"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(100), default="Admin")
    avatar_url = Column(String(500), nullable=True)
    theme = Column(String(50), default="dark")
    password_lock = Column(String(256), nullable=True)


class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    username = Column(String(100), unique=True, nullable=False, index=True)
    uuid = Column(String(36), unique=True, nullable=False)
    traffic_limit = Column(BigInteger, default=0)  # bytes, 0 = unlimited
    traffic_used = Column(BigInteger, default=0)
    expire_date = Column(DateTime, nullable=True)
    ip_limit = Column(Integer, default=-1)  # -1 = unlimited
    description = Column(Text, default="")
    inbound_id = Column(Integer, ForeignKey("inbounds.id"), nullable=True)
    status = Column(String(20), default="active")  # active, disabled, expired
    proxy_id = Column(Integer, ForeignKey("proxy_servers.id"), nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)

    inbound = relationship("Inbound", back_populates="users")
    proxy = relationship("ProxyServer", back_populates="users")


class Inbound(Base):
    __tablename__ = "inbounds"

    id = Column(Integer, primary_key=True, index=True)
    remark = Column(String(200), nullable=False)
    port = Column(Integer, nullable=False)
    protocol = Column(String(50), default="vless")
    security = Column(String(50), default="reality")
    transport = Column(String(50), default="tcp")
    stream_settings = Column(JSON, default=dict)
    sni = Column(String(200), default="")
    host = Column(String(200), default="")
    path = Column(String(200), default="")
    settings = Column(JSON, default=dict)
    tag = Column(String(100), unique=True, nullable=False)
    sniffing = Column(JSON, default=lambda: {"enabled": True, "destOverride": ["http", "tls"]})
    mux = Column(JSON, default=dict)
    enabled = Column(Boolean, default=True)
    created_at = Column(DateTime, default=datetime.utcnow)

    users = relationship("User", back_populates="inbound")
    stats = relationship("InboundStat", back_populates="inbound")


class InboundStat(Base):
    __tablename__ = "inbound_stats"

    id = Column(Integer, primary_key=True, index=True)
    inbound_id = Column(Integer, ForeignKey("inbounds.id"), nullable=False)
    up = Column(BigInteger, default=0)
    down = Column(BigInteger, default=0)
    timestamp = Column(DateTime, default=datetime.utcnow)

    inbound = relationship("Inbound", back_populates="stats")


class NewsCache(Base):
    __tablename__ = "news_cache"

    id = Column(Integer, primary_key=True, index=True)
    title = Column(String(500), nullable=False)
    image = Column(String(500), nullable=True)
    description = Column(Text, default="")
    url = Column(String(500), nullable=False)
    pub_date = Column(DateTime, nullable=True)


class Setting(Base):
    __tablename__ = "settings"

    id = Column(Integer, primary_key=True, index=True)
    key = Column(String(100), unique=True, nullable=False)
    value = Column(Text, default="")


class TelegramBot(Base):
    __tablename__ = "telegram_bots"

    id = Column(Integer, primary_key=True, index=True)
    bot_token = Column(String(200), nullable=False)
    admin_id = Column(String(100), nullable=False)


class ProxyServer(Base):
    __tablename__ = "proxy_servers"

    id = Column(Integer, primary_key=True, index=True)
    country = Column(String(100), default="")
    ip = Column(String(50), nullable=False)
    port = Column(Integer, nullable=False)
    type = Column(String(50), default="socks5")  # socks5, http

    users = relationship("User", back_populates="proxy")
