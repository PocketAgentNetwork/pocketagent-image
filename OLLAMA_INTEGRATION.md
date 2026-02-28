# Ollama Cloud Integration for 📟 PocketAgent

## What is Ollama Cloud?

Ollama Cloud provides access to powerful open-source models (Kimi K2.5, MiniMax M2.5, GLM-5, etc.) through a simple API - no GPU infrastructure required. Models run on Ollama's cloud infrastructure while you use the same familiar Ollama interface.

**Key Benefits:**
- ✅ No GPU required on your server
- ✅ Access to frontier open models
- ✅ Pay-per-use (no idle costs)
- ✅ Simple API key authentication
- ✅ OpenAI-compatible API
- ✅ Works with OpenClaw out of the box

## Available Cloud Models

**Recommended for PocketAgent:**

| Model | Best For | Notes |
|-------|----------|-------|
| `kimi-k2.5` | General assistant, multimodal | Vision + language, agentic capabilities |
| `minimax-m2.5` | Coding & productivity | State-of-the-art for real-world tasks |
| `minimax-m2` | Agent workflows | High-efficiency coding |
| `glm-5` | Complex reasoning | 744B total params (40B active) |
| `qwen3-coder-next` | Multilingual coding | Optimized for development |
| `qwen3.5` | Multimodal with tools | Vision + tools |
| `gpt-oss:120b` | Large tasks | 120B parameters |
| `deepseek-v3` | Advanced reasoning | Latest DeepSeek |

Full list: https://ollama.com/search?c=cloud

## Setup Guide

### Step 1: Get Ollama API Key

1. Sign up at https://ollama.com
2. Go to https://ollama.com/settings/keys
3. Create a new API key
4. Save it securely

### Step 2: Configure in PocketAgent

Add to your `.env` file:

```bash
OLLAMA_API_KEY=""
```

### Step 3: Configure OpenClaw

OpenClaw will auto-configure Ollama Cloud during onboarding, or you can manually configure:

**`~/.openclaw/openclaw.json`:**

```json
{
  "agents": {
    "defaults": {
      "model": {
        "primary": "ollama/kimi-k2.5",
        "fallbacks": ["ollama/minimax-m2.5"]
      },
      "models": {
        "ollama/kimi-k2.5": { "alias": "kimi" },
        "ollama/minimax-m2.5": { "alias": "minimax" }
      }
    }
  },
  "models": {
    "providers": {
      "ollama": {
        "baseUrl": "https://ollama.com",
        "apiKey": "${OLLAMA_API_KEY}",
        "api": "ollama"
      }
    }
  }
}
```

### Step 4: Test

```bash
# Via OpenClaw CLI
pocketagent models status

# Or test directly
curl https://ollama.com/api/chat \
  -H "Authorization: Bearer $OLLAMA_API_KEY" \
  -d '{
    "model": "kimi-k2.5",
    "messages": [{
      "role": "user",
      "content": "Hello!"
    }],
    "stream": false
  }'
```

## Architecture

```
┌─────────────────────┐
│   PocketAgent       │
│   (OpenClaw)        │
│                     │
│   - Workspace       │
│   - Memory          │
│   - Skills          │
└──────────┬──────────┘
           │
           │ HTTPS API
           │
           ▼
┌─────────────────────┐
│   Ollama Cloud      │
│   (ollama.com)      │
│                     │
│   - kimi-k2.5       │
│   - minimax-m2.5    │
│   - glm-5           │
│   - qwen3-coder     │
└─────────────────────┘
```

**No additional infrastructure needed!**
- No Ollama container
- No GPU requirements
- No model storage
- Just API key configuration

## Use Cases & Model Selection

**General Purpose Assistant:**
```json
{
  "model": {
    "primary": "ollama/kimi-k2.5"
  }
}
```
- Multimodal (vision + text)
- Agentic capabilities
- Good for varied tasks

**Coding & Development:**
```json
{
  "model": {
    "primary": "ollama/minimax-m2.5",
    "fallbacks": ["ollama/qwen3-coder-next"]
  }
}
```
- Optimized for code generation
- Multi-language support
- Tool calling

**Complex Reasoning:**
```json
{
  "model": {
    "primary": "ollama/glm-5"
  }
}
```
- 744B total parameters (40B active)
- Strong reasoning capabilities
- Long-horizon tasks

**Cost-Optimized:**
```json
{
  "model": {
    "primary": "ollama/minimax-m2"
  }
}
```
- High efficiency
- Good performance/cost ratio
- Fast inference

## Pricing

Ollama Cloud uses pay-per-use pricing:
- No subscription fees
- No idle costs
- Competitive token pricing
- Check current rates: https://ollama.com/pricing

**Cost Comparison:**
- More affordable than GPT-4/Claude Opus
- Comparable to GPT-4o-mini/Claude Sonnet
- No infrastructure costs (GPU, storage, etc.)

## Benefits

**Why Ollama Cloud for PocketAgent:**

✅ **No Infrastructure** - No GPU, no containers, no model storage
✅ **Powerful Models** - Access to Kimi K2.5, MiniMax M2.5, GLM-5
✅ **Simple Setup** - Just API key configuration
✅ **Pay-per-Use** - No idle costs, only pay for what you use
✅ **OpenClaw Compatible** - Works out of the box
✅ **Reliable** - Ollama's managed infrastructure
✅ **Flexible** - Easy to switch models or add fallbacks

## Hybrid Setup (Optional)

You can combine Ollama Cloud with other providers:

```json
{
  "agents": {
    "defaults": {
      "model": {
        "primary": "ollama/kimi-k2.5",
        "fallbacks": [
          "ollama/minimax-m2.5",
          "anthropic/claude-sonnet-4-5",
          "openai/gpt-5.2-mini"
        ]
      }
    }
  }
}
```

This gives you:
- Ollama Cloud as primary (cost-effective, powerful)
- Anthropic/OpenAI as fallback (if Ollama is down)
- Best of both worlds

## Next Steps

1. ✅ Document Ollama Cloud in README
2. ✅ Add to onboarding flow (ask for Ollama API key)
3. ✅ Update setup.sh to prompt for Ollama Cloud
4. ✅ Add example configs to DEPLOYMENT_GUIDE.md
5. ✅ Test with OpenClaw

## Resources

- Ollama Cloud Docs: https://docs.ollama.com/cloud
- Model Library: https://ollama.com/search?c=cloud
- API Keys: https://ollama.com/settings/keys
- Pricing: https://ollama.com/pricing
- OpenClaw Docs: https://molty.finna.ai/docs/
