# Spider Panel - VPS Control Panel API for Xray VPN Management

## Quick Start

```bash
# Clone and setup
cp .env.example .env
# Edit .env with your settings

# Docker Compose
docker-compose up -d

# Access
# API: http://localhost:8000/docs
# Login with your API key
```

## API Endpoints

### Auth
- `POST /api/auth/login` - Login with API key

### Profile
- `GET /api/users/profile` - Get profile
- `PATCH /api/users/profile` - Update profile

### Dashboard
- `GET /api/dashboard` - Server stats

### Users
- `GET /api/users` - List users
- `POST /api/users` - Create user
- `PATCH /api/users/{id}` - Update user
- `DELETE /api/users/{id}` - Delete user
- `GET /api/users/{id}/qr` - QR code
- `GET /api/users/{id}/config` - Config link
- `GET /api/users/{id}/subscription` - Subscription URL
- `POST /api/users/{id}/reset` - Reset traffic
- `POST /api/users/{id}/proxy` - Assign proxy

### Inbounds
- `GET /api/inbounds` - List inbounds
- `POST /api/inbounds` - Create inbound
- `PATCH /api/inbounds/{id}` - Update
- `DELETE /api/inbounds/{id}` - Delete
- `POST /api/inbounds/{id}/enable` - Enable
- `POST /api/inbounds/{id}/disable` - Disable
- `GET /api/inbounds/{id}/json` - Copy JSON
- `GET /api/inbounds/{id}/stats` - Statistics

### Hermes AI
- `POST /api/hermes/install` - Install Hermes
- `POST /api/hermes/start` - Start Hermes
- `POST /api/hermes/chat` - Chat (streaming)
- `POST /api/hermes/upload` - Upload image

### News
- `GET /api/news` - Get cached news
- `POST /api/news/refresh` - Refresh cache

### Proxy
- `GET /api/proxy` - List proxies
- `POST /api/proxy` - Add proxy
- `DELETE /api/proxy/{id}` - Remove proxy

### Settings
- `GET /api/settings` - All settings
- `PATCH /api/settings/theme` - Change theme
- `PATCH /api/settings/password` - Set password
- `GET /api/settings/apikeys` - List API keys
- `POST /api/settings/apikeys` - Generate key
- `DELETE /api/settings/apikeys/{id}` - Delete key
- `POST /api/settings/apikeys/{id}/regenerate` - Regenerate
- `POST /api/settings/backup` - Backup
- `POST /api/settings/restore` - Restore
- `POST /api/settings/reset` - Reset panel

### Telegram
- `POST /api/telegram/connect` - Connect bot
- `GET /api/telegram/status` - Bot status
