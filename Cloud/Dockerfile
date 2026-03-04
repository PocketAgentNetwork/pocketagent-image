FROM node:22-bookworm

# ══════════════════════════════════════════════════════════════
# 📟 POCKETAGENT CLOUD IMAGE
# ══════════════════════════════════════════════════════════════
# Full-featured AI agent environment with:
# - Node.js + Python runtimes
# - Chrome browser (web automation)
# - FFmpeg + ImageMagick (media processing)
# - Pandoc (document conversion)
# - Build tools (compile native packages)
# - SSH, networking, database tools
# - And more...
#
# The agent can:
# - Browse the web and automate tasks
# - Process images, audio, video
# - Convert documents between formats
# - Run Python/Node scripts
# - Connect to servers via SSH
# - Install additional tools on the fly (sudo access)
# ══════════════════════════════════════════════════════════════

# ── OpenClaw Version ──
# Set which OpenClaw release to use
# Override at build time: docker build --build-arg OPENCLAW_VERSION=v2026.3.2
ARG OPENCLAW_VERSION=v2026.3.2

# ── System Tools ──
# Full dev environment for the agent
RUN apt-get update && apt-get install -y \
    # ── Core Utilities ──
    socat \
    curl \
    wget \
    git \
    jq \
    unzip \
    zip \
    tree \
    htop \
    less \
    file \
    nano \
    vim \
    sudo \
    cron \
    # ── SSH (client — so the agent can connect to other machines) ──
    openssh-client \
    # ── Build Tools (compile native packages, Rust crates, etc.) ──
    build-essential \
    pkg-config \
    libssl-dev \
    cmake \
    # ── Python ──
    python3 \
    python3-pip \
    python3-venv \
    # ── Networking ──
    dnsutils \
    iputils-ping \
    net-tools \
    ca-certificates \
    # ── File Sync & Transfer ──
    rsync \
    # ── Database ──
    sqlite3 \
    # ── Archives ──
    xz-utils \
    bzip2 \
    tar \
    gzip \
    # ── Security / Crypto ──
    gnupg \
    # ── Terminal Multiplexer (persistent sessions) ──
    tmux \
    screen \
    # ── Media Processing ──
    ffmpeg \
    imagemagick \
    # ── Document Conversion ──
    pandoc \
    # ── Browser Support (Chrome/Puppeteer) ──
    libnss3 \
    libxss1 \
    libasound2 \
    libatk-bridge2.0-0 \
    libgtk-3-0 \
    libgbm-dev \
    fonts-liberation \
    libayatana-appindicator3-1 \
    lsb-release \
    xdg-utils \
    && rm -rf /var/lib/apt/lists/*

# ── Install Google Chrome Stable (amd64 only) ──
# Chrome is not available for ARM, skip on ARM builds
RUN if [ "$(dpkg --print-architecture)" = "amd64" ]; then \
        curl -fsSL https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmor -o /usr/share/keyrings/google-chrome.gpg && \
        echo "deb [arch=amd64 signed-by=/usr/share/keyrings/google-chrome.gpg] http://dl.google.com/linux/chrome/deb/ stable main" | tee /etc/apt/sources.list.d/google-chrome.list && \
        apt-get update && \
        apt-get install -y google-chrome-stable && \
        rm -rf /var/lib/apt/lists/*; \
    else \
        echo "Skipping Chrome installation on ARM architecture"; \
    fi

# ── Allow the node user to sudo (install packages on the fly) ──
RUN echo "node ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# ── PocketAgent Directory Structure ──
# OpenClaw is hidden inside /pocketagent/lib/openclaw/
# Users only see "PocketAgent"
RUN mkdir -p /pocketagent/lib /pocketagent/bin /data /logs

# ── Clone and build OpenClaw (hidden in lib/) ──
WORKDIR /pocketagent/lib/openclaw
# Clone OpenClaw and checkout specific release tag
RUN git clone https://github.com/openclaw/openclaw.git . && \
    git checkout ${OPENCLAW_VERSION} && \
    echo ${OPENCLAW_VERSION} > /pocketagent/OPENCLAW_VERSION && \
    corepack enable && \
    pnpm install --frozen-lockfile && \
    pnpm build && \
    pnpm ui:install && \
    pnpm ui:build

# ── Create PocketAgent wrapper script ──
# This is what users run - it calls OpenClaw internally
RUN echo '#!/bin/bash' > /pocketagent/bin/pocketagent && \
    echo 'cd /pocketagent/lib/openclaw' >> /pocketagent/bin/pocketagent && \
    echo 'exec node dist/index.js "$@"' >> /pocketagent/bin/pocketagent && \
    chmod +x /pocketagent/bin/pocketagent

# Add PocketAgent to PATH
ENV PATH="/pocketagent/bin:${PATH}"

# ── Home directory setup ──
# Persistent volume for agent's home directory
ENV HOME=/home/node
RUN mkdir -p /home/node/.openclaw \
    /home/node/.local/bin \
    /home/node/.ssh \
    /home/node/.config \
    /home/node/files \
    && chmod 700 /home/node/.ssh \
    && chown -R node:node /home/node

# Include user-installed tools in PATH
ENV PATH="/home/node/.local/bin:/home/node/.cargo/bin:${PATH}"

# ── Startup script ──
COPY Cloud/entrypoint.sh /pocketagent/entrypoint.sh
RUN chmod +x /pocketagent/entrypoint.sh

# ── Bake PocketAgent workspace into image (for seeding) ──
COPY workspace /pocketagent/workspace_init

# ── Verify workspace was copied correctly ──
RUN echo "📦 Verifying workspace structure..." && \
    ls -la /pocketagent/workspace_init/ && \
    test -f /pocketagent/workspace_init/SOUL.md && \
    test -f /pocketagent/workspace_init/IDENTITY.md && \
    test -d /pocketagent/workspace_init/skills && \
    test -d /pocketagent/workspace_init/agents && \
    test -d /pocketagent/workspace_init/memory && \
    echo "✅ Workspace structure verified" || \
    (echo "❌ Workspace verification failed" && exit 1)

# ── Set ownership ──
RUN chown -R node:node /pocketagent /data /logs /home/node

# ── Add backup script ──
RUN echo '#!/bin/bash' > /usr/local/bin/backup-pocketagent && \
    echo 'tar -czf /data/backups/pocketagent-$(date +%Y%m%d-%H%M%S).tar.gz \' >> /usr/local/bin/backup-pocketagent && \
    echo '  /home/node/.openclaw \' >> /usr/local/bin/backup-pocketagent && \
    echo '  /home/node/files' >> /usr/local/bin/backup-pocketagent && \
    chmod +x /usr/local/bin/backup-pocketagent && \
    mkdir -p /data/backups

# ── Switch to node user ──
USER node

# ── Runtime ──
EXPOSE 18789
ENV NODE_ENV=production

# ── Health check ──
HEALTHCHECK --interval=30s --timeout=10s --retries=3 --start-period=40s \
  CMD curl -f http://localhost:18789/health || exit 1

ENTRYPOINT ["/pocketagent/entrypoint.sh"]
CMD ["pocketagent", "gateway"]
