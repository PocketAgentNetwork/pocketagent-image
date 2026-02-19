# 🤖 PocketAgent (Cloud Image)

Production-ready cloud deployment image for PocketAgent. This image is used by PAN infrastructure to provision user containers automatically.

---

## 🎯 Purpose

This cloud image serves two use cases:

1. **PAN-Managed Cloud Nodes** (Production)
   - PAN backend provisions containers automatically
   - User API keys injected during onboarding
   - Zero manual setup for end users
   - Part of $69.99/month managed service

2. **Self-Hosted Deployment** (Advanced/Testing)
   - Deploy to your own VPS/cloud
   - Manual configuration required
   - For testing or advanced users who want full control

---

## 🔄 How It Works

```
1. Container starts (only needs gateway token)
   ↓
2. User opens PocketAgent Client
   - Web: http://localhost:18789
   - Mobile: PocketAgent app
   ↓
3. Client connects using gateway token
   ↓
4. OpenClaw onboarding UI appears
   ↓
5. User completes onboarding in client:
   - Agent name and identity
   - API keys (OpenAI, Anthropic, etc.)
   - Optional integrations
   ↓
6. Client sends config to container
   ↓
7. Container saves config to persistent volume
   ↓
8. Agent is live!
```

**Key Point:** API keys are configured through the client UI during onboarding, not in .env files. OpenClaw handles this automatically.

---

## ⚡ Quick Start

### For Testing (Your Laptop)

```bash
# Run setup script (generates token)
./setup.sh

# Start container
docker compose up --build -d

# Open browser
http://localhost:18789
```

That's it! Container runs on localhost, no resource limits.

### For Production (PAN Cloud)

Same command, but set environment variables:

```bash
# Single user container
CONTAINER_NAME=pocketagent-user123 \
VOLUME_PREFIX=user123 \
PORT_BIND="" \
  docker compose up -d

# Another user on same server
CONTAINER_NAME=pocketagent-user456 \
VOLUME_PREFIX=user456 \
PORT_BIND="" \
  docker compose up -d
```

**For production, also uncomment the resource limits in docker-compose.yml:**
```yaml
deploy:
  resources:
    limits:
      cpus: "2.0"
      memory: "4G"
```

This prevents one user's agent from eating all server resources.

---

---

## 🎯 Quick CLI Access

For easier management via SSH, set up the `pocketagent` command:

```bash
echo 'alias pocketagent="docker exec -it pocketagent node /pocketagent/lib/openclaw/dist/index.js"' >> ~/.bashrc
source ~/.bashrc

# Now just use: pocketagent models status, pocketagent doctor --fix, etc.
```

See [CLI.md](CLI.md) for details and [COMMANDS.md](COMMANDS.md) for full Docker reference.

---

## 📁 Project Structure

```
.
├── workspace/                  # ← This is your agent's brain
│   ├── SOUL.md                 # Personality & behaviour
│   ├── IDENTITY.md             # Name, emoji, type
│   ├── AGENTS.md               # Agent instructions & capabilities
│   ├── USER.md                 # Who the agent is helping
│   ├── JOB.md                  # What this agent does (role definition)
│   ├── TOOLS.md                # Environment-specific tool notes
│   ├── HEARTBEAT.md            # Periodic background tasks
│   ├── MEMORY.md               # Long-term curated memory
│   ├── BOOT.md                 # Startup tasks
│   ├── BOOTSTRAP.md            # First-run setup (deleted after use)
│   ├── memory/                 # Daily logs (YYYY-MM-DD.md)
│   ├── agents/                 # Sub-agents go here
│   └── skills/                 # Skills go here
│       ├── skill-maker/        # Pre-installed: create new skills
│       └── agent-maker/        # Pre-installed: spawn sub-agents
├── Dockerfile                  # Main build (clones OpenClaw + workspace)
├── docker-compose.yml          # One-command deployment
├── entrypoint.sh               # Container startup script
├── .env.example                # Template for secrets
└── README.md                   # You are here
```

---

## 🧠 Customization Guide

### Identity (`workspace/IDENTITY.md`)
- Name: Your agent's name
- Type: AI Agent
- Emoji: Pick one that represents your agent

### Job Definition (`workspace/JOB.md`)
This is what makes your PocketAgent unique. Define what role it plays:
- Personal assistant
- Developer companion
- Research assistant
- Content creator
- Or anything else you need

### Personality (`workspace/SOUL.md`)
Defines how your agent thinks and behaves. All PocketAgents share the same core values but express them through their unique job role.

### User Info (`workspace/USER.md`)
Tell your agent about yourself so it can serve you better.

---

## 🔑 Environment Variables

### Required

None! The `--allow-unconfigured` flag lets the container start and handle configuration during onboarding.

### Optional (in .env file)

| Variable | Default | Description |
|----------|---------|-------------|
| `OPENCLAW_GATEWAY_TOKEN` | Auto-generated | Pre-set token (optional - OpenClaw generates if empty) |
| `OPENCLAW_GATEWAY_PORT` | `18789` | Gateway port |
| `OPENCLAW_GATEWAY_BIND` | `lan` | Bind address (`lan`, `127.0.0.1`, or `0.0.0.0`) |

### Configuration via Onboarding

These are configured through the web UI during onboarding (not in .env):
- Agent name and identity
- API keys (OpenAI, Anthropic, Google, OpenRouter)
- Integrations (Telegram, Discord, etc.)
- Gateway token (if not pre-set)

OpenClaw stores all configuration securely in the container's persistent volume.

---

## 🛡️ Security

- **Never commit `.env`** — it's in `.gitignore`
- Use `openssl rand -hex 32` to generate your gateway token
- The default `docker-compose.yml` binds to `127.0.0.1` (localhost only)
- For production, use a reverse proxy (nginx, Caddy) with HTTPS

---

## 📦 Persistent Storage

The image uses Docker volumes for persistence:
- `/home/node/` - Agent's home directory (tools, configs, installed packages)
- `/home/node/.openclaw/` - OpenClaw data and sessions
- `/home/node/.openclaw/workspace/` - Your agent's workspace (seeded on first run)
- `/home/node/files/` - Files created by the agent

---

## 🔄 Updates

To update your PocketAgent image:
```bash
docker compose down
docker compose build --no-cache
docker compose up -d
```

Your workspace and data persist across updates.

---

## 📄 License

MIT — do whatever you want with it.

---

*Powered by [OpenClaw](https://github.com/openclaw/openclaw).* 🤖
