# PocketAgent Local - Changelog

## [Unreleased] - 2026-03-03

### Added
- **Auto-Start Daemon Support** 🚀
  - macOS: launchd service automatically configured during installation
  - Linux: systemd service automatically configured during installation
  - PocketAgent now starts automatically on boot, just like OpenClaw daemon
  - New commands: `pocketagent enable` and `pocketagent disable` to manage auto-start
  - Service keeps PocketAgent running and restarts it if it crashes
  - Separate logs for service manager (launchd/systemd)

### Changed
- Installer now sets up auto-start service by default
- Uninstaller now removes auto-start service automatically
- Updated help text to include auto-start commands

### Documentation
- Added [AUTOSTART.md](./AUTOSTART.md) - Complete auto-start documentation
- Added [COMMANDS.md](./COMMANDS.md) - Full command reference
- Updated [README.md](./README.md) - Mentioned auto-start feature

### Technical Details

**macOS (launchd):**
- Service file: `~/Library/LaunchAgents/com.pocketagent.plist`
- Logs: `/Applications/PocketAgent/logs/launchd.{out,err}.log`
- Starts on user login
- Keeps agent alive with automatic restart on failure

**Linux (systemd):**
- Service file: `~/.config/systemd/user/pocketagent.service`
- Logs: `~/.local/share/pocketagent/logs/systemd.{out,err}.log`
- Starts on boot (via `loginctl enable-linger`)
- Runs as user service
- Automatic restart on failure with 10s delay

### Benefits
- ✅ No manual startup needed after reboot
- ✅ Automatic recovery from crashes
- ✅ Consistent with OpenClaw daemon behavior
- ✅ Cross-platform support (macOS, Linux)
- ✅ Easy to enable/disable via CLI

---

## Previous Versions

See git history for earlier changes.
