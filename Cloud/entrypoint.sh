#!/bin/bash
set -e

echo "🤖 PocketAgent starting up..."

# ── Ensure directory structure exists ──
mkdir -p /home/node/.openclaw/workspace
mkdir -p /home/node/.local/bin
mkdir -p /home/node/files
mkdir -p /data
mkdir -p /logs

# ── Seed Workspace (First Run) ──
# If the persistent workspace is empty, populate it from the image
if [ -z "$(ls -A /home/node/.openclaw/workspace)" ]; then
    echo "🌱 Initializing PocketAgent workspace from image..."
    if [ -d "/pocketagent/workspace_init" ]; then
        cp -r /pocketagent/workspace_init/* /home/node/.openclaw/workspace/
        echo "✅ PocketAgent workspace seeded."
    else
        echo "⚠️ No baked workspace found at /pocketagent/workspace_init"
    fi
else
    echo "💾 Persistent workspace found. Skipping initialization."
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
