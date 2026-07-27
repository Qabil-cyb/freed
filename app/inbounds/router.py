from typing import List
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import get_db
from app.models import Inbound, InboundStat, UserProfile
from app.schemas import InboundCreate, InboundUpdate, InboundOut, InboundStatsOut, MessageResponse
from app.auth.dependencies import get_current_user

router = APIRouter()


@router.get("", response_model=List[InboundOut])
async def list_inbounds(
    db: AsyncSession = Depends(get_db),
    current_user: UserProfile = Depends(get_current_user),
):
    """Get all inbounds."""
    result = await db.execute(select(Inbound).order_by(Inbound.id))
    return result.scalars().all()


@router.post("", response_model=InboundOut, status_code=status.HTTP_201_CREATED)
async def create_inbound(
    data: InboundCreate,
    db: AsyncSession = Depends(get_db),
    current_user: UserProfile = Depends(get_current_user),
):
    """Create a new inbound."""
    existing = await db.execute(select(Inbound).where(Inbound.tag == data.tag))
    if existing.scalar_one_or_none():
        raise HTTPException(status_code=400, detail="Tag already exists")

    inbound = Inbound(**data.model_dump())
    db.add(inbound)
    await db.commit()
    await db.refresh(inbound)
    return inbound


@router.patch("/{inbound_id}", response_model=InboundOut)
async def update_inbound(
    inbound_id: int,
    data: InboundUpdate,
    db: AsyncSession = Depends(get_db),
    current_user: UserProfile = Depends(get_current_user),
):
    """Update an inbound."""
    result = await db.execute(select(Inbound).where(Inbound.id == inbound_id))
    inbound = result.scalar_one_or_none()
    if not inbound:
        raise HTTPException(status_code=404, detail="Inbound not found")

    update_data = data.model_dump(exclude_unset=True)
    for field, value in update_data.items():
        setattr(inbound, field, value)

    await db.commit()
    await db.refresh(inbound)
    return inbound


@router.delete("/{inbound_id}", response_model=MessageResponse)
async def delete_inbound(
    inbound_id: int,
    db: AsyncSession = Depends(get_db),
    current_user: UserProfile = Depends(get_current_user),
):
    """Delete an inbound."""
    result = await db.execute(select(Inbound).where(Inbound.id == inbound_id))
    inbound = result.scalar_one_or_none()
    if not inbound:
        raise HTTPException(status_code=404, detail="Inbound not found")

    await db.delete(inbound)
    await db.commit()
    return MessageResponse(message="Inbound deleted successfully")


@router.post("/{inbound_id}/enable", response_model=MessageResponse)
async def enable_inbound(
    inbound_id: int,
    db: AsyncSession = Depends(get_db),
    current_user: UserProfile = Depends(get_current_user),
):
    """Enable an inbound."""
    result = await db.execute(select(Inbound).where(Inbound.id == inbound_id))
    inbound = result.scalar_one_or_none()
    if not inbound:
        raise HTTPException(status_code=404, detail="Inbound not found")

    inbound.enabled = True
    await db.commit()
    return MessageResponse(message="Inbound enabled")


@router.post("/{inbound_id}/disable", response_model=MessageResponse)
async def disable_inbound(
    inbound_id: int,
    db: AsyncSession = Depends(get_db),
    current_user: UserProfile = Depends(get_current_user),
):
    """Disable an inbound."""
    result = await db.execute(select(Inbound).where(Inbound.id == inbound_id))
    inbound = result.scalar_one_or_none()
    if not inbound:
        raise HTTPException(status_code=404, detail="Inbound not found")

    inbound.enabled = False
    await db.commit()
    return MessageResponse(message="Inbound disabled")


@router.get("/{inbound_id}/json")
async def get_inbound_json(
    inbound_id: int,
    db: AsyncSession = Depends(get_db),
    current_user: UserProfile = Depends(get_current_user),
):
    """Get inbound as JSON for copying."""
    result = await db.execute(select(Inbound).where(Inbound.id == inbound_id))
    inbound = result.scalar_one_or_none()
    if not inbound:
        raise HTTPException(status_code=404, detail="Inbound not found")

    return {
        "id": inbound.id,
        "tag": inbound.tag,
        "port": inbound.port,
        "protocol": inbound.protocol,
        "security": inbound.security,
        "transport": inbound.transport,
        "settings": inbound.settings,
        "stream_settings": inbound.stream_settings,
        "sniffing": inbound.sniffing,
        "mux": inbound.mux,
        "enabled": inbound.enabled,
    }


@router.get("/{inbound_id}/stats")
async def get_inbound_stats(
    inbound_id: int,
    db: AsyncSession = Depends(get_db),
    current_user: UserProfile = Depends(get_current_user),
):
    """Get inbound traffic statistics."""
    from sqlalchemy import func

    result = await db.execute(select(Inbound).where(Inbound.id == inbound_id))
    inbound = result.scalar_one_or_none()
    if not inbound:
        raise HTTPException(status_code=404, detail="Inbound not found")

    stats_result = await db.execute(
        select(
            func.coalesce(func.sum(InboundStat.up), 0).label("up"),
            func.coalesce(func.sum(InboundStat.down), 0).label("down"),
        ).where(InboundStat.inbound_id == inbound_id)
    )
    row = stats_result.one()
    up = int(row.up) if row.up else 0
    down = int(row.down) if row.down else 0

    return {
        "inbound_id": inbound_id,
        "remark": inbound.remark,
        "up": up,
        "down": down,
        "total": up + down,
    }
