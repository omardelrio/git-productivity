# Scoped Memory Skill for Claude Code

Save and retrieve memories from conversations, organized by scope/category, to a personal folder outside the current project.

## Installation

To install this skill for use in any Claude Code session:

```bash
# Copy the skill files to your Claude Code skills directory
mkdir -p ~/.claude/skills/scoped-memory
cp SKILL.md RECALL.md memory-helper.sh ~/.claude/skills/scoped-memory/
chmod +x ~/.claude/skills/scoped-memory/memory-helper.sh

# Create the memories storage directory
mkdir -p ~/.claude-memories
```

## Skills Included

### `/remember` - Save Memories
Invoke by saying:
- "Remember this CSS trick"
- "Save this as a memory under python"
- "Store this solution in my memories"

### `/recall` - Retrieve Memories
Invoke by saying:
- "Recall my CSS memories"
- "What did I save about authentication?"
- "Show my recent memories"

## Memory Storage

All memories are stored in `~/.claude-memories/{scope}/` as markdown files with timestamps.

## Helper Script Commands

The `memory-helper.sh` script provides CLI utilities:

### Saving
```bash
echo "content" | ./memory-helper.sh save css "Title"
```

### Listing
```bash
./memory-helper.sh scopes              # List all scopes
./memory-helper.sh list css            # List files in scope
./memory-helper.sh recent 10           # List recent files
```

### Retrieving (with full content)
```bash
./memory-helper.sh recall css          # All memories from scope
./memory-helper.sh recall-search "flex" # Search with content
./memory-helper.sh recall-recent 5     # Recent with content
./memory-helper.sh summary             # Titles overview
```

### Searching
```bash
./memory-helper.sh search "keyword"    # Find files containing keyword
```

## Example Workflow

1. **In conversation A**: Working on CSS, discover a useful flexbox pattern
   - Say: "Remember this flexbox centering trick"
   - Provide the content and scope "css"

2. **In conversation B** (days later): Need that flexbox pattern
   - Say: "Recall my CSS memories"
   - The saved pattern is retrieved and ready to use

## File Structure

```
~/.claude-memories/
├── css/
│   ├── memory_20240115_143022.md
│   └── memory_20240116_091234.md
├── python/
│   └── memory_20240115_162045.md
└── react/
    └── memory_20240117_103512.md
```
