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
    cd /pocketagent/lib/openclaw
    node dist/index.js doctor --fix 2>/dev/null || echo "⚠️  Config validation skipped (will use defaults)"
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
