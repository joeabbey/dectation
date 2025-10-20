# Claude Code Hooks for Dectation

This directory contains Claude Code hooks that enhance the voice-to-Claude workflow with audio feedback.

## Available Hooks

### play-prompt-sound.sh

**Type:** `UserPromptSubmit` hook
**Purpose:** Plays a soft bell sound when you submit a prompt to Claude Code
**Sound:** Gentle bell tone (same as used for Talon voice commands)

## Installation

### Automatic Installation

Run the install script from the dectation directory:

```bash
cd ~/dectation
./install-claude-hooks.sh
```

This will:
1. Copy the hook script to `~/.claude/hooks/`
2. Make it executable
3. Add the hook configuration to `~/.claude/settings.json`
4. Explain the approval process

### Manual Installation

1. **Copy the hook script:**
   ```bash
   mkdir -p ~/.claude/hooks
   cp ~/dectation/claude-hooks/play-prompt-sound.sh ~/.claude/hooks/
   chmod +x ~/.claude/hooks/play-prompt-sound.sh
   ```

2. **Configure Claude Code settings:**

   Edit `~/.claude/settings.json` and add:
   ```json
   {
     "hooks": {
       "UserPromptSubmit": [
         {
           "hooks": [
             {
               "type": "command",
               "command": "/home/deck/.claude/hooks/play-prompt-sound.sh"
             }
           ]
         }
       ]
     }
   }
   ```

3. **Approve the hook on first use:**
   - Next time you submit a prompt in Claude Code, you'll see a hook approval dialog
   - Select "Always allow" to enable the sound for all future prompts
   - The bell will play immediately after approval

## How It Works

```
┌─────────────────────────────────────────┐
│  You type/paste prompt in Claude Code   │
└───────────────┬─────────────────────────┘
                │
                ▼
┌─────────────────────────────────────────┐
│       Press Enter to submit              │
└───────────────┬─────────────────────────┘
                │
                ▼
┌─────────────────────────────────────────┐
│  UserPromptSubmit hook triggers          │
│  play-prompt-sound.sh executes           │
└───────────────┬─────────────────────────┘
                │
                ▼
┌─────────────────────────────────────────┐
│      🔔 Bell sound plays                 │
└───────────────┬─────────────────────────┘
                │
                ▼
┌─────────────────────────────────────────┐
│   Prompt continues to Claude             │
│   Claude processes your request          │
└─────────────────────────────────────────┘
```

## Benefits

- **Immediate feedback:** Know when your prompt was submitted
- **Pleasant UX:** Soft, non-intrusive bell tone
- **Voice workflow enhancement:** Confirms successful prompt submission
- **Automatic:** Works for all prompts (typed, pasted, or voice-dictated)

## Troubleshooting

### Sound doesn't play

1. **Check if hook is approved:**
   - Open Claude Code
   - Type a test prompt and press Enter
   - Look for the approval dialog

2. **Verify hook script exists and is executable:**
   ```bash
   ls -la ~/.claude/hooks/play-prompt-sound.sh
   # Should show -rwxr-xr-x permissions
   ```

3. **Test the sound script manually:**
   ```bash
   ~/dectation/scripts/play-sound.sh prompt
   # Should hear a bell sound
   ```

4. **Check Claude settings:**
   ```bash
   cat ~/.claude/settings.json | grep -A 10 "UserPromptSubmit"
   # Should show the hook configuration
   ```

### Hook approval keeps prompting

If Claude keeps asking for approval instead of remembering your choice:
- Make sure you selected "Always allow" not just "Allow once"
- Check that Claude Code has permissions to write to `~/.claude/`

### Want to disable the sound?

Remove the hook from `~/.claude/settings.json`:
```bash
# Edit the file and remove the "hooks" section
nano ~/.claude/settings.json
```

Or use Claude Code's `/hooks` menu to disable it.

## See Also

- [Claude Code Hooks Documentation](https://docs.claude.com/en/docs/claude-code/hooks)
- [Dectation V2 README](../docs/README_V2.md)
- [V2 Summary](../docs/V2_SUMMARY.md)
