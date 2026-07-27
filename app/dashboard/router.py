from fastapi import APIRouter, Depends
from sqlalchemy import select, func
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import get_db
from app.models import User, UserProfile
from app.dashboard.service import get_system_stats
from app.schemas import DashboardOut
from app.auth.dependencies import get_current_user

router = APIRouter()


@router.get("", response_model=DashboardOut)
async def get_dashboard(
    db: AsyncSession = Depends(get_db),
    current_user: UserProfile = Depends(get_current_user),
):
    """Get dashboard with system stats and user counts."""
    stats = get_system_stats()

    # Get user counts
    total_users = await db.scalar(select(func.count(User.id)))
    active_users = await db.scalar(
        select(func.count(User.id)).where(User.status == "active")
    )

    return {
        **stats,
        "total_users": total_users or 0,
        "active_users": active_users or 0,
    }
