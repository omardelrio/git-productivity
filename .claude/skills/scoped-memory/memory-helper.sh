#!/bin/bash
# Memory Helper Script for Scoped Memory Skill
# This script helps manage memories stored in ~/.claude-memories/

set -euo pipefail

MEMORIES_DIR="$HOME/.claude-memories"

# Ensure memories directory exists
mkdir -p "$MEMORIES_DIR"

# For save command, capture stdin early before it's consumed
STDIN_CONTENT=""
if [ "${1:-}" = "save" ] && [ ! -t 0 ]; then
    # Read all available stdin
    read -r -d '' STDIN_CONTENT || true
fi

usage() {
    echo "Usage: $0 <command> [options]"
    echo ""
    echo "Commands:"
    echo "  save <scope> <title> [content]  Save a memory (content via arg, stdin, or --file)"
    echo "  list [scope]            List all memories or memories in a scope"
    echo "  search <keyword>        Search memories for a keyword"
    echo "  show <filepath>         Display a specific memory"
    echo "  scopes                  List all available scopes"
    echo "  recent [n]              Show n most recent memories (default: 10)"
    echo ""
    echo "Retrieval Commands:"
    echo "  recall <scope>          Show all memories in a scope with full content"
    echo "  recall-search <keyword> Search and display matching memories with content"
    echo "  recall-recent [n]       Show n most recent memories with full content"
    echo "  summary [scope]         Show a brief summary of memories (titles only)"
    echo ""
    echo "Examples:"
    echo "  echo 'my content' | $0 save css 'Flexbox Centering Trick'"
    echo "  $0 list css"
    echo "  $0 search flexbox"
    echo "  $0 scopes"
    echo "  $0 recent 5"
    echo "  $0 recall css"
    echo "  $0 recall-search 'flexbox'"
}

