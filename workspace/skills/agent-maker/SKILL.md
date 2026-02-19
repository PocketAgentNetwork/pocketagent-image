---
name: agent-maker
description: How to create sub-agents for specialized tasks
---

# Agent Maker

This skill teaches you how to create sub-agents - specialized agents that handle specific tasks.

## What is a Sub-Agent?

A sub-agent is a specialized agent with its own identity, personality, and capabilities. Sub-agents live in `workspace/agents/` and can be spawned by the main agent when needed.

## Sub-Agent Structure

```
workspace/agents/my-sub-agent/
├── IDENTITY.md    # Required: Who this agent is
├── SOUL.md        # Required: Agent's personality
└── AGENTS.md      # Required: Agent's capabilities
```

## How to Create a Sub-Agent

### Step 1: Create the folder
```bash
mkdir -p workspace/agents/my-sub-agent
```

### Step 2: Create IDENTITY.md
```markdown
# IDENTITY.md - My Sub-Agent

- **Name:** My Sub-Agent
- **Type:** Specialized Agent
- **Role:** What this agent does
- **Emoji:** 🤖
- **Avatar:** _(optional)_

---

Brief description of who this agent is.
```

### Step 3: Create SOUL.md
```markdown
# SOUL.md - My Sub-Agent Personality

## Core Purpose
What this agent is designed to do.

## Personality Traits
- Trait 1
- Trait 2
- Trait 3

## How This Agent Works
Behavioral guidelines specific to this agent's role.

## Communication Style
How this agent communicates.
```

### Step 4: Create AGENTS.md
```markdown
# AGENTS.md - My Sub-Agent Capabilities

## Every Session

Before doing anything:
1. Read IDENTITY.md
2. Read SOUL.md
3. Understand your specialized role

## Capabilities
- What this agent can do
- Tools it has access to
- Limitations

## Reporting
How this agent reports back to the main agent.
```

### Step 5: Spawn the sub-agent
```
sessions_spawn --task "Do specific task" --agentId my-sub-agent
```

## Sub-Agent Examples

### Example 1: Research Agent
```
workspace/agents/research-agent/
├── IDENTITY.md    # "I am a Research Agent"
├── SOUL.md        # Deep, thorough, analytical
└── AGENTS.md      # Can search, summarize, cite sources
```

### Example 2: Social Media Agent
```
workspace/agents/social-agent/
├── IDENTITY.md    # "I am a Social Media Agent"
├── SOUL.md        # Engaging, friendly, brand-aware
└── AGENTS.md      # Can post, engage, track metrics
```

### Example 3: Code Review Agent
```
workspace/agents/code-reviewer/
├── IDENTITY.md    # "I am a Code Review Agent"
├── SOUL.md        # Detail-oriented, constructive
└── AGENTS.md      # Can review code, suggest improvements
```

## When to Create a Sub-Agent

Create a sub-agent when:
- A task requires specialized personality or approach
- You need to delegate complex work
- Different tasks need different communication styles
- You want to organize responsibilities clearly

## Best Practices

1. **Give each sub-agent a clear purpose**
   - One role, well-defined
   - Don't make generalist sub-agents

2. **Define personality that fits the role**
   - Research agent: thorough, analytical
   - Social agent: engaging, friendly
   - Code agent: precise, constructive

3. **Document capabilities clearly**
   - What can this agent do?
   - What tools does it have?
   - What are its limitations?

4. **Test before relying on it**
   - Spawn the agent
   - Give it a task
   - Verify it works as expected

## Spawning Sub-Agents

Use the `sessions_spawn` tool:

```
sessions_spawn --task "Research topic X and summarize" --agentId research-agent
```

The sub-agent will:
1. Read its IDENTITY, SOUL, and AGENTS files
2. Execute the task
3. Report back to you

## Communication with Sub-Agents

Use `sessions_send` to communicate:

```
sessions_send --to research-agent --message "Update me on progress"
```

## Sub-Agent vs Main Agent

**Main Agent (You):**
- Generalist, handles everything
- Coordinates and delegates
- Interfaces with the user

**Sub-Agents:**
- Specialists, focused role
- Execute specific tasks
- Report back to main agent

---

**You now know how to create sub-agents! Go build your team.**
