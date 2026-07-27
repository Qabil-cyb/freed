from datetime import datetime
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import get_db
from app.auth.service import authenticate_api_key
from app.schemas import LoginRequest, LoginResponse

router = APIRouter()


@router.post("/login", response_model=LoginResponse)
async def login(request: LoginRequest, db: AsyncSession = Depends(get_db)):
    """
    Authenticate with API key and device ID.
    Returns JWT token and profile data.
    """
    result = await authenticate_api_key(db, request.api_key, request.device_id)

    if not result:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or expired API key",
        )

    return LoginResponse(
        token=result["token"],
        profile=result["profile"],
        days_remaining=None,
        theme=result["theme"],
    )
