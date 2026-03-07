#!/bin/bash
# PocketAgent Master Installer & Manager
# Handles: Installation, Updates, Workspace Management

set -e

SCRIPT_VERSION="0.0.1"

# Detect OS and set paths
if [[ "$OSTYPE" == "darwin"* ]]; then
    INSTALL_DIR="/Applications/PocketAgent"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    INSTALL_DIR="$HOME/.local/share/pocketagent"
else
    echo "❌ Unsupported OS: $OSTYPE"
    exit 1
fi

WORKSPACE_VERSION_FILE="$INSTALL_DIR/home/.openclaw/workspace/.workspace_version"
WORKSPACE_SOURCE="https://raw.githubusercontent.com/PocketAgentNetwork/pocketagent-image/main/workspace"

# ══════════════════════════════════════════════════════════════
# HELPER FUNCTIONS
# ══════════════════════════════════════════════════════════════

check_installed() {
    [ -d "$INSTALL_DIR" ] && [ -f "$INSTALL_DIR/bin/pocketagent" ]
}

setup_autostart() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS - use launchd
        local plist_file="$HOME/Library/LaunchAgents/com.pocketagent.plist"
        
        echo "  Creating launchd service for macOS..."
        mkdir -p "$HOME/Library/LaunchAgents"
        
        cat > "$plist_file" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.pocketagent</string>
    <key>ProgramArguments</key>
    <array>
        <string>$INSTALL_DIR/bin/pocketagent</string>
        <string>start</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <dict>
        <key>SuccessfulExit</key>
        <false/>
    </dict>
    <key>StandardOutPath</key>
    <string>$INSTALL_DIR/logs/launchd.out.log</string>
    <key>StandardErrorPath</key>
    <string>$INSTALL_DIR/logs/launchd.err.log</string>
    <key>EnvironmentVariables</key>
    <dict>
        <key>PATH</key>
        <string>/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$INSTALL_DIR/bin</string>
    </dict>
</dict>
</plist>
EOF
        
        # Load the service
        launchctl unload "$plist_file" 2>/dev/null || true
        launchctl load "$plist_file"
        
        echo "  ✓ launchd service installed and enabled"
        
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Linux - use systemd
        local service_file="$HOME/.config/systemd/user/pocketagent.service"
        
        echo "  Creating systemd service for Linux..."
        mkdir -p "$HOME/.config/systemd/user"
        
        cat > "$service_file" << EOF
[Unit]
Description=PocketAgent - Personal AI Agent
After=network.target

[Service]
Type=simple
ExecStart=$INSTALL_DIR/bin/pocketagent start
ExecStop=$INSTALL_DIR/bin/pocketagent stop
Restart=on-failure
RestartSec=10
StandardOutput=append:$INSTALL_DIR/logs/systemd.out.log
StandardError=append:$INSTALL_DIR/logs/systemd.err.log
Environment="PATH=/usr/local/bin:/usr/bin:/bin:$INSTALL_DIR/bin"

[Install]
WantedBy=default.target
EOF
        
        # Reload systemd and enable service
        systemctl --user daemon-reload
        systemctl --user enable pocketagent.service
        
        # Enable lingering so service runs even when user is not logged in
        loginctl enable-linger "$USER" 2>/dev/null || true
        
        echo "  ✓ systemd service installed and enabled"
    else
        echo "  ⚠️  Auto-start not configured for this OS"
        echo "     You'll need to manually start PocketAgent after reboot"
    fi
}

remove_autostart() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS - remove launchd
        local plist_file="$HOME/Library/LaunchAgents/com.pocketagent.plist"
        
        if [ -f "$plist_file" ]; then
            echo "  Removing launchd service..."
            launchctl unload "$plist_file" 2>/dev/null || true
            rm "$plist_file"
            echo "  ✓ launchd service removed"
        fi
        
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Linux - remove systemd
        local service_file="$HOME/.config/systemd/user/pocketagent.service"
        
        if [ -f "$service_file" ]; then
            echo "  Removing systemd service..."
            systemctl --user stop pocketagent.service 2>/dev/null || true
            systemctl --user disable pocketagent.service 2>/dev/null || true
            rm "$service_file"
            systemctl --user daemon-reload
            echo "  ✓ systemd service removed"
        fi
    fi
}

get_workspace_version() {
    if [ -f "$WORKSPACE_VERSION_FILE" ]; then
        cat "$WORKSPACE_VERSION_FILE"
    else
        echo "0.0.0"
    fi
}

