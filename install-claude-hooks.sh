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

# Copy hook script
echo -e "${BLUE}→${NC} Installing play-prompt-sound.sh hook..."
cp "$SCRIPT_DIR/claude-hooks/play-prompt-sound.sh" ~/.claude/hooks/
chmod +x ~/.claude/hooks/play-prompt-sound.sh
echo -e "${GREEN}✓${NC} Hook script installed"

# Check if settings.json exists
if [ ! -f ~/.claude/settings.json ]; then
    echo -e "${BLUE}→${NC} Creating ~/.claude/settings.json..."
    echo '{}' > ~/.claude/settings.json
fi

# Check if hook is already configured
if grep -q "UserPromptSubmit" ~/.claude/settings.json 2>/dev/null; then
    echo -e "${YELLOW}!${NC} Hook already configured in settings.json"
else
    echo -e "${BLUE}→${NC} Adding hook to Claude Code settings..."

    # Use Python to safely add the hook to JSON
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

settings['hooks']['Stop'] = [
    {
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

    echo -e "${GREEN}✓${NC} Hook configured"
fi

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✓${NC} Installation Complete!"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${YELLOW}IMPORTANT:${NC} Hook approval required on first use"
echo ""
echo "Next time you submit a prompt in Claude Code:"
echo "  1. You'll see a hook approval dialog"
echo "  2. Select ${GREEN}\"Always allow\"${NC} to enable the sound"
echo "  3. 🔔 Bell will play on all future prompts!"
echo ""
echo "To test:"
echo "  1. Open Claude Code"
echo "  2. Type any prompt and press Enter"
echo "  3. Approve the hook when prompted"
echo "  4. Listen for the bell! 🔔"
echo ""
