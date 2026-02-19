---
name: skill-maker
description: How to create new skills for PocketAgent
---

# Skill Maker

This skill teaches you how to create new skills for yourself.

## What is a Skill?

A skill is a capability or tool you can use. Each skill lives in its own folder under `workspace/skills/`.

## Skill Structure

```
workspace/skills/my-new-skill/
├── SKILL.md              # Required: What the skill does and how to use it
├── HEARTBEAT.md          # Optional: Periodic checks for this skill
├── MESSAGING.md          # Optional: Communication guide
└── (other files)         # Optional: Code, configs, data
```

## How to Create a New Skill

### Step 1: Create the folder
```bash
mkdir -p workspace/skills/my-new-skill
```

### Step 2: Create SKILL.md
```markdown
---
name: my-new-skill
description: Brief description of what this skill does
---

# My New Skill

## What This Skill Does
Explain the purpose and capabilities.

## How to Use It
Provide clear instructions and examples.

## Examples
Show practical usage examples.

## Notes
Any important details or limitations.
```

### Step 3: Add optional files (if needed)

**HEARTBEAT.md** - For periodic checks:
```markdown
# Heartbeat for My New Skill

Check something every X minutes/hours.
```

**MESSAGING.md** - For communication patterns:
```markdown
# Messaging Guide

How to communicate using this skill.
```

### Step 4: Test the skill
- Read the SKILL.md to load it
- Try using the skill
- Refine as needed

## Skill Examples

### Example 1: Web Search Skill
```
workspace/skills/web-search/
└── SKILL.md

Content:
---
name: web-search
description: How to search the web effectively
---

# Web Search Skill

## What This Does
Search the web using available tools and return relevant results.

## How to Use
1. Identify search query
2. Use web_search tool
3. Summarize findings
4. Cite sources

## Best Practices
- Use specific keywords
- Verify information from multiple sources
- Always cite where information came from
```

### Example 2: Code Review Skill
```
workspace/skills/code-review/
├── SKILL.md
└── checklist.md

SKILL.md Content:
---
name: code-review
description: How to review code professionally
---

# Code Review Skill

## What This Does
Review code for quality, bugs, and best practices.

## Review Checklist
See checklist.md for detailed items.

## How to Review
1. Read the code thoroughly
2. Check against checklist
3. Provide constructive feedback
4. Suggest improvements with examples

## Tone
- Be constructive, not critical
- Explain why, not just what
- Offer solutions, not just problems
```

### Example 3: Social Media Skill
```
workspace/skills/social-media/
├── SKILL.md
├── HEARTBEAT.md
└── MESSAGING.md

SKILL.md Content:
---
name: social-media
description: How to manage social media presence
---

# Social Media Skill

## What This Does
Post content, engage with audience, track metrics.

## Capabilities
- Draft posts
- Schedule content
- Respond to mentions
- Track engagement

## Tone Guide
See MESSAGING.md for brand voice and style.

## Monitoring
See HEARTBEAT.md for periodic checks.
```

### Example 4: Research Skill
```
workspace/skills/research/
├── SKILL.md
└── sources.md

SKILL.md Content:
---
name: research
description: Deep research and analysis
---

# Research Skill

## What This Does
Conduct thorough research on any topic.

## Research Process
1. Define research question
2. Gather sources (see sources.md for trusted sources)
3. Analyze information
4. Synthesize findings
5. Cite all sources

## Output Format
- Executive summary
- Key findings
- Detailed analysis
- Sources cited
```

## Best Practices

1. **Keep SKILL.md clear and concise**
   - Explain what it does
   - Show how to use it
   - Provide examples

2. **One skill, one purpose**
   - Don't make mega-skills
   - Keep them focused

3. **Document everything**
   - Future you will thank you
   - Make it easy to understand

4. **Test before relying on it**
   - Make sure it works
   - Refine based on usage

## When to Create a New Skill

Create a new skill when:
- You need a new capability
- You want to organize knowledge about a topic
- You have a repeating pattern that needs documentation
- You want to extend your abilities

## Skill Discovery

All skills in `workspace/skills/` are automatically available to you.

**How skills are loaded:**
1. OpenClaw scans `workspace/skills/` folder
2. Reads all SKILL.md files
3. Loads them into your system prompt
4. You can use them immediately

**To use a skill:**
- Just reference it in your work
- The knowledge is already in your context
- No special activation needed

**To refresh skills:**
- Restart your session
- New/updated skills will be loaded automatically

---

## Troubleshooting

**Skill not working?**
- Check SKILL.md exists in the skill folder
- Verify the frontmatter (name, description) is correct
- Make sure instructions are clear
- Restart session to reload

**Skill too complex?**
- Break it into smaller skills
- Keep each skill focused on one thing
- Use multiple simple skills instead of one complex one

**Need to update a skill?**
- Edit the SKILL.md file
- Restart session to reload changes
- Test to verify it works

---

## Advanced: Skills with Code

Skills can include executable code or scripts:

```
workspace/skills/my-code-skill/
├── SKILL.md           # How to use this skill
├── script.py          # Python script
├── config.json        # Configuration
└── README.md          # Additional docs
```

In SKILL.md, document:
- What the code does
- How to run it
- What parameters it needs
- Example usage

### Example: Data Analysis Skill with Python Script

**Step 1: Create the folder and files**
```bash
mkdir -p workspace/skills/data-analysis
cd workspace/skills/data-analysis
```

**Step 2: Create the Python script (analyze.py)**
```python
#!/usr/bin/env python3
import sys
import json

def analyze_data(data_file):
    # Your analysis code here
    with open(data_file, 'r') as f:
        data = json.load(f)
    
    # Perform analysis
    result = {
        "total": len(data),
        "summary": "Analysis complete"
    }
    
    return result

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python analyze.py <data_file>")
        sys.exit(1)
    
    result = analyze_data(sys.argv[1])
    print(json.dumps(result, indent=2))
```

**Step 3: Create SKILL.md**
```markdown
---
name: data-analysis
description: Analyze data files using Python script
---

# Data Analysis Skill

## What This Does
Analyzes JSON data files and provides summary statistics.

## How to Use

1. Prepare your data file (JSON format)
2. Run the analysis script:
   ```bash
   python workspace/skills/data-analysis/analyze.py data.json
   ```
3. Review the output

## Script Parameters
- `data_file`: Path to JSON file to analyze

## Output Format
Returns JSON with:
- `total`: Number of records
- `summary`: Analysis summary

## Example Usage
```bash
# Analyze sales data
python workspace/skills/data-analysis/analyze.py sales_data.json

# Output:
# {
#   "total": 150,
#   "summary": "Analysis complete"
# }
```

## Requirements
- Python 3.x
- JSON data file

## Troubleshooting
- Ensure Python is installed
- Check file path is correct
- Verify JSON format is valid
```

**Step 4: Make script executable (optional)**
```bash
chmod +x workspace/skills/data-analysis/analyze.py
```

**Step 5: Test it**
```bash
# Create test data
echo '{"items": [1, 2, 3]}' > test.json

# Run the skill
python workspace/skills/data-analysis/analyze.py test.json
```

### Tips for Skills with Scripts

1. **Document everything**
   - How to run the script
   - What parameters it needs
   - What it returns
   - Example usage

2. **Handle errors gracefully**
   - Check for missing parameters
   - Validate input
   - Provide helpful error messages

3. **Make it portable**
   - Use relative paths
   - Document dependencies
   - Include requirements.txt for Python

4. **Test thoroughly**
   - Test with different inputs
   - Test error cases
   - Document expected behavior

---

**You now know how to create skills! Go extend yourself.**
