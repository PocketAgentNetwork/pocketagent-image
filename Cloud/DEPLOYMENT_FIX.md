# Butler Deployment Fix Guide

## Problem We Fixed

### Issue: Container Restart Loop
**Symptom:** Container kept restarting every few seconds with exit code 1

**Root Cause:** Invalid `typingMode` configuration in `/home/node/.openclaw/openclaw.json`

**Error Message:**
```
Invalid config at /home/node/.openclaw/openclaw.json:
- agents.defaults.typingMode: Invalid input
- session.typingMode: Invalid input
```

### Why It Happened
- Old/corrupted config file from previous OpenClaw version
- Config format changed but old values weren't migrated
- Manual config edits with invalid values

---

## The Fix

### Immediate Solution
```bash
# Stop the container
docker stop butler
docker rm butler

# Remove the corrupted config (it will regenerate)
rm /opt/butler/data/openclaw/openclaw.json

# Restart container
docker start butler
```

### Alternative: Fix the Config
```bash
# Edit the config and set valid typingMode values
# Valid values: "instant", "typing", "realistic"
docker run --rm -it \
  -v /opt/butler/data/openclaw:/home/node/.openclaw \
  ghcr.io/thejamesnick/butler:latest \
  sh -c "sed -i 's/\"typingMode\".*$/\"typingMode\": \"instant\",/g' /home/node/.openclaw/openclaw.json"
```

---

## Prevention Measures Added

### 1. Health Checks
Added to `docker-compose.yml` and deploy workflow:
```yaml
healthcheck:
  test: ["CMD", "curl", "-f", "http://localhost:18789"]
  interval: 30s
  timeout: 10s
  retries: 3
  start_period: 40s
```

**Benefit:** Detects when container is unhealthy and prevents endless restart loops

### 2. Automatic Backups
Added to `.github/workflows/deploy.yml`:
```bash
# Backup before every deployment
tar -czf /opt/butler/backups/butler-backup-$(date +%Y%m%d-%H%M%S).tar.gz \
  /opt/butler/data
```

**Benefit:** Can restore if deployment breaks something

### 3. Config Validation
Added pre-deployment validation:
```bash
# Validate and fix config before starting
docker run --rm \
  -v /opt/butler/data/openclaw:/home/node/.openclaw \
  ghcr.io/${{ github.repository }}:latest \
  sh -c "openclaw doctor --fix || echo 'Config validation skipped'"
```

**Benefit:** Catches config errors before they cause restart loops

### 4. Version-Based Deployments
Changed trigger from `push to main` to `version tags`:
```yaml
on:
  push:
    tags:
      - 'v*.*.*'
```

**Benefit:** Controlled updates, no accidental deployments

### 5. Self-Update Skill
Added `workspace/skills/self-update/SKILL.md` for agent to update itself:
```bash
cd /app && git checkout <version> && pnpm install && pnpm build
```

**Benefit:** Agent can update OpenClaw without rebuilding Docker image

### 6. Automatic Workspace Sync
Added workspace sync to deployment workflow:
```yaml
- name: Sync workspace to server
  uses: appleboy/scp-action@v0.1.7
  with:
    source: "workspace/*"
    target: "/opt/butler/"
    overwrite: true
```

**Benefit:** New and updated skills automatically sync to server on deployment

