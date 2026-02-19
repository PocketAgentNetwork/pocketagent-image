# PocketAgent Image

**The Complete Agent Runtime Environment**

This repo contains the PocketAgent Image - the complete, packaged agent environment that runs on any node (local, cloud, or hardware).

## What's Inside

The PA Image includes:

1. **OpenClaw** - Open source agent framework (event loop, tools, memory)
2. **PocketModel** - Smart model routing and failover
3. **PAN Supervisor** - Process manager and health monitoring
4. **Connectors** - Email, calendar, wallets, APIs
5. **Memory & Storage** - Vector store, database, context persistence
6. **Communication Layer** - Secure client connections
7. **Agent Workspace** - Pre-configured environment with skills

## Deployment Options

### Cloud Deployment

Docker-based deployment for cloud hosting:

```bash
cd Cloud
docker compose build
docker compose up -d
```

Access at `http://localhost:18789`

See `Cloud/README.md` for detailed setup instructions.

### Local Deployment

Native installation for Mac/Linux/Windows:

```bash
cd Local
# Coming soon - installer scripts
```

See `Local/task.txt` for current status.

### Hardware Deployment

Pre-configured image for PocketAgent hardware devices (future).

## Workspace

The `workspace/` directory contains the agent's initial environment:

- **Identity & Configuration** - IDENTITY.md, SOUL.md, USER.md, JOB.md
- **System Docs** - BOOT.md, HEARTBEAT.md, MEMORY.md, AGENTS.md, TOOLS.md
- **Pre-installed Skills** - skill-maker, agent-maker
- **Memory Storage** - Daily logs and context persistence

## Architecture

Same components, different packaging:

- **Local**: Native installation, runs as system service
- **Cloud**: Docker container, managed deployment
- **Hardware**: Pre-loaded on device, plug & play

All three run the identical PA Image internally.

## Status

✅ Cloud Docker setup ready  
✅ Workspace environment configured  
✅ OpenClaw integration complete  
⏳ Local installer (in progress)  
⏳ PocketModel integration (planned)  
⏳ PAN Supervisor (planned)  

## Part of PocketAgent Ecosystem

The PA Image is one of the 7 pillars of the PocketAgent ecosystem. See the main [Ecosystem documentation](../Ecosystem/) for the complete architecture.