save_memory() {
    local scope="$1"
    local title="$2"
    local content_arg="${3:-}"
    local scope_dir="$MEMORIES_DIR/$scope"

    mkdir -p "$scope_dir"

    local timestamp=$(date +%Y%m%d_%H%M%S)
    local date_formatted=$(date "+%Y-%m-%d %H:%M")
    local filename="memory_${timestamp}.md"
    local filepath="$scope_dir/$filename"

    # Determine content source: argument > stdin > error
    local content=""
    if [ -n "$content_arg" ]; then
        # Content provided as argument
        content="$content_arg"
    elif [ -n "$STDIN_CONTENT" ]; then
        # Content from stdin
        content="$STDIN_CONTENT"
    else
        echo "Error: No content provided."
        echo "Provide content as argument or via stdin:"
        echo "  $0 save $scope '$title' 'your content here'"
        echo "  echo 'your content' | $0 save $scope '$title'"
        exit 1
    fi

    # Build the memory file
    {
        echo "# $title"
        echo ""
        echo "**Date**: $date_formatted"
        echo "**Scope**: $scope"
        echo ""
        echo "## Content"
        echo ""
        printf '%s\n' "$content"
        echo ""
        echo "## Notes"
        echo ""
        echo "_Add any additional notes here_"
    } > "$filepath"

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

# Retrieval functions - display full content for use in conversations

recall_scope() {
    local scope="$1"
    local scope_dir="$MEMORIES_DIR/$scope"

    if [ ! -d "$scope_dir" ]; then
        echo "Scope '$scope' not found."
        echo "Available scopes:"
        list_scopes
        return 1
    fi

    echo "=== MEMORIES FROM SCOPE: $scope ==="
    echo ""

    local count=0
    for file in "$scope_dir"/*.md; do
        if [ -f "$file" ]; then
            count=$((count + 1))
            echo "--- Memory $count: $(basename "$file") ---"
            cat "$file"
            echo ""
            echo "---"
            echo ""
        fi
    done

    if [ $count -eq 0 ]; then
        echo "No memories found in scope '$scope'"
    else
        echo "=== END OF $count MEMORIES FROM $scope ==="
    fi
}

recall_search() {
    local keyword="$1"

    echo "=== MEMORIES MATCHING: '$keyword' ==="
    echo ""

    local files=$(grep -r -l -i "$keyword" "$MEMORIES_DIR" 2>/dev/null || true)

    if [ -z "$files" ]; then
        echo "No memories found matching '$keyword'"
        return 0
    fi

    local count=0
    for file in $files; do
        if [ -f "$file" ]; then
            count=$((count + 1))
            local scope=$(basename "$(dirname "$file")")
            echo "--- Memory $count [$scope]: $(basename "$file") ---"
            cat "$file"
            echo ""
            echo "---"
            echo ""
        fi
    done

    echo "=== END OF $count MATCHING MEMORIES ==="
}

recall_recent() {
    local count="${1:-5}"

    echo "=== $count MOST RECENT MEMORIES ==="
    echo ""

    local files=$(find "$MEMORIES_DIR" -name "*.md" -type f -printf '%T@ %p\n' 2>/dev/null | \
        sort -rn | \
        head -n "$count" | \
        cut -d' ' -f2-)

    if [ -z "$files" ]; then
        echo "No memories found"
        return 0
    fi

    local num=0
    for file in $files; do
        if [ -f "$file" ]; then
            num=$((num + 1))
            local scope=$(basename "$(dirname "$file")")
            echo "--- Memory $num [$scope]: $(basename "$file") ---"
            cat "$file"
            echo ""
            echo "---"
            echo ""
        fi
    done

    echo "=== END OF RECENT MEMORIES ==="
}

summary_memories() {
    local scope="${1:-}"

    echo "=== MEMORY SUMMARY ==="
    echo ""

    if [ -n "$scope" ]; then
        local scope_dir="$MEMORIES_DIR/$scope"
        if [ ! -d "$scope_dir" ]; then
            echo "Scope '$scope' not found"
            return 1
        fi

        echo "Scope: $scope"
        echo "---"
        for file in "$scope_dir"/*.md; do
            if [ -f "$file" ]; then
                local title=$(head -n 1 "$file" | sed 's/^# //')
                local date=$(grep -m 1 "^\*\*Date\*\*:" "$file" | sed 's/\*\*Date\*\*: //' || echo "Unknown")
                echo "- $title ($date)"
                echo "  File: $file"
            fi
        done
    else
        for dir in "$MEMORIES_DIR"/*/; do
            if [ -d "$dir" ]; then
                local scope_name=$(basename "$dir")
                echo "Scope: $scope_name"
                echo "---"
                for file in "$dir"/*.md; do
                    if [ -f "$file" ]; then
                        local title=$(head -n 1 "$file" | sed 's/^# //')
                        local date=$(grep -m 1 "^\*\*Date\*\*:" "$file" | sed 's/\*\*Date\*\*: //' || echo "Unknown")
                        echo "- $title ($date)"
                        echo "  File: $file"
                    fi
                done
                echo ""
            fi
        done
    fi

    echo "=== END OF SUMMARY ==="
}

# Main command handler
case "${1:-}" in
    save)
        if [ $# -lt 3 ]; then
            echo "Error: save requires scope and title"
            usage
            exit 1
        fi
        save_memory "$2" "$3" "${4:-}"
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
    recall)
        if [ $# -lt 2 ]; then
            echo "Error: recall requires a scope"
            echo "Available scopes:"
            list_scopes
            exit 1
        fi
        recall_scope "$2"
        ;;
    recall-search)
        if [ $# -lt 2 ]; then
            echo "Error: recall-search requires a keyword"
            usage
            exit 1
        fi
        recall_search "$2"
        ;;
    recall-recent)
        recall_recent "${2:-5}"
        ;;
    summary)
        summary_memories "${2:-}"
        ;;
    help|--help|-h)
        usage
        ;;
    *)
        usage
        exit 1
        ;;
esac
