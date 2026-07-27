import os
from fastapi import APIRouter, Depends, UploadFile, File
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
import aiofiles

from app.database import get_db
from app.models import UserProfile
from app.auth.dependencies import get_current_user

router = APIRouter()


@router.get("")
async def get_profile(user=Depends(get_current_user)):
    return {
        "id": user.id, "name": user.name,
        "avatar_url": user.avatar_url, "theme": user.theme,
        "password_lock": bool(user.password_lock),
    }


@router.patch("")
async def update_profile(data: dict, user=Depends(get_current_user), db: AsyncSession = Depends(get_db)):
    for k in ("name", "theme"):
        if k in data:
            setattr(user, k, data[k])
    await db.commit()
    return {"ok": True}


@router.post("/avatar")
async def upload_avatar(file: UploadFile = File(...), user=Depends(get_current_user), db: AsyncSession = Depends(get_db)):
    os.makedirs("uploads/avatars", exist_ok=True)
    ext = file.filename.split(".")[-1] if "." in file.filename else "png"
    filename = f"avatar_{user.id}.{ext}"
    filepath = f"uploads/avatars/{filename}"
    async with aiofiles.open(filepath, "wb") as f:
        content = await file.read()
        await f.write(content)
    user.avatar_url = f"/uploads/avatars/{filename}"
    await db.commit()
    return {"ok": True, "url": user.avatar_url}
