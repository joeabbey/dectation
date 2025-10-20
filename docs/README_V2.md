# Dectation V2 - Interactive Claude Integration

Voice control for Steam Deck using Talon Voice - now with intelligent keyboard management and seamless Claude Code integration!

![Dictation Mode in Action](screenshots/dictation-mode-screenshot.png)
*Press L1 + Y on Steam Deck to activate dictation mode - keyboard automatically hides!*

## What's New in V2

### 🎯 Smart Keyboard Management
- **Auto-hide during dictation** - Onscreen keyboard automatically gets out of your way when you start speaking
- **Auto-restore on sleep** - Keyboard comes back when you need to type manually
- **Voice control** - "show keyboard" / "hide keyboard" commands
- **Manual override** - "keyboard stay" to disable auto-hide when needed

### 🤖 Claude Code Integration
- **Voice-activated prompts** - Send prompts to Claude Code hands-free
- **Quick action templates** - "claude review this", "claude debug this", etc.
- **Clipboard workflow** - Seamless code capture and prompt sending
- **Session management** - Start/stop Claude sessions with your voice

### 💬 Voice Commands for Everything
No more fumbling with keyboards! Control your entire workflow:
- Toggle dictation: **L1 + Y**
- Manage keyboard: "show keyboard", "hide keyboard"
- Send to Claude: "claude review this", "send to claude"
- Quick templates: "claude refactor", "claude write tests"

---

## Features (All Versions)

- 🎤 **Voice Commands**: Full Talon Voice integration for hands-free control
- ⌨️ **Hardware Button Toggle**: Press `L1 + Y` on Steam Deck to toggle voice control (`Ctrl+Space`)
- 📝 **Auto Dictation Mode**: Wakes up in dictation mode - just press L1+Y and start talking!
- 🔄 **Auto-Start**: Automatically starts Talon if not running when triggered
- 🔔 **Visual Feedback**: Desktop notifications show current state
- 🎮 **Steam Deck Optimized**: Configured specifically for Steam Deck in desktop mode

### V2 Additions
- ⌨️ **Smart Keyboard Management**: Auto-hide/show onscreen keyboard during dictation
- 🤖 **Claude Integration**: Voice commands for interacting with Claude Code
- 📋 **Clipboard Workflow**: Seamless code capture and prompt sending
- 🎯 **Quick Templates**: Pre-built prompts for common tasks

---

## Quick Start

**Easy Installation (Recommended):**

```bash
cd ~
git clone https://github.com/joeabbey/dectation.git
cd dectation
git checkout v2-interactive-claude  # For V2 features
./install.sh
```

The installer will automatically:
- Download and install Talon Voice
- Accept the Talon EULA
- Install Talon community commands
- Set up keyboard shortcuts (L1 + Y / Ctrl+Space)
- Configure all scripts
- **V2**: Install keyboard management and Claude integration

**After installation:**
1. Speech models need to be installed through Talon's GUI (one-time setup)
2. Right-click Talon tray icon → **Speech Recognition** → **Install Conformer**
3. Press **`L1 + Y`** on your Steam Deck (or `Ctrl+Space`) to toggle voice control!
4. **V2**: Keyboard will automatically hide when you start speaking!

---

## V2 Usage Guide

### Keyboard Management

The onscreen keyboard is now intelligent and stays out of your way:

**Automatic Behavior:**
- When you press **L1 + Y** to start dictating → keyboard hides
- When you press **L1 + Y** to sleep → keyboard shows (if it was visible before)

**Manual Control:**
- "**show keyboard**" - Show the onscreen keyboard
- "**hide keyboard**" - Hide the onscreen keyboard
- "**toggle keyboard**" - Toggle keyboard visibility

**Override Auto-Management:**
- "**keyboard stay**" - Disable auto-hide (keyboard stays visible even during dictation)
- "**keyboard auto**" - Re-enable auto-hide

### Claude Code Integration

