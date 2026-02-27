# 📟 PocketAgent Installer Personalization

## ⭐ CRITICAL FEATURE - DO NOT FORGET!

The installer MUST ask personalization questions and update workspace files.

---

## What Gets Personalized

### 1. Agent Name
- **Question:** "What should your agent be called?"
- **Default:** PocketAgent
- **Updates:** `workspace/IDENTITY.md`
- **Field:** `- **Name:** [AGENT_NAME]`

### 2. User Name
- **Question:** "What's your name?"
- **Updates:** `workspace/USER.md`
- **Field:** `**Name:** [USER_NAME]`

### 3. Timezone
- **Question:** "What's your timezone? (e.g., America/New_York)"
- **Updates:** `workspace/USER.md`
- **Field:** `**Timezone:** [USER_TIMEZONE]`

### 4. Language
- **Question:** "What's your preferred language?"
- **Default:** English
- **Updates:** `workspace/USER.md`
- **Field:** `**Language:** [USER_LANGUAGE]`

---

## Implementation

### Installer Flow

```bash
#!/bin/bash
# PocketAgent Installer with Personalization

echo "📟 PocketAgent Installer"
echo "======================="
echo ""

# ── STEP 1: Personalization Questions ──
echo "Let's personalize your agent!"
echo ""

read -p "What's your name? " USER_NAME
read -p "What should your agent be called? (default: PocketAgent) " AGENT_NAME
AGENT_NAME=${AGENT_NAME:-PocketAgent}

read -p "What's your timezone? (e.g., America/New_York) " USER_TIMEZONE
read -p "What's your preferred language? (default: English) " USER_LANGUAGE
USER_LANGUAGE=${USER_LANGUAGE:-English}

echo ""
echo "Great! Setting up $AGENT_NAME for $USER_NAME..."
echo ""

# ... installation steps ...

# ── STEP 6: Personalize Workspace Files ──
echo "✓ Personalizing workspace for $USER_NAME and $AGENT_NAME..."

WORKSPACE_DIR="$INSTALL_DIR/home/.openclaw/workspace"

# Update IDENTITY.md with agent name
sed -i '' "s/^- \*\*Name:\*\* .*/- **Name:** $AGENT_NAME/" "$WORKSPACE_DIR/IDENTITY.md"

# Update USER.md with user info
sed -i '' "s/^\*\*Name:\*\* .*/\*\*Name:\*\* $USER_NAME/" "$WORKSPACE_DIR/USER.md"
sed -i '' "s/^\*\*Timezone:\*\* .*/\*\*Timezone:\*\* $USER_TIMEZONE/" "$WORKSPACE_DIR/USER.md"
sed -i '' "s/^\*\*Language:\*\* .*/\*\*Language:\*\* $USER_LANGUAGE/" "$WORKSPACE_DIR/USER.md"

echo "✅ Workspace personalized!"
```

---

## Example User Experience

```
📟 PocketAgent Installer
=======================

Let's personalize your agent!

What's your name? John
What should your agent be called? (default: PocketAgent) Jarvis
What's your timezone? (e.g., America/New_York) America/Los_Angeles
What's your preferred language? (default: English) English

Great! Setting up Jarvis for John...

✓ Checking system requirements...
✓ Creating directories...
✓ Installing PocketAgent...
✓ Setting up workspace...
✓ Personalizing workspace for John and Jarvis...
✓ Generating gateway token...
✓ Starting Jarvis...

🎉 Jarvis is now running and ready to help John!

🔑 Your Gateway Token:
   abc123def456...

📱 Next Steps:
   1. Open: http://localhost:18789
   2. Complete onboarding (add API keys)
   3. Start chatting with Jarvis!
```

---

## Files Modified

### Before Installation (Template)

**workspace/IDENTITY.md:**
```markdown
- **Name:** PocketAgent
```

**workspace/USER.md:**
```markdown
**Name:** 

**Timezone:** 

**Language:** 
```

### After Installation (Personalized)

**workspace/IDENTITY.md:**
```markdown
- **Name:** Jarvis
```

**workspace/USER.md:**
```markdown
**Name:** John

**Timezone:** America/Los_Angeles

**Language:** English
```

---

## Why This Matters

1. **Personal Connection**
   - User feels ownership ("my agent Jarvis")
   - Agent knows who it's serving
   - More engaging experience

2. **Better Context**
   - Agent addresses user by name
   - Timezone-aware scheduling
   - Language preferences respected

3. **Differentiation**
   - Not just "PocketAgent"
   - Each installation is unique
   - User's personal AI operator

---

## Future Enhancements

Could also ask:
- Occupation
- Interests
- Goals
- Working hours
- Communication style preferences

But keep it simple for v0.x - just the essentials!

---

## Testing Checklist

- [ ] Installer asks all 4 questions
- [ ] Default values work (PocketAgent, English)
- [ ] IDENTITY.md updated correctly
- [ ] USER.md updated correctly
- [ ] Agent uses personalized name in responses
- [ ] Works on Mac
- [ ] Works on Linux
- [ ] Works on Windows

---

**REMEMBER:** This is a key differentiator! Every PocketAgent installation should feel personal and unique.
