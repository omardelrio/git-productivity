---
name: remember
description: Save a memory from the current conversation with a scope/category. Use when the user says "remember this", "save this memory", or wants to store something they learned for future reference.
---

# Scoped Memory Skill

Save memories from conversations, organized by scope/category, to a personal folder outside the current project.

## Overview

This skill allows you to capture insights, code snippets, solutions, or any valuable information from your current session and save it for future reference. Memories are organized by scope (e.g., "CSS", "React", "Python", "DevOps", "Debugging").

## Storage Location

All memories are stored in: `~/.claude-memories/{scope}/`

Each memory is saved as a markdown file with a timestamp.

## Workflow

### 1. Gather Information

When the user invokes this skill, ask them:

1. **What to remember**: Ask the user what specific information they want to save. This could be:
   - A code snippet or pattern
   - A solution to a problem
   - A useful command or technique
   - A concept or explanation
   - Any insight from the current conversation

2. **Scope/Category**: Ask for the scope or category to classify this memory. Examples:
   - Programming languages: `css`, `javascript`, `python`, `rust`, `go`
   - Frameworks: `react`, `vue`, `django`, `nextjs`
   - Tools: `git`, `docker`, `kubernetes`, `vim`
   - Concepts: `algorithms`, `architecture`, `security`, `testing`
   - Custom: Any category the user prefers

### 2. Format the Memory

Structure the memory as a markdown file with:

```markdown
# [Brief Title]

**Date**: [YYYY-MM-DD HH:MM]
**Scope**: [scope]
**Context**: [Brief context from the conversation - what was the user working on?]

## Content

[The actual memory content - code, explanation, solution, etc.]

## Notes

[Any additional notes, caveats, or related information]
```

### 3. Save the Memory

Use the following process to save:

```bash
# Ensure the scope directory exists
mkdir -p ~/.claude-memories/{scope}

# Generate filename with timestamp
FILENAME="memory_$(date +%Y%m%d_%H%M%S).md"

# Save the memory
cat > ~/.claude-memories/{scope}/$FILENAME << 'EOF'
[formatted memory content]
EOF
```

### 4. Confirm to User

After saving, confirm:
- The memory has been saved
- Show the full path to the file
- Show a preview of what was saved
- Remind them they can access memories at `~/.claude-memories/`

## Example Usage

**User**: "Remember this CSS trick for centering"

**Assistant**:
1. Asks: "What specific CSS centering technique would you like me to save?"
2. User provides the content
3. Asks: "What scope should I use? (e.g., 'css', 'styling', 'layout')"
4. User says "css"
5. Saves to `~/.claude-memories/css/memory_20240115_143022.md`
6. Confirms with path and preview

## Listing Memories

If the user asks to see their memories, use:

```bash
# List all scopes
ls -la ~/.claude-memories/

# List memories in a specific scope
ls -la ~/.claude-memories/{scope}/

# Show recent memories across all scopes
find ~/.claude-memories -name "*.md" -type f -mtime -7 | head -20
```

## Searching Memories

To search through saved memories:

```bash
# Search for keyword across all memories
grep -r "keyword" ~/.claude-memories/

# Search within a specific scope
grep -r "keyword" ~/.claude-memories/{scope}/
```

## Tips

- Use consistent scope names for easier retrieval
- Be descriptive in the title
- Include context about what problem this solved
- Add related tags in the notes section if helpful
