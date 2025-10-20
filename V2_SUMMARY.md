# Dectation V2 - Quick Summary

## What We Built

Version 2 adds two major feature sets to make voice coding on Steam Deck truly hands-free:

### 1. 🎯 Smart Keyboard Management
**Problem Solved:** Onscreen keyboard constantly covering terminal during dictation

**Solution:**
- Keyboard automatically hides when you start dictating (L1 + Y)
- Keyboard automatically shows when you stop dictating (if it was visible before)
- Voice commands: "show keyboard", "hide keyboard", "keyboard stay"
- Works with Steam Deck's onscreen keyboard

**How it works:**
- `steam-keyboard-control.sh` - Controls keyboard via Steam URIs
- `keyboard_manager.py` - Tracks keyboard state in Talon
- `toggle_sleep.py` - Triggers hide/show on dictation mode changes
- Fully configurable and non-intrusive

### 2. 🤖 Claude Code Integration
**Problem Solved:** Clunky workflow to interact with Claude Code via voice

**Solution:**
- Voice commands to send prompts to Claude
- Pre-built templates for common tasks
- Clipboard-based workflow (no terminal switching needed)
- Session management (start/stop Claude)

**Voice Commands:**
- "**start claude**" - Opens Claude in terminal
- "**send to claude**" - Sends clipboard/selection to Claude
- "**claude review this**" - Sends code review prompt
- "**claude debug this**" - Sends debug prompt
- "**claude refactor this**" - Sends refactor prompt
- Plus: explain, document, write tests, optimize, security review

**How it works:**
- `claude-session-manager.sh` - Manages Claude processes
- `claude_integration.py` - Core integration logic
- `claude_templates.py` - Pre-built prompt templates
- `claude_commands.talon` - Voice command definitions
- Clipboard-based for seamless cross-app workflow

## Installation

```bash
cd ~/dectation
git checkout v2-interactive-claude
./install.sh
```

All V2 components install automatically. Fully backward compatible with V1.

## Quick Start

**Keyboard Management:**
1. Press L1 + Y to start dictating
2. Keyboard automatically hides
3. Press L1 + Y to sleep
4. Keyboard shows back up

**Claude Integration:**
1. Install Claude Code: `npm install -g @anthropic-ai/claude-code`
2. Say "**start claude**" to open a Claude session
3. Select some code in your editor
4. Say "**claude review this**"
5. Paste in Claude terminal (Ctrl+Shift+V)
6. Get instant code review!

## Voice Command Cheat Sheet

### Keyboard Control
- "show keyboard" / "hide keyboard"
- "keyboard stay" (disable auto-hide)
- "keyboard auto" (re-enable auto-hide)

### Claude Commands
- "start claude" / "stop claude"
- "send to claude" (sends clipboard)
- "claude [your prompt]" (direct prompt)

### Quick Actions (with clipboard/selection context)
- "claude review this"
- "claude refactor this"
- "claude debug this"
- "claude explain this"
- "claude document this"
- "claude write tests"
- "claude optimize this"
- "claude security review"

## Configuration

Create `~/.talon/user/dectation_settings.py`:

```python
from talon import Module
mod = Module()

# Disable auto-hide if you want
mod.setting("dectation_auto_hide_keyboard", bool, default=False)

# Disable auto-start Claude if you want
mod.setting("dectation_claude_auto_start", bool, default=False)
```

## File Structure

**New in V2:**
```
scripts/
  ├── steam-keyboard-control.sh    # Keyboard show/hide
  └── claude-session-manager.sh    # Claude session management

talon/
  ├── keyboard_manager.py          # Keyboard state tracking
  ├── keyboard_commands.talon      # Keyboard voice commands
  ├── claude_integration.py        # Claude integration core
  ├── claude_templates.py          # Prompt templates
  └── claude_commands.talon        # Claude voice commands

README_V2.md                       # Complete V2 user guide
V2_PLAN.md                         # Implementation plan & roadmap
```

**Updated:**
- `install.sh` - Installs V2 components
- `talon/toggle_sleep.py` - Integrated keyboard management

## Testing V2

**Test Keyboard Management:**
```bash
# Manual test
~/dectation/scripts/steam-keyboard-control.sh hide
~/dectation/scripts/steam-keyboard-control.sh show

# Test with voice (after Talon installed)
# Say: "show keyboard"
# Say: "hide keyboard"

# Test automatic behavior
# 1. Make sure keyboard is visible
# 2. Press L1 + Y (keyboard should hide)
# 3. Press L1 + Y again (keyboard should show)
```

**Test Claude Integration:**
```bash
# Install Claude Code first
npm install -g @anthropic-ai/claude-code

# Manual test
~/dectation/scripts/claude-session-manager.sh start
~/dectation/scripts/claude-session-manager.sh status
~/dectation/scripts/claude-session-manager.sh stop

# Test with voice (after Talon installed)
# Say: "start claude"
# Copy some code
# Say: "claude review this"
# Paste in Claude terminal
```

## Troubleshooting

**Keyboard not hiding:**
- Check logs: `tail -f ~/.talon/talon.log | grep keyboard`
- Test script: `~/dectation/scripts/steam-keyboard-control.sh hide`
- Disable temporarily: Say "keyboard stay"

**Claude commands not working:**
- Install Claude: `npm install -g @anthropic-ai/claude-code`
- Check path: `which claude`
- Check logs: `tail -f ~/.talon/talon.log | grep claude`

**V2 features not active:**
- Make sure you're on v2 branch: `git branch`
- Re-run installer: `./install.sh`
- Restart Talon

## Next Steps

1. **Test the keyboard management** - Most impactful for immediate workflow
2. **Install Claude Code** - Unlock voice-to-Claude workflow
3. **Customize templates** - Edit `talon/claude_templates.py` for your needs
4. **Provide feedback** - Open issues on GitHub

## Roadmap (Post-V2)

See `V2_PLAN.md` for future enhancements:
- Direct IDE integration
- Smart context detection
- Multi-turn conversations
- Text-to-speech responses
- Custom user templates
- And more!

## Credits

Built with ❤️ for Steam Deck voice coding enthusiasts!

- Original Dectation by joeabbey
- V2 enhancements with Claude Code assistance

---

**Branch:** `v2-interactive-claude`
**Status:** ✅ Feature complete, ready for testing
**Compatibility:** Fully backward compatible with V1
