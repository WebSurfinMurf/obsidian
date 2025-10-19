# Obsidian - Self-Hosted Knowledge Management

## Overview
Obsidian is a powerful knowledge management and note-taking application that works on local Markdown files. This deployment uses LinuxServer.io's Docker image to provide web browser access to Obsidian from anywhere, making your personal knowledge base accessible across all devices.

**Project Type:** Knowledge Management / Note-Taking / Personal Wiki
**Deployment Date:** 2025-10-19
**Status:** Production
**Primary DNS:** https://obsidian.ai-servicers.com

## Architecture

### Components

1. **Obsidian (lscr.io/linuxserver/obsidian:latest)** - Main application
   - Container: `obsidian`
   - Internal port: 3000 (HTTP), 3001 (HTTPS)
   - External port: 3000 (direct access)
   - Networks: `obsidian-net` (isolated), `traefik-net`
   - Technology: Electron app in containerized desktop environment
   - Shared memory: 1GB

2. **OAuth2 Proxy (latest)** - Authentication gateway
   - Container: `obsidian-auth-proxy`
   - External port: 4180 (via Traefik)
   - Networks: `obsidian-net`, `keycloak-net`, `traefik-net`
   - Keycloak integration with hybrid URL strategy

### Network Isolation

```
Internet → Traefik (traefik-net)
              ↓
         OAuth2 Proxy (traefik-net + keycloak-net + obsidian-net)
              ↓
         Obsidian (obsidian-net + traefik-net)
```

**Dual Access Model:**
- **External (SSO)**: https://obsidian.ai-servicers.com → OAuth2 Proxy → Obsidian
- **Internal (No Auth)**: http://obsidian.linuxserver.lan → Traefik → Obsidian
- **Direct Port**: http://linuxserver.lan:3000 → Obsidian

## Features

### Core Functionality
- **Local Markdown Files**: All notes stored as plain text .md files
- **Graph View**: Visualize connections between notes
- **Backlinks**: Automatic bidirectional links between notes
- **Tags**: Organize notes with tags and nested tags
- **Search**: Powerful search across all notes
- **Command Palette**: Quick access to all features (Ctrl/Cmd+P)
- **Workspaces**: Save and switch between different layouts

### Advanced Features
- **Canvas**: Visual whiteboard for organizing ideas
- **Templates**: Create note templates for consistency
- **Daily Notes**: Automatic daily note creation
- **Plugins**: 1000+ community plugins
- **Themes**: Extensive theme customization
- **Vim Mode**: Vim keybindings support
- **Mobile Sync**: Sync with Obsidian mobile apps (requires sync solution)

### Knowledge Management
- **Zettelkasten**: Perfect for zettelkasten-style note-taking
- **Wiki-Style Links**: [[Internal links]] between notes
- **Aliases**: Multiple names for the same note
- **Outgoing/Incoming Links**: See all connections
- **Unlinked Mentions**: Find references to notes not yet linked
- **Folder Organization**: Hierarchical folder structure

### Content Features
- **Markdown**: Full CommonMark + GFM support
- **LaTeX Math**: Inline and block math equations
- **Mermaid Diagrams**: Flowcharts, sequence diagrams, etc.
- **Code Blocks**: Syntax highlighting for 50+ languages
- **Embeds**: Embed notes, images, PDFs, audio, video
- **Tables**: Markdown tables with sorting

## Configuration

### Environment Variables

Location: `/home/administrator/secrets/obsidian.env`

**Container Settings:**
- `PUID=1000` - User ID for file permissions
- `PGID=1000` - Group ID for file permissions
- `TZ=America/New_York` - Timezone

**Obsidian Ports:**
- `OBSIDIAN_HTTP_PORT=3000` - HTTP web interface
- `OBSIDIAN_HTTPS_PORT=3001` - HTTPS web interface (not exposed)
- `OBSIDIAN_DIRECT_PORT=3000` - Direct access port

**OAuth2 Proxy Settings (Hybrid URL Strategy):**
- `OAUTH2_PROXY_CLIENT_ID=obsidian`
- `OAUTH2_PROXY_CLIENT_SECRET` - Keycloak client secret
- `OAUTH2_PROXY_COOKIE_SECRET` - 32-byte session cookie encryption key
- `OAUTH2_PROXY_COOKIE_NAME=_obsidian_oauth2_proxy`
- `OAUTH2_PROXY_PROVIDER=keycloak-oidc`
- `OAUTH2_PROXY_OIDC_ISSUER_URL=https://keycloak.ai-servicers.com/realms/master`
- `OAUTH2_PROXY_LOGIN_URL=https://keycloak.ai-servicers.com/realms/master/protocol/openid-connect/auth`
- `OAUTH2_PROXY_REDEEM_URL=http://keycloak:8080/realms/master/protocol/openid-connect/token`
- `OAUTH2_PROXY_OIDC_JWKS_URL=http://keycloak:8080/realms/master/protocol/openid-connect/certs`
- `OAUTH2_PROXY_SKIP_OIDC_DISCOVERY=true`
- `OAUTH2_PROXY_REDIRECT_URL=https://obsidian.ai-servicers.com/oauth2/callback`
- `OAUTH2_PROXY_ALLOWED_GROUPS=/developers,/administrators`
- `OAUTH2_PROXY_UPSTREAMS=http://obsidian:3000`

