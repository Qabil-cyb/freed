from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import get_db
from app.models import Setting, UserProfile
from app.schemas import HermesChatRequest
from app.auth.dependencies import get_current_user
import httpx
import json

router = APIRouter()


@router.post("/install")
async def install_hermes(
    db: AsyncSession = Depends(get_db),
    current_user: UserProfile = Depends(get_current_user),
):
    """Install Hermes AI on the VPS."""
    try:
        import subprocess
        result = subprocess.run(
            ["bash", "-c", "curl -fsSL https://hermes-agent.sh/install | bash"],
            capture_output=True, text=True, timeout=300,
        )
        return {
            "success": result.returncode == 0,
            "message": "Hermes installed" if result.returncode == 0 else result.stderr,
        }
    except Exception as e:
        return {"success": False, "message": str(e)}


@router.post("/start")
async def start_hermes(
    db: AsyncSession = Depends(get_db),
    current_user: UserProfile = Depends(get_current_user),
):
    """Start Hermes AI service."""
    try:
        import subprocess
        result = subprocess.run(
            ["hermes", "start"],
            capture_output=True, text=True, timeout=30,
        )
        return {
            "success": result.returncode == 0,
            "message": "Hermes started" if result.returncode == 0 else result.stderr,
        }
    except Exception as e:
        return {"success": False, "message": str(e)}


@router.post("/chat")
async def chat_hermes(
    data: HermesChatRequest,
    db: AsyncSession = Depends(get_db),
    current_user: UserProfile = Depends(get_current_user),
):
    """
    Chat with AI via Google AI Studio API.
    API key is stored in settings (ai_api_key).
    Supports streaming responses.
    """
    from fastapi.responses import StreamingResponse

    # Get AI API key from settings
    result = await db.execute(
        select(Setting).where(Setting.key == "ai_api_key")
    )
    api_key_setting = result.scalar_one_or_none()

    if not api_key_setting or not api_key_setting.value:
        raise HTTPException(
            status_code=400,
            detail="AI API key not configured. Set it in settings first.",
        )

    ai_api_key = api_key_setting.value

    # Get model
    model_result = await db.execute(
        select(Setting).where(Setting.key == "ai_model")
    )
    model_setting = model_result.scalar_one_or_none()
    ai_model = model_setting.value if model_setting else "gemini-2.0-flash"

    # Call Google AI Studio API
    url = f"https://generativelanguage.googleapis.com/v1beta/models/{ai_model}:streamGenerateContent?alt=sse&key={ai_api_key}"

    payload = {
        "contents": [{"parts": [{"text": data.message}]}],
        "generationConfig": {
            "temperature": 0.7,
            "topK": 40,
            "topP": 0.95,
            "maxOutputTokens": 8192,
        },
    }

    async def stream_response():
        async with httpx.AsyncClient(timeout=60.0) as client:
            async with client.stream("POST", url, json=payload) as response:
                if response.status_code != 200:
                    yield json.dumps({"error": f"AI API error: {response.status_code}"})
                    return

                async for line in response.aiter_lines():
                    if line.startswith("data: "):
                        data_str = line[6:]
                        if data_str.strip() == "":
                            continue
                        try:
                            parsed = json.loads(data_str)
                            if "candidates" in parsed:
                                for candidate in parsed["candidates"]:
                                    if "content" in candidate and "parts" in candidate["content"]:
                                        for part in candidate["content"]["parts"]:
                                            if "text" in part:
                                                yield json.dumps({"text": part["text"]}) + "\n"
                            elif "error" in parsed:
                                yield json.dumps({"error": parsed["error"]["message"]}) + "\n"
                        except json.JSONDecodeError:
                            continue

    return StreamingResponse(
        stream_response(),
        media_type="text/event-stream",
        headers={
            "Cache-Control": "no-cache",
            "Connection": "keep-alive",
            "X-Accel-Buffering": "no",
        },
    )


@router.post("/upload")
async def upload_image(
    db: AsyncSession = Depends(get_db),
    current_user: UserProfile = Depends(get_current_user),
):
    """Upload an image for Hermes AI."""
    return {"filename": "", "url": ""}
