# Forking PocketAgent Image

If you've forked this repo to customize PocketAgent, here's how to set it up.

---

## Option 1: Use Official Images (Easiest)

Even if you fork the repo, you can still use the official pre-built images:

```bash
# Just run setup and start
./setup.sh
docker compose up -d
```

This pulls from `ghcr.io/pocketagentnetwork/pocketagent-image` automatically.

**Use this if:** You only want to customize workspace files (SOUL.md, skills, etc.) but not the core container.

---

## Option 2: Build Your Own Images

If you've modified the Dockerfile or want to build from your fork:

### Local Build (No Registry)

```bash
# Edit docker-compose.yml
# Comment out the 'image:' line
# Uncomment the 'build: .' line

# Then build and run
docker compose up --build -d
```

### Push to Your Own Registry

1. **Update GitHub Actions workflow:**

```bash
# The workflow uses ${{ github.repository }} automatically
# So it will push to: ghcr.io/yourusername/pocketagent-image
```

2. **Update your .env:**

```bash
# Add this to .env
POCKETAGENT_IMAGE=ghcr.io/yourusername/pocketagent-image
POCKETAGENT_VERSION=latest
```

3. **Push a version tag:**

```bash
git tag v1.0.0
git push origin v1.0.0
```

4. **GitHub Actions will:**
   - Build your custom image
   - Push to `ghcr.io/yourusername/pocketagent-image`

5. **On your VPS:**

```bash
# Pull your custom image
docker compose pull
docker compose up -d
```

---

## Option 3: Use Docker Hub Instead

If you prefer Docker Hub over GitHub Container Registry:

1. **Update docker-compose.yml:**

```yaml
image: ${POCKETAGENT_IMAGE:-yourusername/pocketagent}:${POCKETAGENT_VERSION:-latest}
```

2. **Update GitHub Actions workflow:**

```yaml
env:
  REGISTRY: docker.io
  IMAGE_NAME: yourusername/pocketagent
```

3. **Add Docker Hub credentials to GitHub Secrets:**
   - Go to repo Settings → Secrets → Actions
   - Add `DOCKERHUB_USERNAME`
   - Add `DOCKERHUB_TOKEN`

4. **Update login step in workflow:**

```yaml
- name: Log in to Docker Hub
  uses: docker/login-action@v3
  with:
    username: ${{ secrets.DOCKERHUB_USERNAME }}
    password: ${{ secrets.DOCKERHUB_TOKEN }}
```

---

## What Gets Customized?

When you fork, you typically customize:

- `workspace/SOUL.md` - Agent personality
- `workspace/skills/` - Custom skills
- `workspace/agents/` - Sub-agents
- `Cloud/Dockerfile` - Container setup
- `Cloud/entrypoint.sh` - Startup logic

The official images get updates to:
- OpenClaw framework
- System files (AGENTS.md, BOOTSTRAP.md, etc.)
- Security patches

---

## Private Repos & Container Registry

**If your repo is private:**

The container registry (ghcr.io) will also be private by default. You have 3 options:

### Option 1: Make Container Package Public (Recommended)

Even with a private repo, you can make the container image public:

1. Go to: `https://github.com/yourusername?tab=packages`
2. Click on `pocketagent-image`
3. Package settings → Change visibility → Public

Now anyone can pull without authentication!

### Option 2: Authenticate to Pull

Users need to login before pulling:

```bash
# Create GitHub Personal Access Token with read:packages scope
# At: https://github.com/settings/tokens

# Login to registry
echo YOUR_TOKEN | docker login ghcr.io -u yourusername --password-stdin

# Now pull works
docker compose pull
docker compose up -d
```

### Option 3: Build Locally

Skip the registry entirely:

```yaml
# In docker-compose.yml
services:
  pocketagent:
    build: .  # Build from Dockerfile
    # image: ghcr.io/...  # Comment this out
```

Then:
```bash
docker compose up --build -d
```

---

## Staying Updated

If you want to merge updates from the official repo:

```bash
# Add official repo as upstream
git remote add upstream https://github.com/PocketAgentNetwork/pocketagent-image.git

# Fetch updates
git fetch upstream

# Merge updates (resolve conflicts if any)
git merge upstream/main

# Push to your fork
git push origin main
```

---

## Questions?

- Using official images? No setup needed!
- Building custom? Set `POCKETAGENT_IMAGE` in .env
- Need help? Open an issue on GitHub

---

**TL;DR:** Fork doesn't break anything - it still uses official images by default. Only customize if you're modifying the container itself!