### Keycloak Client

**Client ID:** `obsidian`
**Client Type:** Confidential (client authentication ON)
**Valid Redirect URIs:**
- `https://obsidian.ai-servicers.com/*`
- `https://obsidian.ai-servicers.com/oauth2/callback`

**Valid Post Logout Redirect URIs:**
- `https://obsidian.ai-servicers.com/*`

**Web Origins:**
- `https://obsidian.ai-servicers.com`

**Access Control:** `/developers` and `/administrators` groups

**Client Scopes:**
- `obsidian-dedicated` - Has only **groups** mapper (NO audience mapper)
- Mapper configuration:
  - Name: `groups`
  - Token Claim Name: `groups`
  - Full group path: ON
  - Add to ID token: ON
  - Add to access token: ON
  - Add to userinfo: ON

## Deployment

### Initial Deployment

**Step 1: Create Keycloak Client**

Manual setup (recommended):
```bash
cat /home/administrator/projects/obsidian/setup-keycloak-client.md
```

**Step 2: Update Secrets File**

After creating the Keycloak client:
```bash
nano /home/administrator/secrets/obsidian.env
# Update KEYCLOAK_CLIENT_SECRET and OAUTH2_PROXY_CLIENT_SECRET
```

**Step 3: Deploy**

```bash
cd /home/administrator/projects/obsidian
./deploy.sh
```

The deployment script:
1. Validates environment file exists
2. Verifies Keycloak client secret is configured
3. Creates Docker networks
4. Exports environment variables
5. Deploys containers via docker-compose
6. Waits for containers to start (first start takes 30-60 seconds)
7. Verifies containers are running

### Manual Operations

**Restart services:**
```bash
cd /home/administrator/projects/obsidian
docker compose restart
```

**View logs:**
```bash
docker logs -f obsidian
docker logs -f obsidian-auth-proxy
```

**Redeploy:**
```bash
cd /home/administrator/projects/obsidian
./deploy.sh
```

## Access

### Web Interface

**External (SSO):** https://obsidian.ai-servicers.com
- Authentication: OAuth2 via Keycloak
- Authorized Groups: `/developers`, `/administrators`
- Features: Full Obsidian web interface with SSO protection

**Internal (No Auth):** http://obsidian.linuxserver.lan
- Authentication: None (direct access)
- Access: Internal network only
- Use Case: Quick access to notes from trusted network

**Direct Port:** http://linuxserver.lan:3000
- Same as internal Traefik access
- Direct container port binding

### First-Time Setup

1. **Access Obsidian** via one of the URLs above
2. **Create or Open a Vault:**
   - Click "Create new vault" OR
   - Click "Open folder as vault"
   - Recommended location: `/config/vaults/MyVault`
3. **Start taking notes!**

### Vault Location

Vaults are stored at: `/home/administrator/projects/data/obsidian/vaults/`

This directory is mounted to `/config` inside the container.

## Use Cases

### 1. Personal Knowledge Base
```bash
# Create interconnected notes on any topic
# Use [[wiki-links]] to connect concepts
# Build a graph of your knowledge over time
```

### 2. Project Documentation
```bash
# Document each project in its own folder
# Link related documentation together
# Use tags for categorization
# Search across all project notes
```

### 3. Zettelkasten Method
```bash
# Create atomic notes (one idea per note)
# Link notes together to form knowledge chains
# Use graph view to discover connections
# Tag notes with #fleeting, #literature, #permanent
```

### 4. Daily Journaling
```bash
# Enable Daily Notes plugin
# Automatic note creation for each day
# Template with prompts, tasks, reflections
# Link to relevant project notes
```

### 5. Code Snippet Library
```bash
# Store reusable code snippets
# Syntax highlighting for all languages
# Tag by language, framework, purpose
# Quick search to find snippets
```

### 6. Meeting Notes
```bash
# Create template for meeting notes
# Link to related project notes
# Use checkboxes for action items
# Tag attendees, topics, decisions
```

### 7. AI-Assisted Note-Taking (with MCP)
```bash
# LLMs can read/write notes via MCP filesystem access
# Ask Claude to summarize long notes
# Have AI create new notes from conversations
# Search your knowledge base through AI
```

## Data Persistence

### Volume Mounts

