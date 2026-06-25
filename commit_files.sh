#!/bin/bash
# Commits each untracked file individually in creation-time order,
# with a random 1-3 minute pause between commits.

set -e

get_commit_message() {
    local file="$1"
    local base
    base=$(basename "$file")

    case "$file" in
        .gitignore)
            echo "chore: add .gitignore"
            ;;
        .env.example)
            echo "chore: add environment variables template"
            ;;
        requirements.txt)
            echo "chore: add Python dependencies"
            ;;
        agent/__init__.py)
            echo "feat: initialize agent package"
            ;;
        agent/tools.py)
            echo "feat: add agent tools module"
            ;;
        agent/providers.py)
            echo "feat: add LLM provider abstractions"
            ;;
        agent/loop.py)
            echo "feat: add core agent loop implementation"
            ;;
        agent/mcp_server.py)
            echo "feat: add MCP server implementation"
            ;;
        examples/01_tools.py)
            echo "feat: add basic tools example"
            ;;
        examples/02_one_tool_call.py)
            echo "feat: add single tool call example"
            ;;
        examples/03_agent_loop.py)
            echo "feat: add agent loop example"
            ;;
        examples/04_multiple_tools.py)
            echo "feat: add multiple tools example"
            ;;
        examples/05_limits_and_errors.py)
            echo "feat: add limits and error handling example"
            ;;
        examples/06_human_in_the_loop.py)
            echo "feat: add human-in-the-loop example"
            ;;
        examples/07_observability.py)
            echo "feat: add observability example"
            ;;
        examples/08_memory.py)
            echo "feat: add memory example"
            ;;
        examples/09_multi_agent.py)
            echo "feat: add multi-agent example"
            ;;
        examples/10_mcp.py)
            echo "feat: add MCP integration example"
            ;;
        hands_on/agent.py)
            echo "feat: add hands-on agent exercise"
            ;;
        check_setup.py)
            echo "feat: add environment setup checker"
            ;;
        EXERCISES.md)
            echo "docs: add course exercises guide"
            ;;
        README.md)
            echo "docs: add project README"
            ;;
        *)
            echo "feat: add $base"
            ;;
    esac
}

# Build sorted file list: creation-time + path, sort numerically, strip timestamp
tmpfile=$(mktemp /tmp/commit_order.XXXXXX)

while IFS= read -r f; do
    ctime=$(stat -f "%B" "$f" 2>/dev/null)
    echo "$ctime $f"
done < <(git ls-files --others --exclude-standard) | sort -n > "$tmpfile"

total=$(wc -l < "$tmpfile" | tr -d ' ')
count=0

while IFS= read -r line; do
    file="${line#* }"
    [ -z "$file" ] && continue

    count=$((count + 1))
    msg=$(get_commit_message "$file")
    delay=$((RANDOM % 121 + 60))

    echo ""
    echo "[$count/$total] $file"
    echo "  commit : $msg"

    git add "$file"
    git commit -m "$msg"
    git push -u origin main

    if [ "$count" -lt "$total" ]; then
        echo "  waiting : ${delay}s before next file..."
        sleep "$delay"
    fi
done < "$tmpfile"

rm -f "$tmpfile"
echo ""
echo "Done. All $total files committed and pushed."
