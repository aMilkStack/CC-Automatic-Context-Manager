![CC-ACM Header](assets/header.png)

# CC-ACM (Claude Code Automatic Context Manager)

Automatic context handoff for Claude Code. When your session hits 60% context usage, a dialog prompts you to generate a summary and open a fresh session with full context.

**For authenticated Claude Code CLI users** - Uses your logged-in session via `claude -p` (no API keys, no cost per handoff). This is a productivity tool for Pro/Teams users, not an API wrapper.

## Features

- **Auto-trigger at 60%** - Statusline monitors context usage (configurable)
- **Yes / In 5 min / Dismiss** - Snooze support for when you're mid-task (duration configurable)
- **Seamless handoff** - Summary generated via `claude -p`, new tab opens with `--append-system-prompt`
- **Dark themed UI** - Vibrant cyberpunk or minimal styles
- **Interactive config** - Use `/acm:config` to customize settings through Claude
- **Clean uninstaller** - Easy removal with `./uninstall.sh`

## How It Works

```
Statusline (every 300ms)
    │
    └─ at 60% → handoff-prompt.sh
                    │
                    ├─ [Handoff] → claude -p generates summary → new tab opens
                    ├─ [In 5 min] → snooze, asks again later
                    └─ [Dismiss] → won't ask again this session
```

## Installation

```bash
# Run the install script
./install.sh
```

This will:
1. Copy scripts to `~/.claude/scripts/`
2. Update your statusline to trigger at 60%
3. Back up existing files

## Manual Installation

1. Copy `scripts/handoff-prompt.sh` to `~/.claude/scripts/`
2. Make executable: `chmod +x ~/.claude/scripts/handoff-prompt.sh`
3. Add the trigger logic to your statusline (see `statusline-patch.sh`)

## Files

```
scripts/
├── handoff-prompt.sh   # Main script: dialog + handoff flow
└── statusline-patch.sh # Patch for ~/.claude/statusline-command.sh
```

## Configuration

### Interactive Configuration (Recommended)

Use the `/acm:config` skill in Claude Code for an interactive setup:

```bash
# In any Claude Code session
/acm:config
```

Claude will guide you through customizing:
- **Trigger threshold** (50-90%, default: 60%)
- **Snooze duration** (1-60 minutes, default: 5)
- **Summary token length** (200-2000, default: 500)
- **Dialog style** (vibrant or minimal)

Settings are saved to `~/.claude/cc-acm.conf` and apply immediately to new sessions.

### Manual Configuration

Alternatively, create/edit `~/.claude/cc-acm.conf`:

```bash
# CC-ACM Configuration
THRESHOLD=60
SNOOZE_DURATION=300
SUMMARY_TOKENS=500
DIALOG_STYLE=vibrant
```

### Viewing Current Config

```bash
cat ~/.claude/cc-acm.conf
```

## Requirements (WSL/Warp - Default)

- Claude Code CLI
- WSL with Warp terminal (uses PowerShell for dialogs)
- Python 3 (for transcript parsing)

## Platform Support

**Primary Platform (Fully Supported):**
- **WSL + Warp Terminal** - Tested on Windows 11 + WSL2 + Warp

**Other Platforms (In Development):**

| Platform | Dialog | New Tab | Status |
|----------|--------|---------|--------|
| [Linux (Zenity)](platforms/linux-zenity/) | Zenity GTK | gnome-terminal | In Development |
| [macOS](platforms/macos/) | osascript | iTerm2/Terminal | In Development |
| [Generic](platforms/generic/) | Text prompt | Manual | In Development |

To try a platform variant, copy the `handoff-prompt.sh` from the relevant `platforms/` folder instead of the default one. Contributions and testing feedback welcome!

## Uninstall

To completely remove CC-ACM:

```bash
./uninstall.sh
```

This will:
- Remove the handoff script
- Restore your original statusline
- Delete configuration and temp files

## License

MIT
