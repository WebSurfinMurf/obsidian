# Keycloak Client Setup for Obsidian

## Step 1: Create the Client

1. Go to https://keycloak.ai-servicers.com/admin/master/console/#/master/clients
2. Click **"Create client"**
3. Fill in the following:
   - **Client ID**: `obsidian`
   - **Client type**: `OpenID Connect`
4. Click **Next**

## Step 2: Configure Client Authentication

1. Enable **"Client authentication"** (toggle ON)
2. Click **Save**

## Step 3: Configure Redirect URIs

1. Go to the **Settings** tab
2. Set the following:
   - **Valid redirect URIs**: `https://obsidian.ai-servicers.com/*`
   - **Valid post logout redirect URIs**: `https://obsidian.ai-servicers.com/*`
   - **Web origins**: `https://obsidian.ai-servicers.com`
3. Click **Save**

## Step 4: Get Client Secret

1. Go to the **Credentials** tab
2. Copy the **Client secret**
3. Update `$HOME/projects/secrets/obsidian.env`:
   ```bash
   nano $HOME/projects/secrets/obsidian.env
   # Update these lines with the client secret from Keycloak:
   # KEYCLOAK_CLIENT_SECRET=<paste-secret-here>
   # OAUTH2_PROXY_CLIENT_SECRET=<paste-secret-here>
   ```

## Step 5: Create Groups Mapper

1. Go to **Client scopes** tab
2. Click on **obsidian-dedicated**
3. Click **Add mapper** → **By configuration**
4. Select **Group Membership**
5. Fill in the following:
   - **Name**: `groups`
   - **Token Claim Name**: `groups`
   - **Full group path**: `ON`
   - **Add to ID token**: `ON`
   - **Add to access token**: `ON`
   - **Add to userinfo**: `ON`
6. Click **Save**

## Step 6: Verify User Group Membership

1. Go to **Users** in the left menu
2. Find your user
3. Go to **Groups** tab
4. Ensure the user is in `/developers` or `/administrators` group

## Step 7: Deploy Obsidian

```bash
cd /home/administrator/projects/obsidian
./deploy.sh
```
