#!/bin/bash
# Install Claude Code hooks for Dectation audio feedback

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  Dectation Claude Code Hooks Installer  ${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Create hooks directory
echo -e "${BLUE}→${NC} Creating ~/.claude/hooks/ directory..."
mkdir -p ~/.claude/hooks
echo -e "${GREEN}✓${NC} Directory created"

# Copy hook scripts
echo -e "${BLUE}→${NC} Installing hook scripts..."
cp "$SCRIPT_DIR/claude-hooks/play-prompt-sound.sh" ~/.claude/hooks/
cp "$SCRIPT_DIR/claude-hooks/play-stop-sound.sh" ~/.claude/hooks/
chmod +x ~/.claude/hooks/play-prompt-sound.sh
chmod +x ~/.claude/hooks/play-stop-sound.sh
echo -e "${GREEN}✓${NC} Hook scripts installed"

# Check if settings.json exists
if [ ! -f ~/.claude/settings.json ]; then
    echo -e "${BLUE}→${NC} Creating ~/.claude/settings.json..."
    echo '{}' > ~/.claude/settings.json
fi

# Check if hook is already configured
if grep -q "Stop.*PreToolUse" ~/.claude/settings.json 2>/dev/null; then
    echo -e "${YELLOW}!${NC} Hooks already configured in settings.json"
else
    echo -e "${BLUE}→${NC} Adding hooks to Claude Code settings..."

    # Use Python to safely add the hooks to JSON
    python3 << 'EOF'
import json
import os

settings_file = os.path.expanduser("~/.claude/settings.json")

# Read existing settings
with open(settings_file, 'r') as f:
    settings = json.load(f)

# Add hooks configuration
if 'hooks' not in settings:
    settings['hooks'] = {}

# Stop hook: Fires when Claude finishes responding and is ready for input
settings['hooks']['Stop'] = [
    {
        "hooks": [
            {
                "type": "command",
                "command": os.path.expanduser("~/.claude/hooks/play-stop-sound.sh")
            }
        ]
    }
]

# PreToolUse hook: Fires before AskUserQuestion tool (when options appear)
settings['hooks']['PreToolUse'] = [
    {
        "tool": "AskUserQuestion",
        "hooks": [
            {
                "type": "command",
                "command": os.path.expanduser("~/.claude/hooks/play-prompt-sound.sh")
            }
        ]
    }
]

# Write back
with open(settings_file, 'w') as f:
    json.dump(settings, f, indent=2)

print("Hook configuration added")
EOF

    echo -e "${GREEN}✓${NC} Hooks configured"
fi

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✓${NC} Installation Complete!"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${YELLOW}IMPORTANT:${NC} Hook approval required on first use"
echo ""
echo "Next time you interact with Claude Code:"
echo "  1. You'll see hook approval dialogs"
echo "  2. Select ${GREEN}\"Always allow\"${NC} to enable the sounds"
echo "  3. 🔔 Bell will play when Claude is ready for input!"
echo ""
echo "The bell will play:"
echo "  • When Claude finishes responding (Stop hook)"
echo "  • When Claude presents options/questions (PreToolUse hook)"
echo ""
echo "To test:"
echo "  1. Open Claude Code"
echo "  2. Submit a prompt and wait for Claude to finish"
echo "  3. Approve hooks when prompted"
echo "  4. Listen for the bell! 🔔"
echo ""
