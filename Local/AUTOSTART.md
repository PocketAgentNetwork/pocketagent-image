# 🚀 PocketAgent Auto-Start

PocketAgent automatically starts when your computer boots, just like any other system service.

---

## How It Works

### macOS
Uses **launchd** (Apple's service manager):
- Service file: `~/Library/LaunchAgents/com.pocketagent.plist`
- Starts automatically on login
- Keeps PocketAgent running in the background
- Restarts if it crashes

### Linux
Uses **systemd** (Linux service manager):
- Service file: `~/.config/systemd/user/pocketagent.service`
- Starts automatically on boot
- Runs even when you're not logged in (via `loginctl enable-linger`)
- Restarts if it crashes

### Windows
Uses **Windows Startup folder**:
- Startup script: `%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\PocketAgent.bat`
- Starts automatically on login
- Runs in background via Git Bash
- Simple batch script approach for maximum compatibility

### Windows (WSL)
If you're using WSL (Windows Subsystem for Linux), the systemd service will work if you have systemd enabled in WSL2.

---

## Managing Auto-Start

### Check Status
```bash
# macOS
launchctl list | grep pocketagent

# Linux
systemctl --user status pocketagent.service

# Windows
ls "$APPDATA/Microsoft/Windows/Start Menu/Programs/Startup/" | grep PocketAgent
```

### Disable Auto-Start
```bash
pocketagent disable
```

This removes the service file and prevents PocketAgent from starting on boot. You'll need to manually run `pocketagent start` after each reboot.

### Re-Enable Auto-Start
```bash
pocketagent enable
```

This recreates the service file and enables auto-start again.

---

## Manual Control

Even with auto-start enabled, you can still manually control PocketAgent:

```bash
# Stop PocketAgent
pocketagent stop

# Start PocketAgent
pocketagent start

# Restart PocketAgent
pocketagent restart

# Check if running
pocketagent status
```

---

## Logs

Auto-start logs are separate from the main PocketAgent logs:

### macOS (launchd)
```bash
# View launchd logs
tail -f /Applications/PocketAgent/logs/launchd.out.log
tail -f /Applications/PocketAgent/logs/launchd.err.log
```

### Linux (systemd)
```bash
# View systemd logs
tail -f ~/.local/share/pocketagent/logs/systemd.out.log
tail -f ~/.local/share/pocketagent/logs/systemd.err.log

# Or use journalctl
journalctl --user -u pocketagent.service -f
```

### Windows
```bash
# View startup logs (if PocketAgent was started via startup script)
tail -f ~/AppData/Local/PocketAgent/logs/pocketagent.log
```

---

## Troubleshooting

### PocketAgent not starting on boot?

**macOS:**
```bash
# Check if service is loaded
launchctl list | grep pocketagent

# Reload service
launchctl unload ~/Library/LaunchAgents/com.pocketagent.plist
launchctl load ~/Library/LaunchAgents/com.pocketagent.plist

# Check logs
tail -f /Applications/PocketAgent/logs/launchd.err.log
```

**Linux:**
```bash
# Check service status
systemctl --user status pocketagent.service

# Check if lingering is enabled
loginctl show-user $USER | grep Linger

# Enable lingering if needed
loginctl enable-linger $USER

# Restart service
systemctl --user restart pocketagent.service

# Check logs
journalctl --user -u pocketagent.service -n 50
```

**Windows:**
```bash
# Check if startup script exists
ls "$APPDATA/Microsoft/Windows/Start Menu/Programs/Startup/PocketAgent.bat"

# Test startup script manually
cd ~/AppData/Local/PocketAgent/bin
bash pocketagent start

# Check PocketAgent status
pocketagent status
```

### Disable auto-start temporarily

**macOS:**
```bash
launchctl unload ~/Library/LaunchAgents/com.pocketagent.plist
```

**Linux:**
```bash
systemctl --user stop pocketagent.service
```

**Windows:**
```bash
# Stop PocketAgent (startup script will try to restart on next boot)
pocketagent stop
```

This stops the service but doesn't remove it. It will start again on next boot.

---

## Uninstalling

When you uninstall PocketAgent, the auto-start service is automatically removed:

```bash
curl -fsSL https://raw.githubusercontent.com/PocketAgentNetwork/pocketagent-image/main/Local/install.sh | bash -s uninstall
```

Or manually remove:

**macOS:**
```bash
launchctl unload ~/Library/LaunchAgents/com.pocketagent.plist
rm ~/Library/LaunchAgents/com.pocketagent.plist
```

**Linux:**
```bash
systemctl --user stop pocketagent.service
systemctl --user disable pocketagent.service
rm ~/.config/systemd/user/pocketagent.service
systemctl --user daemon-reload
```

**Windows:**
```bash
# Remove startup script
rm "$APPDATA/Microsoft/Windows/Start Menu/Programs/Startup/PocketAgent.bat"
rm ~/AppData/Local/PocketAgent/bin/pocketagent-startup.bat
```

---

## Why Auto-Start?

PocketAgent is designed to be your always-available personal AI agent. Auto-start ensures:

- ✅ PocketAgent is ready when you need it
- ✅ No manual startup after reboots
- ✅ Automatic recovery from crashes
- ✅ Consistent experience like other system services

Just like OpenClaw's daemon mode, PocketAgent runs quietly in the background, ready to help whenever you need it.
