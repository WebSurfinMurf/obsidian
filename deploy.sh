#!/bin/bash

set -e

PROJECT_DIR="/home/administrator/projects/obsidian"
SECRETS_FILE="/home/administrator/secrets/obsidian.env"

echo "========================================="
echo "Obsidian Deployment Script"
echo "========================================="
echo ""

# Check if secrets file exists
if [ ! -f "$SECRETS_FILE" ]; then
    echo "ERROR: Secrets file not found at $SECRETS_FILE"
    exit 1
fi

# Source the secrets file
source "$SECRETS_FILE"

# Check if Keycloak client secret is configured
if [ "$KEYCLOAK_CLIENT_SECRET" = "REPLACE_ME" ]; then
    echo "ERROR: Keycloak client secret not configured!"
    echo ""
    echo "Please create a Keycloak client first:"
    echo "1. Go to https://keycloak.ai-servicers.com/admin/master/console/#/master/clients"
    echo "2. Click 'Create client'"
    echo "3. Client ID: obsidian"
    echo "4. Client type: OpenID Connect"
    echo "5. Click Next"
    echo "6. Enable 'Client authentication'"
    echo "7. Click Save"
    echo "8. Go to 'Credentials' tab and copy the 'Client secret'"
    echo "9. Update $SECRETS_FILE with the client secret"
    echo ""
    echo "Also configure the client:"
    echo "- Valid redirect URIs: https://obsidian.ai-servicers.com/*"
    echo "- Valid post logout redirect URIs: https://obsidian.ai-servicers.com/*"
    echo "- Web origins: https://obsidian.ai-servicers.com"
    echo ""
    echo "Then create a 'groups' mapper in Client scopes -> obsidian-dedicated:"
    echo "- Mapper type: Group Membership"
    echo "- Name: groups"
    echo "- Token Claim Name: groups"
    echo "- Full group path: ON"
    echo "- Add to ID token: ON"
    echo "- Add to access token: ON"
    echo "- Add to userinfo: ON"
    echo ""
    exit 1
fi

# Create networks if they don't exist
echo "Creating Docker networks..."
docker network create traefik-net 2>/dev/null || echo "traefik-net already exists"
docker network create keycloak-net 2>/dev/null || echo "keycloak-net already exists"

# Export secrets as environment variables for docker-compose
export PUID="$PUID"
export PGID="$PGID"
export TZ="$TZ"
export OAUTH2_PROXY_CLIENT_SECRET="$OAUTH2_PROXY_CLIENT_SECRET"
export OAUTH2_PROXY_COOKIE_SECRET="$OAUTH2_PROXY_COOKIE_SECRET"

# Debug: Verify variables are set
if [ -z "$OAUTH2_PROXY_CLIENT_SECRET" ]; then
    echo "WARNING: OAUTH2_PROXY_CLIENT_SECRET is empty!"
fi
if [ -z "$OAUTH2_PROXY_COOKIE_SECRET" ]; then
    echo "WARNING: OAUTH2_PROXY_COOKIE_SECRET is empty!"
fi

# Stop and remove existing containers
echo "Stopping existing containers..."
docker compose -f "$PROJECT_DIR/docker-compose.yml" down 2>/dev/null || true

# Pull latest images
echo "Pulling latest images..."
docker compose -f "$PROJECT_DIR/docker-compose.yml" pull

# Start containers
echo "Starting containers..."
docker compose -f "$PROJECT_DIR/docker-compose.yml" up -d

# Wait for containers to start
echo "Waiting for containers to start..."
sleep 5

# Check container status
echo ""
echo "Container status:"
docker ps --filter name=obsidian

echo ""
echo "========================================="
echo "Obsidian Deployment Complete!"
echo "========================================="
echo ""
echo "Access URLs:"
echo "  External (SSO): https://obsidian.ai-servicers.com"
echo ""
echo "Note: Internal access removed for security"
echo ""
echo "Authorized Groups: /developers, /administrators"
echo ""
echo "Notes:"
echo "  - First startup may take 30-60 seconds to initialize"
echo "  - Vault location: /home/administrator/projects/data/obsidian/vaults/"
echo "  - Create your first vault via the web interface"
echo ""
echo "Check logs:"
echo "  docker logs obsidian"
echo "  docker logs obsidian-auth-proxy"
echo ""