```
/home/administrator/projects/data/obsidian → /config (bind mount)
```

Stored data:
- Obsidian vaults (notes, attachments)
- Application settings
- Installed plugins
- Custom themes
- Workspaces
- User preferences

**Note:** All data is stored in `/home/administrator/projects/data/obsidian`, not in the project directory.

### Vault Structure

Typical vault structure inside `/config/vaults/MyVault/`:
```
MyVault/
├── .obsidian/           # Obsidian configuration
│   ├── plugins/         # Installed plugins
│   ├── themes/          # Custom themes
│   ├── workspace.json   # Workspace layout
│   └── app.json         # App settings
├── Daily Notes/         # Daily journal entries
├── Projects/            # Project documentation
├── Zettelkasten/        # Atomic notes
├── Templates/           # Note templates
└── Attachments/         # Images, PDFs, files
```

### Backup Strategy

**Manual Vault Backup:**
```bash
# Backup entire vault
tar -czf obsidian-vault-backup-$(date +%Y%m%d).tar.gz \
  /home/administrator/projects/data/obsidian/vaults/

# Or use git for version control
cd /home/administrator/projects/data/obsidian/vaults/MyVault
git init
git add .
git commit -m "Initial vault backup"
```

**Automated Backup with Git:**
```bash
# Create a git repository for your vault
cd /home/administrator/projects/data/obsidian/vaults/MyVault
git init
git remote add origin <your-git-repo-url>

# Add to cron for daily backups
# 0 2 * * * cd /home/administrator/projects/data/obsidian/vaults/MyVault && git add . && git commit -m "Daily backup $(date +\%Y-\%m-\%d)" && git push
```

## Common Commands

```bash
# Check status
docker ps --filter name=obsidian

# View Obsidian logs
docker logs obsidian --tail 50

# View OAuth2 proxy logs
docker logs obsidian-auth-proxy --tail 50

# Restart Obsidian only
docker restart obsidian

# Restart OAuth2 proxy only
docker restart obsidian-auth-proxy

# Full redeploy
cd /home/administrator/projects/obsidian
./deploy.sh

# Check container health
docker inspect obsidian --format '{{.State.Status}}'
docker inspect obsidian-auth-proxy --format '{{.State.Status}}'

# Access vault files directly
ls -la /home/administrator/projects/data/obsidian/vaults/

# Check vault size
du -sh /home/administrator/projects/data/obsidian/vaults/*

# Test internal access
curl -I http://obsidian.linuxserver.lan

# Test direct port access
curl -I http://localhost:3000
```

## Troubleshooting

### Obsidian Won't Start

**Issue:** Container keeps restarting
**Cause:** Insufficient shared memory or permissions issue
**Solution:**

```bash
# Check logs
docker logs obsidian --tail 100

# Verify shm_size is set to 1gb in docker-compose.yml
docker inspect obsidian | grep -i shm

# Check file permissions
ls -la /home/administrator/projects/data/obsidian/
# Should be owned by UID 1000 (PUID)

# Fix permissions if needed
sudo chown -R 1000:1000 /home/administrator/projects/data/obsidian/
```

### Slow Initial Startup

**Issue:** Obsidian takes 30-60 seconds to start
**Cause:** Normal - containerized desktop environment initialization
**Solution:** Wait patiently on first startup

```bash
# Monitor startup progress
docker logs -f obsidian
```

### Can't Create Vault

**Issue:** Permission denied when creating vault
**Cause:** File permissions inside container
**Solution:**

```bash
# Ensure directory exists and has correct permissions
mkdir -p /home/administrator/projects/data/obsidian/vaults/
sudo chown -R 1000:1000 /home/administrator/projects/data/obsidian/

# Create vault directory manually
mkdir -p /home/administrator/projects/data/obsidian/vaults/MyVault
sudo chown -R 1000:1000 /home/administrator/projects/data/obsidian/vaults/MyVault

# Then open as existing vault in Obsidian
```

### OAuth2 Proxy Issues

**Issue:** 403 Forbidden on login
**Cause:** User not in authorized groups
**Solution:** Verify user is in `/developers` or `/administrators` group in Keycloak

**Issue:** Invalid cookie secret
**Cause:** Cookie secret is wrong length
**Solution:** Regenerate with `python3 -c "import secrets; print(secrets.token_urlsafe(32))"`

### Plugins Not Working

**Issue:** Community plugins fail to install
**Cause:** Network restrictions or safe mode enabled
**Solution:**

```bash
# Check if safe mode is disabled
# In Obsidian: Settings → Community plugins → Turn off safe mode

# Verify internet access from container
docker exec obsidian ping -c 3 github.com
```

### Web Interface Slow

**Issue:** Laggy or slow web interface
**Cause:** Network latency or insufficient resources
**Solution:**

