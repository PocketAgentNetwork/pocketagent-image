# PocketAgent VPS Deployment Walkthrough

Complete step-by-step guide to deploy PocketAgent on a VPS (DigitalOcean, AWS, Linode, etc.)

---

## Prerequisites

- A VPS with Ubuntu 22.04+ (2GB RAM minimum, 4GB recommended)
- Root or sudo access
- Domain name (optional, but recommended for HTTPS)

---

## Step 1: Get a VPS

**Recommended providers:**
- DigitalOcean: $6-12/month droplet
- Linode: $5-10/month instance
- AWS Lightsail: $5-10/month
- Vultr: $6-12/month

**Minimum specs:**
- 2 vCPUs
- 2GB RAM
- 50GB disk
- Ubuntu 22.04 LTS

---

## Step 2: Initial Server Setup

SSH into your VPS:

```bash
ssh root@your-vps-ip
```

### Update system

```bash
apt update && apt upgrade -y
```

### Create a non-root user (optional but recommended)

```bash
adduser pocketagent
usermod -aG sudo pocketagent
su - pocketagent
```

---

## Step 3: Install Docker

```bash
# Install Docker
curl -fsSL https://get.docker.com | sh

# Add your user to docker group (so you don't need sudo)
sudo usermod -aG docker $USER

# Log out and back in for group changes to take effect
exit
# SSH back in
ssh pocketagent@your-vps-ip

# Verify Docker is working
docker --version
docker compose version
```

---

## Step 4: Configure Firewall

```bash
# Allow SSH (important!)
sudo ufw allow 22/tcp

# Allow PocketAgent port
sudo ufw allow 18789/tcp

# Enable firewall
sudo ufw enable

# Check status
sudo ufw status
```

---

## Step 5: Clone PocketAgent Repository

```bash
# Clone the repo
git clone https://github.com/PocketAgentNetwork/pocketagent-image.git

# Navigate to Cloud directory
cd pocketagent-image/Cloud
```

---

## Step 6: Run Setup Script

```bash
# Make setup script executable
chmod +x setup.sh

# Run setup (generates gateway token)
./setup.sh
```

**What this does:**
- Generates a secure gateway token
- Creates `.env` file
- Sets up CLI alias

**Output:**
```
🔑 Your Gateway Token:
   abc123def456...
   
   Keep this secret! You'll need it to connect your client.
```

**Save this token somewhere safe!**

---

## Step 7: Configure Environment

Edit the `.env` file:

```bash
nano .env
```

**Add your Ollama API key:**

```bash
# Gateway Configuration (already set by setup.sh)
OPENCLAW_GATEWAY_TOKEN=abc123def456...
OPENCLAW_GATEWAY_PORT=18789
OPENCLAW_GATEWAY_BIND=lan

# PocketAgent Version
POCKETAGENT_VERSION=latest

# Ollama Cloud API Key
OLLAMA_API_KEY=your_ollama_key_here

# Optional: Other providers
# OPENAI_API_KEY=
# ANTHROPIC_API_KEY=
```

**Save and exit:** `Ctrl+X`, then `Y`, then `Enter`

---

## Step 8: Start PocketAgent

```bash
# Pull the latest image and start
docker compose up -d

# Check if it's running
docker compose ps

# Check logs
docker compose logs -f
```

**Expected output:**
```
🤖 PocketAgent starting up...
🌱 Initializing PocketAgent workspace from image...
✅ PocketAgent workspace seeded.
✅ Ready. Launching PocketAgent...
```

**Press `Ctrl+C` to exit logs**

---

## Step 9: Access PocketAgent

Open your browser and go to:

```
http://your-vps-ip:18789
```

**You should see the OpenClaw onboarding UI!**

---

## Step 10: Complete Onboarding

### In the web UI:

1. **Welcome Screen**
   - Click "Get Started"

2. **Agent Identity**
   - Name: `MyAgent` (or whatever you want)
   - Emoji: 🤖 (pick one)
   - Click "Next"

3. **Configure Models**
   - Select "Ollama" as provider
   - It should auto-detect your API key from .env
   - Choose primary model: `kimi-k2.5:cloud`
   - Choose fallback: `minimax-m2.5:cloud`
   - Click "Next"

4. **Optional Integrations**
   - Skip for now (or configure if you want)
   - Click "Finish"

5. **Done!**
   - Your PocketAgent is now live!

---

## Step 11: Test Your Agent

