#!/bin/bash
set -e

echo "📟 PocketAgent starting up..."

# ── Ensure directory structure exists ──
mkdir -p /home/node/.openclaw/workspace
mkdir -p /home/node/.local/bin
mkdir -p /home/node/files
mkdir -p /data
mkdir -p /logs

# ── Seed Workspace (First Run & Updates) ──
# Copy workspace files from image, but intelligently handle updates
if [ -d "/pocketagent/workspace_init" ]; then
    echo "🌱 Syncing workspace from image..."
    
    WORKSPACE_VERSION_FILE="/home/node/.openclaw/workspace/.workspace_version"
    IMAGE_VERSION_FILE="/pocketagent/workspace_init/.workspace_version"
    
    # Ensure workspace directory exists
    mkdir -p /home/node/.openclaw/workspace
    
    # Check if workspace is empty (first run)
    if [ -z "$(ls -A /home/node/.openclaw/workspace 2>/dev/null)" ]; then
        echo "📦 First run - copying all workspace files..."
        # Copy all files including hidden ones and subdirectories
        cp -r /pocketagent/workspace_init/. /home/node/.openclaw/workspace/
        
        # Ensure subdirectories exist
        mkdir -p /home/node/.openclaw/workspace/skills
        mkdir -p /home/node/.openclaw/workspace/agents
        mkdir -p /home/node/.openclaw/workspace/memory
        
        echo "✅ PocketAgent workspace initialized."
    else
        echo "� Existing workspace found - checking for updates..."
        
        # Get versions
        CURRENT_VERSION=""
        IMAGE_VERSION=""
        [ -f "$WORKSPACE_VERSION_FILE" ] && CURRENT_VERSION=$(cat "$WORKSPACE_VERSION_FILE")
        [ -f "$IMAGE_VERSION_FILE" ] && IMAGE_VERSION=$(cat "$IMAGE_VERSION_FILE")
        
        if [ "$CURRENT_VERSION" != "$IMAGE_VERSION" ] && [ -n "$IMAGE_VERSION" ]; then
            echo "📝 Workspace version changed: $CURRENT_VERSION → $IMAGE_VERSION"
            echo "   Updating system files (preserving user customizations)..."
            
            # System files that should be updated (not user-customized)
            SYSTEM_FILES=(
                "SOUL.md"
                "AGENTS.md"
                "BOOTSTRAP.md"
                "BOOT.md"
                "TOOLS.md"
            )
            
            # Update system files
            for file in "${SYSTEM_FILES[@]}"; do
                if [ -f "/pocketagent/workspace_init/$file" ]; then
                    # Backup existing file
                    if [ -f "/home/node/.openclaw/workspace/$file" ]; then
                        cp "/home/node/.openclaw/workspace/$file" "/home/node/.openclaw/workspace/${file}.backup" 2>/dev/null || true
                    fi
                    # Copy new version
                    cp "/pocketagent/workspace_init/$file" "/home/node/.openclaw/workspace/$file"
                    echo "   ✓ Updated $file (backup saved as ${file}.backup)"
                fi
            done
            
            # Update version file
            cp "$IMAGE_VERSION_FILE" "$WORKSPACE_VERSION_FILE" 2>/dev/null || true
        fi
        
        # Always sync new files/folders that don't exist yet (including skills and agents)
        # This ensures new skills/agents from image updates are added
        rsync -a --ignore-existing /pocketagent/workspace_init/ /home/node/.openclaw/workspace/
        
        # Ensure subdirectories exist
        mkdir -p /home/node/.openclaw/workspace/skills
        mkdir -p /home/node/.openclaw/workspace/agents
        mkdir -p /home/node/.openclaw/workspace/memory
        
        echo "✅ Workspace synced (user files preserved)."
    fi
else
    echo "⚠️ No baked workspace found at /pocketagent/workspace_init"
    echo "   Creating minimal workspace structure..."
    mkdir -p /home/node/.openclaw/workspace/skills
    mkdir -p /home/node/.openclaw/workspace/agents
    mkdir -p /home/node/.openclaw/workspace/memory
fi

# ── Validate and fix config ──
if [ -f "/home/node/.openclaw/openclaw.json" ]; then
    echo "🔍 Validating configuration..."
    
    # Check for invalid typingMode values (common issue)
    if grep -q '"typingMode"' /home/node/.openclaw/openclaw.json; then
        echo "📝 Checking typingMode configuration..."
        # Valid values: "instant", "typing", "realistic"
        if ! grep -qE '"typingMode":\s*"(instant|typing|realistic)"' /home/node/.openclaw/openclaw.json; then
            echo "⚠️  Invalid typingMode detected. Fixing..."
            sed -i 's/"typingMode"[^,]*,/"typingMode": "instant",/g' /home/node/.openclaw/openclaw.json
        fi
    fi
    
    # Check and fix context window if too small
    echo "📝 Checking model context window..."
    CONTEXT_WINDOW=$(grep -o '"contextWindow":[0-9]*' /home/node/.openclaw/openclaw.json | head -1 | cut -d: -f2)
    if [ ! -z "$CONTEXT_WINDOW" ] && [ "$CONTEXT_WINDOW" -lt 16000 ]; then
        echo "⚠️  Context window too small ($CONTEXT_WINDOW tokens). Updating to 128000..."
        cd /pocketagent/lib/openclaw
        node dist/index.js config set models.providers.pocketagent-local.models.0.contextWindow 128000 2>/dev/null || true
        node dist/index.js config set models.providers.pocketagent-local.models.0.maxTokens 128000 2>/dev/null || true
        echo "✅ Context window updated"
    fi
    
    # Run OpenClaw doctor to validate full config
    cd /pocketagent/lib/openclaw
    if node dist/index.js doctor --fix 2>/dev/null; then
        echo "✅ Configuration validated successfully"
    else
        echo "⚠️  Config validation failed. Backing up and using defaults..."
        if [ -f "/home/node/.openclaw/openclaw.json" ]; then
            cp /home/node/.openclaw/openclaw.json /home/node/.openclaw/openclaw.json.backup.$(date +%Y%m%d-%H%M%S)
            rm /home/node/.openclaw/openclaw.json
            echo "📝 Corrupted config backed up. Fresh config will be generated."
        fi
    fi
else
    echo "📝 No existing config found. Will create on first run."
fi

# ── Run user-defined startup commands if they exist ──
CUSTOM_STARTUP="/home/node/.startup.sh"
if [ -f "$CUSTOM_STARTUP" ]; then
    echo "📜 Running custom startup script..."
    source "$CUSTOM_STARTUP"
fi

echo "✅ Ready. Launching PocketAgent..."

# Hand off to the CMD (pocketagent gateway or whatever is passed)
exec "$@"
