from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import Optional
import secrets
import json

from app.deploy.railway import RailwayClient

router = APIRouter()


class DeployRequest(BaseModel):
    railway_token: str
    ghcr_image: str = "ghcr.io/Qabil-cyb/spider-panel:latest"
    project_name: str = "spider-panel"


class DeployResponse(BaseModel):
    success: bool
    panel_url: Optional[str] = None
    api_key: Optional[str] = None
    project_id: Optional[str] = None
    message: Optional[str] = None


@router.post("/deploy", response_model=DeployResponse)
async def deploy_panel(req: DeployRequest):
    """Deploy Spider Panel to Railway from ghcr.io image."""
    if not req.railway_token:
        raise HTTPException(400, "Railway token is required")

    # Generate secure keys for the new panel
    jwt_secret = "sk_" + secrets.token_hex(32)
    first_api_key = "sk_" + secrets.token_urlsafe(32)

    client = RailwayClient(req.railway_token)
    try:
        result = await client.deploy_panel(
            image=req.ghcr_image,
            jwt_secret=jwt_secret,
            first_api_key=first_api_key,
        )
    except Exception as e:
        return DeployResponse(
            success=False,
            message=f"Railway API error: {str(e)}"
        )

    if "error" in result:
        return DeployResponse(
            success=False,
            message=result["error"],
        )

    return DeployResponse(
        success=result.get("deployed", False),
        panel_url=result.get("url"),
        api_key=first_api_key,
        project_id=result.get("project_id"),
        message="Panel deployed successfully!" if result.get("deployed") else "Deployment in progress...",
    )


@router.get("/projects")
async def list_projects(token: str):
    """List all Railway projects for the given token."""
    client = RailwayClient(token)
    try:
        projects = await client.get_projects()
        return {"projects": projects}
    except Exception as e:
        raise HTTPException(400, f"Failed to fetch projects: {str(e)}")
