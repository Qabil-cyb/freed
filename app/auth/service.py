import hashlib
from datetime import datetime
from typing import Optional
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models import ApiKey, UserProfile
from app.utils.security import hash_api_key, verify_api_key, create_access_token


async def authenticate_api_key(db: AsyncSession, raw_key: str, device_id: str = "") -> Optional[dict]:
    """
    Authenticate an API key. Returns dict with token and profile data, or None.
    """
    key_hash = hash_api_key(raw_key)

    result = await db.execute(
        select(ApiKey).where(ApiKey.key_hash == key_hash, ApiKey.enabled == True)
    )
    api_key = result.scalar_one_or_none()

    if not api_key:
        return None

    # Check expiry
    if api_key.expire_at and api_key.expire_at < datetime.utcnow():
        return None

    # Update last_used and device_id
    api_key.last_used = datetime.utcnow()
    if device_id:
        api_key.device_id = device_id
    await db.commit()

    # Create JWT
    token = create_access_token({
        "sub": "api_key_auth",
        "api_key_id": api_key.id,
        "owner": api_key.owner,
    })

    # Get profile
    profile_result = await db.execute(select(UserProfile).limit(1))
    profile = profile_result.scalar_one_or_none()

    if not profile:
        profile = UserProfile(name="Admin", theme="dark")
        db.add(profile)
        await db.commit()
        await db.refresh(profile)

    return {
        "token": token,
        "profile": profile,
        "theme": profile.theme,
    }
