import httpx
import json
import time
from typing import Optional, Dict, Any


class RailwayClient:
    """Client for Railway API to deploy containers from ghcr.io."""

    RAILWAY_API = "https://api.railway.app/graphql/v2"

    def __init__(self, api_token: str):
        self.headers = {
            "Authorization": f"Bearer {api_token}",
            "Content-Type": "application/json",
        }

    async def _query(self, query: str, variables: dict = None) -> dict:
        async with httpx.AsyncClient(timeout=30.0) as client:
            resp = await client.post(
                self.RAILWAY_API,
                json={"query": query, "variables": variables or {}},
                headers=self.headers,
            )
            resp.raise_for_status()
            return resp.json()

    async def get_projects(self) -> list:
        """Get all projects."""
        q = """
        query {
            projects {
                edges { node { id name } }
            }
        }
        """
        data = await self._query(q)
        edges = data.get("data", {}).get("projects", {}).get("edges", [])
        return [e["node"] for e in edges]

    async def create_project(self, name: str = "spider-panel") -> dict:
        """Create a new empty project on Railway."""
        q = """
        mutation CreateProject($name: String!) {
            createProject(name: $name) {
                id name
            }
        }
        """
        data = await self._query(q, {"name": name})
        return data.get("data", {}).get("createProject", {})

    async def create_service(self, project_id: str, source_image: str, service_name: str = "spider-panel") -> dict:
        """Create a service from a ghcr.io image in a project."""
        q = """
        mutation CreateService($projectId: String!, $sourceImage: String!, $name: String!) {
            createService(projectId: $projectId, sourceImage: $sourceImage, name: $name) {
                id name
            }
        }
        """
        data = await self._query(q, {
            "projectId": project_id,
            "sourceImage": source_image,
            "name": service_name,
        })
        return data.get("data", {}).get("createService", {})

    async def add_postgres(self, project_id: str) -> dict:
        """Add PostgreSQL plugin to project."""
        q = """
        mutation CreatePlugin($projectId: String!, $pluginId: String!) {
            pluginCreate(projectId: $projectId, pluginId: $pluginId) {
                id name
            }
        }
        """
        data = await self._query(q, {
            "projectId": project_id,
            "pluginId": "postgres",
        })
        return data.get("data", {}).get("pluginCreate", {})

    async def set_variable(self, project_id: str, service_id: str, key: str, value: str) -> dict:
        """Set environment variable for a service."""
        q = """
        mutation VariableCreate($projectId: String!, $serviceId: String!, $key: String!, $value: String!) {
            variableCreate(
                projectId: $projectId,
                serviceId: $serviceId,
                name: $key,
                value: $value
            ) { id name }
        }
        """
        data = await self._query(q, {
            "projectId": project_id,
            "serviceId": service_id,
            "key": key,
            "value": value,
        })
        return data.get("data", {}).get("variableCreate", {})

    async def get_service_url(self, project_id: str, service_id: str) -> Optional[str]:
        """Get the public URL of a service."""
        q = """
        query ($projectId: String!, $serviceId: String!) {
            service(projectId: $projectId, id: $serviceId) {
                domains { edges { node { domain } } }
            }
        }
        """
        data = await self._query(q, {"projectId": project_id, "serviceId": service_id})
        edges = (data.get("data", {}).get("service", {}).get("domains", {}).get("edges", []))
        if edges:
            return f"https://{edges[0]['node']['domain']}"
        return None

    async def wait_for_deploy(self, service_id: str, timeout: int = 180) -> bool:
        """Wait for a service to finish deploying."""
        q = """
        query ($serviceId: String!) {
            deployments(serviceId: $serviceId, last: 1) {
                edges { node { id status } }
            }
        }
        """
        start = time.time()
        while time.time() - start < timeout:
            data = await self._query(q, {"serviceId": service_id})
            edges = data.get("data", {}).get("deployments", {}).get("edges", [])
            if edges:
                status = edges[0]["node"]["status"]
                if status == "SUCCESS":
                    return True
                elif status == "FAILED":
                    return False
            await time.sleep(5)
        return False

    async def deploy_panel(self, image: str, project_name: str = "spider-panel",
                           jwt_secret: str = None, first_api_key: str = None) -> dict:
        """
        Full deploy flow:
        1. Create project on Railway
        2. Create service from ghcr.io image
        3. Add PostgreSQL plugin
        4. Set env vars (JWT_SECRET_KEY, FIRST_API_KEY)
        5. Wait for deploy
        6. Get public URL
        7. Return result
        """
        # 1. Create project
        project = await self.create_project(project_name)
        project_id = project.get("id")
        if not project_id:
            return {"error": "Failed to create Railway project", "detail": project}

        # 2. Create service from image
        service = await self.create_service(project_id, image)
        service_id = service.get("id")
        if not service_id:
            return {"error": "Failed to create Railway service", "detail": service}

        # 3. Add PostgreSQL
        try:
            await self.add_postgres(project_id)
        except Exception as e:
            pass  # Postgres might already be added

        # 4. Set env vars
        if jwt_secret:
            await self.set_variable(project_id, service_id, "JWT_SECRET_KEY", jwt_secret)
        if first_api_key:
            await self.set_variable(project_id, service_id, "FIRST_API_KEY", first_api_key)

        # 5. Wait for deploy
        deployed = await self.wait_for_deploy(service_id)

        # 6. Get URL
        url = await self.get_service_url(project_id, service_id)

        return {
            "project_id": project_id,
            "service_id": service_id,
            "url": url or "waiting...",
            "deployed": deployed,
        }
