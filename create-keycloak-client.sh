#!/bin/bash

# This script creates a Keycloak client for Obsidian using kcadm.sh
# Run this script to automatically configure the Keycloak client

set -e

echo "========================================="
echo "Creating Keycloak Client for Obsidian"
echo "========================================="
echo ""

# Load Keycloak admin password from secrets
KEYCLOAK_SECRETS="/home/administrator/secrets/keycloak.env"
if [ ! -f "$KEYCLOAK_SECRETS" ]; then
    echo "ERROR: Keycloak secrets file not found at $KEYCLOAK_SECRETS"
    exit 1
fi

source "$KEYCLOAK_SECRETS"

# Configure kcadm.sh
docker exec keycloak /opt/keycloak/bin/kcadm.sh config credentials \
  --server http://localhost:8080 \
  --realm master \
  --user admin \
  --password "$KEYCLOAK_ADMIN_PASSWORD"

# Create the client
CLIENT_ID=$(docker exec keycloak /opt/keycloak/bin/kcadm.sh create clients -r master \
  -s clientId=obsidian \
  -s enabled=true \
  -s publicClient=false \
  -s protocol=openid-connect \
  -s 'redirectUris=["https://obsidian.ai-servicers.com/*"]' \
  -s 'webOrigins=["https://obsidian.ai-servicers.com"]' \
  -s 'attributes."post.logout.redirect.uris"="https://obsidian.ai-servicers.com/*"' \
  -i 2>&1)

echo "Client created with ID: $CLIENT_ID"

# Get the client secret
CLIENT_SECRET=$(docker exec keycloak /opt/keycloak/bin/kcadm.sh get "clients/$CLIENT_ID/client-secret" -r master --fields value | \
  python3 -c "import sys, json; print(json.load(sys.stdin)['value'])")

echo ""
echo "Client Secret: $CLIENT_SECRET"
echo ""

# Create groups mapper
docker exec keycloak /opt/keycloak/bin/kcadm.sh create \
  "clients/$CLIENT_ID/protocol-mappers/models" -r master \
  -s name=groups \
  -s protocol=openid-connect \
  -s protocolMapper=oidc-group-membership-mapper \
  -s 'config."claim.name"=groups' \
  -s 'config."full.path"=true' \
  -s 'config."id.token.claim"=true' \
  -s 'config."access.token.claim"=true' \
  -s 'config."userinfo.token.claim"=true'

echo "Groups mapper created"
echo ""

# Update secrets file
SECRETS_FILE="/home/administrator/secrets/obsidian.env"
if [ -f "$SECRETS_FILE" ]; then
    sed -i "s/KEYCLOAK_CLIENT_SECRET=REPLACE_ME/KEYCLOAK_CLIENT_SECRET=$CLIENT_SECRET/" "$SECRETS_FILE"
    sed -i "s/OAUTH2_PROXY_CLIENT_SECRET=REPLACE_ME/OAUTH2_PROXY_CLIENT_SECRET=$CLIENT_SECRET/" "$SECRETS_FILE"
    echo "Updated $SECRETS_FILE with client secret"
else
    echo "WARNING: Secrets file not found at $SECRETS_FILE"
    echo "Please manually add:"
    echo "  KEYCLOAK_CLIENT_SECRET=$CLIENT_SECRET"
    echo "  OAUTH2_PROXY_CLIENT_SECRET=$CLIENT_SECRET"
fi

echo ""
echo "========================================="
echo "Keycloak Client Setup Complete!"
echo "========================================="
echo ""
echo "You can now run: cd /home/administrator/projects/obsidian && ./deploy.sh"
echo ""
