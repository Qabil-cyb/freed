import json
import asyncio
import uuid as uuid_lib
import subprocess
import qrcode
from io import BytesIO
from typing import Dict, Any, List, Optional
from app.config import get_settings


def generate_uuid() -> str:
    """Generate a random UUID for a user."""
    return str(uuid_lib.uuid4())


def generate_qr(data: str):
    """Generate a QR code image."""
    qr = qrcode.QRCode(version=1, box_size=10, border=4)
    qr.add_data(data)
    qr.make(fit=True)
    return qr.make_image(fill_color="black", back_color="white")


def generate_xray_config(user) -> str:
    """Generate a client config share link for a user."""
    protocol = getattr(user, 'protocol', 'vless') or 'vless'
    uuid_val = user.uuid
    return f"{protocol}://{uuid_val}@SERVER:443?security=reality#Spider-{user.username}"

settings = get_settings()


def build_xray_config(inbounds: List[dict], proxies: List[dict] = None) -> Dict[str, Any]:
    """Build a complete Xray configuration from DB inbound records."""
    log_config = {
        "access": "none",
        "error": "log",
        "loglevel": "warning",
    }

    routing_config = {
        "domainStrategy": "AsIs",
        "rules": [
            {
                "inboundTag": ["api"],
                "outboundTag": "api",
                "type": "field"
            }
        ]
    }

    api_inbound = {
        "tag": "api",
        "protocol": "dokodemo-door",
        "listen": "127.0.0.1",
        "port": settings.XRAY_API_PORT,
        "settings": {
            "address": "127.0.0.1"
        }
    }

    xray_inbounds = [api_inbound]

    for ib in inbounds:
        inbound_entry = {
            "tag": ib.get("tag", f"inbound-{ib.get('id', 0)}"),
            "port": ib.get("port", 0),
            "protocol": ib.get("protocol", "vless"),
            "settings": ib.get("settings", {}),
            "sniffing": ib.get("sniffing", {"enabled": True, "destOverride": ["http", "tls"]}),
        }

        # Build stream settings
        stream = ib.get("stream_settings", {})
        if stream:
            inbound_entry["streamSettings"] = stream

        mux = ib.get("mux", {})
        if mux:
            inbound_entry["mux"] = mux

        xray_inbounds.append(inbound_entry)

    xray_outbounds = [
        {
            "tag": "direct",
            "protocol": "freedom",
            "settings": {}
        },
        {
            "tag": "api",
            "protocol": "blackhole",
            "settings": {}
        }
    ]

    # Add proxy outbounds
    if proxies:
        for p in proxies:
            tag = f"proxy-{p.get('id', 0)}-{p.get('country', 'unknown')}"
            proxy_type = p.get("type", "socks5")
            outbound = {
                "tag": tag,
                "protocol": proxy_type if proxy_type in ("socks", "http") else "socks",
                "settings": {
                    "servers": [
                        {
                            "address": p.get("ip", ""),
                            "port": p.get("port", 0)
                        }
                    ]
                }
            }
            xray_outbounds.append(outbound)

    config = {
        "log": log_config,
        "routing": routing_config,
        "inbounds": xray_inbounds,
        "outbounds": xray_outbounds,
    }

    return config


async def save_xray_config(config: Dict[str, Any]) -> bool:
    """Save the Xray config to disk."""
    config_path = settings.XRAY_CONFIG_PATH
    try:
        config_json = json.dumps(config, indent=2)
        proc = await asyncio.create_subprocess_exec(
            "tee", config_path,
            stdin=asyncio.subprocess.PIPE,
            stdout=asyncio.subprocess.DEVNULL,
            stderr=asyncio.subprocess.PIPE,
        )
        _, stderr = await proc.communicate(input=config_json.encode())
        return proc.returncode == 0
    except Exception:
        return False


async def reload_xray() -> bool:
    """Reload Xray config via systemctl."""
    try:
        proc = await asyncio.create_subprocess_exec(
            "systemctl", "reload", "xray",
            stdout=asyncio.subprocess.PIPE,
            stderr=asyncio.subprocess.PIPE,
        )
        stdout, stderr = await proc.communicate()
        if proc.returncode != 0:
            # Try restart if reload fails
            proc2 = await asyncio.create_subprocess_exec(
                "systemctl", "restart", "xray",
                stdout=asyncio.subprocess.PIPE,
                stderr=asyncio.subprocess.PIPE,
            )
            await proc2.communicate()
            return proc2.returncode == 0
        return True
    except Exception:
        return False


async def get_xray_stats() -> Dict[str, Any]:
    """Query Xray stats via xray api."""
    try:
        proc = await asyncio.create_subprocess_exec(
            "xray", "api", "statsquery",
            "--server", f"127.0.0.1:{settings.XRAY_API_PORT}",
            stdout=asyncio.subprocess.PIPE,
            stderr=asyncio.subprocess.PIPE,
        )
        stdout, stderr = await proc.communicate()
        if proc.returncode == 0 and stdout:
            return json.loads(stdout.decode())
    except Exception:
        pass
    return {"stat": []}


async def get_user_config_text(user_uuid: str, inbound: dict) -> str:
    """Generate Xray client config text for a user."""
    protocol = inbound.get("protocol", "vless")
    port = inbound.get("port", 0)
    sni = inbound.get("sni", "")
    host = inbound.get("host", "")
    stream = inbound.get("stream_settings", {})
    transport = inbound.get("transport", "tcp")
    security = inbound.get("security", "reality")

    if protocol == "vless":
        # Build VLESS share link
        params = []
        if security == "reality":
            params.append(f"security=reality")
            fp = stream.get("securitySettings", {}).get("fingerprint", "chrome")
            pbk = stream.get("realitySettings", {}).get("publicKey", "")
            sid = stream.get("realitySettings", {}).get("shortId", "")
            params.append(f"fp={fp}")
            params.append(f"pbk={pbk}")
            params.append(f"sid={sid}")
            params.append(f"sni={sni}")
        elif security == "tls":
            params.append(f"security=tls")
            params.append(f"sni={sni}")

        params.append(f"type={transport}")
        if transport == "ws":
            params.append(f"path={inbound.get('path', '/')}")
            params.append(f"host={host}")

        param_str = "&".join(params)
        share_link = f"vless://{user_uuid}@{host or 'SERVER_IP'}:{port}?{param_str}#{inbound.get('remark', 'Spider')}"

        return share_link

    elif protocol == "vmess":
        vmess_obj = {
            "v": "2",
            "ps": inbound.get("remark", "Spider"),
            "add": host or "SERVER_IP",
            "port": str(port),
            "id": user_uuid,
            "aid": "0",
            "scy": "auto",
            "net": transport,
            "type": "none",
            "host": host,
            "path": inbound.get("path", ""),
            "tls": "tls" if security == "tls" else "",
            "sni": sni,
        }
        import base64
        return f"vmess://{base64.b64encode(json.dumps(vmess_obj).encode()).decode()}"

    return f"{protocol}://{user_uuid}@SERVER_IP:{port}"
