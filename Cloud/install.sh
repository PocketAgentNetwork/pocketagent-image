#!/bin/bash
set -e

echo "📟 PocketAgent Quick Installer"
echo "=============================="
echo ""

# Create directory
mkdir -p pocketagent
cd pocketagent

# Download files
echo "📥 Downloading configuration files..."
curl -fsSL https://raw.githubusercontent.com/PocketAgentNetwork/pocketagent-image/main/Cloud/docker-compose.yml -o docker-compose.yml
curl -fsSL https://raw.githubusercontent.com/PocketAgentNetwork/pocketagent-image/main/Cloud/setup.sh -o setup.sh
chmod +x setup.sh

echo "✅ Files downloaded!"
echo ""
echo "📋 Next steps:"
echo ""
echo "1. Run setup:"
echo "   ./setup.sh"
echo ""
echo "2. Start PocketAgent:"
echo "   docker compose up -d"
echo ""
echo "3. Open in browser:"
echo "   http://localhost:18789"
echo ""