Interact with Claude Code using your voice!

#### Starting Claude

**Voice Commands:**
- "**start claude**" or "**start claude session**" - Opens a new terminal with Claude Code
- "**close claude**" or "**stop claude**" - Closes the Claude session

**Note:** Claude Code must be installed separately. Install with:
```bash
npm install -g @anthropic-ai/claude-code
```

#### Sending Prompts

**From Clipboard:**
1. Select code or text in any application
2. Say "**send to claude**"
3. Paste in Claude terminal (Ctrl+Shift+V)

**Direct Prompt:**
- Say "**claude [your prompt]**"
- Example: "**claude explain this function**"
- Example: "**claude how do I fix this error**"

#### Quick Action Templates

Pre-built prompts for common tasks - just select code and say:

- "**claude review this**" - Code review with best practices
- "**claude refactor this**" - Refactoring suggestions
- "**claude document this**" - Generate documentation
- "**claude write tests**" - Create unit tests
- "**claude debug this**" - Debug help for errors
- "**claude explain this**" - Detailed explanation
- "**claude optimize this**" - Performance optimization
- "**claude security review**" - Security analysis

**Workflow Example:**
1. Select a function in your editor
2. Say "**claude review this**"
3. Prompt is copied to clipboard
4. Paste in Claude terminal
5. Get detailed code review!

#### Context Capture

The system automatically captures context from:
- **Clipboard** - Selected text from any application
- **Editor** - Active file content
- **Terminal** - Error messages and output

---

## Voice Command Reference

### Dictation Control
- **L1 + Y** (or Ctrl+Space) - Toggle dictation on/off
- Dictation mode starts automatically when you wake Talon

### Keyboard Management (V2)
- "**show keyboard**" - Show onscreen keyboard
- "**hide keyboard**" - Hide onscreen keyboard
- "**toggle keyboard**" - Toggle keyboard visibility
- "**keyboard stay**" - Disable auto-hide
- "**keyboard auto**" - Enable auto-hide

### Claude Session (V2)
- "**start claude [session]**" - Start Claude Code
- "**stop claude**" / "**close claude**" - Stop Claude

### Sending to Claude (V2)
- "**send to claude**" - Send clipboard contents
- "**claude [prompt text]**" - Direct prompt

### Quick Actions (V2)
- "**claude review [this]**" - Code review
- "**claude refactor [this]**" - Refactoring
- "**claude document [this]**" - Documentation
- "**claude write tests**" - Test generation
- "**claude debug [this]**" - Debugging help
- "**claude explain [this]**" - Explanation
- "**claude optimize [this]**" - Optimization
- "**claude security [review]**" - Security review

---

## Configuration (V2)

Create `~/.talon/user/dectation_settings.py` to customize behavior:

```python
from talon import Module

mod = Module()

# Keyboard management
mod.setting("dectation_auto_hide_keyboard", bool, default=True)
mod.setting("dectation_keyboard_restore", bool, default=True)
mod.setting("dectation_keyboard_delay_ms", int, default=200)

# Claude integration
mod.setting("dectation_claude_binary", str, default="claude")
mod.setting("dectation_claude_auto_start", bool, default=True)
```

### Settings Explained

**Keyboard Management:**
- `dectation_auto_hide_keyboard` - Auto-hide keyboard during dictation (default: true)
- `dectation_keyboard_restore` - Restore keyboard on sleep (default: true)
- `dectation_keyboard_delay_ms` - Delay before hide/show in ms (default: 200)

**Claude Integration:**
- `dectation_claude_binary` - Path to Claude Code binary (default: "claude")
- `dectation_claude_auto_start` - Auto-start Claude if not running (default: true)

---

## File Structure

