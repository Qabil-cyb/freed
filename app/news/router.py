from typing import List
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select, delete
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import get_db
from app.models import NewsCache, UserProfile
from app.schemas import NewsItemOut, MessageResponse
from app.auth.dependencies import get_current_user

router = APIRouter()


@router.get("", response_model=List[NewsItemOut])
async def get_news(
    db: AsyncSession = Depends(get_db),
    current_user: UserProfile = Depends(get_current_user),
):
    """Get cached news items."""
    result = await db.execute(
        select(NewsCache).order_by(NewsCache.pub_date.desc()).limit(20)
    )
    items = result.scalars().all()

    # If no cached news, fetch fresh
    if not items:
        items = await refresh_news_cache(db)

    return items


@router.post("/refresh", response_model=List[NewsItemOut])
async def refresh_news(
    db: AsyncSession = Depends(get_db),
    current_user: UserProfile = Depends(get_current_user),
):
    """Force refresh news cache."""
    return await refresh_news_cache(db)


async def refresh_news_cache(db: AsyncSession) -> List[NewsCache]:
    """Fetch news and update cache."""
    from app.news.service import fetch_iran_news

    try:
        news_items = await fetch_iran_news()
    except Exception:
        news_items = []

    # Clear old cache
    await db.execute(delete(NewsCache))

    # Insert new items
    cached_items = []
    for item in news_items:
        news = NewsCache(
            title=item["title"],
            image=item["image"],
            description=item["description"],
            url=item["url"],
            pub_date=item["pub_date"],
        )
        db.add(news)
        cached_items.append(news)

    await db.commit()
    return cached_items
