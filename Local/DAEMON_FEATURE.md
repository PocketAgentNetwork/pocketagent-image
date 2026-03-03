# 🚀 Auto-Start Daemon Feature

PocketAgent now starts automatically on boot, just like OpenClaw's daemon mode!

---

## What Changed?

### Before ❌
```bash
# After reboot
$ pocketagent status
📟 PocketAgent is stopped

# Had to manually start every time
$ pocketagent start
```

### After ✅
```bash
# After reboot
$ pocketagent status
📟 PocketAgent is running (PID: 12345)
🌐 Access at: http://localhost:18789

# Already running automatically!
```

---

## How It Works

### Installation
```bash
curl -fsSL https://raw.githubusercontent.com/PocketAgentNetwork/pocketagent-image/main/Local/install.sh | bash
```

The installer now:
1. ✅ Installs PocketAgent
2. ✅ Sets up auto-start service (launchd/systemd)
3. ✅ Enables auto-start by default

### Platform Support

| Platform | Service Manager | Status |
|----------|----------------|--------|
| macOS | launchd | ✅ Supported |
| Linux | systemd | ✅ Supported |
| Windows WSL | systemd | ✅ Supported (if systemd enabled) |

---

## Managing Auto-Start

### Check Status

**macOS:**
```bash
launchctl list | grep pocketagent
```

**Linux:**
```bash
systemctl --user status pocketagent.service
```

### Disable Auto-Start
```bash
pocketagent disable
```

### Re-Enable Auto-Start
```bash
pocketagent enable
```

---

## Service Details

### macOS (launchd)

**Service File:**
```
~/Library/LaunchAgents/com.pocketagent.plist
```

**Features:**
- Starts on user login
- Keeps PocketAgent alive
- Restarts automatically if it crashes
- Separate logs for service manager

**Logs:**
```bash
tail -f /Applications/PocketAgent/logs/launchd.out.log
tail -f /Applications/PocketAgent/logs/launchd.err.log
```

### Linux (systemd)

**Service File:**
```
~/.config/systemd/user/pocketagent.service
```

**Features:**
- Starts on boot (via lingering)
- Runs as user service
- Restarts automatically if it crashes (10s delay)
- Separate logs for service manager

**Logs:**
```bash
tail -f ~/.local/share/pocketagent/logs/systemd.out.log
tail -f ~/.local/share/pocketagent/logs/systemd.err.log

# Or use journalctl
journalctl --user -u pocketagent.service -f
```

---

## Architecture

```
┌─────────────────────────────────────────┐
│         System Boot / User Login        │
└─────────────────┬───────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────┐
│   Service Manager (launchd/systemd)     │
│   - Loads service configuration         │
│   - Starts PocketAgent automatically    │
│   - Monitors process health             │
└─────────────────┬───────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────┐
│         pocketagent start               │
│   - Starts OpenClaw gateway             │
│   - Binds to localhost:18789            │
│   - Runs in background (nohup)          │
└─────────────────┬───────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────┐
│         PocketAgent Running             │
│   - Web UI available                    │
│   - Ready to serve requests             │
│   - Logs to pocketagent.log             │
└─────────────────────────────────────────┘
```

---

## Comparison with OpenClaw Daemon

| Feature | OpenClaw Daemon | PocketAgent Auto-Start |
|---------|----------------|----------------------|
| Auto-start on boot | ✅ | ✅ |
| Runs in background | ✅ | ✅ |
| Automatic restart | ✅ | ✅ |
| Service manager | systemd/launchd | systemd/launchd |
| Cross-platform | ✅ | ✅ |
| Easy enable/disable | ✅ | ✅ |

PocketAgent now has feature parity with OpenClaw's daemon mode!

---

## Benefits

### For Users
- 🎯 **Zero friction** - PocketAgent just works after reboot
- 🔄 **Automatic recovery** - Crashes don't require manual intervention
- 🚀 **Always ready** - No waiting for manual startup
- 💪 **Reliable** - Uses battle-tested service managers

### For Developers
- 📦 **Standard approach** - Uses OS-native service managers
- 🔧 **Easy to debug** - Standard service logs and tools
- 🌍 **Cross-platform** - Works on macOS and Linux
- 🎨 **Customizable** - Users can easily enable/disable

---

## Troubleshooting

### Service not starting?

**macOS:**
```bash
# Check service status
launchctl list | grep pocketagent

# View logs
tail -f /Applications/PocketAgent/logs/launchd.err.log

# Reload service
pocketagent disable
pocketagent enable
```

**Linux:**
```bash
# Check service status
systemctl --user status pocketagent.service

# View logs
journalctl --user -u pocketagent.service -n 50

# Restart service
systemctl --user restart pocketagent.service
```

### Want to disable temporarily?

**macOS:**
```bash
launchctl unload ~/Library/LaunchAgents/com.pocketagent.plist
```

**Linux:**
```bash
systemctl --user stop pocketagent.service
```

This stops the service but doesn't remove it. It will start again on next boot.

---

## Documentation

- [AUTOSTART.md](./AUTOSTART.md) - Detailed auto-start documentation
- [COMMANDS.md](./COMMANDS.md) - Full command reference
- [README.md](./README.md) - Main documentation

---

## Future Enhancements

Potential improvements for future versions:

- [ ] Windows native service support (not just WSL)
- [ ] GUI service manager integration
- [ ] Health check notifications
- [ ] Automatic update on boot
- [ ] Resource limit configuration
- [ ] Multiple agent instances

---

**Status:** ✅ Implemented and tested

**Version:** 0.0.1+daemon

**Date:** 2026-03-03
