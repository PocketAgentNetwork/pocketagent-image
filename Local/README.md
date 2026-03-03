# 📟 PocketAgent Local Deployment

Native installation of PocketAgent on your local machine (Mac, Linux, Windows).

---

## 🎯 What This Is

Install PocketAgent as a **background service** on your local machine. Your personal AI agent runs 24/7, accessible via:
- Web UI (http://localhost:18789) - available now
- Native Client apps - coming soon (mobile & desktop)

---

## 🚀 Quick Start

**Coming Soon!** One-line installer:

```bash
# Install PocketAgent
curl -fsSL https://raw.githubusercontent.com/PocketAgentNetwork/pocketagent-image/main/Local/install.sh | bash

# Or download and run manually
curl -O https://raw.githubusercontent.com/PocketAgentNetwork/pocketagent-image/main/Local/install.sh
chmod +x install.sh
./install.sh
```

The installer will:
1. Ask you to personalize your agent (your name, agent name, timezone, language)
2. Install PocketAgent as a background service
3. Start your agent automatically
4. Give you a gateway token for client apps

---

## 📋 Installer Versions

### v0.x: Shell Script Installer (In Development)
- One-line terminal install
- Works on Mac & Linux
- Installs agent as background service
- Access via web browser
- **Includes personalization!** (agent name, user name, etc.)

### v1.x: GUI Installer (Future)
- `.dmg` for Mac
- `.exe` for Windows
- `.deb`/`.rpm` for Linux
- Double-click to install
- Nice progress bars and UX

### v2.x: Native App Bundle (Future)
- **Installer + Client in one!**
- Download one app
- Includes both agent (background) and client (UI)
- Everything just works
- QR code for mobile pairing

---

## 🏗️ What Gets Installed

```
/Applications/PocketAgent/          (Mac)
~/.local/share/pocketagent/         (Linux)
C:\Users\...\AppData\Local\PocketAgent\  (Windows)

├── bin/
│   └── pocketagent                 # Main executable
├── lib/
│   └── openclaw/                   # OpenClaw framework (hidden)
├── home/                           # Agent's home directory
│   ├── .openclaw/                  # Config & memory
│   │   └── workspace/              # IDENTITY, SOUL, JOB, etc.
│   ├── files/                      # Workspace
│   ├── .local/bin/                 # Installed tools
│   └── .ssh/                       # SSH keys
├── data/                           # PocketAgent data
└── logs/                           # Logs
```

---

## ⭐ Personalization Feature

The installer asks you:
- **Your name** → Agent knows who it's serving
- **Agent name** → Call it whatever you want (Jarvis, Alfred, etc.)
- **Timezone** → For scheduling and time-aware tasks
- **Language** → Preferred language

Every installation is unique and personal!

See [PERSONALIZATION.md](./PERSONALIZATION.md) for details.

---

## 🎮 Usage

After installation:

```bash
# Check status
pocketagent status

# Start agent
pocketagent start

# Stop agent
pocketagent stop

# Restart agent
pocketagent restart

# Manage auto-start
pocketagent enable    # Enable auto-start on boot (default)
pocketagent disable   # Disable auto-start on boot

# View logs
pocketagent logs
```

**Access web UI:**
```
http://localhost:18789
```

**Auto-Start:** PocketAgent automatically starts when your computer boots (via launchd on macOS, systemd on Linux). See [AUTOSTART.md](./AUTOSTART.md) for details.

---

## 🔄 Updating

When OpenClaw releases updates:

```bash
pocketagent update
```

This will:
1. Stop your agent
2. Backup current version
3. Download latest OpenClaw
4. Rebuild everything
5. Restart your agent

**Your data is safe!** All settings, memory, and workspace files are preserved.

---

## 🔧 How It Works

1. **Installer runs** → Sets up folders, installs OpenClaw, personalizes workspace
2. **Agent starts** → Runs as background service (launchd/systemd)
3. **Gateway opens** → Listens on localhost:18789
4. **You connect** → Via web browser (now) or client app (later)
5. **Agent works** → 24/7 personal AI operator

---

## 📱 Client Apps (Coming Soon)

**Desktop Client:**
- Native app for Mac/Windows/Linux
- Connect to your local agent
- Better UX than web browser

**Mobile Client:**
- iOS & Android apps
- Connect via gateway token or QR code
- Control your agent from anywhere (on same network)

---

## 🆚 Local vs Cloud

| Feature | Local | Cloud |
|---------|-------|-------|
| **Runs on** | Your machine | VPS/Cloud server |
| **Access** | localhost only | Internet accessible |
| **Setup** | One-line installer | Docker compose |
| **Cost** | Free (your hardware) | VPS cost (~$7-17/mo) |
| **Use case** | Personal use | Remote access, always-on |

---

## 📚 Documentation

- [plan.txt](./plan.txt) - Complete build plan
- [task.txt](./task.txt) - Current development tasks
- [PERSONALIZATION.md](./PERSONALIZATION.md) - Installer personalization feature
- [AUTOSTART.md](./AUTOSTART.md) - Auto-start daemon/service documentation
- [COMMANDS.md](./COMMANDS.md) - Full command reference

---

## 🚧 Development Status

**Current Phase:** Planning & Design

**Next Steps:**
1. Build v0.x shell script installer
2. Test on Mac & Linux
3. Add Windows support
4. Build GUI installer (v1.x)
5. Build native app bundle (v2.x)

---

## 🤝 Contributing

This is part of the PocketAgent Image project. See main [README](../README.md) for more info.

---

**Questions?** Check the [Cloud deployment](../Cloud/) for a working reference implementation.
