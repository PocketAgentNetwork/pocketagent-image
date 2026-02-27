# 📟 PocketAgent Commands Cheat Sheet

Quick reference for managing PocketAgent on your VPS.

---

## 📟 PocketAgent Commands (User-Facing)

These commands use the `pocketagent` alias (no Docker knowledge needed).

**Setup alias first:**
```bash
# The setup.sh script adds this automatically, or add manually:
alias pocketagent="docker exec -it pocketagent node /pocketagent/lib/openclaw/dist/index.js"

# Reload shell
source ~/.bashrc  # or source ~/.zshrc
```

### Agent Management
```bash
# Check model status
pocketagent models status

# Switch models
pocketagent model kimi
pocketagent model minimax

# Run diagnostics
pocketagent doctor --fix

# View help
pocketagent --help
```

---

## 🐳 Docker Management (Infrastructure)

These commands manage the Docker container itself.

## 📦 Container Management

### Start Container
```bash
# Start in background
docker compose up -d

# Start and rebuild image
docker compose up --build -d

# Start specific user container (production)
CONTAINER_NAME=pocketagent-user123 VOLUME_PREFIX=user123 docker compose up -d
```

### Stop Container
```bash
# Stop container
docker compose down

# Stop and remove volumes (⚠️ deletes all data!)
docker compose down -v

# Stop specific container
docker stop pocketagent
```

### Restart Container
```bash
# Restart
docker compose restart

# Restart specific container
docker restart pocketagent
```

---

## 📊 Monitoring & Logs

### View Logs
```bash
# View all logs
docker compose logs

# Follow logs (live tail)
docker compose logs -f

# Last 100 lines
docker compose logs --tail=100

# Logs for specific container
docker logs pocketagent

# Follow logs with timestamps
docker logs -f --timestamps pocketagent
```

### Check Status
```bash
# List running containers
docker ps

# List all containers (including stopped)
docker ps -a

# Check container health
docker inspect pocketagent | grep -A 10 Health

# Container resource usage (CPU, RAM)
docker stats pocketagent
```

---

## 🔍 Debugging

### Enter Container Shell
```bash
# Open bash shell inside container
docker exec -it pocketagent bash

# Run command as root
docker exec -it -u root pocketagent bash

# Run single command
docker exec pocketagent ls -la /home/node
```

### Inspect Container
```bash
# Full container details
docker inspect pocketagent

# Get container IP
docker inspect pocketagent | grep IPAddress

# Check environment variables
docker exec pocketagent env

# Check running processes
docker exec pocketagent ps aux
```

### Check Files/Volumes
```bash
# List volumes
docker volume ls

# Inspect volume
docker volume inspect pocketagent-home

# Check workspace files
docker exec pocketagent ls -la /home/node/.openclaw/workspace

# View agent config
docker exec pocketagent cat /home/node/.openclaw/config.json
```

---

## 🔄 Updates & Maintenance

### Update Container
```bash
# Pull latest code and rebuild
cd "Product/PocketAgent Image/Cloud"
git pull
docker compose down
docker compose up --build -d

# Or force rebuild without cache
docker compose build --no-cache
docker compose up -d
```

### Clean Up
```bash
# Remove stopped containers
docker container prune

# Remove unused images
docker image prune

# Remove unused volumes (⚠️ careful!)
docker volume prune

# Remove everything unused (⚠️ very careful!)
docker system prune -a
```

### Backup Data
```bash
# Backup volume to tar file
docker run --rm -v pocketagent-home:/data -v $(pwd):/backup \
  ubuntu tar czf /backup/pocketagent-backup.tar.gz /data

# Restore from backup
docker run --rm -v pocketagent-home:/data -v $(pwd):/backup \
  ubuntu tar xzf /backup/pocketagent-backup.tar.gz -C /
```

---

## 🏭 Production Multi-User Management

### List All User Containers
```bash
# List all PocketAgent containers
docker ps --filter "name=pocketagent"

# With resource usage
docker stats $(docker ps --filter "name=pocketagent" -q)
```

### Start Multiple Users
```bash
# User 1
CONTAINER_NAME=pocketagent-user123 VOLUME_PREFIX=user123 PORT_BIND="" \
  docker compose up -d

# User 2
CONTAINER_NAME=pocketagent-user456 VOLUME_PREFIX=user456 PORT_BIND="" \
  docker compose up -d

# User 3
CONTAINER_NAME=pocketagent-user789 VOLUME_PREFIX=user789 PORT_BIND="" \
  docker compose up -d
```

### Stop Specific User
```bash
docker stop pocketagent-user123
docker rm pocketagent-user123
```

### Check User's Logs
```bash
docker logs -f pocketagent-user123
```

---

## 🚨 Troubleshooting

### Container Won't Start
```bash
# Check logs for errors
docker compose logs

# Check if port is already in use
sudo lsof -i :18789

# Check disk space
df -h

# Check Docker daemon
sudo systemctl status docker
```

### Container Keeps Restarting
```bash
# Check restart count
docker ps -a

# View last crash logs
docker logs --tail=50 pocketagent

# Disable auto-restart temporarily
docker update --restart=no pocketagent
```

### High Resource Usage
```bash
# Check what's using resources
docker stats

# Limit resources (edit docker-compose.yml)
# Uncomment the deploy.resources section

# Restart with limits
docker compose down
docker compose up -d
```

### Can't Connect to Container
```bash
# Check if container is running
docker ps | grep pocketagent

# Check port binding
docker port pocketagent

# Check firewall
sudo ufw status

# Test connection
curl http://localhost:18789/health
```

---

## 🔐 Security

### View Container Permissions
```bash
# Check user running inside container
docker exec pocketagent whoami

# Check sudo access
docker exec pocketagent sudo -l
```

### Update Gateway Token
```bash
# Generate new token
openssl rand -hex 32

# Update .env file
nano .env

# Restart container
docker compose restart
```

---

## 📈 Performance

### Monitor Resource Usage
```bash
# Real-time stats
docker stats pocketagent

# Historical stats (if monitoring enabled)
docker stats --no-stream pocketagent
```

### Check Container Size
```bash
# Image size
docker images | grep pocketagent

# Container size
docker ps -s | grep pocketagent
```

---

## 💡 Quick Tips

- Always use `docker compose` (not `docker-compose`) - it's the newer version
- Use `-d` flag to run in background (detached mode)
- Use `-f` flag to follow logs in real-time
- Use `--tail=N` to limit log output
- Use `docker exec -it` for interactive shell
- Always backup volumes before major updates
- Check logs first when troubleshooting

---

## 🆘 Emergency Commands

### Force Stop Everything
```bash
docker stop $(docker ps -q)
```

### Force Remove Everything
```bash
docker rm -f $(docker ps -aq)
```

### Restart Docker Daemon
```bash
sudo systemctl restart docker
```

### Check Docker Disk Usage
```bash
docker system df
```

---

**Need more help?** Check the main [README.md](README.md) or OpenClaw documentation.
