#!/bin/bash
set -e

echo "🤖 PocketAgent Cloud Container Setup"
echo "====================================="
echo ""

# Check if .env already exists
if [ -f .env ]; then
    echo "⚠️  .env file already exists!"
    read -p "Do you want to overwrite it? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Setup cancelled."
        exit 0
    fi
fi

# Generate gateway token
echo "🔐 Generating secure gateway token..."
TOKEN=$(openssl rand -hex 32)
if [ -z "$TOKEN" ]; then
    echo "❌ Failed to generate token. Please install openssl."
    exit 1
fi

# Create .env from template
echo "📝 Creating .env file..."
cat > .env << EOF
# PocketAgent Cloud Container Configuration
# Generated: $(date)

# Gateway Configuration
OPENCLAW_GATEWAY_TOKEN=$TOKEN
OPENCLAW_GATEWAY_PORT=18789
OPENCLAW_GATEWAY_BIND=lan

# Container Metadata (optional)
# POCKETAGENT_USER_ID=
# POCKETAGENT_CONTAINER_ID=
# POCKETAGENT_REGION=

# Feature Flags (optional)
# ENABLE_WEB_SEARCH=true
# ENABLE_CODE_EXECUTION=true
EOF

echo "✅ Configuration file created"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔑 Your Gateway Token:"
echo "   $TOKEN"
echo ""
echo "   Keep this secret! You'll need it to connect your client."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# ── Setup CLI Alias ──
echo "� Setting up 'pocketagent' command alias..."

ALIAS_CMD='alias pocketagent="docker exec -it pocketagent node /pocketagent/lib/openclaw/dist/index.js"'

# Detect shell and add alias
if [ -f ~/.bashrc ]; then
    if ! grep -q "alias pocketagent=" ~/.bashrc; then
        echo "$ALIAS_CMD" >> ~/.bashrc
        echo "✅ Added alias to ~/.bashrc"
    else
        echo "✅ Alias already exists in ~/.bashrc"
    fi
fi

if [ -f ~/.zshrc ]; then
    if ! grep -q "alias pocketagent=" ~/.zshrc; then
        echo "$ALIAS_CMD" >> ~/.zshrc
        echo "✅ Added alias to ~/.zshrc"
    else
        echo "✅ Alias already exists in ~/.zshrc"
    fi
fi

echo ""
echo "📋 Next Steps:"
echo ""
echo "1. Start PocketAgent:"
echo "   docker compose up --build -d"
echo ""
echo "2. Reload your shell to use 'pocketagent' command:"
echo "   source ~/.bashrc  # or source ~/.zshrc"
echo ""
echo "3. Open in browser:"
echo "   http://localhost:18789"
echo ""
echo "4. Complete onboarding in the web UI:"
echo "   - Set agent name and identity"
echo "   - Add your API keys:"
echo "     • Ollama Cloud (Recommended): https://ollama.com/settings/keys"
echo "     • Or OpenAI, Anthropic, Google, etc."
echo "   - Configure integrations (optional)"
echo ""
echo "5. Use the CLI:"
echo "   pocketagent models status"
echo "   pocketagent doctor --fix"
echo ""
echo "6. Check logs:"
echo "   docker compose logs -f"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "💡 Recommended: Use Ollama Cloud for powerful models without GPU"
echo "   Models: kimi-k2.5, minimax-m2.5, glm-5, qwen3-coder"
echo "   Cost: ~$1-5/month for typical usage"
echo "   Sign up: https://ollama.com"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "3. Open in browser:"
echo "   http://localhost:18789"
echo ""
echo "4. Complete onboarding in the web UI:"
echo "   - Set agent name and identity"
echo "   - Add your API keys (OpenAI, Anthropic, etc.)"
echo "   - Configure integrations (optional)"
echo ""
echo "5. Use the CLI:"
echo "   pocketagent models status"
echo "   pocketagent doctor --fix"
echo ""
echo "6. Check logs:"
echo "   docker compose logs -f"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "� Note:"
echo "   API keys are configured through the web UI during onboarding."
echo "   No need to manually edit .env for API keys!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
