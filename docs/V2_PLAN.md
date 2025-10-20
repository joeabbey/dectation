# Dectation V2: Interactive Claude Integration

## Overview
Version 2 adds seamless voice-to-Claude interaction and intelligent onscreen keyboard management for Steam Deck, making voice coding truly hands-free.

## Core Problems Solved

### 1. Onscreen Keyboard Interference
**Problem**: Steam's onscreen keyboard covers the terminal during dictation, requiring constant manual dismissal.

**Solution**: Automatic keyboard management integrated with dictation mode:
- Auto-hide keyboard when entering dictation mode (voice input active)
- Auto-show keyboard when exiting dictation mode (manual typing may be needed)
- Smart detection: don't interfere if keyboard wasn't shown by user
- Steam Deck keyboard integration via `steam://close/keyboard` and `steam://open/keyboard`

### 2. Clunky Claude Interaction
**Problem**: Interacting with Claude Code requires switching contexts, typing commands, and breaking voice flow.

**Solution**: Native Talon voice commands for Claude:
- Direct voice-to-Claude prompt submission
- Context-aware code capture and sending
- Clipboard-based workflow for seamless integration
- Quick prompt templates for common tasks

---

## Feature Set

### Phase 1: Keyboard Management (Priority 1)

#### 1.1 Keyboard State Detection
- Detect if Steam keyboard is currently visible
- Track keyboard state in Talon context
- Preserve user's keyboard preference (don't force close if they want it open)

#### 1.2 Auto-Hide on Dictation
Integration points:
- When `toggle_sleep.py` enables dictation mode → close keyboard
- When `toggle_sleep.py` disables dictation (sleep) → restore keyboard if it was open
- Steam Deck specific: Use `steam://close/keyboard` URI
- Alternative: DBus commands for KDE Virtual Keyboard if available

#### 1.3 Manual Override
Voice commands:
- "show keyboard" / "hide keyboard" - manual control
- "keyboard stay" - prevent auto-hide for current session
- State persists until next toggle

**Files to create:**
- `talon/keyboard_manager.py` - Keyboard state tracking and control
- `scripts/steam-keyboard-control.sh` - Steam keyboard show/hide wrapper
- Update `talon/toggle_sleep.py` - Integrate keyboard management

---

### Phase 2: Claude Code Voice Integration (Priority 1)

#### 2.1 Basic Claude Commands
Voice commands for common Claude interactions:

**Starting Claude:**
- "start Claude session" → Opens terminal, starts `claude` if installed
- "Claude help me" → Opens Claude in current directory
- "new Claude window" → Opens konsole with Claude running

**Sending Prompts:**
- "send to Claude" → Takes clipboard/selected text, sends as prompt
- "Claude [prompt text]" → Direct dictation to Claude
  - Example: "Claude explain this function"
  - Example: "Claude write tests for this module"

**Quick Actions:**
- "Claude commit" → Triggers git commit workflow
- "Claude review" → Sends current file for review
- "Claude fix errors" → Captures terminal errors, sends to Claude

#### 2.2 Context Capture System
Automated context gathering:

**File Context:**
- "send this file to Claude" → Captures current file path and contents
- "Claude explain this file" → Auto-formats: "Please explain /path/to/file.py"
- Smart detection of active window/editor

**Selection Context:**
- "Claude look at this" → Captures selected text from any application
- Works via clipboard with formatting preservation
- Automatic language detection for code blocks

**Error Context:**
- "Claude debug this" → Captures last N lines of terminal output
- Formats as: "I got this error: [error text]. How do I fix it?"

**Directory Context:**
- "Claude show workspace" → Sends `tree` output or directory structure
- "Claude find [pattern]" → Sends grep results to Claude

#### 2.3 Clipboard-Based Workflow
Seamless integration without terminal switching:

**Prompt Builder:**
- Voice dictation → formats as Claude prompt → clipboard → auto-submit
- "Ask Claude: [your question]" → builds and sends prompt
- Template system: common prompt patterns pre-formatted

**Response Handler:**
- Claude's response → can be copied to clipboard via voice
- "copy Claude's answer" → grabs last response
- "insert Claude's code" → pastes code block from response

**Chain Commands:**
- "select this, ask Claude, insert answer" → complete workflow
- Context preservation: maintains conversation thread

#### 2.4 Quick Prompt Templates
Pre-built prompt patterns:

**Code Review:**
- "Claude review this" → "Please review this code for best practices: [code]"

**Debugging:**
- "Claude debug this" → "I'm getting this error: [error]. Please explain and suggest fixes."

**Documentation:**
- "Claude document this" → "Please write documentation for: [code]"

**Refactoring:**
- "Claude refactor this" → "Please refactor this code for better readability: [code]"

**Testing:**
- "Claude write tests" → "Please write unit tests for: [code]"

**Files to create:**
- `talon/claude_integration.py` - Main Claude voice commands
- `talon/claude_context.py` - Context capture utilities
- `talon/claude_templates.py` - Prompt templates
- `scripts/claude-session-manager.sh` - Terminal/Claude process management
- `scripts/capture-context.sh` - File/selection/error capture helpers

