# 📟 PocketAgent Cloud Deployment Guide

## Quick Start

### 1. Build the Image
```bash
cd pocketagent-image/Cloud
docker compose build
```

### 2. Configure
```bash
cp .env.example .env
# Edit .env and add:
# - OPENCLAW_GATEWAY_TOKEN (generate with: openssl rand -hex 32)
# - Your LLM API keys
```

### 3. Run
```bash
docker compose up -d
```

### 4. Access
Open http://localhost:18789

---

## Production Deployment

### Prerequisites
- Docker & Docker Compose installed
- Server with at least 2GB RAM, 2 CPU cores
- Ports 18789 open (or your custom port)

### Step-by-Step

#### 1. Clone Repository
```bash
git clone https://github.com/PocketAgentNetwork/pocketagent-image.git
cd pocketagent-image/Cloud
```

#### 2. Configure Environment
```bash
cp .env.example .env
nano .env
```

**Required variables:**
```bash
# Gateway token (generate with: openssl rand -hex 32)
OPENCLAW_GATEWAY_TOKEN=your-secure-token-here

# LLM API Keys
OPENAI_API_KEY=sk-...
ANTHROPIC_API_KEY=sk-ant-...
GROQ_API_KEY=gsk_...

# Optional: Custom port
OPENCLAW_GATEWAY_PORT=18789

# Optional: Bind to all interfaces (for remote access)
PORT_BIND=  # Empty = all interfaces, 127.0.0.1: = localhost only
```

#### 3. Build Image
```bash
docker compose build
```

#### 4. Start Container
```bash
docker compose up -d
```

#### 5. Check Status
```bash
# Check if running
docker ps | grep pocketagent

# Check logs
docker logs -f pocketagent

# Check health
docker inspect --format='{{.State.Health.Status}}' pocketagent
```

---

## Troubleshooting

### Container Keeps Restarting

**Check logs:**
```bash
docker logs pocketagent
```

**Common issues:**

#### 1. Invalid Config (typingMode error)
**Symptom:**
```
Invalid config at /home/node/.openclaw/openclaw.json:
- agents.defaults.typingMode: Invalid input
```

**Fix:**
```bash
# Stop container
docker stop pocketagent

# Remove corrupted config (will regenerate)
docker run --rm -v pocketagent-home:/home/node \
  alpine sh -c "rm /home/node/.openclaw/openclaw.json"

# Restart
docker start pocketagent
```

**Or manually fix:**
```bash
# Valid typingMode values: "instant", "typing", "realistic"
docker run --rm -it -v pocketagent-home:/home/node \
  alpine sh -c "sed -i 's/\"typingMode\".*$/\"typingMode\": \"instant\",/g' \
  /home/node/.openclaw/openclaw.json"
```

#### 2. Port Already in Use
**Symptom:**
```
Error: bind: address already in use
```

**Fix:**
```bash
# Check what's using the port
sudo netstat -tlnp | grep 18789

# Either stop that service or change PocketAgent port in .env
OPENCLAW_GATEWAY_PORT=18790
```

#### 3. Permission Issues
**Symptom:**
```
EACCES: permission denied
```

**Fix:**
```bash
# Fix volume permissions
docker run --rm -v pocketagent-home:/home/node \
  alpine chown -R 1000:1000 /home/node
```

---

## Backup & Restore

### Create Backup
```bash
# Manual backup
docker exec pocketagent backup-pocketagent

# Or backup volumes directly
docker run --rm \
  -v pocketagent-home:/home/node \
  -v $(pwd)/backups:/backups \
  alpine tar -czf /backups/pocketagent-$(date +%Y%m%d-%H%M%S).tar.gz \
    /home/node/.openclaw \
    /home/node/files
```

### Restore from Backup
```bash
# Stop container
docker stop pocketagent

# Restore
docker run --rm \
  -v pocketagent-home:/home/node \
  -v $(pwd)/backups:/backups \
  alpine tar -xzf /backups/pocketagent-YYYYMMDD-HHMMSS.tar.gz -C /

# Start container
docker start pocketagent
```

---

## Updates

### Update PocketAgent Image

#### Option 1: Rebuild (Recommended)
```bash
# Pull latest code
cd pocketagent-image/Cloud
git pull

# Rebuild image
docker compose build

# Restart with new image
docker compose down
docker compose up -d
```

#### Option 2: Update OpenClaw Only (Faster)
```bash
# Enter container
docker exec -it pocketagent bash

# Update OpenClaw
cd /pocketagent/lib/openclaw
git pull
pnpm install
pnpm build

# Exit and restart
exit
docker restart pocketagent
```

### Rollback to Previous Version
```bash
# Stop current container
docker stop pocketagent
docker rm pocketagent

# Restore from backup
# (see Backup & Restore section)

# Start with previous image
docker run -d --name pocketagent \
  --env-file .env \
  -v pocketagent-home:/home/node \
  -v pocketagent-data:/data \
  -v pocketagent-logs:/logs \
  -p 18789:18789 \
  your-registry/pocketagent:previous-tag
```

