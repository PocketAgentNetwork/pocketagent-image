# Ollama Local (Self-Hosted) for PocketAgent

## Overview

Running Ollama locally means downloading and running models on your own hardware instead of using Ollama's cloud API. This eliminates API costs but requires GPU/CPU resources.

## When to Use Local vs Cloud

### Use Ollama Cloud (Recommended)
- ✅ No GPU required
- ✅ No infrastructure management
- ✅ Access to all models instantly
- ✅ Pay only for what you use
- ✅ No storage concerns
- ❌ Ongoing API costs
- ❌ Requires internet

### Use Ollama Local (Self-Hosted)
- ✅ Zero API costs after setup
- ✅ Works offline
- ✅ Full data privacy
- ✅ Good for high-volume usage
- ❌ Requires GPU (or slow CPU)
- ❌ Large disk space (2-10GB per model)
- ❌ Infrastructure management
- ❌ Limited to models that fit in memory

## Cost Comparison

**Ollama Cloud:**
- $0 infrastructure
- Pay per token (competitive rates)
- Example: ~$0.50-2.00 per million tokens

**Ollama Local:**
- GPU server: $50-500/month (or one-time hardware cost)
- Electricity costs
- Storage costs
- $0 per token after setup
- **Break-even:** High usage (millions of tokens/month)

## Hardware Requirements

### Minimum (CPU-only)
- 8GB RAM
- 20GB disk space
- Very slow inference (not recommended)

### Recommended (GPU)
- NVIDIA GPU with 8GB+ VRAM (for 7B models)
- 16GB+ VRAM (for 13B models)
- 24GB+ VRAM (for 30B+ models)
- 16GB system RAM
- 50GB+ disk space

### Model Size Guide
| Model Size | VRAM Needed | Disk Space | Speed |
|------------|-------------|------------|-------|
| 1B params  | 2GB         | 1.3GB      | Fast  |
| 3B params  | 4GB         | 2GB        | Fast  |
| 7B params  | 8GB         | 4GB        | Good  |
| 13B params | 16GB        | 7GB        | Good  |
| 30B params | 24GB        | 15GB       | Slow  |
| 70B params | 48GB+       | 40GB       | Very Slow |

## Docker Setup (Shared Ollama Service)

For multi-tenant PocketAgent deployment, run one shared Ollama instance:

### docker-compose.yml

```yaml
services:
  pocketagent:
    build: .
    container_name: ${CONTAINER_NAME:-pocketagent}
    hostname: ${CONTAINER_NAME:-pocketagent}
    restart: unless-stopped
    environment:
      - OLLAMA_HOST=http://ollama:11434
    networks:
      - pocketagent
    volumes:
      - ${VOLUME_PREFIX:-pocketagent}-home:/home/node
      - ${VOLUME_PREFIX:-pocketagent}-data:/data
      - ${VOLUME_PREFIX:-pocketagent}-logs:/logs

  # Shared Ollama service
  ollama:
    image: ollama/ollama:latest
    container_name: ollama
    hostname: ollama
    restart: unless-stopped
    volumes:
      - ollama-models:/root/.ollama
    networks:
      - pocketagent
    ports:
      - "11434:11434"
    
    # GPU support (NVIDIA)
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: all
              capabilities: [gpu]
        limits:
          cpus: "4.0"
          memory: "16G"
    
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:11434/api/tags"]
      interval: 30s
      timeout: 10s
      retries: 3

networks:
  pocketagent:
    driver: bridge

volumes:
  ollama-models:
    name: ollama-models
  ${VOLUME_PREFIX:-pocketagent}-home:
    name: ${VOLUME_PREFIX:-pocketagent}-home
  ${VOLUME_PREFIX:-pocketagent}-data:
    name: ${VOLUME_PREFIX:-pocketagent}-data
  ${VOLUME_PREFIX:-pocketagent}-logs:
    name: ${VOLUME_PREFIX:-pocketagent}-logs
```

### GPU Setup (NVIDIA)

Install NVIDIA Container Toolkit on host:

```bash
# Ubuntu/Debian
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | \
  sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg

curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
  sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
  sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

sudo apt-get update
sudo apt-get install -y nvidia-container-toolkit
sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker

# Verify
docker run --rm --gpus all nvidia/cuda:12.0-base nvidia-smi
```

### Start Services

```bash
# Start everything
docker compose up -d

# Check Ollama is running
docker exec ollama ollama list

# Pull models
docker exec ollama ollama pull llama3.2:3b
docker exec ollama ollama pull mistral:7b
docker exec ollama ollama pull codellama:7b

# Check GPU usage
docker exec ollama nvidia-smi
```

## Model Management

### Pull Models