---

### Phase 3: Advanced Features (Priority 2)

#### 3.1 Session Management
- "pause Claude" / "resume Claude" - Manage Claude process state
- "Claude history" - Show recent prompts/responses
- "Claude retry" - Re-send last prompt
- Session persistence across dictation toggles

#### 3.2 Multi-Modal Responses
- Text-to-speech integration: Claude reads responses aloud
- Voice command: "read Claude's answer"
- Configurable: auto-read vs manual trigger

#### 3.3 Terminal Integration
- Custom Claude Code TUI wrapper for better voice control
- Split pane: dictation area + Claude response area
- Voice-navigable output (scroll, search, copy sections)

**Files to create:**
- `talon/claude_session.py` - Session state management
- `talon/claude_tts.py` - Text-to-speech integration
- `scripts/claude-tui-wrapper.sh` - Enhanced terminal UI

---

## Technical Architecture

### Component Overview

```
Voice Input (Talon)
    ↓
[Keyboard Manager] ← Monitors dictation state
    ↓               ↓
    ↓           [Steam Keyboard Control]
    ↓
[Claude Integration Layer]
    ↓
[Context Capture] → [Clipboard Manager] → [Prompt Builder]
    ↓
[Claude Code Session]
    ↓
[Response Handler] → [TTS] / [Clipboard] / [Auto-insert]
```

### Integration Points

**With Existing Toggle System:**
- `toggle_sleep.py` calls keyboard manager on mode change
- Keyboard state tracked alongside sleep/wake state
- Unified notification system

**With Talon Community:**
- Leverages existing clipboard commands
- Extends editing/selection commands
- Compatible with existing dictation mode

**With Steam Deck:**
- Steam keyboard URIs: `steam://open/keyboard`, `steam://close/keyboard`
- Fallback to DBus if Steam keyboard unavailable
- Game mode vs Desktop mode detection

### State Management

**Keyboard State:**
- Was keyboard visible before dictation?
- User preference: auto-manage or manual control
- Persists across toggle cycles

**Claude Session State:**
- Active Claude process PID
- Current working directory
- Recent prompts history (last 10)
- Conversation context

**Context Capture:**
- Last captured file/selection
- Active terminal for error capture
- Clipboard history for undo

---

## Implementation Plan

### Milestone 1: Keyboard Management (Week 1)
1. Implement Steam keyboard detection and control
2. Add keyboard manager to toggle_sleep.py
3. Test auto-hide/show on dictation toggle
4. Add manual override commands
5. Handle edge cases (keyboard already closed, Steam not running)

**Deliverable:** Keyboard automatically hides during dictation, shows on sleep

### Milestone 2: Basic Claude Integration (Week 2)
1. Create Claude session manager (start/stop/detect)
2. Implement clipboard-based prompt sending
3. Add basic voice commands: "send to Claude", "Claude [prompt]"
4. Test with simple prompts

**Deliverable:** Can send voice prompts to Claude Code via clipboard

### Milestone 3: Context Capture (Week 3)
1. File context capture (active file detection)
2. Selection context (clipboard-based)
3. Terminal error capture (last N lines)
4. Directory context (tree/ls output)

**Deliverable:** Can voice-capture code/errors and send to Claude with context

### Milestone 4: Prompt Templates (Week 4)
1. Implement template system
2. Add common templates (review, debug, document, test)
3. Voice commands for each template
4. Test end-to-end workflows

**Deliverable:** Quick voice commands for common Claude tasks

### Milestone 5: Polish & Documentation (Week 5)
1. Error handling and edge cases
2. Performance optimization
3. Update README with v2 features
4. Create tutorial/demo video
5. User testing and feedback

**Deliverable:** Production-ready v2 release

---

## File Structure (New in V2)

```
dectation/
├── V2_PLAN.md                          # This file
├── README.md                           # Updated with v2 features
├── scripts/
│   ├── steam-keyboard-control.sh       # Steam keyboard show/hide
│   ├── claude-session-manager.sh       # Start/stop Claude sessions
│   ├── capture-context.sh              # Capture file/selection/errors
│   └── [existing scripts]
├── talon/
│   ├── keyboard_manager.py             # Keyboard state and control
│   ├── claude_integration.py           # Main Claude voice commands
│   ├── claude_context.py               # Context capture utilities
│   ├── claude_templates.py             # Prompt templates
│   ├── claude_session.py               # Session management (Phase 3)
│   ├── claude_tts.py                   # Text-to-speech (Phase 3)
│   └── toggle_sleep.py                 # Updated with keyboard integration
└── [existing files]
```

---

## Voice Command Reference (V2)

### Keyboard Control
- "show keyboard" - Show onscreen keyboard
- "hide keyboard" - Hide onscreen keyboard
- "keyboard stay" - Disable auto-hide for current session
- "keyboard auto" - Re-enable auto-hide

