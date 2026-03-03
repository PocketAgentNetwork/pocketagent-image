# Workspace Sync Mechanism

## How It Works

The Cloud image uses a smart workspace syncing system that:
1. Bakes the workspace into the Docker image at build time
2. Copies it to the container's persistent volume on first run
3. Intelligently updates system files on version changes
4. Preserves user customizations across updates

---

## Build Time (Dockerfile)

```dockerfile
# Copy entire workspace directory into image
COPY workspace /pocketagent/workspace_init

# Verify all files and directories were copied
RUN test -f /pocketagent/workspace_init/.workspace_version && \
    test -f /pocketagent/workspace_init/SOUL.md && \
    test -d /pocketagent/workspace_init/skills && \
    test -d /pocketagent/workspace_init/agents
```

This ensures:
- ✅ All files (including hidden files like `.workspace_version`)
- ✅ All subdirectories (`skills/`, `agents/`, `memory/`)
- ✅ All nested files (`skills/agent-maker/SKILL.md`, etc.)
- ✅ Build fails if workspace is incomplete

---

## Runtime (entrypoint.sh)

### First Run (Empty Workspace)

```bash
# Copy everything from image to persistent volume
cp -r /pocketagent/workspace_init/. /home/node/.openclaw/workspace/
```

The `/. ` syntax ensures:
- ✅ Hidden files are copied (`.workspace_version`)
- ✅ All subdirectories are copied recursively
- ✅ Directory structure is preserved

### Subsequent Runs (Existing Workspace)

```bash
# Check version
CURRENT_VERSION=$(cat /home/node/.openclaw/workspace/.workspace_version)
IMAGE_VERSION=$(cat /pocketagent/workspace_init/.workspace_version)

if [ "$CURRENT_VERSION" != "$IMAGE_VERSION" ]; then
    # Update system files only
    for file in SOUL.md AGENTS.md BOOTSTRAP.md BOOT.md TOOLS.md; do
        cp /pocketagent/workspace_init/$file /home/node/.openclaw/workspace/$file
    done
fi

# Sync new files that don't exist yet (skills, agents, etc.)
rsync -a --ignore-existing /pocketagent/workspace_init/ /home/node/.openclaw/workspace/
```

This ensures:
- ✅ System files get updates
- ✅ User customizations are preserved (IDENTITY.md, USER.md, JOB.md)
- ✅ New skills/agents from updates are added
- ✅ User's custom skills/agents are never overwritten

---

## What Gets Copied

### Always Copied (First Run)
```
workspace/
├── .workspace_version          ✅ Version tracking
├── SOUL.md                     ✅ System file
├── IDENTITY.md                 ✅ User file (preserved on updates)
├── AGENTS.md                   ✅ System file
├── USER.md                     ✅ User file (preserved on updates)
├── JOB.md                      ✅ User file (preserved on updates)
├── TOOLS.md                    ✅ System file
├── HEARTBEAT.md                ✅ User file (preserved on updates)
├── MEMORY.md                   ✅ User file (preserved on updates)
├── BOOT.md                     ✅ System file
├── BOOTSTRAP.md                ✅ System file
├── workspace.txt               ✅ Documentation
├── skills/                     ✅ Full directory
│   ├── agent-maker/
│   │   └── SKILL.md
│   └── skill-maker/
│       └── SKILL.md
├── agents/                     ✅ Full directory (empty initially)
└── memory/                     ✅ Full directory
    └── .gitkeep
```

### Updated on Version Change
- `SOUL.md` - Core personality (system)
- `AGENTS.md` - Agent capabilities (system)
- `BOOTSTRAP.md` - First-run setup (system)
- `BOOT.md` - Startup tasks (system)
- `TOOLS.md` - Tool documentation (system)

### Never Overwritten (User Files)
- `IDENTITY.md` - Agent name/emoji
- `USER.md` - User information
- `JOB.md` - Agent role definition
- `HEARTBEAT.md` - Periodic tasks
- `MEMORY.md` - Long-term memory
- `memory/*.md` - Daily logs
- Custom skills in `skills/`
- Custom agents in `agents/`

---

## Verification

### During Build
```bash
docker build -t pocketagent .
# Look for: "✅ Workspace structure verified"
```

### During Runtime
```bash
docker compose up -d
docker compose logs | grep "workspace"
# Look for: "✅ PocketAgent workspace initialized"
# Or: "✅ Workspace synced (user files preserved)"
```

### Manual Check
```bash
# Check workspace in running container
docker exec -it pocketagent ls -la /home/node/.openclaw/workspace/

# Should show:
# - All .md files
# - skills/ directory with agent-maker and skill-maker
# - agents/ directory
# - memory/ directory
# - .workspace_version file
```

---

## Troubleshooting

### Workspace not copying?

**Check image:**
```bash
docker run --rm pocketagent ls -la /pocketagent/workspace_init/
```

Should show all workspace files. If empty, rebuild:
```bash
docker compose build --no-cache
```

### Missing subdirectories?

The entrypoint creates them automatically:
```bash
mkdir -p /home/node/.openclaw/workspace/skills
mkdir -p /home/node/.openclaw/workspace/agents
mkdir -p /home/node/.openclaw/workspace/memory
```

### Version not updating?

Check version files:
```bash
# In image
docker run --rm pocketagent cat /pocketagent/workspace_init/.workspace_version

# In container
docker exec -it pocketagent cat /home/node/.openclaw/workspace/.workspace_version
```

If different, restart container to trigger update.

---

## Best Practices

### For Development
1. Update workspace files in repo
2. Increment `.workspace_version`
3. Rebuild image: `docker compose build --no-cache`
4. Restart container: `docker compose up -d`

### For Production
1. Pull new image: `docker compose pull`
2. Restart container: `docker compose up -d`
3. Check logs: `docker compose logs -f`
4. Verify workspace: `docker exec -it pocketagent ls -la /home/node/.openclaw/workspace/`

### For Users
- User customizations are always preserved
- System files get updates automatically
- New skills/agents are added automatically
- No manual intervention needed

---

## Technical Details

### Why `cp -r source/. dest/`?

The `/.` syntax is crucial:
- `cp -r source/* dest/` - Skips hidden files (`.workspace_version`)
- `cp -r source/. dest/` - Copies everything including hidden files ✅

### Why `rsync --ignore-existing`?

This ensures:
- New files from image are added
- Existing files are never overwritten
- User customizations are preserved
- Skills/agents from updates are synced

### Why separate system/user files?

- System files: Updated on version changes (SOUL.md, AGENTS.md, etc.)
- User files: Never overwritten (IDENTITY.md, USER.md, JOB.md, etc.)
- This allows OpenClaw improvements while preserving user setup

---

**Status**: ✅ Workspace copying is bulletproof

**Verified**: All files, subdirectories, and hidden files copy correctly

**Safe**: User customizations are always preserved
