# 📟 PocketAgent Commands Reference

Complete command reference for managing your local PocketAgent installation.

---

## Service Management

### Start/Stop/Restart

```bash
# Start PocketAgent
pocketagent start

# Stop PocketAgent
pocketagent stop

# Restart PocketAgent
pocketagent restart

# Check if running
pocketagent status
```

### Auto-Start Management

```bash
# Enable auto-start on boot (default after installation)
pocketagent enable

# Disable auto-start on boot
pocketagent disable
```

See [AUTOSTART.md](./AUTOSTART.md) for detailed auto-start documentation.

---

## Logs

```bash
# View last 50 lines of logs
pocketagent logs

# Follow logs in real-time
pocketagent logs --follow
pocketagent logs -f

# View last N lines
pocketagent logs --tail 100
```

---

## Updates

```bash
# Update to latest OpenClaw version
pocketagent update

# Check current version
pocketagent version
```

The update command:
- Checks for new OpenClaw releases
- Backs up current version
- Downloads and builds new version
- Updates workspace files (preserves customizations)
- Restarts PocketAgent

---

## Configuration

```bash
# View configuration
pocketagent config

# Fix model context window (set to 128k tokens)
pocketagent fix-context
```

---

## Diagnostics

```bash
# Run health check
pocketagent doctor

# Run health check and auto-fix issues
pocketagent doctor --fix

# Check agent health
pocketagent health
```

---

## Model Management

```bash
# Check model status
pocketagent models status

# List available models
pocketagent models list

# Add a model
pocketagent models add

# Remove a model
pocketagent models remove
```

---

## Workspace Management

```bash
# View workspace info
pocketagent workspace

# List workspace files
pocketagent workspace list
```

---

## Skills Management

```bash
# List installed skills
pocketagent skills list

# Add a skill
pocketagent skills add

# Remove a skill
pocketagent skills remove
```

---

## Integrations

```bash
# List integrations
pocketagent integrations list

# Configure integration
pocketagent integrations configure
```

---

## Direct OpenClaw Commands

PocketAgent wraps OpenClaw, so all OpenClaw commands work:

```bash
# Channel management
pocketagent channels login
pocketagent channels list

# Send messages
pocketagent message send --target +1234567890 --message "Hello"

# Agent management
pocketagent agents list
pocketagent agents create

# Browser control
pocketagent browser open
pocketagent browser close

# And many more...
```

---

## Installation Management

```bash
# Install PocketAgent
curl -fsSL https://raw.githubusercontent.com/PocketAgentNetwork/pocketagent-image/main/Local/install.sh | bash

# Update PocketAgent
curl -fsSL https://raw.githubusercontent.com/PocketAgentNetwork/pocketagent-image/main/Local/install.sh | bash -s update

# Uninstall PocketAgent
curl -fsSL https://raw.githubusercontent.com/PocketAgentNetwork/pocketagent-image/main/Local/install.sh | bash -s uninstall
```

Or if you have the script locally:

```bash
./install.sh install
./install.sh update
./install.sh uninstall
```

---

## Help

```bash
# Show help
pocketagent --help
pocketagent -h
pocketagent help
```

---

## Installation Paths

### macOS
```
/Applications/PocketAgent/
├── bin/pocketagent          # Command wrapper
├── lib/openclaw/            # OpenClaw framework
├── home/                    # Agent's home directory
│   ├── .openclaw/           # Config & workspace
│   ├── files/               # Agent's files
│   └── .local/bin/          # Installed tools
├── data/                    # PocketAgent data
└── logs/                    # Logs
```

### Linux
```
~/.local/share/pocketagent/
├── bin/pocketagent          # Command wrapper
├── lib/openclaw/            # OpenClaw framework
├── home/                    # Agent's home directory
│   ├── .openclaw/           # Config & workspace
│   ├── files/               # Agent's files
│   └── .local/bin/          # Installed tools
├── data/                    # PocketAgent data
└── logs/                    # Logs
```

---

## Environment Variables

PocketAgent uses these environment variables (set in `~/.openclaw/.env`):

```bash
OPENCLAW_GATEWAY_TOKEN=<your-token>
OPENCLAW_GATEWAY_PORT=18789
OPENCLAW_GATEWAY_BIND=127.0.0.1
```

---

## Web UI

Access PocketAgent's web interface:

```
http://localhost:18789
```

Use your gateway token to authenticate (shown during installation).

---

## Troubleshooting

### PocketAgent won't start

```bash
# Check logs
pocketagent logs --tail 100

# Check if port is in use
lsof -i :18789

# Try restarting
pocketagent restart
```

### Auto-start not working

See [AUTOSTART.md](./AUTOSTART.md) for platform-specific troubleshooting.

### Update failed

```bash
# Check logs
pocketagent logs

# Try manual update
cd /Applications/PocketAgent/lib  # or ~/.local/share/pocketagent/lib on Linux
rm -rf openclaw
# Then run update again
pocketagent update
```

### Reset configuration

```bash
# Backup first!
cp -r /Applications/PocketAgent/home/.openclaw /Applications/PocketAgent/home/.openclaw.backup

# Remove config
rm /Applications/PocketAgent/home/.openclaw/.env
rm /Applications/PocketAgent/home/.openclaw/openclaw.json

# Restart and reconfigure
pocketagent restart
```

---

## Support

- GitHub Issues: https://github.com/PocketAgentNetwork/pocketagent-image/issues
- Documentation: [README.md](./README.md)
- Auto-Start Guide: [AUTOSTART.md](./AUTOSTART.md)
- Personalization: [PERSONALIZATION.md](./PERSONALIZATION.md)