download_workspace() {
    local dest="$1"
    echo "  Downloading workspace files..."
    
    # Download workspace files from GitHub
    mkdir -p "$dest"
    
    # List of workspace files to download
    local files=(
        ".workspace_version"
        "IDENTITY.md"
        "SOUL.md"
        "JOB.md"
        "USER.md"
        "MEMORY.md"
        "HEARTBEAT.md"
        "AGENTS.md"
        "BOOTSTRAP.md"
        "BOOT.md"
        "TOOLS.md"
    )
    
    for file in "${files[@]}"; do
        curl -fsSL "$WORKSPACE_SOURCE/$file" -o "$dest/$file" 2>/dev/null || true
    done
    
    # Create directories
    mkdir -p "$dest"/{skills,agents,memory}
    
    # Download skills
    echo "  Downloading skills..."
    local skills=("agent-maker" "skill-maker")
    for skill in "${skills[@]}"; do
        mkdir -p "$dest/skills/$skill"
        curl -fsSL "$WORKSPACE_SOURCE/skills/$skill/SKILL.md" -o "$dest/skills/$skill/SKILL.md" 2>/dev/null || true
    done
}

personalize_workspace() {
    local workspace_dir="$1"
    
    echo ""
    echo "Let's personalize your agent!"
    echo ""
    
    # Check if stdin is available (not piped)
    if [ -t 0 ]; then
        read -p "What's your name? " USER_NAME
        read -p "What should your agent be called? (default: PocketAgent) " AGENT_NAME
        AGENT_NAME=${AGENT_NAME:-PocketAgent}
        
        read -p "What's your timezone? (e.g., America/New_York) " USER_TIMEZONE
        read -p "What's your preferred language? (default: English) " USER_LANGUAGE
        USER_LANGUAGE=${USER_LANGUAGE:-English}
    else
        # Stdin not available (piped install), use defaults
        echo "⚠️  Interactive input not available (piped install)"
        echo "   Using default values. You can customize later by editing:"
        echo "   - $workspace_dir/IDENTITY.md"
        echo "   - $workspace_dir/USER.md"
        echo ""
        USER_NAME="User"
        AGENT_NAME="PocketAgent"
        USER_TIMEZONE="UTC"
        USER_LANGUAGE="English"
    fi
    
    echo ""
    echo "Great! Setting up $AGENT_NAME for $USER_NAME..."
    
    # Update IDENTITY.md
    if [ -f "$workspace_dir/IDENTITY.md" ]; then
        sed -i.bak "s/^- \*\*Name:\*\* .*/- **Name:** $AGENT_NAME/" "$workspace_dir/IDENTITY.md"
        rm "$workspace_dir/IDENTITY.md.bak" 2>/dev/null || true
    fi
    
    # Update USER.md
    if [ -f "$workspace_dir/USER.md" ]; then
        sed -i.bak "s/^\*\*Name:\*\* .*/\*\*Name:\*\* $USER_NAME/" "$workspace_dir/USER.md"
        sed -i.bak "s/^\*\*Timezone:\*\* .*/\*\*Timezone:\*\* $USER_TIMEZONE/" "$workspace_dir/USER.md"
        sed -i.bak "s/^\*\*Language:\*\* .*/\*\*Language:\*\* $USER_LANGUAGE/" "$workspace_dir/USER.md"
        rm "$workspace_dir/USER.md.bak" 2>/dev/null || true
    fi
}