---

## Monitoring

### Health Checks
```bash
# Check container health
docker inspect --format='{{.State.Health.Status}}' pocketagent

# Should return: healthy
```

### Logs
```bash
# Follow logs
docker logs -f pocketagent

# Last 100 lines
docker logs --tail 100 pocketagent

# Search for errors
docker logs pocketagent | grep -i error
```

### Resource Usage
```bash
# CPU and memory usage
docker stats pocketagent

# Disk usage
docker system df
```

### Restart Count
```bash
# Check how many times container restarted
docker inspect --format='{{.RestartCount}}' pocketagent

# If > 0, check logs for issues
```

---

## Security

### Firewall Rules
```bash
# Allow only specific IPs (recommended)
sudo ufw allow from YOUR_IP to any port 18789

# Or allow all (less secure)
sudo ufw allow 18789
```

### HTTPS/SSL
Use a reverse proxy (nginx, Caddy, Traefik) for HTTPS:

**Example with Caddy:**
```
your-domain.com {
    reverse_proxy localhost:18789
}
```

### Gateway Token
Always use a strong token:
```bash
# Generate secure token
openssl rand -hex 32

# Add to .env
OPENCLAW_GATEWAY_TOKEN=your-generated-token
```

---

## Performance Tuning

### Resource Limits
Edit `docker-compose.yml`:
```yaml
deploy:
  resources:
    limits:
      cpus: "2.0"      # Max 2 CPU cores
      memory: "4G"     # Max 4GB RAM
    reservations:
      cpus: "0.5"      # Guaranteed 0.5 CPU
      memory: "1G"     # Guaranteed 1GB RAM
```

### Log Rotation
Already configured in `docker-compose.yml`:
```yaml
logging:
  driver: "json-file"
  options:
    max-size: "10m"   # Max 10MB per log file
    max-file: "3"     # Keep 3 files (30MB total)
```

---

## Advanced

### Custom Workspace
```bash
# Mount custom workspace
docker run -d --name pocketagent \
  --env-file .env \
  -v pocketagent-home:/home/node \
  -v $(pwd)/my-workspace:/home/node/.openclaw/workspace \
  -p 18789:18789 \
  pocketagent:latest
```

### Multiple Instances
```bash
# Instance 1
CONTAINER_NAME=pocketagent-1 \
OPENCLAW_GATEWAY_PORT=18789 \
VOLUME_PREFIX=pa1 \
docker compose up -d

# Instance 2
CONTAINER_NAME=pocketagent-2 \
OPENCLAW_GATEWAY_PORT=18790 \
VOLUME_PREFIX=pa2 \
docker compose up -d
```

### Development Mode
```bash
# Mount source code for live editing
docker run -d --name pocketagent-dev \
  --env-file .env \
  -v pocketagent-home:/home/node \
  -v $(pwd)/../../Pillars/PocketModel:/pocketmodel \
  -p 18789:18789 \
  pocketagent:latest
```

---

## Checklist

### Pre-Deployment
- [ ] Server meets minimum requirements (2GB RAM, 2 CPU)
- [ ] Docker & Docker Compose installed
- [ ] Firewall configured
- [ ] .env file configured with secure tokens
- [ ] LLM API keys added

### Post-Deployment
- [ ] Container is running (`docker ps`)
- [ ] Health check passes (`docker inspect`)
- [ ] Can access dashboard (http://localhost:18789)
- [ ] Agent responds to messages
- [ ] Logs show no errors
- [ ] Backup created

### Maintenance
- [ ] Regular backups (daily/weekly)
- [ ] Monitor disk usage
- [ ] Check logs for errors
- [ ] Update image monthly
- [ ] Review resource usage

---

## Support

### Common Commands
```bash
# Start
docker compose up -d

# Stop
docker compose down

# Restart
docker restart pocketagent

# Logs
docker logs -f pocketagent

# Shell access
docker exec -it pocketagent bash

# Backup
docker exec pocketagent backup-pocketagent

# Health check
docker inspect --format='{{.State.Health.Status}}' pocketagent
```

### Getting Help
- Check logs: `docker logs pocketagent`
- Review this guide
- Check GitHub issues
- Join community Discord

---

## What's Included

✅ OpenClaw agent framework
✅ Node.js 22 + Python 3
✅ Chrome browser (web automation)
✅ FFmpeg + ImageMagick (media processing)
✅ Pandoc (document conversion)
✅ Build tools (compile native packages)
✅ SSH client
✅ Automatic config validation
✅ Health checks
✅ Backup scripts
✅ Workspace seeding
✅ PocketAgent branding

---

Ready to deploy! 🚀
