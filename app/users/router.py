import uuid
from datetime import datetime
from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, status, UploadFile, File
from fastapi.responses import Response
from sqlalchemy import select, func
from sqlalchemy.ext.asyncio import AsyncSession
import io
import qrcode

from app.database import get_db
from app.models import User, UserProfile, Inbound
from app.schemas import (
    UserCreate, UserUpdate, UserOut, ProxyAssignRequest, MessageResponse,
    ProfileUpdate, ProfileOut,
)
from app.auth.dependencies import get_current_user

router = APIRouter()


# ──────────────── Profile ────────────────

@router.get("", response_model=List[UserOut])
async def list_users(
    db: AsyncSession = Depends(get_db),
    current_user: UserProfile = Depends(get_current_user),
):
    """Get all users."""
    result = await db.execute(select(User).order_by(User.id))
    users = result.scalars().all()
    return users


@router.post("", response_model=UserOut, status_code=status.HTTP_201_CREATED)
async def create_user(
    data: UserCreate,
    db: AsyncSession = Depends(get_db),
    current_user: UserProfile = Depends(get_current_user),
):
    """Create a new user."""
    existing = await db.execute(select(User).where(User.username == data.username))
    if existing.scalar_one_or_none():
        raise HTTPException(status_code=400, detail="Username already exists")

    user_uuid = str(uuid.uuid4())

    user = User(
        username=data.username,
        uuid=user_uuid,
        traffic_limit=data.traffic_limit,
        expire_date=data.expire_date,
        ip_limit=data.ip_limit,
        description=data.description,
        inbound_id=data.inbound_id,
        status=data.status,
    )

    # Auto-assign first available inbound if none specified
    if user.inbound_id is None:
        ib_result = await db.execute(select(Inbound).where(Inbound.enabled == True).limit(1))
        inbound = ib_result.scalar_one_or_none()
        if inbound:
            user.inbound_id = inbound.id

    db.add(user)
    await db.commit()
    await db.refresh(user)
    return user


@router.patch("/{user_id}", response_model=UserOut)
async def update_user(
    user_id: int,
    data: UserUpdate,
    db: AsyncSession = Depends(get_db),
    current_user: UserProfile = Depends(get_current_user),
):
    """Update a user."""
    result = await db.execute(select(User).where(User.id == user_id))
    user = result.scalar_one_or_none()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    update_data = data.model_dump(exclude_unset=True)
    for field, value in update_data.items():
        setattr(user, field, value)

    await db.commit()
    await db.refresh(user)
    return user


@router.delete("/{user_id}", response_model=MessageResponse)
async def delete_user(
    user_id: int,
    db: AsyncSession = Depends(get_db),
    current_user: UserProfile = Depends(get_current_user),
):
    """Delete a user."""
    result = await db.execute(select(User).where(User.id == user_id))
    user = result.scalar_one_or_none()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    await db.delete(user)
    await db.commit()
    return MessageResponse(message="User deleted successfully")


@router.get("/{user_id}/qr")
async def get_user_qr(
    user_id: int,
    db: AsyncSession = Depends(get_db),
    current_user: UserProfile = Depends(get_current_user),
):
    """Generate QR code for user's config link."""
    result = await db.execute(select(User).where(User.id == user_id))
    user = result.scalar_one_or_none()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    config_link = await _get_user_config(db, user)

    qr = qrcode.QRCode(box_size=8, border=2)
    qr.add_data(config_link)
    qr.make(fit=True)
    img = qr.make_image(fill_color="black", back_color="white")

    buf = io.BytesIO()
    img.save(buf, format="PNG")
    buf.seek(0)

    return Response(
        content=buf.getvalue(),
        media_type="image/png",
        headers={"Content-Disposition": f"inline; filename=user_{user_id}_config.png"},
    )


@router.get("/{user_id}/config")
async def get_user_config(
    user_id: int,
    db: AsyncSession = Depends(get_db),
    current_user: UserProfile = Depends(get_current_user),
):
    """Get user's xray config link."""
    from fastapi.responses import PlainTextResponse

    result = await db.execute(select(User).where(User.id == user_id))
    user = result.scalar_one_or_none()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    config_link = await _get_user_config(db, user)
    return PlainTextResponse(config_link)


