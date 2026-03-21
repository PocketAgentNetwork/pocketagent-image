# NemoClaw Intel — What We Can Learn

> NVIDIA announced NemoClaw at GTC 2026 (March 16, 2026).
> It's built on top of OpenClaw — the same engine we run.
> This doc breaks down what they built, why it matters, and what we should steal.
> GitHub: [NVIDIA/OpenShell-Community](https://github.com/NVIDIA/OpenShell-Community) (Apache 2.0)

---

## What NemoClaw Actually Is

NemoClaw is not a new agent framework. It's a **security and policy layer on top of OpenClaw**.

NVIDIA's stack:
```
Browser (port 18789)
       │
       ▼
policy-proxy.js  ← intercepts /api/policy (read/write policy.yaml at runtime)
       │
       ▼
OpenClaw Gateway (port 18788)
       │
       ▼
OpenShell Gateway (k3s harness) ← out-of-process policy enforcement
       │
       ▼
NVIDIA Inference Endpoints (Nemotron, Kimi K2.5, DeepSeek V3.2)
```

Three core components (from the actual repo):
1. **OpenShell runtime** — sandboxed execution layer. Kernel-level isolation via Linux Landlock. Every file access, network call, and inference request is governed by a declarative `policy.yaml`. Runs as a separate process — the agent cannot override it even if compromised.
2. **NemoClaw Plugin** — a thin TypeScript package that registers commands under `openclaw nemoclaw`. Handles CLI interactions in-process with the OpenClaw gateway.
3. **NemoClaw Blueprint** — a versioned Python artifact that orchestrates OpenShell resources (gateway, providers, sandbox, inference route, policy). The plugin resolves, verifies digest, and executes the blueprint as a subprocess.

The repo structure (`NVIDIA/OpenShell-Community`) contains:
```
sandboxes/
  base/          ← foundational image, system tools, dev environment
  ollama/        ← local + cloud LLMs, Claude Code, Codex pre-installed
  sdg/           ← synthetic data generation workflows
  openclaw/      ← OpenClaw sandbox (what NemoClaw builds on)
  openclaw-nvidia/ ← NemoClaw DevX extension layered on top
brev/            ← one-click cloud deployment launchable
```

---

## The Critical Architectural Insight From the Repo

The most important thing NVIDIA figured out — and it's in the OpenShell blog post explicitly:

> "The critical failure mode: guardrails living inside the same process they're supposed to be guarding."

Every existing agent runtime (including our current setup) has security logic inside the agent. A compromised agent can bypass it. OpenShell moves the control point **entirely outside the agent's reach** — out-of-process policy enforcement. The agent literally cannot override it.

This is the browser tab model applied to agents:
- Sessions are isolated
- Permissions are verified by the runtime before any action executes
- Policy updates happen live at sandbox scope with a full audit trail of every allow/deny

The blueprint lifecycle from the actual repo:
```
resolve → verify digest → plan → apply → status
```
The plugin resolves the blueprint artifact, checks version compatibility (`min_openshell_version`, `min_openclaw_version`), verifies the digest, then the Python runner determines what OpenShell resources to create/update and executes them via `openshell` CLI calls.

---

## The Policy System (The Real Innovation)

This is the part worth studying closely.

`policy.yaml` defines what the agent can and cannot do at the kernel level:

```yaml
filesystem_policy:
  read_only:
    - /usr
    - /lib
    - /etc
  read_write:
    - /sandbox
    - /tmp

network_policies:
  nvidia:
    endpoints:
      - { host: integrate.api.nvidia.com, port: 443 }
    binaries:
      - { path: /usr/bin/python3 }

  github_rest_api:
    endpoints:
      - host: api.github.com
        port: 443
        protocol: rest
        tls: terminate
        enforcement: enforce
        rules:
          - allow: { method: GET, path: "/**" }
    binaries:
      - { path: /usr/local/bin/openclaw }
```

Key design decisions:
- **Binary-scoped network enforcement** — outbound connections are tied to a specific binary path, not just a process name. `/usr/bin/python3` can hit NVIDIA APIs. `/usr/bin/node` cannot (unless you say so).
- **L7 REST enforcement** — GitHub access is whitelisted by HTTP method + URL path pattern. Not just host/port.
- **TLS termination** — the proxy inspects requests before forwarding. Real L7 policy, not just firewall rules.
- **Runtime policy updates** — the policy proxy exposes `/api/policy` so the UI can update `policy.yaml` without rebuilding the container.
- **Landlock `best_effort`** — degrades gracefully on kernels without Landlock support rather than hard-failing.

---

## What They Got Right

### 1. The Privacy Router
NemoClaw routes inference calls through a privacy router that decides: local model or cloud model, based on the sensitivity of the request. The agent can use frontier cloud models for general tasks but falls back to local Nemotron models for anything touching private data.

**For PocketAgent:** We already have PocketModel for failover. We should add a sensitivity-aware routing layer — not just "is the API down?" but "should this request leave the device at all?"

### 2. Zero-Fork UI Extension Pattern
NVIDIA ships enterprise UI features (model selector, deploy modal, API keys page, nav group) as a TypeScript extension injected via MutationObserver — without forking OpenClaw's source. This means they track upstream OpenClaw releases automatically.

**For PocketAgent:** Our client should follow the same pattern. Don't fork OpenClaw's UI. Build our experience as an extension layer on top. This keeps us compatible with every OpenClaw update.

### 3. Runtime Policy Without Rebuilds
The policy proxy lets you change security rules at runtime via the UI. No container rebuild. No restart. Just update `policy.yaml` and it's live.

**For PocketAgent:** Our entrypoint.sh does config validation at startup but nothing is changeable at runtime without a restart. A lightweight policy/config proxy would be a real UX improvement — especially for the managed cloud tier.

### 4. Binary-Scoped Network Enforcement
Most sandboxes do IP allowlisting. NemoClaw ties network permissions to specific executable paths. This is a much stronger security model — a compromised Python script can't suddenly start calling home if Python isn't in the network policy.

**For PocketAgent:** Worth implementing in the Cloud image. Our current setup has no network enforcement at all. Even a basic allowlist of known-good endpoints would be a meaningful security upgrade.

### 5. MIG Isolation for Multi-Agent
On Jetson Thor, NemoClaw uses NVIDIA's Multi-Instance GPU (MIG) to give each agent its own isolated compute slice. No agent starves another.

**For PocketAgent (PAN):** When we run multiple agents on the same node (PAN infrastructure), we need resource isolation. MIG is GPU-specific but the concept applies — CPU/memory cgroups per agent container, enforced at the host level.

### 6. Single-Command Install
```bash
nemoclaw install
```
That's it. Installs OpenShell, pulls Nemotron models, configures the sandbox, starts the gateway.

**For PocketAgent:** Our `install.sh` is already close to this. But the experience should be even tighter — one command, zero questions, agent is live. The personalization step (name, timezone) can happen inside the agent's first conversation, not during install.

### 7. Synthetic Data Generation Sandbox
The repo has a `sandboxes/sdg/` — synthetic data generation workflows. The agent generates synthetic data to fix edge cases and iterates through thousands of failures in isolated sandboxes. This is how the agent self-improves without touching production data.

**For PocketAgent:** The MEMORY.md + HEARTBEAT.md system is our version of this. But we could go further — let the agent run simulated task scenarios in an isolated sandbox to improve its own skills before deploying them live.

---

### Enterprise-first = friction-first
NemoClaw is built for IT departments, not individuals. The policy system is powerful but complex. The target user is a Cisco security engineer, not someone who wants a personal agent in 60 seconds.

**Our lane:** Sovereign, personal, zero-friction. The individual is the enterprise.

### GPU dependency
NemoClaw is optimized for NVIDIA hardware. DGX Spark, DGX Station, Jetson Thor. The local model story requires serious hardware.

**Our lane:** PocketModel's failover stack means you get a capable agent on a $7/month VPS or a 3-year-old laptop. No GPU required.

### No network / social layer
NemoClaw is a single-agent deployment story. There's no concept of agents talking to each other, hiring each other, or forming a network.

**Our lane:** PAN is the moat. Agent-to-agent communication, the skills marketplace, the social graph — none of that exists in NemoClaw.

### OpenAI-owned foundation
OpenClaw was acquired by OpenAI in February 2026. NemoClaw is built on top of it. That's a dependency on a competitor's infrastructure.

**Our lane:** We should be watching this closely. If OpenAI changes OpenClaw's licensing or direction, NemoClaw has a problem. We have the same dependency — but we're building PAN and the skills layer as our own moat above it.

---

## Immediate Actions

| Priority | Action | Why |
|----------|--------|-----|
| HIGH | Add a `policy.yaml` concept to the Cloud image | Security baseline, differentiator for enterprise/prosumer users |
| HIGH | Build a privacy router into PocketModel | Route sensitive requests to local models, general tasks to cloud |
| HIGH | Move policy enforcement out-of-process | Don't trust the agent to police itself — enforce at the runtime level |
| MED | Move agent personalization from install-time to first-conversation | Reduces install friction, matches NemoClaw's single-command UX |
| MED | Add runtime config update endpoint to entrypoint | No restart needed to change model or settings |
| MED | Implement cgroup resource limits per agent container (PAN infra) | Required for multi-agent hosting |
| MED | Add audit trail to entrypoint (every allow/deny logged) | Needed for trust — users should be able to see what their agent did |
| LOW | Explore zero-fork UI extension pattern for the client | Stay compatible with upstream OpenClaw updates |
| LOW | Explore SDG sandbox concept for skill self-improvement | Agent tests new skills in isolation before deploying live |
| WATCH | Monitor OpenClaw licensing changes post-OpenAI acquisition | NemoClaw and PocketAgent share this dependency risk |

---

## The Big Picture

NemoClaw validates the entire direction. NVIDIA — the most important company in AI infrastructure — just announced that:

1. OpenClaw is "the operating system for personal AI" (Jensen Huang's words)
2. The next frontier is making agents **secure, persistent, and always-on**
3. The enterprise market needs exactly what we're building for individuals

We're not competing with NemoClaw. We're building the personal version of what they're building for enterprises. The market is being defined right now. PocketAgent needs to be the name people say when they mean "personal sovereign agent" the same way NemoClaw will be the name enterprises say.

The window is open. Ship.

---

*Sources: [NVIDIA GTC 2026 Announcement](https://nvidianews.nvidia.com/news/nvidia-announces-nemoclaw) · [NVIDIA/OpenShell-Community GitHub](https://github.com/NVIDIA/OpenShell-Community) · [NemoClaw Architecture Docs](https://docs.nvidia.com/nemoclaw/latest/reference/architecture.html) · [NemoClaw.bot](https://nemoclaw.bot) · [Ajeet Raina — NemoClaw on Jetson AGX Thor](https://www.ajeetraina.com/getting-started-with-nvidia-nemoclaw-on-jetson-agx-thor) · [NVIDIA OpenShell Developer Blog](https://developer.nvidia.com/blog/run-autonomous-self-evolving-agents-more-safely-with-nvidia-openshell/)*
