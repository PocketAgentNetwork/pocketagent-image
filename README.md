# 📟 PocketAgent Image

**The Complete Agent Runtime Environment**

This repo contains the PocketAgent Image - the complete, packaged agent environment that runs on any node (local, cloud, or hardware).

---

## 🚀 Quick Start

### Cloud Deployment (VPS/Server)

Deploy PocketAgent on a VPS with Docker:

```bash
# One-line install
curl -fsSL https://raw.githubusercontent.com/PocketAgentNetwork/pocketagent-image/main/Cloud/install.sh | bash
cd pocketagent
./setup.sh
docker compose up -d
```

**Access:** http://your-vps-ip:18789

📚 **Full Guide:** [Cloud/VPS_DEPLOYMENT.md](Cloud/VPS_DEPLOYMENT.md)

---

### Local Deployment (Mac/Linux/Windows)

Install PocketAgent natively on your machine:

```bash
# One-line install
curl -fsSL https://raw.githubusercontent.com/PocketAgentNetwork/pocketagent-image/main/Local/install.sh | bash

# Start agent
pocketagent start
```

**Access:** http://localhost:18789

📚 **Full Guide:** [Local/README.md](Local/README.md)

---

## 📦 What's Inside

The PocketAgent Image includes:

1. **OpenClaw** - Open source agent framework (event loop, tools, memory)
2. **Agent Workspace** - Pre-configured environment (IDENTITY, SOUL, JOB, skills)
3. **Ollama Cloud Integration** - AI models without GPU infrastructure
4. **Smart Workspace Sync** - Version tracking and updates
5. **Personalization** - Custom agent names and user preferences
6. **24/7 Operation** - Background service with auto-restart

---

## 🎯 Deployment Options

| Feature | Cloud | Local |
|---------|-------|-------|
| **Platform** | VPS/Cloud Server | Mac/Linux/Windows |
| **Technology** | Docker | Native Installation |
| **Access** | Internet (remote) | Localhost only |
| **Setup** | `docker compose up` | One-line installer |
| **Cost** | ~$7-17/month | Free (your hardware) |
| **Use Case** | Always-on, remote access | Personal use, privacy |

---

## 📂 Repository Structure

```
pocketagent-image/
├── Cloud/                      # Cloud deployment (Docker)
│   ├── Dockerfile             # Container image
│   ├── docker-compose.yml     # Deployment config
│   ├── entrypoint.sh          # Startup script
│   ├── setup.sh               # Setup wizard
│   ├── VPS_DEPLOYMENT.md      # Complete guide
│   └── COMMANDS.md            # Command reference
│
├── Local/                      # Local deployment (Native)
│   ├── install.sh             # Master installer
│   ├── bin/pocketagent        # CLI wrapper
│   ├── README.md              # Installation guide
│   ├── COMMANDS.md            # Command reference
│   └── PERSONALIZATION.md     # Customization guide
│
├── workspace/                  # Agent workspace files
│   ├── IDENTITY.md            # Agent identity (📟 PocketAgent)
│   ├── SOUL.md                # Agent personality
│   ├── JOB.md                 # Agent role/purpose
│   ├── USER.md                # User information
│   ├── skills/                # Pre-installed skills
│   └── agents/                # Sub-agents
│
├── OLLAMA_INTEGRATION.md       # Ollama Cloud setup
├── OLLAMA_LOCAL.md             # Self-hosted Ollama
└── README.md                   # This file
```

---

## 🔄 Updates

### Cloud Updates
```bash
# Pull latest image
docker compose pull

# Restart with new version
docker compose up -d
```

### Local Updates
```bash
# Update everything (OpenClaw + workspace)
curl -fsSL https://raw.githubusercontent.com/PocketAgentNetwork/pocketagent-image/main/Local/install.sh | bash -s update

# Or use the CLI
pocketagent update
```

**Your data persists!** All settings, memory, and customizations are preserved.

---

## 🌟 Features

### Personalization
During installation, you can customize:
- Agent name (e.g., "Jarvis", "Alfred")
- Your name
- Timezone
- Language preferences

### Smart Workspace Management
- Version tracking (`.workspace_version`)
- Automatic updates for system files
- Preserves user customizations
- Syncs new skills and agents

### Ollama Cloud Integration
- No GPU required
- Powerful models (Kimi K2.5, MiniMax M2.5)
- ~$1-5/month for typical usage
- See [OLLAMA_INTEGRATION.md](OLLAMA_INTEGRATION.md)

### 24/7 Operation
- Runs as background service
- Auto-restart on failure
- Persistent memory across restarts
- Health monitoring

---

## 📚 Documentation

### Getting Started
- [Cloud Deployment Guide](Cloud/VPS_DEPLOYMENT.md)
- [Local Installation Guide](Local/README.md)
- [Ollama Cloud Setup](OLLAMA_INTEGRATION.md)

### Reference
- [Cloud Commands](Cloud/COMMANDS.md)
- [Local Commands](Local/COMMANDS.md)
- [Personalization](Local/PERSONALIZATION.md)

### Development
- [Cloud Plan](Cloud/plan.txt)
- [Local Plan](Local/plan.txt)

---

## 🆚 Cloud vs Local

**Choose Cloud if:**
- You want remote access from anywhere
- You need 24/7 uptime
- You're okay with VPS costs (~$7-17/month)

**Choose Local if:**
- You want maximum privacy
- You have a machine that's always on
- You prefer no monthly costs

**Both options:**
- Use the same PocketAgent image
- Have identical features
- Support the same models and integrations

---

## 🔧 Architecture

```
┌─────────────────────────────────────────┐
│         PocketAgent Image               │
├─────────────────────────────────────────┤
│  OpenClaw Framework                     │
│  ├── Gateway (localhost:18789)          │
│  ├── Agent Runtime                      │
│  ├── Memory System                      │
│  └── Skills & Tools                     │
├─────────────────────────────────────────┤
│  Workspace                              │
│  ├── IDENTITY.md (📟 PocketAgent)       │
│  ├── SOUL.md (Personality)              │
│  ├── JOB.md (Purpose)                   │
│  ├── USER.md (Your info)                │
│  └── skills/ (Capabilities)             │
├─────────────────────────────────────────┤
│  Ollama Cloud Integration               │
│  ├── Kimi K2.5 (Primary)                │
│  └── MiniMax M2.5 (Fallback)            │
└─────────────────────────────────────────┘
```

---

## 🚧 Status

**v0.0.1 (Current)**
- ✅ Cloud Docker deployment
- ✅ Local native installation
- ✅ Workspace management
- ✅ Ollama Cloud integration
- ✅ Personalization
- ✅ Smart updates

**Future Versions**
- ⏳ PocketModel integration
- ⏳ PAN Supervisor
- ⏳ Native client apps (mobile/desktop)
- ⏳ Hardware deployment

---

## 🤝 Contributing

This is part of the PocketAgent ecosystem. See the main documentation for contribution guidelines.

---

## 📄 License

[Add license information]

---

**Ready to get started?**
- [Deploy to Cloud](Cloud/VPS_DEPLOYMENT.md)
- [Install Locally](Local/README.md)
