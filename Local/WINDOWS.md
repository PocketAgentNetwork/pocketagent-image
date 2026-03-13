# Windows Support

PocketAgent now supports Windows installation and operation.

## Installation Methods

### Option 1: Native Windows (Recommended)
Use PowerShell or Command Prompt to install Node.js, then use Git Bash for PocketAgent.

### Option 2: WSL 2 (Windows Subsystem for Linux)
If you have WSL 2 installed, you can use the Linux installation method directly.

**Note:** WSL 1 is not supported. Please upgrade to WSL 2.

## What Was Fixed

The installer script and pocketagent command wrapper were updated to support Windows:

1. **OS Detection** - Added Windows detection (msys/cygwin/win32)
2. **Installation Path** - Windows installs to `%USERPROFILE%\AppData\Local\PocketAgent\`
3. **Auto-Start** - Uses Windows Startup folder instead of launchd/systemd
4. **Process Management** - Uses `tasklist` and `taskkill` for Windows process control
5. **Shell Integration** - Adds pocketagent to PATH in `.bashrc` or `.bash_profile`
6. **Line Endings** - Fixed CRLF to LF for bash compatibility

## Installation

Use the standard one-line installer in Git Bash:

```bash
curl -fsSL https://raw.githubusercontent.com/PocketAgentNetwork/pocketagent-image/main/Local/install.sh | bash
```

## Requirements

- Git Bash (from [git-scm.com](https://git-scm.com/download/win))
- Node.js 22+ (from [nodejs.org](https://nodejs.org/))
- Python 3.8+ (from [python.org](https://www.python.org/downloads/))
- 2GB+ free disk space

## Installation Location

```
%USERPROFILE%\AppData\Local\PocketAgent\
```

## Auto-Start

PocketAgent automatically starts on user login via Windows Startup folder. Manage with:

```bash
pocketagent enable    # Enable auto-start
pocketagent disable   # Disable auto-start
```

## PATH Setup (How `pocketagent` Command Works)

The installer automatically adds PocketAgent to your PATH:

1. **During Installation**: The script detects your shell (`.bashrc` or `.bash_profile`)
2. **Adds to PATH**: Appends this line:
   ```bash
   export PATH="$HOME/AppData/Local/PocketAgent/bin:$PATH"
   ```
3. **Reload Shell**: After installation, reload your shell:
   ```bash
   source ~/.bashrc
   ```

Now you can use `pocketagent` command from anywhere in Git Bash.

**How it works:**
- The actual script is at: `%USERPROFILE%\AppData\Local\PocketAgent\bin\pocketagent`
- PATH entry makes it accessible as just `pocketagent`
- Same as macOS and Linux installations

## Usage

All standard commands work on Windows:

```bash
pocketagent start      # Start service
pocketagent stop       # Stop service
pocketagent status     # Check status
pocketagent logs       # View logs
pocketagent update     # Update to latest
```

## Web UI

Access at: `http://localhost:18789`

## Troubleshooting

**Command not found after install:**
```bash
source ~/.bashrc
```
This reloads your shell configuration with the new PATH entry.

**PATH not working:**
Check if the entry was added:
```bash
cat ~/.bashrc | grep PocketAgent
```

Should show:
```bash
export PATH="$HOME/AppData/Local/PocketAgent/bin:$PATH"
```

If missing, add it manually:
```bash
echo 'export PATH="$HOME/AppData/Local/PocketAgent/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

**Node.js not found:**
Restart Git Bash after installing Node.js

**Permission issues:**
Run Git Bash as Administrator

**Check logs:**
```bash
pocketagent logs --follow
```

See [AUTOSTART.md](./AUTOSTART.md) for auto-start troubleshooting.
