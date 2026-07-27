from typing import List
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import get_db
from app.models import Setting, UserProfile, ApiKey
from app.schemas import (
    SettingOut, ThemeUpdate, PasswordUpdate, MessageResponse,
    ApiKeyCreate, ApiKeyOut, ApiKeyCreatedResponse,
)
from app.auth.dependencies import get_current_user
from app.utils.security import hash_api_key, generate_api_key

router = APIRouter()


@router.get("", response_model=List[SettingOut])
async def get_settings(
    db: AsyncSession = Depends(get_db),
    current_user: UserProfile = Depends(get_current_user),
):
    """Get all settings."""
    from typing import List
    result = await db.execute(select(Setting))
    settings = result.scalars().all()
    return [SettingOut(key=s.key, value=s.value) for s in settings]


@router.patch("/theme", response_model=MessageResponse)
async def update_theme(
    data: ThemeUpdate,
    db: AsyncSession = Depends(get_db),
    current_user: UserProfile = Depends(get_current_user),
):
    """Change theme setting."""
    current_user.theme = data.theme

    result = await db.execute(select(Setting).where(Setting.key == "theme"))
    setting = result.scalar_one_or_none()
    if setting:
        setting.value = data.theme
    else:
        db.add(Setting(key="theme", value=data.theme))

    await db.commit()
    return MessageResponse(message=f"Theme changed to {data.theme}")


@router.patch("/password", response_model=MessageResponse)
async def update_password(
    data: PasswordUpdate,
    db: AsyncSession = Depends(get_db),
    current_user: UserProfile = Depends(get_current_user),
):
    """Set or change password lock."""
    from passlib.hash import bcrypt
    current_user.password_lock = bcrypt.hash(data.password)
    await db.commit()
    return MessageResponse(message="Password updated successfully")


# ──────────────── API Keys ────────────────

@router.get("/apikeys", response_model=List[ApiKeyOut])
async def list_api_keys(
    db: AsyncSession = Depends(get_db),
    current_user: UserProfile = Depends(get_current_user),
):
    """List all API keys."""
    result = await db.execute(select(ApiKey).order_by(ApiKey.id))
    return result.scalars().all()


@router.post("/apikeys", response_model=ApiKeyCreatedResponse)
async def create_api_key(
    data: ApiKeyCreate,
    db: AsyncSession = Depends(get_db),
    current_user: UserProfile = Depends(get_current_user),
):
    """Generate a new API key."""
    raw_key = generate_api_key()
    api_key = ApiKey(
        key_hash=hash_api_key(raw_key),
        owner=data.owner,
        expire_at=data.expire_at,
        permissions=data.permissions,
    )
    db.add(api_key)
    await db.commit()
    await db.refresh(api_key)

    return ApiKeyCreatedResponse(
        id=api_key.id,
        key=raw_key,
        owner=api_key.owner,
        created_at=api_key.created_at,
    )


@router.delete("/apikeys/{api_key_id}", response_model=MessageResponse)
async def delete_api_key(
    api_key_id: int,
    db: AsyncSession = Depends(get_db),
    current_user: UserProfile = Depends(get_current_user),
):
    """Delete an API key."""
    result = await db.execute(select(ApiKey).where(ApiKey.id == api_key_id))
    api_key = result.scalar_one_or_none()
    if not api_key:
        raise HTTPException(status_code=404, detail="API key not found")

    await db.delete(api_key)
    await db.commit()
    return MessageResponse(message="API key deleted")


@router.post("/apikeys/{api_key_id}/regenerate", response_model=ApiKeyCreatedResponse)
async def regenerate_api_key(
    api_key_id: int,
    db: AsyncSession = Depends(get_db),
    current_user: UserProfile = Depends(get_current_user),
):
    """Regenerate an existing API key."""
    result = await db.execute(select(ApiKey).where(ApiKey.id == api_key_id))
    api_key = result.scalar_one_or_none()
    if not api_key:
        raise HTTPException(status_code=404, detail="API key not found")

    raw_key = generate_api_key()
    api_key.key_hash = hash_api_key(raw_key)
    api_key.last_used = None
    await db.commit()

    return ApiKeyCreatedResponse(
        id=api_key.id,
        key=raw_key,
        owner=api_key.owner,
        created_at=api_key.created_at,
    )


# ──────────────── Backup / Restore / Reset ────────────────

@router.post("/backup")
async def create_backup(
    db: AsyncSession = Depends(get_db),
    current_user: UserProfile = Depends(get_current_user),
):
    """Create a database backup."""
    import json
    from datetime import datetime

    settings_result = await db.execute(select(Setting))
    settings = settings_result.scalars().all()
    backup = {"settings": [{"key": s.key, "value": s.value} for s in settings]}

    apikeys_result = await db.execute(select(ApiKey))
    apikeys = apikeys_result.scalars().all()
    backup["api_keys"] = [
        {"id": k.id, "owner": k.owner, "key_hash": k.key_hash}
        for k in apikeys
    ]

    backup_file = f"backup_{datetime.utcnow().strftime('%Y%m%d_%H%M%S')}.json"
    import aiofiles
    async with aiofiles.open(backup_file, "w") as f:
        await f.write(json.dumps(backup, indent=2, default=str))

    return {"message": "Backup created", "file": backup_file}


@router.post("/restore")
async def restore_backup(
    db: AsyncSession = Depends(get_db),
    current_user: UserProfile = Depends(get_current_user),
):
    """Restore from a backup."""
    return MessageResponse(message="Restore endpoint ready. Upload a backup file.")


@router.post("/reset", response_model=MessageResponse)
async def reset_panel(
    db: AsyncSession = Depends(get_db),
    current_user: UserProfile = Depends(get_current_user),
):
    """Reset all panel data."""
    for table in [Setting, ApiKey, UserProfile]:
        from sqlalchemy import delete as sa_delete
        await db.execute(sa_delete(table))

    db.add(UserProfile(name="Admin", theme="dark"))
    db.add(Setting(key="theme", value="dark"))
    db.add(Setting(key="ai_api_key", value=""))
    db.add(Setting(key="ai_model", value="gemini-2.0-flash"))

    raw_key = generate_api_key()
    db.add(ApiKey(key_hash=hash_api_key(raw_key), owner="admin", permissions=["all"]))

    await db.commit()
    return MessageResponse(message="Panel has been reset. New API key generated.")
