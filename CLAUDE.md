# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Dectation** is a voice control system for Steam Deck that integrates Talon Voice with a hardware button toggle. The name combines "deck" and "dictation". Users press `L1 + Y` on Steam Deck (which maps to `Ctrl+Space` in desktop mode) to toggle between dictation mode and sleep.

**Key Behavior**: When waking from sleep, Talon automatically enters dictation mode - users can immediately start speaking without saying "dictation mode" first.

## Architecture

The system consists of three interconnected components:

### 1. KDE Global Shortcut Integration
- **Desktop file**: `toggle-dictation.desktop` registers with KDE's global shortcuts system
- **Configuration**: Entry in `~/.config/kglobalshortcutsrc` maps `Ctrl+Space` to the desktop file
- **Service**: `plasma-kglobalaccel.service` manages the keyboard shortcut triggers

### 2. Toggle Script (`scripts/toggle-talon.sh`)
- Auto-starts Talon if not running (via `start-talon.sh`)
- Connects to Talon's REPL socket at `~/.talon/.sys/repl.sock`
- Uses JSON protocol: `{"cmd": "input", "text": "from talon import actions; actions.user.toggle_sleep()"}`
- REPL communication is critical - must send commands as JSON, not raw Python

### 3. Talon Action (`talon/toggle_sleep.py`)
- Checks sleep state using `scope.get("mode", [])` - looking for "sleep" in modes list
- **Wake behavior**: Explicitly disables command mode and enables dictation mode
- Uses `actions.speech.enable()/disable()` for wake/sleep
- Must be installed to `~/.talon/user/toggle_sleep.py` to be loaded by Talon

## Installation Flow

The `install.sh` script handles:
1. Downloading and extracting Talon from talonvoice.com
2. Cloning Talon community commands to `~/.talon/user/community/`
3. Copying `toggle_sleep.py` to `~/.talon/user/`
4. Installing desktop file to `~/.local/share/applications/`
5. Configuring `~/.config/kglobalshortcutsrc` with the `Ctrl+Space` mapping
6. Restarting `plasma-kglobalaccel.service` to register the shortcut

## Critical Implementation Details

### Steam Deck Button Mapping
- `L1 + Y` on Steam Deck hardware = `Ctrl+Space` in KDE desktop mode
- All user-facing documentation should reference `L1 + Y` first, then mention `Ctrl+Space`

### Talon REPL Protocol
The REPL expects JSON messages, not raw Python:
```python
command = {
    "cmd": "input",
    "text": "from talon import actions; actions.user.toggle_sleep()"
}
writer.write(json.dumps(command) + '\n')
```

### Mode Management
- Talon modes: `sleep`, `command`, `dictation`, `all`, `hotkey`, `noise`, `gamepad`, `deck`, `face`
- Check sleep state: `"sleep" in scope.get("mode", [])`
- Wake sequence: disable sleep/command, enable dictation
- This ensures users wake directly into dictation mode for immediate use

### File Paths
Scripts reference absolute paths to `~/dectation/scripts/` and `~/.talon/`:
- `toggle-dictation.desktop` → `Exec=/home/deck/dectation/scripts/toggle-talon.sh`
- `toggle-talon.sh` → starts via `~/dectation/scripts/start-talon.sh`
- `toggle_sleep.py` → must exist at `~/.talon/user/toggle_sleep.py`

## Testing Changes

**Test the toggle script directly:**
```bash
~/dectation/scripts/toggle-talon.sh
```

**Enable debug logging:**
Uncomment all lines starting with `# echo` in `scripts/toggle-talon.sh` to write to `~/.talon/toggle-debug.log`

**Check Talon logs:**
```bash
tail -f ~/.talon/talon.log
```

**Verify keyboard shortcut registration:**
```bash
grep "toggle-dictation" ~/.config/kglobalshortcutsrc
systemctl --user restart plasma-kglobalaccel.service
```

**Test after modifying `toggle_sleep.py`:**
Must copy to `~/.talon/user/` for Talon to load changes:
```bash
cp ~/dectation/talon/toggle_sleep.py ~/.talon/user/
```

## Common Modifications

**Changing wake-up mode:**
Edit `toggle_sleep.py` in the wake-up section - modify which modes are enabled/disabled after `actions.speech.enable()`

**Changing notification messages:**
Edit `app.notify()` calls in `toggle_sleep.py`

**Adjusting keyboard shortcut:**
Update both `toggle-dictation.desktop` and the installer's `kglobalshortcutsrc` configuration

**Modifying auto-start behavior:**
Edit the Talon detection and start logic at the beginning of `toggle-talon.sh`
