# NemoClaw Intel — What We Can Learn

> NVIDIA announced NemoClaw at GTC 2026 (March 16, 2026).
> It's built on top of OpenClaw — the same engine we run.
> Repo: [github.com/NVIDIA/NemoClaw](https://github.com/NVIDIA/NemoClaw) (Apache 2.0, early preview)
> Docs: [docs.nvidia.com/nemoclaw](https://docs.nvidia.com/nemoclaw/latest/)

---

## What It Actually Is (From the Repo)

NemoClaw is not a new agent framework. It's a **security and policy layer on top of OpenClaw** — a reference stack that adds sandboxing, network policy, and inference routing in a single install command.

```bash
curl -fsSL https://www.nvidia.com/nemoclaw.sh | bash
```

That one command installs OpenShell, pulls Nemotron models, creates a sandboxed OpenClaw instance, and applies security policies. When done, you get:

```
──────────────────────────────────────────────────
Sandbox      my-assistant (Landlock + seccomp + netns)
Model        nvidia/nemotron-3-super-120b-a12b (NVIDIA Cloud API)
──────────────────────────────────────────────────
Run:         nemoclaw my-assistant connect
Status:      nemoclaw my-assistant status
Logs:        nemoclaw my-assistant logs --follow
──────────────────────────────────────────────────
```

---

## The Architecture (How It Fits Together)

```
nemoclaw onboard
       │
       ▼
nemoclaw plugin (TypeScript)
       │
       ▼
blueprint runner (versioned Python artifact)
       │
       ▼
openshell CLI (sandbox · gateway · inference · policy)
       │
       ▼
┌─────────────────────────────────┐
│        OpenShell Sandbox        │
│  OpenClaw agent                 │
│  ├── NVIDIA inference (routed)  │
│  ├── strict network policy      │
│  └── filesystem isolation       │
└─────────────────────────────────┘
```

Three components:

| Component | What It Does |
|-----------|-------------|
| Plugin | Thin TypeScript CLI — `nemoclaw` commands + `openclaw nemoclaw` subcommands |
| Blueprint | Versioned Python artifact — orchestrates sandbox creation, policy, inference setup |
| Sandbox | Isolated OpenShell container running OpenClaw with enforced egress + filesystem |

The **thin plugin / versioned blueprint** split is a key design decision. The plugin stays small and stable. All orchestration logic lives in the blueprint on its own release cadence. Blueprint artifacts are immutable, versioned, and digest-verified before execution — supply chain safety built in.

---

## The Protection Layers (From the Actual Repo)

Four layers, two hot-reloadable at runtime:

| Layer | What It Protects | Hot-Reload? |
|-------|-----------------|-------------|
| Network | Blocks unauthorized outbound connections | ✅ Yes |
| Filesystem | Prevents reads/writes outside `/sandbox` and `/tmp` | ❌ Locked at creation |
| Process | Blocks privilege escalation + dangerous syscalls | ❌ Locked at creation |
| Inference | Reroutes model API calls to controlled backends | ✅ Yes |

When the agent tries to reach an unlisted host, OpenShell **blocks the request and surfaces it in the TUI for operator approval**. Approved endpoints persist for the current session but are not saved to the baseline policy — you have to explicitly promote them.

The baseline policy (`openclaw-sandbox.yaml`):
```yaml
filesystem_policy:
  read_only: [/usr, /lib, /etc]
  read_write: [/sandbox, /tmp]

network_policies:
  nvidia:
    endpoints:
      - { host: integrate.api.nvidia.com, port: 443 }
    binaries:
      - { path: /usr/bin/python3 }
      - { path: /usr/local/bin/openclaw }

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

Key details:
- **Binary-scoped network enforcement** — connections tied to specific executable paths, not just process names
- **L7 REST enforcement** — GitHub access whitelisted by HTTP method + URL path pattern
- **TLS termination** — proxy inspects requests before forwarding, real L7 policy not just firewall rules
- **Landlock + seccomp + netns** — three kernel-level isolation mechanisms stacked

---

## The Critical Insight (Why This Matters)

From the NVIDIA OpenShell blog post — they named the failure mode explicitly:

> "The critical failure mode: guardrails living inside the same process they're supposed to be guarding."

Every existing agent runtime (including our current setup) has security logic **inside** the agent. A compromised agent can bypass it. OpenShell moves the control point **entirely outside the agent's reach** — out-of-process policy enforcement. The agent literally cannot override its own constraints.

This is the browser tab model applied to agents:
- Sessions are isolated
- Permissions are verified by the runtime before any action executes
- Policy updates happen live at sandbox scope with a full audit trail

---

## The Inference Routing

Inference requests from the agent **never leave the sandbox directly**. OpenShell intercepts every call and routes it to the configured provider. The agent doesn't know or care — it just calls the model API as normal.

Current provider:

| Provider | Model | Notes |
|----------|-------|-------|
| NVIDIA cloud | `nvidia/nemotron-3-super-120b-a12b` | Requires API key from build.nvidia.com |

Local inference (Ollama, vLLM) is experimental and not fully supported yet on macOS. This is actually a gap we can exploit — our PocketModel failover stack works today without GPU.

You can switch models at runtime without restarting the sandbox. That's the hot-reload inference layer.

---

## Hardware Requirements (From the Repo)

| Resource | Minimum | Recommended |
|----------|---------|-------------|
| CPU | 4 vCPU | 4+ vCPU |
| RAM | 8 GB | 16 GB |
| Disk | 20 GB free | 40 GB free |

The sandbox image is ~2.4 GB compressed. On machines with less than 8 GB RAM, the OOM killer can trigger during image push. They recommend 8 GB swap as a workaround.

Supported platforms: Linux (Ubuntu 22.04+), macOS Apple Silicon (Colima/Docker Desktop), Windows WSL (Docker Desktop). Podman on macOS not supported yet.

---

## What We Can Steal

### 1. Out-of-Process Policy Enforcement
Our entrypoint.sh does config validation at startup but security logic lives inside the agent. We need a lightweight policy layer that sits between the agent and the host — not inside the container, outside it.

**Action:** Add a `policy.yaml` to the Cloud image and a simple proxy that enforces it. Even a basic network allowlist is a meaningful upgrade.

### 2. The Thin Plugin / Versioned Blueprint Pattern
NemoClaw keeps the CLI plugin tiny and stable. All orchestration logic is in a versioned Python blueprint with its own release cadence. Digest-verified before execution.

**Action:** Our `entrypoint.sh` is doing too much. Split it — thin entrypoint that calls a versioned workspace bootstrap script. Easier to update without touching the core image.

### 3. Hot-Reloadable Network + Inference Policy
Network and inference policies can be updated at runtime without restarting the sandbox. Filesystem and process isolation is locked at creation.

**Action:** Add a `/api/policy` endpoint to our entrypoint that lets the client update model routing and network rules live. No restart needed.

### 4. Operator Approval Flow for Blocked Requests
When the agent hits a blocked endpoint, OpenShell surfaces it in the TUI for operator approval. The agent can reason about the roadblock and propose a policy update — you have final say.

**Action:** This is a UX pattern worth building into PocketAgent. When the agent can't do something due to a policy, it should tell the user clearly and ask for approval rather than silently failing.

### 5. Single-Command Install with Named Sandboxes
`nemoclaw onboard` creates a named sandbox (`my-assistant`). You can run multiple named sandboxes on the same host. Each has its own policy, model config, and state.

**Action:** Our install.sh should support named instances. This is the foundation for PAN — multiple agents on one host, each isolated.

### 6. Supply Chain Safety for Skills/Blueprints
Blueprint artifacts are immutable, versioned, and digest-verified before execution. No skill or blueprint runs unless it passes verification.

**Action:** PocketMP skills should have version pinning and digest verification. Right now anyone can push a skill and it runs with no verification. That's a security gap.

---

## What They Got Wrong (Our Advantage)

**GPU dependency** — NemoClaw is optimized for DGX Spark, DGX Station, Jetson Thor. Local inference requires serious hardware. Our PocketModel failover stack works on a $7/month VPS today.

**Enterprise-first = friction-first** — The target user is an IT department, not an individual. The policy system is powerful but complex. We're building for the person, not the org.

**No network / social layer** — NemoClaw is single-agent. No concept of agents talking to each other, hiring each other, or forming a network. PAN is our moat.

**OpenAI-owned foundation** — NemoClaw is built on OpenClaw which was acquired by OpenAI in February 2026. That's a dependency on a competitor. We share this risk — worth watching.

**Local inference is still experimental** — They admit Ollama/vLLM support is not fully there yet. We're ahead on this.

---

## Immediate Actions

| Priority | Action |
|----------|--------|
| HIGH | Add `policy.yaml` + lightweight policy proxy to Cloud image |
| HIGH | Move policy enforcement out-of-process (not inside the agent) |
| HIGH | Build privacy router into PocketModel (sensitive = local, general = cloud) |
| MED | Split `entrypoint.sh` into thin entrypoint + versioned bootstrap script |
| MED | Add hot-reload config endpoint (model + network policy without restart) |
| MED | Add operator approval flow when agent hits a blocked action |
| MED | Support named sandbox instances (foundation for PAN multi-agent) |
| MED | Add digest verification to PocketMP skill installs |
| LOW | Move personalization from install-time to first conversation |
| WATCH | Monitor OpenClaw licensing post-OpenAI acquisition |

---

## The Big Picture

NemoClaw validates the entire direction. Jensen Huang called OpenClaw "the operating system for personal AI" on stage at GTC. NVIDIA — the most important company in AI infrastructure — just shipped a security layer on top of the exact engine we run.

We're not competing with NemoClaw. They're building the enterprise version. We're building the personal version. The market is being defined right now and the window is open.

Ship.

---

*Sources: [NVIDIA/NemoClaw GitHub](https://github.com/NVIDIA/NemoClaw) · [NemoClaw Docs](https://docs.nvidia.com/nemoclaw/latest/) · [NVIDIA GTC 2026 Announcement](https://nvidianews.nvidia.com/news/nvidia-announces-nemoclaw) · [NVIDIA OpenShell Developer Blog](https://developer.nvidia.com/blog/run-autonomous-self-evolving-agents-more-safely-with-nvidia-openshell/) · [NVIDIA/OpenShell-Community GitHub](https://github.com/NVIDIA/OpenShell-Community)*
