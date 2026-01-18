#!/bin/bash
# Claudikins Automatic Context Manager SessionStart Hook
# Detects if a handoff is available and prompts Claude to use it

# Read hook input from stdin
INPUT=$(cat)

# Extract session info
SOURCE=$(echo "$INPUT" | grep -o '"source":"[^"]*"' | sed 's/.*:"//' | sed 's/"//')

# Only check for handoff on new sessions (not resume/clear/compact)
if [ "$SOURCE" != "startup" ]; then
    exit 0
fi

# Project-local state location (per-project handoff)
# Check current project's .claude directory for handoff
PROJECT_HANDOFF=".claude/claudikins-acm/handoff.md"

if [ ! -f "$PROJECT_HANDOFF" ]; then
    # No handoff for this project
    exit 0
fi

HANDOFF_STATE="$PROJECT_HANDOFF"

# Check if file has actual content (not empty or placeholder)
if [ ! -s "$HANDOFF_STATE" ]; then
    exit 0
fi

# Check for placeholder content
if grep -q "No Active Handoff" "$HANDOFF_STATE"; then
    exit 0
fi

# Check for structured state (preferred)
STATE_FILE=".claude/claudikins-acm/handoff-state.json"
STRUCTURED_CONTEXT=""

if [ -f "$STATE_FILE" ]; then
    # Extract key info from structured state
    STRUCTURED_CONTEXT=$(python3 << 'PYEOF'
import json
import sys

try:
    with open('.claude/claudikins-acm/handoff-state.json') as f:
        state = json.load(f)

    ctx = state.get('context', {})
    lines = []

    if ctx.get('current_objective'):
        lines.append(f"PREVIOUS OBJECTIVE: {ctx['current_objective']}")

    if ctx.get('active_todos'):
        lines.append("ACTIVE TODOS:")
        for t in ctx['active_todos']:
            status = t.get('status', 'pending')
            content = t.get('content', '')
            lines.append(f"  - [{status}] {content}")

    if ctx.get('key_files_modified'):
        files = ', '.join(ctx['key_files_modified'][:5])
        lines.append(f"RECENTLY MODIFIED: {files}")

    print('\n'.join(lines))
except Exception as e:
    print(f"Error reading state: {e}", file=sys.stderr)
PYEOF
)
fi

# Handoff exists! Tell Claude to immediately invoke it
if [ -n "$STRUCTURED_CONTEXT" ]; then
    CONTEXT="CONTEXT HANDOFF DETECTED. Previous session state:

$STRUCTURED_CONTEXT

You MUST immediately invoke the /acm:handoff skill using the Skill tool to get full details. This is automatic context restoration."
else
    CONTEXT="IMPORTANT: A context handoff from the previous session exists. You MUST immediately invoke the /acm:handoff skill using the Skill tool BEFORE responding to anything else. This is automatic context restoration - do not ask the user, just invoke the skill now."
fi

# Return as JSON with additionalContext
python3 -c "import json; print(json.dumps({
    'hookSpecificOutput': {
        'hookEventName': 'SessionStart',
        'additionalContext': '''$CONTEXT'''
    }
}))"

exit 0
