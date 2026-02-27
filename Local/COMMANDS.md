# 📟 PocketAgent Local Commands

Quick reference for managing PocketAgent on your local machine.

---

## 🎮 Basic Commands

### Start Agent
```bash
pocketagent start
```

Starts PocketAgent in the background. Agent will be accessible at http://localhost:18789

### Stop Agent
```bash
pocketagent stop
```

Stops the running PocketAgent service.

### Check Status
```bash
pocketagent status
```

Shows whether PocketAgent is currently running or stopped.

### View Logs
```bash
pocketagent logs

# Follow logs in real-time
pocketagent logs --follow

# Show last 100 lines
pocketagent logs --tail 100
```

---

## 🔄 Update Commands

### Update to Latest Version
```bash
pocketagent update
```

**What this does:**
1. Stops your agent
2. Backs up current OpenClaw version (with timestamp)
3. Downloads latest OpenClaw from GitHub
4. Rebuilds everything
5. Restarts your agent

**Your data is safe!** All settings, memory, workspace files, and API keys are preserved.

**Backup location:**
```
/Applications/PocketAgent/lib/openclaw.backup.YYYYMMDD
```

### Check Current Version
```bash
pocketagent version
```

Shows the current OpenClaw version installed.

---

## 📟 Agent Management (OpenClaw CLI)

These commands interact with the agent itself:

### Model Management
```bash
# Check model status
pocketagent models status

# List available models
pocketagent models list

# Switch to specific model
pocketagent models use kimi-k2.5:cloud
pocketagent models use minimax-m2.5:cloud

# Set primary and fallback models
pocketagent models set-primary kimi-k2.5:cloud
pocketagent models set-fallback minimax-m2.5:cloud
```

### Diagnostics
```bash
# Run health check
pocketagent doctor

# Run health check and auto-fix issues
pocketagent doctor --fix

# Check agent health
pocketagent health
```

### Configuration
```bash
# View all configuration
pocketagent config show

# Get specific config value
pocketagent config get <key>

# Set config value
pocketagent config set <key> <value>
```

### Workspace Management
```bash
# Show workspace info
pocketagent workspace info

# Backup workspace
pocketagent workspace backup

# Restore from backup
pocketagent workspace restore <backup-file>
```

### Skills & Integrations
```bash
# List installed skills
pocketagent skills list

# Enable a skill
pocketagent skills enable <skill-name>

# Disable a skill
pocketagent skills disable <skill-name>

# List integrations
pocketagent integrations list

# Add integration
pocketagent integrations add <integration-name>

# Remove integration
pocketagent integrations remove <integration-name>
```

### Help
```bash
# General help
pocketagent --help

# Command-specific help
pocketagent <command> --help
```

---

## 🗂️ File Locations

### Installation Directory
```bash
# macOS
/Applications/PocketAgent/

# Linux
~/.local/share/pocketagent/

# Windows
C:\Users\{username}\AppData\Local\PocketAgent\
```

### Important Paths
```bash
# Agent home (workspace, config, memory)
/Applications/PocketAgent/home/

# Workspace files (IDENTITY, SOUL, JOB, etc.)
/Applications/PocketAgent/home/.openclaw/workspace/

# Configuration
/Applications/PocketAgent/home/.openclaw/openclaw.json

# API keys and credentials
/Applications/PocketAgent/home/.openclaw/.env

# Logs
/Applications/PocketAgent/logs/

# OpenClaw installation
/Applications/PocketAgent/lib/openclaw/
```

---

## 🔧 Advanced Commands

### Manual Backup
```bash
# Backup entire home directory
tar -czf pocketagent-backup-$(date +%Y%m%d).tar.gz \
  /Applications/PocketAgent/home/

# Backup just workspace
tar -czf workspace-backup-$(date +%Y%m%d).tar.gz \
  /Applications/PocketAgent/home/.openclaw/workspace/
```

### Manual Restore
```bash
# Restore home directory
tar -xzf pocketagent-backup-YYYYMMDD.tar.gz -C /

# Restore workspace
tar -xzf workspace-backup-YYYYMMDD.tar.gz -C /
```

### View Configuration Files
```bash
# View agent identity
cat /Applications/PocketAgent/home/.openclaw/workspace/IDENTITY.md

# View user info
cat /Applications/PocketAgent/home/.openclaw/workspace/USER.md

# View agent soul/personality
cat /Applications/PocketAgent/home/.openclaw/workspace/SOUL.md

# View job definition
cat /Applications/PocketAgent/home/.openclaw/workspace/JOB.md
```

### Edit Configuration
```bash
# Edit identity
nano /Applications/PocketAgent/home/.openclaw/workspace/IDENTITY.md

# Edit user info
nano /Applications/PocketAgent/home/.openclaw/workspace/USER.md

# After editing, restart agent
pocketagent stop
pocketagent start
```

---

## 🚨 Troubleshooting

### Agent Won't Start
```bash
# Check if already running
pocketagent status

# Check logs for errors
pocketagent logs --tail 50

# Try stopping and starting
pocketagent stop
sleep 2
pocketagent start
```

### Port Already in Use
```bash
# Check what's using port 18789
lsof -i :18789

# Kill the process
kill -9 <PID>

# Or change port in config
nano /Applications/PocketAgent/home/.openclaw/.env
# Change OPENCLAW_GATEWAY_PORT=18789 to another port
```

### Reset to Defaults
```bash
# Backup first!
pocketagent workspace backup

# Stop agent
pocketagent stop

# Remove config (will regenerate)
rm /Applications/PocketAgent/home/.openclaw/openclaw.json

# Start agent (will create fresh config)
pocketagent start
```

### Complete Reinstall
```bash
# Backup your data first!
tar -czf pocketagent-full-backup.tar.gz /Applications/PocketAgent/home/

# Remove installation
rm -rf /Applications/PocketAgent/

# Run installer again
curl -fsSL https://install.pocketagent.com | bash
```

---

## 💡 Tips

- **Always backup before updates:** `pocketagent workspace backup`
- **Check logs if something's wrong:** `pocketagent logs --follow`
- **Your data is in home/:** Everything persists across updates
- **Web UI:** http://localhost:18789
- **Gateway token:** Saved in `/Applications/PocketAgent/home/.openclaw/.env`

---

## 🆘 Need Help?

- Check logs: `pocketagent logs`
- Run diagnostics: `pocketagent doctor --fix`
- View help: `pocketagent --help`
- See [README.md](./README.md) for more info
