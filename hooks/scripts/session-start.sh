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

# Handoff exists! Tell Claude to immediately invoke it
CONTEXT="IMPORTANT: A context handoff from the previous session exists. You MUST immediately invoke the /acm:handoff skill using the Skill tool BEFORE responding to anything else. This is automatic context restoration - do not ask the user, just invoke the skill now."

# Return as JSON with additionalContext
python3 -c "import json; print(json.dumps({
    'hookSpecificOutput': {
        'hookEventName': 'SessionStart',
        'additionalContext': '''$CONTEXT'''
    }
}))"

exit 0