@router.get("/{user_id}/subscription")
async def get_user_subscription(
    user_id: int,
    db: AsyncSession = Depends(get_db),
    current_user: UserProfile = Depends(get_current_user),
):
    """Get user's subscription URL (base64 encoded configs)."""
    import base64
    from fastapi.responses import PlainTextResponse

    result = await db.execute(select(User).where(User.id == user_id))
    user = result.scalar_one_or_none()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    config_link = await _get_user_config(db, user)
    encoded = base64.b64encode(config_link.encode()).decode()

    return PlainTextResponse(encoded)


@router.post("/{user_id}/reset", response_model=MessageResponse)
async def reset_user_traffic(
    user_id: int,
    db: AsyncSession = Depends(get_db),
    current_user: UserProfile = Depends(get_current_user),
):
    """Reset user's traffic usage to zero."""
    result = await db.execute(select(User).where(User.id == user_id))
    user = result.scalar_one_or_none()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    user.traffic_used = 0
    await db.commit()
    return MessageResponse(message="Traffic reset successfully")


@router.post("/{user_id}/proxy", response_model=UserOut)
async def assign_user_proxy(
    user_id: int,
    data: ProxyAssignRequest,
    db: AsyncSession = Depends(get_db),
    current_user: UserProfile = Depends(get_current_user),
):
    """Assign a proxy to a user."""
    result = await db.execute(select(User).where(User.id == user_id))
    user = result.scalar_one_or_none()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    user.proxy_id = data.proxy_id
    await db.commit()
    await db.refresh(user)
    return user


# ──────────────── Profile Endpoints ────────────────

@router.get("/profile", response_model=ProfileOut)
async def get_profile(
    db: AsyncSession = Depends(get_db),
    current_user: UserProfile = Depends(get_current_user),
):
    """Get current user profile."""
    return current_user


@router.patch("/profile", response_model=ProfileOut)
async def update_profile(
    data: ProfileUpdate,
    db: AsyncSession = Depends(get_db),
    current_user: UserProfile = Depends(get_current_user),
):
    """Update profile."""
    update_data = data.model_dump(exclude_unset=True)
    for field, value in update_data.items():
        setattr(current_user, field, value)
    await db.commit()
    await db.refresh(current_user)
    return current_user


@router.post("/profile/avatar")
async def upload_avatar(
    avatar: UploadFile = File(...),
    db: AsyncSession = Depends(get_db),
    current_user: UserProfile = Depends(get_current_user),
):
    """Upload avatar for profile."""
    import os

    ext = os.path.splitext(avatar.filename)[1] if avatar.filename else ".png"
    filename = f"avatar_{current_user.id}{ext}"
    filepath = os.path.join("uploads", "avatars", filename)

    content = await avatar.read()
    os.makedirs(os.path.dirname(filepath), exist_ok=True)
    with open(filepath, "wb") as f:
        f.write(content)

    current_user.avatar_url = f"/uploads/avatars/{filename}"
    await db.commit()

    return {"url": current_user.avatar_url}


# ──────────────── Helpers ────────────────

async def _get_user_config(db: AsyncSession, user: User) -> str:
    """Generate user config link based on their inbound."""
    if not user.inbound_id:
        return f"vless://{user.uuid}@SERVER_IP:443?security=reality&type=tcp#Spider-User"

    result = await db.execute(select(Inbound).where(Inbound.id == user.inbound_id))
    inbound = result.scalar_one_or_none()
    if not inbound:
        return f"vless://{user.uuid}@SERVER_IP:443?security=reality&type=tcp#Spider-User"

    from app.utils.xray import get_user_config_text
    return await get_user_config_text(user.uuid, {
        "protocol": inbound.protocol,
        "port": inbound.port,
        "sni": inbound.sni,
        "host": inbound.host or inbound.sni,
        "path": inbound.path,
        "transport": inbound.transport,
        "security": inbound.security,
        "stream_settings": inbound.stream_settings or {},
        "remark": inbound.remark,
    })
