from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import get_db
from app.models import TelegramBot, UserProfile
from app.schemas import TelegramConnectRequest, TelegramConnectResponse
from app.auth.dependencies import get_current_user

router = APIRouter()


@router.post("/connect", response_model=TelegramConnectResponse)
async def connect_telegram(
    data: TelegramConnectRequest,
    db: AsyncSession = Depends(get_db),
    current_user: UserProfile = Depends(get_current_user),
):
    """Set Telegram bot token and admin ID."""
    result = await db.execute(select(TelegramBot).limit(1))
    existing = result.scalar_one_or_none()

    if existing:
        existing.bot_token = data.bot_token
        existing.admin_id = data.admin_id
    else:
        bot = TelegramBot(bot_token=data.bot_token, admin_id=data.admin_id)
        db.add(bot)

    await db.commit()

    return TelegramConnectResponse(
        success=True,
        message="Telegram bot connected successfully",
    )


@router.get("/status")
async def get_telegram_status(
    db: AsyncSession = Depends(get_db),
    current_user: UserProfile = Depends(get_current_user),
):
    """Get Telegram bot connection status."""
    result = await db.execute(select(TelegramBot).limit(1))
    bot = result.scalar_one_or_none()

    if bot:
        return {
            "connected": True,
            "admin_id": bot.admin_id,
            "bot_token_masked": bot.bot_token[:10] + "..." if bot.bot_token else "",
        }
    return {"connected": False}