```bash
# Check container resource usage
docker stats obsidian

# For better performance, use Obsidian desktop app with vault sync
# Or increase container resources in docker-compose.yml
```

## Security

### Authentication Layers

1. **External Access:** OAuth2 proxy → Keycloak SSO → Group membership check
2. **Internal Access:** No authentication (trusted network)
3. **Network Isolation:** Backend on separate network

### Secret Management

- All secrets stored in `/home/administrator/secrets/obsidian.env`
- Secrets loaded via environment variable substitution
- **Never commit** secrets to git (.gitignore configured)
- No secrets stored in projects/obsidian directory

### Best Practices

- Keep your vault **private** - contains your personal knowledge
- Use **strong passwords** if enabling Obsidian's built-in auth
- Regularly **backup your vault** (git recommended)
- Monitor logs for **suspicious activity**
- Keep internal access **isolated** to trusted network
- Use **version control** (git) for your vault to track changes
- Consider **encrypting sensitive notes** using Obsidian plugins

### Vault Encryption

While Obsidian itself doesn't encrypt notes, you can:
1. Use git-crypt for vault encryption
2. Store vault on encrypted filesystem
3. Use Obsidian encryption plugins (community)
4. Encrypt individual notes with PGP

## MCP Integration

Obsidian works perfectly with MCP (Model Context Protocol) for AI integration:

### MCP Filesystem Access

With the `mcp__filesystem` server configured, LLMs can:
- **Read notes** from your vault: `/home/administrator/projects/data/obsidian/vaults/`
- **Create new notes** based on conversations
- **Update existing notes** with new information
- **Search across notes** to find relevant information
- **Link related notes** automatically

### Example MCP Workflows

**1. AI-Assisted Note Creation:**
```
User: "Claude, create a note about Docker networking in my Obsidian vault"
Claude: [Uses MCP to create /config/vaults/MyVault/Docker Networking.md]
```

**2. Knowledge Base Search:**
```
User: "Find all my notes about authentication"
Claude: [Uses MCP to search vault for "authentication"]
```

**3. Note Summarization:**
```
User: "Summarize my project notes from last week"
Claude: [Reads daily notes via MCP, creates summary]
```

**4. Automatic Linking:**
```
User: "Link this conversation to my Obsidian project notes"
Claude: [Creates note with [[links]] to related notes]
```

### MCP Configuration

To enable MCP access to your Obsidian vault:

1. Ensure MCP filesystem server is running
2. Configure allowed directory: `/home/administrator/projects/data/obsidian`
3. LLMs can now read/write to your vault
4. Use natural language to manage notes

## Naming Convention Compliance

All resources use the name **obsidian**:
- ✓ Container names: `obsidian`, `obsidian-auth-proxy`
- ✓ Project directory: `/home/administrator/projects/obsidian`
- ✓ Component network: `obsidian-net`
- ✓ Environment file: `obsidian.env`
- ✓ Keycloak client: `obsidian`
- ✓ DNS: `obsidian.ai-servicers.com`, `obsidian.linuxserver.lan`
- ✓ Traefik router: `obsidian`, `obsidian-internal`

## Related Documentation

- **Keycloak Integration:** `/home/administrator/projects/AINotes/security.md`
- **OAuth2 Proxy Patterns:** See other OAuth2-protected services (microbin, stirling-pdf)
- **Traefik Configuration:** `/home/administrator/projects/traefik/`
- **Obsidian Official Docs:** https://help.obsidian.md/
- **LinuxServer.io Image:** https://docs.linuxserver.io/images/docker-obsidian/
- **MCP Filesystem:** `/home/administrator/projects/mcp/filesystem/`

## Changelog

### 2025-10-19 - Initial Deployment

**Completed:**
- [x] Project structure creation
- [x] Environment configuration
- [x] Keycloak client setup instructions
- [x] Docker Compose configuration with dual access
- [x] Deployment automation script
- [x] OAuth2 authentication via Keycloak (/developers, /administrators groups)
- [x] Internal access without authentication
- [x] Traefik integration with Let's Encrypt SSL
- [x] Project documentation (this file)

**Configuration:**
- External Access: https://obsidian.ai-servicers.com (SSO required)
- Internal Access: http://obsidian.linuxserver.lan (no auth)
- Direct Access: http://linuxserver.lan:3000 (no auth)
- Features: Full Obsidian web interface, vault management, plugins, themes
- Authentication: Keycloak SSO for external, none for internal
- Data: Stored at `/home/administrator/projects/data/obsidian`

**Use Case:**
- Personal knowledge management
- Note-taking with AI integration via MCP
- Long-term knowledge storage and organization
- Complements MicroBin (sharing) with Obsidian (organizing)

---

*Document created: 2025-10-19*
*Last updated: 2025-10-19*
*Maintained by: Claude Code*
