#!/bin/bash
# Memory Helper Script for Scoped Memory Skill
# This script helps manage memories stored in ~/.claude-memories/

set -euo pipefail

MEMORIES_DIR="$HOME/.claude-memories"

# Ensure memories directory exists
mkdir -p "$MEMORIES_DIR"

usage() {
    echo "Usage: $0 <command> [options]"
    echo ""
    echo "Commands:"
    echo "  save <scope> <title>    Save a new memory (reads content from stdin)"
    echo "  list [scope]            List all memories or memories in a scope"
    echo "  search <keyword>        Search memories for a keyword"
    echo "  show <filepath>         Display a specific memory"
    echo "  scopes                  List all available scopes"
    echo "  recent [n]              Show n most recent memories (default: 10)"
    echo ""
    echo "Examples:"
    echo "  echo 'my content' | $0 save css 'Flexbox Centering Trick'"
    echo "  $0 list css"
    echo "  $0 search flexbox"
    echo "  $0 scopes"
    echo "  $0 recent 5"
}

save_memory() {
    local scope="$1"
    local title="$2"
    local scope_dir="$MEMORIES_DIR/$scope"

    mkdir -p "$scope_dir"

    local timestamp=$(date +%Y%m%d_%H%M%S)
    local date_formatted=$(date "+%Y-%m-%d %H:%M")
    local filename="memory_${timestamp}.md"
    local filepath="$scope_dir/$filename"

    # Read content from stdin
    local content=$(cat)

    cat > "$filepath" << EOF
# $title

**Date**: $date_formatted
**Scope**: $scope

## Content

$content

## Notes

_Add any additional notes here_
EOF

    echo "Memory saved to: $filepath"
}

list_memories() {
    local scope="${1:-}"

    if [ -n "$scope" ]; then
        local scope_dir="$MEMORIES_DIR/$scope"
        if [ -d "$scope_dir" ]; then
            echo "Memories in scope '$scope':"
            ls -lt "$scope_dir"/*.md 2>/dev/null | head -20 || echo "No memories found"
        else
            echo "Scope '$scope' does not exist"
        fi
    else
        echo "All memories:"
        find "$MEMORIES_DIR" -name "*.md" -type f -exec ls -lt {} + 2>/dev/null | head -30 || echo "No memories found"
    fi
}

search_memories() {
    local keyword="$1"
    echo "Searching for '$keyword' in memories..."
    grep -r -l -i "$keyword" "$MEMORIES_DIR" 2>/dev/null || echo "No matches found"
}

show_memory() {
    local filepath="$1"
    if [ -f "$filepath" ]; then
        cat "$filepath"
    else
        echo "Memory not found: $filepath"
        exit 1
    fi
}

list_scopes() {
    echo "Available scopes:"
    if [ -d "$MEMORIES_DIR" ]; then
        for dir in "$MEMORIES_DIR"/*/; do
            if [ -d "$dir" ]; then
                local scope=$(basename "$dir")
                local count=$(find "$dir" -name "*.md" -type f 2>/dev/null | wc -l)
                echo "  $scope ($count memories)"
            fi
        done
    else
        echo "  No scopes yet"
    fi
}

recent_memories() {
    local count="${1:-10}"
    echo "Most recent $count memories:"
    find "$MEMORIES_DIR" -name "*.md" -type f -printf '%T@ %p\n' 2>/dev/null | \
        sort -rn | \
        head -n "$count" | \
        cut -d' ' -f2- || echo "No memories found"
}

# Main command handler
case "${1:-}" in
    save)
        if [ $# -lt 3 ]; then
            echo "Error: save requires scope and title"
            usage
            exit 1
        fi
        save_memory "$2" "$3"
        ;;
    list)
        list_memories "${2:-}"
        ;;
    search)
        if [ $# -lt 2 ]; then
            echo "Error: search requires a keyword"
            usage
            exit 1
        fi
        search_memories "$2"
        ;;
    show)
        if [ $# -lt 2 ]; then
            echo "Error: show requires a filepath"
            usage
            exit 1
        fi
        show_memory "$2"
        ;;
    scopes)
        list_scopes
        ;;
    recent)
        recent_memories "${2:-10}"
        ;;
    help|--help|-h)
        usage
        ;;
    *)
        usage
        exit 1
        ;;
esac