```
dectation/
├── README_V2.md                    # This file
├── V2_PLAN.md                      # Detailed V2 implementation plan
├── install.sh                      # Easy installer script (V2 compatible)
├── uninstall.sh                    # Easy uninstaller script
├── dictation-mode-screenshot.png   # Screenshot
├── scripts/
│   ├── start-talon.sh              # Starts Talon in background
│   ├── toggle-talon.sh             # Toggles Talon sleep/wake mode
│   ├── setup-talon-eula.sh         # Accepts Talon EULA
│   ├── steam-keyboard-control.sh   # V2: Keyboard show/hide
│   └── claude-session-manager.sh   # V2: Claude session management
├── talon/
│   ├── toggle_sleep.py             # Talon action for toggling sleep (V2 updated)
│   ├── keyboard_manager.py         # V2: Keyboard management
│   ├── keyboard_commands.talon     # V2: Keyboard voice commands
│   ├── claude_integration.py       # V2: Claude integration
│   ├── claude_templates.py         # V2: Prompt templates
│   └── claude_commands.talon       # V2: Claude voice commands
└── toggle-dictation.desktop        # Desktop file for keyboard shortcut
```

---

## Troubleshooting

### V2: Keyboard not hiding automatically

1. **Check if auto-hide is enabled:**
   ```bash
   # Should show "True" if enabled
   grep "auto_hide_keyboard" ~/.talon/user/dectation_settings.py
   ```

2. **Test keyboard control manually:**
   ```bash
   ~/dectation/scripts/steam-keyboard-control.sh hide
   ~/dectation/scripts/steam-keyboard-control.sh show
   ```

3. **Check logs:**
   ```bash
   tail -f ~/.talon/talon.log | grep -i keyboard
   ```

4. **Disable auto-hide if needed:**
   - Say "**keyboard stay**" to disable auto-management

### V2: Claude commands not working

1. **Check if Claude Code is installed:**
   ```bash
   which claude
   # Should show path like: /usr/local/bin/claude
   ```

2. **Install Claude Code if missing:**
   ```bash
   npm install -g @anthropic-ai/claude-code
   ```

3. **Test Claude session manager:**
   ```bash
   ~/dectation/scripts/claude-session-manager.sh start
   ~/dectation/scripts/claude-session-manager.sh status
   ```

4. **Check Talon logs:**
   ```bash
   tail -f ~/.talon/talon.log | grep -i claude
   ```

### General Issues

See the main troubleshooting section in the original README for:
- Voice recognition not working
- Keyboard shortcut issues
- Talon startup problems
- Toggle issues

---

## Migration from V1 to V2

V2 is **fully backward compatible** with V1. All existing features continue to work.

**To upgrade:**
1. Pull the v2 branch:
   ```bash
   cd ~/dectation
   git fetch
   git checkout v2-interactive-claude
   ```

2. Run the installer:
   ```bash
   ./install.sh
   ```

3. V2 features are active immediately!

**To disable V2 features:**
- Keyboard management: Say "**keyboard stay**" or set `dectation_auto_hide_keyboard=False`
- Claude integration: Simply don't use the Claude voice commands

---

## What's Next

**Future Enhancements (Post-V2):**
- Direct IDE integration (VS Code, neovim)
- Smart context detection (AI-powered)
- Multi-turn Claude conversations
- Voice corrections ("Claude I meant...")
- Custom user-defined templates
- Text-to-speech response reading

See `V2_PLAN.md` for the complete roadmap.

---

## Credits

- [Talon Voice](https://talonvoice.com/) by Ryan Hileman
- [Talon Community](https://github.com/talonhub/community) for community commands
- Developed for Steam Deck enthusiasts wanting hands-free control

## License

MIT License - Feel free to use and modify!

## Contributing

Contributions welcome! Please open an issue or pull request.

See `V2_PLAN.md` for contribution guidelines and areas of focus.

## Support

Having issues? Check:
1. Troubleshooting section above
2. `V2_PLAN.md` for technical details
3. Open an issue on GitHub

---

**Enjoy hands-free coding on your Steam Deck!** 🎮🎤
