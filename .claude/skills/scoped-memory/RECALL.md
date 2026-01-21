---
name: recall
description: Retrieve saved memories from ~/.claude-memories/ to use in the current conversation. Use when the user says "recall", "get my memories", "what did I save about X", or wants to retrieve previously saved information.
---

# Memory Recall Skill

Retrieve previously saved memories to use in the current conversation.

## Overview

This skill retrieves memories that were saved using the `remember` skill. Memories are stored in `~/.claude-memories/` organized by scope/category.

## When to Use

Invoke this skill when the user:
- Asks to recall or retrieve saved memories
- Wants to see what they saved about a topic
- Says "what do I have saved about X"
- Asks "recall my CSS memories" or similar
- Wants to load context from previous sessions

## Retrieval Workflow

### 1. Determine What to Retrieve

Ask the user what they want to recall:

1. **By Scope**: Retrieve all memories from a specific category
   - "Recall my CSS memories"
   - "What do I have saved under python?"

2. **By Keyword**: Search across all memories for a term
   - "Find memories about flexbox"
   - "Search my memories for authentication"

3. **Recent**: Get the most recent memories regardless of scope
   - "Show my recent memories"
   - "What did I save lately?"

4. **Summary**: Get a quick overview of all saved memories
   - "List all my memories"
   - "What memories do I have?"

### 2. Execute Retrieval

Use the memory-helper script located at `~/.claude/skills/scoped-memory/memory-helper.sh`:

```bash
# Recall all memories from a scope (with full content)
~/.claude/skills/scoped-memory/memory-helper.sh recall {scope}

# Search memories by keyword (with full content)
~/.claude/skills/scoped-memory/memory-helper.sh recall-search "{keyword}"

# Get recent memories (with full content)
~/.claude/skills/scoped-memory/memory-helper.sh recall-recent {count}

# Get a summary (titles only, for overview)
~/.claude/skills/scoped-memory/memory-helper.sh summary [scope]

# List available scopes
~/.claude/skills/scoped-memory/memory-helper.sh scopes
```

### 3. Present to User

After retrieving memories:

1. **Summarize** what was found (e.g., "I found 3 memories in your CSS scope")
2. **Present** the relevant content clearly
3. **Offer** to apply the knowledge to the current task

If no memories are found:
- Inform the user
- Suggest they save memories using the `remember` skill

## Example Interactions

**User**: "Recall my CSS memories"

**Assistant**:
1. Runs: `~/.claude/skills/scoped-memory/memory-helper.sh recall css`
2. Presents the memories found
3. Asks: "Would you like me to apply any of these to your current task?"

---

**User**: "What did I save about authentication?"

**Assistant**:
1. Runs: `~/.claude/skills/scoped-memory/memory-helper.sh recall-search "authentication"`
2. Shows matching memories from any scope
3. Offers to help apply the knowledge

---

**User**: "Show me a summary of all my memories"

**Assistant**:
1. Runs: `~/.claude/skills/scoped-memory/memory-helper.sh summary`
2. Lists all scopes with memory titles
3. Asks which scope or memory to dive into

## Integration with Current Task

After retrieving memories, actively help the user:

1. **Apply the knowledge**: If working on a related task, offer to use the saved information
2. **Cross-reference**: Connect memories to the current problem
3. **Update if needed**: If the memory is outdated, offer to save an updated version

## Quick Commands Reference

| Command | Description |
|---------|-------------|
| `recall {scope}` | Full content from a scope |
| `recall-search "{keyword}"` | Search with full content |
| `recall-recent {n}` | Last n memories with content |
| `summary` | Overview of all memories |
| `summary {scope}` | Overview of one scope |
| `scopes` | List all available scopes |