```bash
# Small models (good for testing)
docker exec ollama ollama pull llama3.2:1b    # 1.3GB
docker exec ollama ollama pull llama3.2:3b    # 2GB

# Medium models (good balance)
docker exec ollama ollama pull mistral:7b     # 4GB
docker exec ollama ollama pull codellama:7b   # 4GB

# Large models (requires more VRAM)
docker exec ollama ollama pull llama3.2:70b   # 40GB
```

### List Models

```bash
docker exec ollama ollama list
```

### Remove Models

```bash
docker exec ollama ollama rm llama3.2:70b
```

### Check Disk Usage

```bash
docker exec ollama du -sh /root/.ollama
```

## OpenClaw Configuration

Configure OpenClaw to use local Ollama:

**`~/.openclaw/openclaw.json`:**

```json
{
  "agents": {
    "defaults": {
      "model": {
        "primary": "ollama/llama3.2:3b",
        "fallbacks": ["ollama/mistral:7b"]
      },
      "models": {
        "ollama/llama3.2:3b": { "alias": "llama" },
        "ollama/mistral:7b": { "alias": "mistral" },
        "ollama/codellama:7b": { "alias": "coder" }
      }
    }
  }
}
```

OpenClaw auto-detects Ollama at `http://ollama:11434` (Docker network) or `http://localhost:11434` (local).

## Recommended Models for PocketAgent

### General Purpose
- `llama3.2:3b` - Good balance (2GB)
- `mistral:7b` - Strong reasoning (4GB)

### Coding
- `codellama:7b` - Specialized for code (4GB)
- `qwen2.5-coder:7b` - Multi-language coding (4GB)

### Lightweight
- `llama3.2:1b` - Fast, minimal (1.3GB)
- `phi3:mini` - Efficient (2GB)

### Embeddings (for RAG)
- `nomic-embed-text` - Best for search (274MB)

## CPU-Only Mode

If you don't have a GPU, remove the `deploy` section from docker-compose.yml:

```yaml
ollama:
  image: ollama/ollama:latest
  # ... other config ...
  # No deploy section = CPU only
  environment:
    - OLLAMA_NUM_PARALLEL=2  # Limit concurrent requests
```

**Warning:** CPU inference is 10-50x slower than GPU. Only use for testing or very low usage.

## Monitoring

### Check Running Models

```bash
docker exec ollama ollama ps
```

### Check Resource Usage

```bash
# GPU usage
docker exec ollama nvidia-smi

# Memory usage
docker stats ollama

# Disk usage
docker exec ollama df -h /root/.ollama
```

### Logs

```bash
docker logs -f ollama
```

## Hybrid Setup (Local + Cloud)

You can use both local and cloud models:

```json
{
  "agents": {
    "defaults": {
      "model": {
        "primary": "ollama/llama3.2:3b",
        "fallbacks": [
          "ollama/kimi-k2.5:cloud",
          "anthropic/claude-sonnet-4-5"
        ]
      }
    }
  },
  "models": {
    "providers": {
      "ollama": {
        "baseUrl": "http://ollama:11434",
        "api": "openai-completions"
      }
    }
  }
}
```

This gives you:
- Local models for routine tasks (free)
- Cloud models for complex tasks (paid)
- Best of both worlds

## Troubleshooting

### Model Won't Load

```bash
# Check available memory
docker exec ollama free -h

# Check GPU memory
docker exec ollama nvidia-smi

# Try smaller model
docker exec ollama ollama pull llama3.2:1b
```

### Slow Performance

- Use GPU instead of CPU
- Use smaller models (3B instead of 7B)
- Reduce concurrent requests
- Check GPU utilization with `nvidia-smi`

### Out of Disk Space

```bash
# Remove unused models
docker exec ollama ollama rm <model>

# Check disk usage
docker exec ollama du -sh /root/.ollama

# Prune Docker volumes (careful!)
docker volume prune
```

### Container Won't Start

```bash
# Check logs
docker logs ollama

# Verify GPU access
docker run --rm --gpus all nvidia/cuda:12.0-base nvidia-smi

# Restart Docker
sudo systemctl restart docker
```

## Cost Analysis Example

**Scenario:** 10 million tokens/month

**Ollama Cloud:**
- Cost: ~$5-20/month (depending on model)
- No infrastructure costs
- Total: $5-20/month

**Ollama Local:**
- GPU server: $100/month (or $2000 one-time for hardware)
- Electricity: ~$20/month
- Total: $120/month (or $20/month after hardware paid off)

**Break-even:** ~50-100 million tokens/month

## Conclusion

**Use Ollama Cloud if:**
- You don't have GPU hardware
- Usage is low-to-medium
- You want simplicity
- You need access to all models

**Use Ollama Local if:**
- You have GPU hardware
- Usage is very high (millions of tokens/month)
- You need offline capability
- You need full data privacy
- You're willing to manage infrastructure

**For most PocketAgent users, Ollama Cloud is the better choice.**
