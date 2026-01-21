# Scoped Memory Skill for Claude Code

Save memories from conversations, organized by scope/category, to a personal folder outside the current project.

## Installation

To install this skill for use in any Claude Code session:

```bash
# Copy the skill files to your Claude Code skills directory
mkdir -p ~/.claude/skills/scoped-memory
cp SKILL.md ~/.claude/skills/scoped-memory/
cp memory-helper.sh ~/.claude/skills/scoped-memory/
chmod +x ~/.claude/skills/scoped-memory/memory-helper.sh

# Create the memories storage directory
mkdir -p ~/.claude-memories
```

## Usage

Invoke the skill by saying things like:
- "Remember this CSS trick"
- "Save this as a memory under python"
- "Store this solution in my memories"

Or use the `/remember` or `/scoped-memory` command.

## Memory Storage

All memories are stored in `~/.claude-memories/{scope}/` as markdown files.

## Helper Script

The `memory-helper.sh` script provides CLI utilities for managing memories:

```bash
# Save a memory
echo "content" | ./memory-helper.sh save css "Title"

# List all scopes
./memory-helper.sh scopes

# List memories in a scope
./memory-helper.sh list css

# Search memories
./memory-helper.sh search "keyword"

# Show recent memories
./memory-helper.sh recent 10
```
