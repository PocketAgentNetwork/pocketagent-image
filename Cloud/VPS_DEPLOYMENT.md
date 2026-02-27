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
- Creates `.env` file with default container name (`pocketagent`)
- Sets persistent hostname (stays same across restarts/rebuilds)
- Optionally adds `pocketagent` CLI alias to your shell

**The generated .env includes:**
```bash
CONTAINER_NAME=pocketagent          # Container name & hostname
OPENCLAW_GATEWAY_TOKEN=abc123...    # Your secure token
OPENCLAW_GATEWAY_PORT=18789         # Gateway port
```

**Why hostname matters:**
- SSH keys are tied to hostname
- License keys may fingerprint by hostname
- Services that cache by hostname work correctly
- Hostname stays consistent even after rebuilds

**Output:**
```
🔑 Your Gateway Token:
   abc123def456...
   
   Keep this secret! You'll need it to connect your client.

✅ Added alias to ~/.bashrc

📋 Next Steps:
1. Start PocketAgent:
   docker compose up --build -d

2. Reload your shell to use 'pocketagent' command:
   source ~/.bashrc  # or source ~/.zshrc
```

**Save this token somewhere safe!**

**Note:** The alias won't work until you reload your shell (Step 14) or log out and back in.

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

## Step 14: Use CLI Commands

The setup script automatically added a `pocketagent` alias to your shell.

**Reload your shell to activate it:**

```bash
# For bash users
source ~/.bashrc

# For zsh users
source ~/.zshrc

# Or just log out and back in
exit
ssh pocketagent@your-vps-ip
```

**Now you can use the CLI:**

```bash
# Check model status
pocketagent models status

# Run diagnostics
pocketagent doctor --fix

# List available commands
pocketagent --help
```

**The alias is:**
```bash
alias pocketagent="docker exec -it pocketagent node /pocketagent/lib/openclaw/dist/index.js"
```

This lets you run OpenClaw commands directly without typing the full docker exec command!

---

## Troubleshooting

### Can't pull image (private registry)

If you're using a private fork and can't pull the image:

```bash
# Option 1: Make your container package public
# Go to: https://github.com/yourusername?tab=packages
# Click package → Settings → Change visibility → Public

# Option 2: Login to registry
echo YOUR_GITHUB_TOKEN | docker login ghcr.io -u yourusername --password-stdin
docker compose pull

# Option 3: Build locally instead
# Edit docker-compose.yml and uncomment: build: .
docker compose up --build -d
```

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

### Create Backup on VPS

```bash
# Navigate to Cloud directory
cd ~/pocketagent-image/Cloud

# Create backup with today's date
docker run --rm \
  -v pocketagent-home:/data \
  -v $(pwd):/backup \
  ubuntu tar czf /backup/pocketagent-backup-$(date +%Y%m%d).tar.gz /data

# Verify backup was created
ls -lh pocketagent-backup-*.tar.gz
```

**This backs up:**
- Agent workspace (identity, soul, job, memory)
- Installed tools and configurations
- All persistent data

### Download Backup to Local Machine

**From your local machine (not VPS):**

```bash
# Download the backup file
scp pocketagent@your-vps-ip:~/pocketagent-image/Cloud/pocketagent-backup-*.tar.gz ~/Downloads/

# Or specify exact date
scp pocketagent@your-vps-ip:~/pocketagent-image/Cloud/pocketagent-backup-20260227.tar.gz ~/Downloads/
```

**Now you have a local copy!** Store it somewhere safe (external drive, cloud storage, etc.)

### Restore from Backup

**Upload backup to VPS (from your local machine):**

```bash
# Upload backup file
scp ~/Downloads/pocketagent-backup-*.tar.gz pocketagent@your-vps-ip:~/
```

**On VPS, restore the backup:**

```bash
# Stop container first
cd ~/pocketagent-image/Cloud
docker compose down

# Restore data
docker run --rm \
  -v pocketagent-home:/data \
  -v ~/:/backup \
  ubuntu tar xzf /backup/pocketagent-backup-*.tar.gz -C /

# Start container
docker compose up -d

# Check logs
docker compose logs -f
```

**Your agent is back with all its data!**

### Automated Backups (Optional)

**Set up daily backups with cron:**

```bash
# Edit crontab
crontab -e

# Add this line (runs daily at 2 AM)
0 2 * * * cd ~/pocketagent-image/Cloud && docker run --rm -v pocketagent-home:/data -v $(pwd):/backup ubuntu tar czf /backup/pocketagent-backup-$(date +\%Y\%m\%d).tar.gz /data

# Keep only last 7 days of backups
0 3 * * * find ~/pocketagent-image/Cloud -name "pocketagent-backup-*.tar.gz" -mtime +7 -delete
```

**Now backups happen automatically!**

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