In the web UI chat:

```
You: Hello! Can you introduce yourself?

Agent: Hi! I'm [YourAgentName], your personal AI assistant...
```

**Try some commands:**
```
/model status          # Check which model is active
/model kimi            # Switch to Kimi K2.5
/model minimax         # Switch to MiniMax M2.5
```

---

## Step 12: Set Up Domain & HTTPS (Optional but Recommended)

### Install Caddy (automatic HTTPS)

```bash
# Install Caddy
sudo apt install -y debian-keyring debian-archive-keyring apt-transport-https
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list
sudo apt update
sudo apt install caddy
```

### Configure Caddy

```bash
sudo nano /etc/caddy/Caddyfile
```

**Add this:**

```
agent.yourdomain.com {
    reverse_proxy localhost:18789
}
```

**Save and exit**

### Point your domain to VPS

In your domain registrar (Namecheap, GoDaddy, etc.):
- Add an A record: `agent.yourdomain.com` → `your-vps-ip`

### Restart Caddy

```bash
sudo systemctl restart caddy
sudo systemctl status caddy
```

### Update firewall

```bash
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
```

### Access via HTTPS

Now you can access at:
```
https://agent.yourdomain.com
```

**Caddy automatically gets SSL certificate from Let's Encrypt!**

---

## Step 13: Manage Your PocketAgent

### View logs

```bash
cd ~/pocketagent-image/Cloud
docker compose logs -f
```

### Restart

```bash
docker compose restart
```

### Stop

```bash
docker compose down
```

### Start

```bash
docker compose up -d
```

### Update to new version

```bash
# Pull latest image
docker compose pull

# Restart with new image
docker compose down
docker compose up -d

# Your data persists!
```

### Check resource usage

```bash
docker stats pocketagent
```

---

## Step 14: CLI Access (Optional)

If you set up the alias during setup:

```bash
# Reload shell
source ~/.bashrc

# Use pocketagent CLI
pocketagent models status
pocketagent doctor --fix
```

---

## Troubleshooting

### Can't access on port 18789

```bash
# Check if container is running
docker compose ps

# Check firewall
sudo ufw status

# Check logs
docker compose logs
```

### Container keeps restarting

```bash
# Check logs for errors
docker compose logs

# Check if port is already in use
sudo netstat -tulpn | grep 18789

# Try rebuilding
docker compose down
docker compose up -d
```

### Out of memory

```bash
# Check memory usage
free -h

# Upgrade your VPS to 4GB RAM
```

### Need to reset everything

```bash
# Stop and remove everything (including volumes)
docker compose down -v

# Start fresh
docker compose up -d

# You'll need to onboard again
```

---

## Backup & Restore

### Backup

```bash
# Backup persistent data
docker run --rm \
  -v pocketagent-home:/data \
  -v $(pwd):/backup \
  ubuntu tar czf /backup/pocketagent-backup-$(date +%Y%m%d).tar.gz /data

# Download to your local machine
scp pocketagent@your-vps-ip:~/pocketagent-image/Cloud/pocketagent-backup-*.tar.gz .
```

### Restore

```bash
# Upload backup to VPS
scp pocketagent-backup-*.tar.gz pocketagent@your-vps-ip:~/

# Restore
docker run --rm \
  -v pocketagent-home:/data \
  -v ~/:/backup \
  ubuntu tar xzf /backup/pocketagent-backup-*.tar.gz -C /
```

---

## Cost Estimate

**VPS:** $6-12/month
**Ollama Cloud API:** $1-5/month (typical usage)
**Domain (optional):** $10-15/year
**Total:** ~$7-17/month

---

## Security Best Practices

1. ✅ Use a non-root user
2. ✅ Enable firewall (ufw)
3. ✅ Use HTTPS with domain
4. ✅ Keep gateway token secret
5. ✅ Regular backups
6. ✅ Update regularly: `docker compose pull`
7. ✅ Monitor logs: `docker compose logs`

---

## Next Steps

- Connect mobile app (if available)
- Add more integrations (Telegram, Discord, etc.)
- Customize your agent's personality
- Add skills and tools
- Set up monitoring (optional)

---

## Support

- GitHub Issues: https://github.com/PocketAgentNetwork/pocketagent-image/issues
- Documentation: See other .md files in Cloud/
- Community: [Add Discord/Forum link]

---

**Congratulations! Your PocketAgent is now running 24/7 on your VPS! 🎉**