update_workspace() {
    local workspace_dir="$INSTALL_DIR/home/.openclaw/workspace"
    local current_version=$(get_workspace_version)
    
    # Download latest version file
    local latest_version=$(curl -fsSL "$WORKSPACE_SOURCE/.workspace_version" 2>/dev/null || echo "0.0.0")
    
    if [ "$current_version" = "$latest_version" ]; then
        echo "  Workspace version up to date (v$current_version)"
        echo "  Checking for missing files..."
    else
        echo "  Workspace update available: v$current_version → v$latest_version"
        echo "  Updating system files (preserving user customizations)..."
    fi
    
    # System files that should be updated (only if version changed)
    if [ "$current_version" != "$latest_version" ]; then
        local system_files=(
            "SOUL.md"
            "AGENTS.md"
            "BOOTSTRAP.md"
            "BOOT.md"
            "TOOLS.md"
        )
        
        # Backup and update system files
        for file in "${system_files[@]}"; do
            if [ -f "$workspace_dir/$file" ]; then
                cp "$workspace_dir/$file" "$workspace_dir/${file}.backup" 2>/dev/null || true
            fi
            curl -fsSL "$WORKSPACE_SOURCE/$file" -o "$workspace_dir/$file" 2>/dev/null || true
            echo "    ✓ Updated $file"
        done
    fi
    
    # ⭐ NEW: Sync new skills and agents (don't overwrite existing)
    echo "  Syncing new skills and agents..."
    
    # Download and sync skills
    local temp_workspace="/tmp/pocketagent-workspace-$$"
    mkdir -p "$temp_workspace"
    download_workspace "$temp_workspace"
    
    # Copy new skills (only if they don't exist)
    if [ -d "$temp_workspace/skills" ]; then
        for skill_dir in "$temp_workspace/skills"/*; do
            if [ -d "$skill_dir" ]; then
                skill_name=$(basename "$skill_dir")
                if [ ! -d "$workspace_dir/skills/$skill_name" ]; then
                    cp -r "$skill_dir" "$workspace_dir/skills/"
                    echo "    ✓ Added new skill: $skill_name"
                fi
            fi
        done
    fi
    
    # Copy new agents (only if they don't exist)
    if [ -d "$temp_workspace/agents" ]; then
        for agent_file in "$temp_workspace/agents"/*; do
            if [ -f "$agent_file" ]; then
                agent_name=$(basename "$agent_file")
                if [ ! -f "$workspace_dir/agents/$agent_name" ]; then
                    cp "$agent_file" "$workspace_dir/agents/"
                    echo "    ✓ Added new agent: $agent_name"
                fi
            fi
        done
    fi
    
    # Cleanup
    rm -rf "$temp_workspace"
    
    # Update version file if changed
    if [ "$current_version" != "$latest_version" ]; then
        echo "$latest_version" > "$WORKSPACE_VERSION_FILE"
    fi
    
    echo "  ✅ Workspace sync complete"
}

# ══════════════════════════════════════════════════════════════
# MAIN COMMANDS
# ══════════════════════════════════════════════════════════════

cmd_install() {
    echo "📟 PocketAgent Installer v$SCRIPT_VERSION"
    echo "=========================================="
    echo ""
    
    # Check if fully installed
    if check_installed && [ -f "$INSTALL_DIR/home/.openclaw/.env" ]; then
        echo "✅ PocketAgent is already installed at: $INSTALL_DIR"
        echo ""
        
        # Check if daemon is set up
        DAEMON_EXISTS=false
        if [[ "$OSTYPE" == "darwin"* ]]; then
            [ -f "$HOME/Library/LaunchAgents/com.pocketagent.plist" ] && DAEMON_EXISTS=true
        elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
            [ -f "$HOME/.config/systemd/user/pocketagent.service" ] && DAEMON_EXISTS=true
        fi
        
        if [ "$DAEMON_EXISTS" = false ]; then
            echo "🔧 Auto-start daemon not found. Setting up..."
            setup_autostart
            echo ""
            echo "✅ Auto-start daemon configured!"
            echo ""
        fi
        
        echo "To update, run:"
        echo "  $0 update"
        echo ""
        echo "To reinstall, run:"
        echo "  rm -rf $INSTALL_DIR && $0 install"
        exit 0
    fi
    
    # Resume installation if partially complete
    if [ -d "$INSTALL_DIR" ]; then
        echo "⚠️  Found partial installation, resuming..."
        echo ""
    fi
    
    # Check prerequisites
    echo "✓ Checking prerequisites..."
    command -v node >/dev/null || { echo "❌ Node.js 22+ required"; exit 1; }
    command -v pnpm >/dev/null || { echo "Installing pnpm..."; npm install -g pnpm; }
    
    # Check disk space (need ~2GB for OpenClaw + node_modules)
    echo "✓ Checking disk space..."
    if [[ "$OSTYPE" == "darwin"* ]]; then
        AVAILABLE_MB=$(df -m / | tail -1 | awk '{print $4}')
    else
        AVAILABLE_MB=$(df -m / | tail -1 | awk '{print $4}')
    fi
    
    if [ "$AVAILABLE_MB" -lt 2048 ]; then
        echo "⚠️  Low disk space: ${AVAILABLE_MB}MB available"
        echo "   OpenClaw needs ~2GB (source + node_modules + build)"
        read -p "   Continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "Installation cancelled"
            exit 1
        fi
    else
        echo "   ${AVAILABLE_MB}MB available (need ~2GB)"
    fi
    
    # Create directories
    if [ ! -d "$INSTALL_DIR/home/.openclaw" ]; then
        echo "✓ Creating directories..."
        mkdir -p "$INSTALL_DIR"/{bin,lib,home,data,logs}
        mkdir -p "$INSTALL_DIR/home"/{.openclaw,.local/bin,.ssh,.config,files}
    else
        echo "✓ Directories exist, skipping..."
    fi
    
    # Install OpenClaw
    if [ -f "$INSTALL_DIR/OPENCLAW_VERSION" ] && [ -d "$INSTALL_DIR/lib/openclaw" ]; then
        echo "✓ OpenClaw already downloaded, checking build..."
        cd "$INSTALL_DIR/lib/openclaw"
        
        # Check if build is complete
        if [ ! -d "dist" ] || [ ! -f "dist/index.js" ]; then
            echo "  Build incomplete, rebuilding..."
            pnpm install
            pnpm build
        else
            echo "  Build complete, skipping..."
        fi
    else
        echo "✓ Installing OpenClaw..."
        mkdir -p "$INSTALL_DIR/lib"
        cd "$INSTALL_DIR/lib"
        if [ -d "openclaw" ]; then
            rm -rf openclaw
        fi
        
        # Get tested OpenClaw version from PocketAgent repo
        OPENCLAW_VERSION=$(curl -fsSL https://raw.githubusercontent.com/PocketAgentNetwork/pocketagent-image/main/OPENCLAW_VERSION)
        
        if [ -z "$OPENCLAW_VERSION" ]; then
            echo "❌ Failed to fetch OpenClaw version"
            exit 1
        fi
        
        echo "  Downloading OpenClaw $OPENCLAW_VERSION..."
        
        # Download release tarball with progress
        if ! curl -L --progress-bar "https://github.com/openclaw/openclaw/archive/refs/tags/$OPENCLAW_VERSION.tar.gz" -o openclaw.tar.gz; then
            echo "❌ Failed to download OpenClaw"
            exit 1
        fi
        
        # Extract
        echo "  Extracting..."
        tar -xzf openclaw.tar.gz
        mv "openclaw-${OPENCLAW_VERSION#v}" openclaw
        rm openclaw.tar.gz
        
        cd openclaw
        
        echo "  Building OpenClaw..."
        
        # Ensure logs directory exists
        mkdir -p "$INSTALL_DIR/logs"
        
        # Check if pnpm is available
        if ! command -v pnpm >/dev/null 2>&1; then
            echo "  pnpm not found. Installing pnpm..."
            if ! npm install -g pnpm; then
                echo "❌ Failed to install pnpm"
                exit 1
            fi
        fi
        
        echo "  Installing dependencies (this may take a few minutes)..."
        if ! pnpm install --recursive 2>&1 | tee "$INSTALL_DIR/logs/pnpm-install.log"; then
            echo "❌ Failed to install dependencies"
            echo "   Check logs: $INSTALL_DIR/logs/pnpm-install.log"
            echo "   Please check your internet connection and try again"
            exit 1
        fi
        
        echo "  Building (this may take a few minutes)..."
        if ! pnpm build 2>&1 | tee "$INSTALL_DIR/logs/pnpm-build.log"; then
            echo "❌ Failed to build OpenClaw"
            echo "   Check logs: $INSTALL_DIR/logs/pnpm-build.log"
            echo "   Please check the error messages above"
            exit 1
        fi
        
        # Verify build succeeded
        if [ ! -f "dist/index.js" ]; then
            echo "❌ Build completed but dist/index.js not found"
            echo "   This is unexpected. Please report this issue."
            exit 1
        fi
        
        # Save version info only after successful build
        echo "$OPENCLAW_VERSION" > "$INSTALL_DIR/OPENCLAW_VERSION"
    fi
    
    # Download and personalize workspace
    if [ ! -f "$INSTALL_DIR/home/.openclaw/workspace/IDENTITY.md" ]; then
        echo "✓ Setting up workspace..."
        download_workspace "$INSTALL_DIR/home/.openclaw/workspace"
        personalize_workspace "$INSTALL_DIR/home/.openclaw/workspace"
    else
        echo "✓ Workspace already exists, skipping..."
    fi
    
    # Generate gateway token
    if [ ! -f "$INSTALL_DIR/home/.openclaw/.env" ]; then
        echo "✓ Generating gateway token..."
        TOKEN=$(openssl rand -hex 32)
        cat > "$INSTALL_DIR/home/.openclaw/.env" << EOF
OPENCLAW_GATEWAY_TOKEN=$TOKEN
OPENCLAW_GATEWAY_PORT=18789
OPENCLAW_GATEWAY_BIND=127.0.0.1
EOF
    else
        echo "✓ Gateway token already exists, skipping..."
        TOKEN=$(grep OPENCLAW_GATEWAY_TOKEN "$INSTALL_DIR/home/.openclaw/.env" | cut -d= -f2)
    fi
    
    # Copy pocketagent script
    if [ ! -f "$INSTALL_DIR/bin/pocketagent" ]; then
        echo "✓ Installing pocketagent command..."
        curl -fsSL "https://raw.githubusercontent.com/PocketAgentNetwork/pocketagent-image/main/Local/bin/pocketagent" \
            -o "$INSTALL_DIR/bin/pocketagent"
        chmod +x "$INSTALL_DIR/bin/pocketagent"
    else
        echo "✓ pocketagent command already installed, skipping..."
    fi
    
    # Fix model context window for ALL providers if config exists
    if [ -f "$INSTALL_DIR/home/.openclaw/openclaw.json" ]; then
        echo "✓ Checking model context windows for all providers..."
        
        # Use Python to fix all models with context < 16k
        python3 << 'PYTHON_FIX'
import json
import sys

config_file = "$INSTALL_DIR/home/.openclaw/openclaw.json"

try:
    with open(config_file, 'r') as f:
        config = json.load(f)
    
    fixed_count = 0
    providers = config.get('models', {}).get('providers', {})
    
    for provider_name, provider_data in providers.items():
        models = provider_data.get('models', [])
        
        for model in models:
            model_id = model.get('id', 'unknown')
            context_window = model.get('contextWindow', 0)
            
            # Set proper context window for all models
            if context_window < 128000:
                old_context = context_window
                model['contextWindow'] = 128000
                
                # Set reasonable maxTokens (output limit)
                if model.get('maxTokens', 0) < 8192:
                    model['maxTokens'] = 8192
                
                print(f"  ✓ Fixed {provider_name}/{model_id}: {old_context} → 128000 tokens")
                fixed_count += 1
    
    if fixed_count > 0:
        with open(config_file, 'w') as f:
            json.dump(config, f, indent=2)
        print(f"  ✓ Updated {fixed_count} model(s)")
    else:
        print("  ✓ All models already configured correctly")
        
except Exception as e:
    print(f"  ⚠️  Could not fix context windows: {e}", file=sys.stderr)
    pass

PYTHON_FIX
    fi
    
    # Add to PATH
    if [[ "$OSTYPE" == "darwin"* ]]; then
        SHELL_RC="$HOME/.zshrc"
    else
        SHELL_RC="$HOME/.bashrc"
    fi
    
    if ! grep -q "PocketAgent/bin" "$SHELL_RC" 2>/dev/null; then
        echo "" >> "$SHELL_RC"
        echo "# PocketAgent" >> "$SHELL_RC"
        echo "export PATH=\"$INSTALL_DIR/bin:\$PATH\"" >> "$SHELL_RC"
    fi
    
    # Setup auto-start daemon/service
    echo ""
    echo "✓ Setting up auto-start service..."
    setup_autostart
    
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🎉 PocketAgent installed successfully!"
    echo ""
    echo "🔑 Your Gateway Token:"
    echo "   $TOKEN"
    echo ""
    echo "   Save this! You'll need it to connect client apps."
    echo ""
    echo "🚀 Auto-Start: ENABLED"
    echo "   PocketAgent will start automatically on boot"
    echo "   To disable: pocketagent disable"
    echo ""
    echo "📋 Next Steps:"
    echo ""
    echo "1. Reload your shell:"
    echo "   source $SHELL_RC"
    echo ""
    echo "2. Start PocketAgent:"
    echo "   pocketagent start"
    echo ""
    echo "3. Open in browser:"
    echo "   http://localhost:18789"
    echo ""
    echo "4. Complete onboarding (add API keys)"
    echo ""
    echo "💡 Note: If you configure a custom model, ensure it has"
    echo "   a context window of at least 16000 tokens."
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

cmd_update() {
    if ! check_installed; then
        echo "❌ PocketAgent is not installed"
        echo "   Run: curl -fsSL https://raw.githubusercontent.com/PocketAgentNetwork/pocketagent-image/main/Local/install.sh | bash"
        exit 1
    fi
    
    echo "📟 Updating PocketAgent..."
    echo ""
    
    # Update installer script itself
    echo "✓ Updating installer script..."
    INSTALLER_URL="https://raw.githubusercontent.com/PocketAgentNetwork/pocketagent-image/main/Local/install.sh"
    if curl -fsSL "$INSTALLER_URL" -o "$INSTALL_DIR/install.sh.new"; then
        chmod +x "$INSTALL_DIR/install.sh.new"
        mv "$INSTALL_DIR/install.sh.new" "$INSTALL_DIR/install.sh"
        echo "  ✓ Installer script updated"
    else
        echo "  ⚠️  Failed to update installer script (continuing anyway)"
    fi
    
    # Update pocketagent command script
    echo "✓ Updating pocketagent command..."
    POCKETAGENT_URL="https://raw.githubusercontent.com/PocketAgentNetwork/pocketagent-image/main/Local/bin/pocketagent"
    if curl -fsSL "$POCKETAGENT_URL" -o "$INSTALL_DIR/bin/pocketagent.new"; then
        chmod +x "$INSTALL_DIR/bin/pocketagent.new"
        mv "$INSTALL_DIR/bin/pocketagent.new" "$INSTALL_DIR/bin/pocketagent"
        echo "  ✓ pocketagent command updated"
    else
        echo "  ⚠️  Failed to update pocketagent command (continuing anyway)"
    fi
    
    # Update OpenClaw (use update-continue to skip script self-update since we just did it)
    echo "✓ Updating OpenClaw..."
    "$INSTALL_DIR/bin/pocketagent" update-continue
    
    # Update workspace
    echo "✓ Checking workspace updates..."
    update_workspace
    
    # Check if daemon is set up
    echo ""
    echo "✓ Checking auto-start daemon..."
    DAEMON_EXISTS=false
    if [[ "$OSTYPE" == "darwin"* ]]; then
        [ -f "$HOME/Library/LaunchAgents/com.pocketagent.plist" ] && DAEMON_EXISTS=true
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        [ -f "$HOME/.config/systemd/user/pocketagent.service" ] && DAEMON_EXISTS=true
    fi
    
    if [ "$DAEMON_EXISTS" = false ]; then
        echo "  Auto-start daemon not found. Setting up..."
        setup_autostart
        echo "  ✅ Auto-start daemon configured!"
    else
        echo "  ✅ Auto-start daemon already configured"
    fi
    
    echo ""
    echo "✅ PocketAgent updated successfully!"
}

cmd_workspace_update() {
    if ! check_installed; then
        echo "❌ PocketAgent is not installed"
        exit 1
    fi
    
    echo "📟 Updating workspace files..."
    update_workspace
}

cmd_uninstall() {
    if ! check_installed; then
        echo "❌ PocketAgent is not installed"
        exit 0
    fi
    
    echo "⚠️  This will remove PocketAgent from your system"
    read -p "Are you sure? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Uninstall cancelled."
        exit 0
    fi
    
    # Stop agent
    "$INSTALL_DIR/bin/pocketagent" stop 2>/dev/null || true
    
    # Remove auto-start service
    echo "Removing auto-start service..."
    remove_autostart
    
    # Remove installation
    echo "Removing $INSTALL_DIR..."
    rm -rf "$INSTALL_DIR"
    
    echo "✅ PocketAgent uninstalled"
}

cmd_help() {
    cat << EOF
📟 PocketAgent Installer & Manager v$SCRIPT_VERSION

Usage: $0 <command>

Commands:
  install            Install PocketAgent
  update             Update OpenClaw and workspace
  workspace-update   Update workspace files only
  uninstall          Remove PocketAgent
  help               Show this help

Examples:
  # Install
  curl -fsSL https://raw.githubusercontent.com/PocketAgentNetwork/pocketagent-image/main/Local/install.sh | bash
  
  # Update
  curl -fsSL https://raw.githubusercontent.com/PocketAgentNetwork/pocketagent-image/main/Local/install.sh | bash -s update
  
  # Uninstall
  curl -fsSL https://raw.githubusercontent.com/PocketAgentNetwork/pocketagent-image/main/Local/install.sh | bash -s uninstall

After installation, use 'pocketagent' command to manage your agent.
EOF
}

# ══════════════════════════════════════════════════════════════
# MAIN
# ══════════════════════════════════════════════════════════════

case "${1:-install}" in
    install)
        cmd_install
        ;;
    update)
        cmd_update
        ;;
    workspace-update)
        cmd_workspace_update
        ;;
    uninstall)
        cmd_uninstall
        ;;
    help|--help|-h)
        cmd_help
        ;;
    *)
        echo "❌ Unknown command: $1"
        cmd_help
        exit 1
        ;;
esac
