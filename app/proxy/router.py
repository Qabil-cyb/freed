from typing import List
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import get_db
from app.models import ProxyServer, UserProfile
from app.schemas import ProxyCreate, ProxyOut, MessageResponse
from app.auth.dependencies import get_current_user

router = APIRouter()


@router.get("", response_model=List[ProxyOut])
async def list_proxies(
    db: AsyncSession = Depends(get_db),
    current_user: UserProfile = Depends(get_current_user),
):
    """Get all proxy servers."""
    result = await db.execute(select(ProxyServer).order_by(ProxyServer.id))
    return result.scalars().all()


@router.post("", response_model=ProxyOut, status_code=status.HTTP_201_CREATED)
async def create_proxy(
    data: ProxyCreate,
    db: AsyncSession = Depends(get_db),
    current_user: UserProfile = Depends(get_current_user),
):
    """Add a new proxy server."""
    proxy = ProxyServer(**data.model_dump())
    db.add(proxy)
    await db.commit()
    await db.refresh(proxy)
    return proxy


@router.delete("/{proxy_id}", response_model=MessageResponse)
async def delete_proxy(
    proxy_id: int,
    db: AsyncSession = Depends(get_db),
    current_user: UserProfile = Depends(get_current_user),
):
    """Remove a proxy server."""
    result = await db.execute(select(ProxyServer).where(ProxyServer.id == proxy_id))
    proxy = result.scalar_one_or_none()
    if not proxy:
        raise HTTPException(status_code=404, detail="Proxy not found")

    await db.delete(proxy)
    await db.commit()
    return MessageResponse(message="Proxy deleted successfully")
