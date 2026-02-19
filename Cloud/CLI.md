# 🎯 PocketAgent CLI Alias

Quick branded commands for managing PocketAgent via SSH.

---

## Setup

### Automatic (Recommended)

The `setup.sh` script automatically creates the alias for you:

```bash
./setup.sh
source ~/.bashrc  # or source ~/.zshrc
```

### Manual Setup

If you didn't run setup.sh, add the alias manually:

```bash
# Add alias to your shell
echo 'alias pocketagent="docker exec -it pocketagent node /pocketagent/lib/openclaw/dist/index.js"' >> ~/.bashrc
source ~/.bashrc

# Or for zsh
echo 'alias pocketagent="docker exec -it pocketagent node /pocketagent/lib/openclaw/dist/index.js"' >> ~/.zshrc
source ~/.zshrc
```

---

## Usage

Now you can run PocketAgent commands with `pocketagent`:

```bash
# Check version
pocketagent --version

# Run onboarding
pocketagent onboard

# Check models
pocketagent models status

# Fix issues
pocketagent doctor --fix

# Start gateway
pocketagent gateway --port 18789

# Any OpenClaw command works
pocketagent [command] [options]
```

---

## Multi-User Setup

For managing multiple user containers:

```bash
# Setup aliases for each user
alias pocketagent-user123="docker exec -it pocketagent-user123 node /pocketagent/lib/openclaw/dist/index.js"
alias pocketagent-user456="docker exec -it pocketagent-user456 node /pocketagent/lib/openclaw/dist/index.js"

# Use them
pocketagent-user123 models status
pocketagent-user456 doctor --fix
```

---

## Common Commands

```bash
# Gateway (main service)
pocketagent gateway                    # Start gateway
pocketagent gateway --port 18789       # Start on specific port
pocketagent gateway --bind lan         # Bind to network

# Onboarding & Setup
pocketagent onboard                    # Run onboarding wizard
pocketagent setup-token                # Setup Claude Code token

# Models
pocketagent models status              # Check model status
pocketagent models list                # List available models
pocketagent models update              # Update model configs

# Diagnostics
pocketagent doctor                     # Run diagnostics
pocketagent doctor --fix               # Auto-fix issues
pocketagent status --all               # Check all status

# Configuration
pocketagent config show                # Show current config
pocketagent config edit                # Edit configuration

# Channels (Integrations)
pocketagent channels list              # List connected channels
pocketagent channels add telegram      # Add Telegram
pocketagent channels add whatsapp      # Add WhatsApp
pocketagent channels add discord       # Add Discord

# Tools
pocketagent tools list                 # List available tools
pocketagent tools allow browser        # Allow browser tool
pocketagent tools deny canvas          # Deny canvas tool

# Logs & Debug
pocketagent logs                       # View logs
pocketagent logs --tail 100            # Last 100 lines
pocketagent --version                  # Check version
pocketagent --help                     # Show help
```

---

**That's it!** Just `pocketagent` instead of long docker commands.

See [COMMANDS.md](COMMANDS.md) for full Docker management reference.
