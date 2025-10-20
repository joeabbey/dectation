# Claude Code Hooks for Dectation

This directory contains Claude Code hooks that enhance the voice-to-Claude workflow with audio feedback.

## Available Hooks

### play-stop-sound.sh

**Hook:** `Stop`
**Purpose:** Plays a success sound when Claude finishes responding
**Sound:** Pleasant completion chime (completion-success.ogg)
**When it plays:** When Claude finishes responding and is ready for your next prompt

### play-prompt-sound.sh

**Hook:** `PreToolUse` (AskUserQuestion)
**Purpose:** Plays a bell sound when Claude needs your input
**Sound:** Gentle bell tone (bell.ogg)
**When it plays:** When Claude presents options/questions for you to answer

## Installation

### Automatic Installation

Run the install script from the dectation directory:

```bash
cd ~/dectation
./install-claude-hooks.sh
```

This will:
1. Copy both hook scripts to `~/.claude/hooks/`
2. Make them executable
3. Add the hook configurations to `~/.claude/settings.json`
4. Explain the approval process

### Manual Installation

1. **Copy the hook scripts:**
   ```bash
   mkdir -p ~/.claude/hooks
   cp ~/dectation/claude-hooks/play-stop-sound.sh ~/.claude/hooks/
   cp ~/dectation/claude-hooks/play-prompt-sound.sh ~/.claude/hooks/
   chmod +x ~/.claude/hooks/play-stop-sound.sh
   chmod +x ~/.claude/hooks/play-prompt-sound.sh
   ```

2. **Configure Claude Code settings:**

   Edit `~/.claude/settings.json` and add:
   ```json
   {
     "hooks": {
       "Stop": [
         {
           "hooks": [
             {
               "type": "command",
               "command": "/home/deck/.claude/hooks/play-stop-sound.sh"
             }
           ]
         }
       ],
       "PreToolUse": [
         {
           "tool": "AskUserQuestion",
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

3. **Approve the hooks on first use:**
   - Next time you interact with Claude Code, you'll see hook approval dialogs
   - Select "Always allow" to enable the sounds
   - The bell will play when Claude is ready for input

## How It Works

### Normal Response Flow (Stop Hook)

```
┌─────────────────────────────────────────┐
│  You submit a prompt in Claude Code     │
└───────────────┬─────────────────────────┘
                │
                ▼
┌─────────────────────────────────────────┐
│   Claude processes your request          │
│   Claude generates response...           │
└───────────────┬─────────────────────────┘
                │
                ▼
┌─────────────────────────────────────────┐
│   Claude finishes responding             │
│   Stop hook triggers                     │
│   play-prompt-sound.sh executes          │
└───────────────┬─────────────────────────┘
                │
                ▼
┌─────────────────────────────────────────┐
│      🔔 Bell sound plays                 │
│   "I'm done, you can speak now!"         │
└─────────────────────────────────────────┘
```

### Options/Questions Flow (PreToolUse Hook)

```
┌─────────────────────────────────────────┐
│   Claude needs your input/decision       │
│   PreToolUse(AskUserQuestion) triggers   │
│   play-prompt-sound.sh executes          │
└───────────────┬─────────────────────────┘
                │
                ▼
┌─────────────────────────────────────────┐
│      🔔 Bell sound plays                 │
│   "I need your input!"                   │
└───────────────┬─────────────────────────┘
                │
                ▼
┌─────────────────────────────────────────┐
│   Options appear for you to select      │
└─────────────────────────────────────────┘
```

## Benefits

- **Perfect timing:** Know exactly when Claude is ready for your input
- **Distinct sounds:** Different audio cues for different events
  - Success chime when Claude finishes responding
  - Bell when Claude needs your input on a question
- **Voice workflow enhancement:** Clear audio cues to start speaking your response
- **Complete coverage:** Works for both normal responses and interactive questions
- **Automatic:** No manual intervention needed once configured

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

3. **Test the sound scripts manually:**
   ```bash
   ~/dectation/scripts/play-sound.sh prompt
   # Should hear a bell sound (for questions/options)

   ~/dectation/scripts/play-sound.sh success
   # Should hear a success chime (for Claude finishing)
   ```

4. **Check Claude settings:**
   ```bash
   cat ~/.claude/settings.json | grep -A 20 "hooks"
   # Should show both Stop and PreToolUse hook configurations
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
