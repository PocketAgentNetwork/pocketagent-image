# 📟 PocketAgent — Complete Setup Guide

Everything you need to get PocketAgent running, whether on your own machine or in the cloud.

---

## Which Setup Is Right for You?

| | Local | Cloud (AWS) |
|---|---|---|
| Runs on | Your machine | AWS EC2 |
| Access | localhost only | Internet accessible |
| Cost | Free | ~$30/mo (t3.medium) |
| Best for | Personal use | Always-on, remote access |

---

# 🖥️ Local Setup

Install PocketAgent as a background service on your Mac or Linux machine.

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/PocketAgentNetwork/pocketagent-image/main/Local/install.sh | bash
```

The installer will set up PocketAgent as a background service and give you a gateway token.

## Access

Open your browser at:
```
http://localhost:18789
```

## Commands

```bash
pocketagent start       # Start agent
pocketagent stop        # Stop agent
pocketagent restart     # Restart agent
pocketagent status      # Check status
pocketagent logs        # View logs
pocketagent update      # Update to latest version
```

See [Local/README.md](./Local/README.md) for full local documentation.

---

# ☁️ Cloud Setup (AWS EC2)

## Step 1: Launch EC2 Instance

1. Go to [AWS EC2 Console](https://console.aws.amazon.com/ec2) → **Launch Instance**
2. Fill in:
   - Name: `pocketagent`
   - AMI: `Ubuntu Server 22.04 LTS (HVM)` — **64-bit (x86)** only, not ARM
   - Instance type: `t3.medium` (~$30/mo)
   - Key pair: Create new → **ED25519** → **.pem** → download and save it
   - Storage: **20GB gp3**
3. Network settings → Allow SSH → Source: **Anywhere (0.0.0.0/0)**
4. Click **Launch Instance**

## Step 2: Open Port 18789

1. EC2 → Instances → click your instance → **Security** tab → click security group
2. **Edit inbound rules** → **Add rule**:
   - Type: Custom TCP, Port: `18789`, Source: `0.0.0.0/0`
3. **Save rules**

## Step 3: SSH In

```bash
chmod 400 ~/Desktop/your-key.pem
ssh -i ~/Desktop/your-key.pem ubuntu@your-ec2-public-ip
```

> Your EC2 public IP is shown in the console under **Public IPv4 address**. If you stop/start the instance it may change — always grab the latest from the console.

## Step 4: Install Docker

```bash
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker ubuntu
exit
```

SSH back in, then verify:
```bash
docker --version
docker compose version
```

## Step 5: Install PocketAgent

```bash
curl -fsSL https://raw.githubusercontent.com/PocketAgentNetwork/pocketagent-image/main/Cloud/install.sh | bash
cd pocketagent
./setup.sh
```

Save the gateway token that gets printed.

## Step 6: Start PocketAgent

```bash
docker compose up -d
docker compose logs -f
```

Wait for `✅ Ready. Launching PocketAgent...` then press `Ctrl+C`.

## Step 7: Access

```
http://your-ec2-public-ip:18789
```

---

# 🤖 Configure AI Model (Ollama Cloud)

Works for both Local and Cloud setups.

Get your API key at [ollama.com/settings/keys](https://ollama.com/settings/keys), then run:

```bash
pocketagent config set models.providers.ollama.apiKey "YOUR_OLLAMA_API_KEY"
pocketagent config set models.providers.ollama.baseUrl "https://ollama.com/v1"
pocketagent config set agents.defaults.model.primary "ollama/minimax-m2.5"
```

Restart to apply:
```bash
# Cloud
docker compose restart

# Local
pocketagent restart
```

**Recommended models:**
| Model | Best For |
|-------|----------|
| `ollama/minimax-m2.5` | General use, coding |
| `ollama/kimi-k2.5` | Multimodal (vision + text) |
| `ollama/glm-5` | Complex reasoning |
| `ollama/qwen3-coder-next` | Coding focused |

Full model list: [OLLAMA_INTEGRATION.md](./OLLAMA_INTEGRATION.md)

---

# 💬 Connect Telegram

Works for both Local and Cloud setups.

```bash
pocketagent channels add
```

Select Telegram and enter your bot token (get one from [@BotFather](https://t.me/BotFather)).

Set DM policy to pairing:
```bash
pocketagent config set channels.telegram.dmPolicy "pairing"
docker compose restart   # or: pocketagent restart
```

Message your bot `/start` on Telegram, then approve the pairing request:
```bash
pocketagent pairing approve telegram YOUR_PAIRING_CODE
```

To lock the bot to only yourself, get your Telegram user ID from [@getmyid_bot](https://t.me/getmyid_bot) then:
```bash
pocketagent config set channels.telegram.dmPolicy "allowlist"
pocketagent config set channels.telegram.allowFrom '["YOUR_TELEGRAM_USER_ID"]'
```

---

# 🔧 Useful Commands

```bash
# Logs
docker compose logs -f          # Cloud
pocketagent logs                # Local

# Restart
docker compose restart          # Cloud
pocketagent restart             # Local

# Update
docker compose pull && docker compose up -d   # Cloud
pocketagent update                            # Local

# Diagnostics
pocketagent doctor --fix

# Models
pocketagent models status

# Channels
pocketagent channels list
```

---

# 💾 Backup (Cloud)

```bash
cd ~/pocketagent
docker run --rm \
  -v pocketagent-home:/data \
  -v $(pwd):/backup \
  ubuntu tar czf /backup/pocketagent-backup-$(date +%Y%m%d).tar.gz /data
```

Download to your machine:
```bash
scp -i ~/Desktop/your-key.pem ubuntu@your-ec2-public-ip:~/pocketagent/pocketagent-backup-*.tar.gz ~/Downloads/
```

---

# 🌐 Add a Domain + HTTPS (Cloud)

Point your domain's A record to your EC2 public IP, then:

```bash
sudo apt install -y debian-keyring debian-archive-keyring apt-transport-https
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list
sudo apt update && sudo apt install caddy
sudo nano /etc/caddy/Caddyfile
```

Add:
```
agent.yourdomain.com {
    reverse_proxy localhost:18789
}
```

```bash
sudo ufw allow 80/tcp && sudo ufw allow 443/tcp
sudo systemctl restart caddy
```

---

For more details see:
- [Cloud/README.md](./Cloud/README.md) — Cloud deployment docs
- [Local/README.md](./Local/README.md) — Local deployment docs
- [OLLAMA_INTEGRATION.md](./OLLAMA_INTEGRATION.md) — Full Ollama Cloud guide
