# Obsidian Installation - Quick Start

## Installation Complete ✓

Obsidian has been installed following the naming convention with:
- ✓ Dual access model (SSO-protected external + open internal)
- ✓ LinuxServer.io Docker image for web browser access
- ✓ OAuth2 proxy for Keycloak SSO integration
- ✓ Traefik integration with automatic SSL
- ✓ Data persistence at `/home/administrator/projects/data/obsidian`
- ✓ No secrets in project directory

## Before First Deployment

### Step 1: Create Keycloak Client

```bash
cat /home/administrator/projects/obsidian/setup-keycloak-client.md
```
Follow the manual instructions to create the Keycloak client.

### Step 2: Update Secrets File

After creating the Keycloak client:
```bash
nano $HOME/projects/secrets/obsidian.env
# Update KEYCLOAK_CLIENT_SECRET and OAUTH2_PROXY_CLIENT_SECRET
```

### Step 3: Deploy Obsidian

```bash
cd /home/administrator/projects/obsidian
./deploy.sh
```

**Note:** First startup takes 30-60 seconds to initialize the containerized desktop environment.

## Access URLs

After deployment:
- **External (SSO)**: https://obsidian.ai-servicers.com
- **Internal (No Auth)**: http://obsidian.linuxserver.lan
- **Direct Port**: http://linuxserver.lan:3000

## First-Time Setup

1. Access Obsidian via one of the URLs above
2. Create a new vault or open existing:
   - Recommended location: `/config/vaults/MyVault`
   - This maps to: `/home/administrator/projects/data/obsidian/vaults/MyVault`
3. Start taking notes!

## Key Features

- **Web Browser Access**: Access Obsidian from any device
- **Graph View**: Visualize connections between your notes
- **Markdown Files**: All notes are plain text .md files
- **Plugins**: 1000+ community plugins available
- **MCP Integration**: AI can read/write your notes via MCP filesystem
- **Backlinks**: Automatic bidirectional linking
- **No Vendor Lock-In**: Plain markdown files you own forever

## Obsidian vs MicroBin

| Feature | Obsidian | MicroBin |
|---------|----------|----------|
| **Purpose** | Knowledge management | Quick code sharing |
| **Storage** | Permanent notes | Temporary pastes |
| **Organization** | Graph view, folders, tags | Simple list |
| **Sharing** | Private vault | Shareable URLs |
| **Use Case** | Long-term knowledge | Quick snippets |
| **Complexity** | Rich features | Simple & fast |

**They're complementary:**
- **Obsidian**: Store your knowledge, organize learnings, AI-assisted note-taking
- **MicroBin**: Share code snippets with colleagues via quick URLs

## MCP Integration

With MCP filesystem access, LLMs can:
- Read all your notes from the vault
- Create new notes based on conversations
- Search your knowledge base
- Link related concepts automatically

Example:
```
User: "Claude, create a note about Docker networking in my Obsidian vault"
Claude: [Uses MCP to create note at /config/vaults/MyVault/Docker Networking.md]
```

## Documentation

Complete documentation: `/home/administrator/projects/obsidian/CLAUDE.md`

## Common Commands

```bash
# Deploy
cd /home/administrator/projects/obsidian
./deploy.sh

# View logs
docker logs -f obsidian

# Check status
docker ps --filter name=obsidian

# Restart
docker restart obsidian

# Access vault files
ls -la /home/administrator/projects/data/obsidian/vaults/
```

## Next Steps

1. Create Keycloak client (see setup-keycloak-client.md)
2. Update secrets file with client secret
3. Run `./deploy.sh`
4. Access via https://obsidian.ai-servicers.com
5. Create your first vault
6. Start building your knowledge base!

---

**Status:** Ready for deployment (pending Keycloak client creation)