### Claude Session
- "start Claude" / "start Claude session" - Start Claude Code
- "new Claude window" - Open new terminal with Claude
- "pause Claude" - Pause Claude process
- "resume Claude" - Resume Claude process
- "close Claude" - Close Claude session

### Sending Prompts
- "send to Claude" - Send clipboard/selection to Claude
- "Claude [your prompt]" - Direct prompt to Claude
  - "Claude explain this function"
  - "Claude fix this error"
  - "Claude write tests"
- "ask Claude: [question]" - Formatted question

### Context Capture
- "send this file to Claude" - Send current file
- "Claude explain this file" - File + explain prompt
- "Claude look at this" - Send selection
- "Claude debug this" - Send terminal errors
- "Claude show workspace" - Send directory tree

### Quick Actions (Templates)
- "Claude review this" - Code review prompt
- "Claude refactor this" - Refactoring prompt
- "Claude document this" - Documentation prompt
- "Claude write tests" - Test generation prompt
- "Claude commit" - Git commit workflow

### Response Handling
- "copy Claude's answer" - Copy response to clipboard
- "insert Claude's code" - Insert code from response
- "read Claude's answer" - TTS read response (Phase 3)
- "Claude retry" - Resend last prompt

---

## Testing Strategy

### Keyboard Management Tests
1. Toggle dictation → keyboard hides
2. Toggle sleep → keyboard shows (if was visible before)
3. Manual "show keyboard" → stays visible during dictation
4. "keyboard stay" → auto-hide disabled
5. Steam not running → graceful fallback

### Claude Integration Tests
1. "Claude hello world" → sends prompt
2. "send to Claude" with clipboard → sends content
3. "Claude explain this file" → captures file and sends
4. "Claude debug this" with terminal error → captures and formats
5. Template commands → correctly formatted prompts

### End-to-End Workflow Tests
1. L1+Y → dictate code → "send to Claude" → review response
2. Select code → "Claude review this" → read suggestions
3. Terminal error → "Claude debug this" → apply fix
4. "Claude commit" → voice git commit message

### Edge Cases
- Claude not installed → helpful error message
- No active file → prompt for file path
- Empty clipboard → request content
- Keyboard control fails → continue without keyboard management
- Multiple Claude sessions → manage separately

---

## Configuration Options

Settings in `~/.talon/user/dectation_settings.py`:

```python
# Keyboard management
AUTO_HIDE_KEYBOARD = True          # Auto-hide on dictation
KEYBOARD_RESTORE = True            # Restore on sleep
KEYBOARD_DELAY_MS = 200           # Delay before hide/show

# Claude integration
CLAUDE_BINARY = "claude"           # Claude Code binary name
CLAUDE_AUTO_START = True           # Auto-start if not running
CONTEXT_MAX_LINES = 50            # Max lines for error context
PROMPT_HISTORY_SIZE = 10          # Remember last N prompts

# Templates
TEMPLATE_PREFIX = "Claude"         # Voice command prefix
TEMPLATE_AUTO_SEND = False        # Auto-send vs confirm

# TTS (Phase 3)
TTS_ENABLED = False               # Read responses aloud
TTS_RATE = 150                    # Words per minute
```

---

## Success Metrics

**V2 is successful when:**

1. **Keyboard stays out of the way**
   - Zero manual keyboard dismissals during normal dictation workflow
   - Keyboard appears when needed (sleep mode, manual typing)

2. **Voice-to-Claude is seamless**
   - Can send prompt to Claude without touching keyboard/mouse
   - 90% of common tasks achievable via voice
   - Response time < 5 seconds from voice command to Claude processing

3. **Context capture works reliably**
   - Correct file/code captured 95%+ of the time
   - Error context includes relevant information
   - No manual copy/paste needed for common workflows

4. **User experience is smooth**
   - Learning curve < 5 minutes for basic commands
   - Voice commands feel natural and memorable
   - Fewer interruptions to flow state

---

## Future Enhancements (Post-V2)

- **IDE Integration**: Direct integration with VS Code, neovim
- **Smart Context**: AI-powered context detection (what file user is looking at)
- **Conversation Threading**: Multi-turn conversations with Claude
- **Voice Corrections**: "Claude I meant [correction]" to fix prompts
- **Custom Templates**: User-defined prompt templates via config
- **Collaborative Coding**: Share Claude sessions across devices
- **Performance Analytics**: Track time saved vs traditional typing

---

## Migration from V1

V2 is **fully backward compatible** with V1:
- All V1 features continue to work
- V2 features are opt-in (can disable keyboard management)
- Existing keyboard shortcuts unchanged (L1+Y still toggles)
- No breaking changes to configuration

Upgrade path:
1. Pull v2 branch
2. Run `./install.sh` (updates scripts and Talon files)
3. V2 features active immediately
4. Configure via `~/.talon/user/dectation_settings.py` if desired

---

## Contributing to V2

See `CONTRIBUTING.md` for development guidelines.

Key areas for contribution:
- Additional prompt templates
- Platform support (Windows, Mac)
- IDE-specific integrations
- TTS voice options
- Performance optimizations

---

## License

MIT License - Same as V1
