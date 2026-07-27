from datetime import datetime
from typing import Optional, List, Any
from pydantic import BaseModel, Field


# ──────────────── Auth ────────────────
class LoginRequest(BaseModel):
    api_key: str
    device_id: str = ""


class LoginResponse(BaseModel):
    token: str
    profile: "ProfileOut"
    days_remaining: Optional[int] = None
    theme: str = "dark"


# ──────────────── Profile ────────────────
class ProfileUpdate(BaseModel):
    name: Optional[str] = None
    theme: Optional[str] = None
    avatar_url: Optional[str] = None
    password_lock: Optional[str] = None


class ProfileOut(BaseModel):
    id: int
    name: str
    avatar_url: Optional[str] = None
    theme: str
    password_lock: Optional[str] = None

    class Config:
        from_attributes = True


# ──────────────── Dashboard ────────────────
class DashboardOut(BaseModel):
    cpu_percent: float
    cpu_count: int
    ram_total: int
    ram_used: int
    ram_percent: float
    disk_total: int
    disk_used: int
    disk_percent: float
    net_sent: int
    net_recv: int
    load_avg: List[float]
    uptime: int
    total_users: int
    active_users: int


# ──────────────── User ────────────────
class UserCreate(BaseModel):
    username: str
    traffic_limit: int = 0
    expire_date: Optional[datetime] = None
    ip_limit: int = -1
    description: str = ""
    inbound_id: Optional[int] = None
    status: str = "active"


class UserUpdate(BaseModel):
    username: Optional[str] = None
    traffic_limit: Optional[int] = None
    expire_date: Optional[datetime] = None
    ip_limit: Optional[int] = None
    description: Optional[str] = None
    inbound_id: Optional[int] = None
    status: Optional[str] = None


class UserOut(BaseModel):
    id: int
    username: str
    uuid: str
    traffic_limit: int
    traffic_used: int
    expire_date: Optional[datetime] = None
    ip_limit: int
    description: str
    inbound_id: Optional[int] = None
    status: str
    proxy_id: Optional[int] = None
    created_at: datetime

    class Config:
        from_attributes = True


class ProxyAssignRequest(BaseModel):
    proxy_id: Optional[int] = None


# ──────────────── Inbound ────────────────
class InboundCreate(BaseModel):
    remark: str
    port: int
    protocol: str = "vless"
    security: str = "reality"
    transport: str = "tcp"
    stream_settings: dict = {}
    sni: str = ""
    host: str = ""
    path: str = ""
    settings: dict = {}
    tag: str
    sniffing: dict = {"enabled": True, "destOverride": ["http", "tls"]}
    mux: dict = {}
    enabled: bool = True


class InboundUpdate(BaseModel):
    remark: Optional[str] = None
    port: Optional[int] = None
    protocol: Optional[str] = None
    security: Optional[str] = None
    transport: Optional[str] = None
    stream_settings: Optional[dict] = None
    sni: Optional[str] = None
    host: Optional[str] = None
    path: Optional[str] = None
    settings: Optional[dict] = None
    tag: Optional[str] = None
    sniffing: Optional[dict] = None
    mux: Optional[dict] = None
    enabled: Optional[bool] = None


class InboundOut(BaseModel):
    id: int
    remark: str
    port: int
    protocol: str
    security: str
    transport: str
    stream_settings: dict
    sni: str
    host: str
    path: str
    settings: dict
    tag: str
    sniffing: dict
    mux: dict
    enabled: bool
    created_at: datetime

    class Config:
        from_attributes = True


class InboundStatsOut(BaseModel):
    inbound_id: int
    up: int
    down: int
    total: int


# ──────────────── News ────────────────
class NewsItemOut(BaseModel):
    id: int
    title: str
    image: Optional[str] = None
    description: str
    url: str
    pub_date: Optional[datetime] = None

    class Config:
        from_attributes = True


# ──────────────── Proxy ────────────────
class ProxyCreate(BaseModel):
    country: str = ""
    ip: str
    port: int
    type: str = "socks5"


class ProxyOut(BaseModel):
    id: int
    country: str
    ip: str
    port: int
    type: str

    class Config:
        from_attributes = True


# ──────────────── Settings ────────────────
class SettingOut(BaseModel):
    key: str
    value: str


class ThemeUpdate(BaseModel):
    theme: str


class PasswordUpdate(BaseModel):
    password: str


# ──────────────── Telegram ────────────────
class TelegramConnectRequest(BaseModel):
    bot_token: str
    admin_id: str


class TelegramConnectResponse(BaseModel):
    success: bool
    message: str


# ──────────────── API Key ────────────────
class ApiKeyCreate(BaseModel):
    owner: str = "admin"
    expire_at: Optional[datetime] = None
    permissions: List[str] = ["all"]


class ApiKeyOut(BaseModel):
    id: int
    owner: str
    created_at: datetime
    expire_at: Optional[datetime] = None
    last_used: Optional[datetime] = None
    device_id: Optional[str] = None
    enabled: bool
    permissions: Any

    class Config:
        from_attributes = True


class ApiKeyCreatedResponse(BaseModel):
    id: int
    key: str
    owner: str
    created_at: datetime


# ──────────────── Hermes ────────────────
class HermesChatRequest(BaseModel):
    message: str


class HermesUploadResponse(BaseModel):
    filename: str
    url: str


# ──────────────── Generic ────────────────
class MessageResponse(BaseModel):
    message: str
    success: bool = True


# Update forward reference
LoginResponse.model_rebuild()