**Behavior:**
- ✅ New skills are copied to server
- ✅ Updated skills are overwritten
- ✅ Removed skills stay on server (safe, won't delete)
- ✅ Agent-created skills are preserved

---

## For Official Image

### Apply These Changes

#### 1. Add Health Check to Dockerfile
```dockerfile
HEALTHCHECK --interval=30s --timeout=10s --retries=3 --start-period=40s \
  CMD curl -f http://localhost:18789 || exit 1
```

#### 2. Add Config Validation to Entrypoint
In `entrypoint.sh`, add before starting OpenClaw:
```bash
# Validate config
if [ -f "$HOME/.openclaw/openclaw.json" ]; then
  echo "🔍 Validating config..."
  openclaw doctor --fix || echo "⚠️  Config validation failed, using defaults"
fi
```

#### 3. Pin OpenClaw Version
In Dockerfile, use specific commit/tag instead of latest:
```dockerfile
RUN git clone https://github.com/openclaw/openclaw.git . && \
    git checkout v1.2.3 && \  # Pin to specific version
    corepack enable && \
    pnpm install --frozen-lockfile && \
    pnpm build
```

#### 4. Add Backup Mechanism
Create a backup script in the image:
```bash
#!/bin/bash
# /usr/local/bin/backup-butler
tar -czf /backups/butler-$(date +%Y%m%d-%H%M%S).tar.gz \
  $HOME/.openclaw \
  $HOME/files
```

#### 5. Document Valid Config Values
Add to README or docs:
```markdown
## Configuration

Valid `typingMode` values:
- "instant" - No typing animation
- "typing" - Realistic typing speed
- "realistic" - Variable typing with pauses
```

---

## Testing Checklist

Before deploying to production:

- [ ] Test config validation with invalid config
- [ ] Verify health check detects failures
- [ ] Confirm backups are created
- [ ] Test self-update feature
- [ ] Verify container restarts properly
- [ ] Check logs for errors
- [ ] Test with version tags

---

## Rollback Plan

If deployment fails:

```bash
# Stop new container
docker stop butler && docker rm butler

# Restore from backup
cd /opt/butler/backups
tar -xzf butler-backup-YYYYMMDD-HHMMSS.tar.gz -C /

# Start with previous image version
docker run -d --name butler [previous-image-tag]
```

---

## Monitoring

Watch for these signs of issues:

```bash
# Check container status
docker ps | grep butler

# Check health status
docker inspect --format='{{.State.Health.Status}}' butler

# Watch logs for errors
docker logs -f butler | grep -i error

# Check restart count
docker inspect --format='{{.RestartCount}}' butler
```

---

## Summary

**What we fixed:**
- Invalid typingMode config causing restart loop
- Permission issues with deployment directories
- SSH connection timeout issues
- Health check failures (curl not available in container)
- Workspace sync permission errors

**What we added:**
- Health checks (later removed due to curl dependency)
- Automatic backups
- Config validation
- Version-based deployments
- Self-update capability
- Automatic workspace sync (skills, agents, configs)

**Result:**
- More stable deployments
- Easier troubleshooting
- Controlled updates
- Quick recovery from failures
- Skills automatically sync on deployment

---

## Additional Fixes Applied

### Fix 1: SSH Permission Issues
**Problem:** GitHub Actions couldn't connect to server

**Solution:**
1. Generate permanent SSH key on local machine
2. Add public key to server's `~/.ssh/authorized_keys`
3. Add private key to GitHub Secrets as `SSH_PRIVATE_KEY`

### Fix 2: Directory Permission Issues
**Problem:** `Permission denied` when creating directories

**Solution:** Add `sudo` to all directory operations:
```bash
sudo mkdir -p /opt/butler/backups
sudo mkdir -p /opt/butler/data/openclaw
sudo mkdir -p /opt/butler/workspace
```

### Fix 3: Health Check Failures
**Problem:** Container never became "healthy" - curl not available

**Solution:** Remove health check, use simple container status check:
```bash
# Instead of health check, just verify container is running
sleep 10
if docker ps | grep -q butler; then
  echo "✅ Butler container is running!"
  docker logs --tail 20 butler
else
  echo "❌ Butler failed to start!"
  docker logs butler
  exit 1
fi
```

### Fix 4: Workspace Sync Permission Errors
**Problem:** SCP couldn't write to `/opt/butler/workspace`

**Solution:** Use git clone/pull with sudo instead of SCP:
```bash
sudo mkdir -p /opt/butler/workspace

if [ -d "/opt/butler/workspace/.git" ]; then
  cd /opt/butler/workspace
  sudo git pull origin main
else
  cd /tmp
  git clone https://github.com/user/repo.git temp-workspace
  sudo cp -r temp-workspace/workspace/* /opt/butler/workspace/
  rm -rf temp-workspace
fi
```

---

## Quick Reference: Apply to New Image

### 1. Dockerfile Changes
```dockerfile
# Add health check (optional, only if curl is available)
HEALTHCHECK --interval=30s --timeout=10s --retries=3 --start-period=40s \
  CMD curl -f http://localhost:18789 || exit 1
```

### 2. Deploy Workflow Changes
```yaml
# Use version tags instead of push to main
on:
  push:
    tags:
      - 'v*.*.*'

# Add sudo to all directory operations
script: |
  sudo mkdir -p /opt/app/backups
  sudo mkdir -p /opt/app/data
  
# Use git for workspace sync instead of SCP
if [ -d "/opt/app/workspace/.git" ]; then
  cd /opt/app/workspace
  sudo git pull origin main
else
  cd /tmp
  git clone https://github.com/user/repo.git temp
  sudo cp -r temp/workspace/* /opt/app/workspace/
  rm -rf temp
fi

# Simple container check instead of health check
sleep 10
if docker ps | grep -q myapp; then
  echo "✅ Running!"
  docker logs --tail 20 myapp
else
  echo "❌ Failed!"
  docker logs myapp
  exit 1
fi
```

### 3. SSH Setup
```bash
# On local machine
ssh-keygen -t ed25519 -C "github-actions" -f ~/.ssh/deploy-key

# On server (via console)
echo "your-public-key" >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys

# In GitHub Secrets
SSH_PRIVATE_KEY = contents of ~/.ssh/deploy-key
SERVER_HOST = your-server-ip
SERVER_USER = your-username
```

### 4. Server Firewall
```bash
# Allow SSH from GitHub Actions
gcloud compute firewall-rules create allow-ssh \
    --allow tcp:22 \
    --source-ranges 0.0.0.0/0
```

---

## Troubleshooting

### Container won't start
```bash
# Check logs
docker logs butler

# Check if port is in use
sudo netstat -tlnp | grep 18789

# Check permissions
ls -la /opt/butler/
```

### SSH connection fails
```bash
# Test SSH manually
ssh -i ~/.ssh/deploy-key user@server-ip

# Check firewall
gcloud compute firewall-rules list | grep ssh
```

### Workspace not syncing
```bash
# Check git repo
cd /opt/butler/workspace
git status
git log

# Check permissions
ls -la /opt/butler/workspace
```
