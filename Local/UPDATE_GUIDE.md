# PocketAgent Update Guide

## For Existing Users

If you already have PocketAgent installed, here's how to get the latest updates:

### Method 1: Using pocketagent command (Recommended)

```bash
pocketagent update
```

This will:
1. Download the latest `pocketagent` script
2. Download the latest `install.sh` script
3. Update OpenClaw to the latest tested version
4. Update workspace files (preserving your customizations)
5. Restart the agent if needed

### Method 2: Using install.sh directly

```bash
curl -fsSL https://raw.githubusercontent.com/PocketAgentNetwork/pocketagent-image/main/Local/install.sh | bash -s update
```

This does the same thing as Method 1, but runs from the installer script.

## What Gets Updated

- ✅ `pocketagent` command script (gets latest features)
- ✅ `install.sh` installer script
- ✅ OpenClaw core (only if version changed)
- ✅ Workspace system files (SOUL.md, AGENTS.md, BOOTSTRAP.md, etc.)
- ✅ New skills and agents (only adds new ones, doesn't overwrite existing)
- ❌ Your customizations (IDENTITY.md, USER.md, custom skills) - preserved

## Update Frequency

Check for updates regularly:
```bash
pocketagent update
```

The update is smart - it only downloads what changed, so it's fast if you're already up to date.

## Troubleshooting

If `pocketagent update` doesn't work or seems stuck:

1. **Manually update the script first:**
   ```bash
   # macOS
   curl -fsSL https://raw.githubusercontent.com/PocketAgentNetwork/pocketagent-image/main/Local/bin/pocketagent -o /Applications/PocketAgent/bin/pocketagent
   chmod +x /Applications/PocketAgent/bin/pocketagent
   
   # Linux
   curl -fsSL https://raw.githubusercontent.com/PocketAgentNetwork/pocketagent-image/main/Local/bin/pocketagent -o ~/.local/share/pocketagent/bin/pocketagent
   chmod +x ~/.local/share/pocketagent/bin/pocketagent
   ```

2. **Then run update again:**
   ```bash
   pocketagent update
   ```

## What's New

### Latest Updates
- ✨ Download progress bar when updating OpenClaw
- ✨ Self-updating scripts (always get latest features)
- ✨ Automatic workspace sync (new skills/agents added automatically)
- ✨ Auto-start daemon setup during updates
