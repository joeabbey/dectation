# Testing Guide for Dectation

This guide explains how to test the installation and functionality of Dectation.

## Automated Testing

### Quick Unit Tests

Run the automated test suite to verify basic installer functionality:

```bash
./test-install.sh
```

This tests:
- ✅ Prerequisites (Python, Git, curl)
- ✅ Directory creation
- ✅ File installation (toggle_sleep.py, desktop file)
- ✅ .bashrc PATH addition
- ✅ Idempotency (can run multiple times safely)
- ✅ Script permissions
- ✅ Repository structure
- ✅ Desktop file format
- ✅ Python syntax validation

**Note**: This runs in an isolated temporary environment and does not modify your actual system.

## Manual Testing

### 1. Fresh Installation Test

Test a complete fresh install:

```bash
# Backup existing installation (if any)
mv ~/.talon/user/toggle_sleep.py ~/.talon/user/toggle_sleep.py.backup 2>/dev/null || true
mv ~/.local/share/applications/net.local.toggle-dictation.sh.desktop ~/.local/share/applications/net.local.toggle-dictation.sh.desktop.backup 2>/dev/null || true

# Run installer
cd ~/dectation
./install.sh

# Expected: Should complete successfully with colored output
```

**Verify**:
- [ ] Talon downloads and extracts to `~/talon/`
- [ ] Community commands clone to `~/.talon/user/community/`
- [ ] `toggle_sleep.py` exists at `~/.talon/user/toggle_sleep.py`
- [ ] Desktop file exists at `~/.local/share/applications/net.local.toggle-dictation.sh.desktop`
- [ ] `.bashrc` contains dectation PATH entry (check with `grep dectation ~/.bashrc`)
- [ ] Keyboard shortcut is in `~/.config/kglobalshortcutsrc` (check with `grep toggle-dictation ~/.config/kglobalshortcutsrc`)

### 2. Idempotency Test

Test that running installer multiple times is safe:

```bash
# Run installer again
./install.sh

# Expected: Should detect existing installation and prompt to skip/update
```

**Verify**:
- [ ] Prompts whether to skip Talon installation
- [ ] Prompts whether to update community commands
- [ ] Shows "Keyboard shortcut already configured"
- [ ] Shows "PATH already configured (skipping)"
- [ ] No duplicate entries in `.bashrc`

### 3. Toggle Script Test

Test the toggle functionality:

```bash
# Make sure Talon is running first
~/dectation/scripts/start-talon.sh

# Wait for Talon to fully start (look for microphone icon in system tray)
sleep 5

# Test toggle
~/dectation/scripts/toggle-talon.sh

# Expected: Should see notification showing state change
```

**Verify**:
- [ ] First toggle: Shows "Sleeping 😴" notification (if was awake) or "Dictation Mode 🎤" (if was asleep)
- [ ] Talon icon changes in system tray
- [ ] Second toggle: Shows opposite notification
- [ ] State actually changes (microphone icon reflects sleep/wake state)

### 4. Keyboard Shortcut Test

Test the hardware button toggle:

```bash
# Make sure Talon is running
pgrep -f "talon/talon"

# Press L1 + Y on Steam Deck (or Ctrl+Space on keyboard)
```

**Verify**:
- [ ] Notification appears showing state change
- [ ] If Talon was asleep, shows "Dictation Mode 🎤"
- [ ] If Talon was awake, shows "Sleeping 😴"
- [ ] Icon in system tray changes appropriately
- [ ] When waking, Talon is in dictation mode (can immediately start speaking text)

### 5. Auto-Start Test

Test that toggle auto-starts Talon if not running:

```bash
# Kill Talon if running
pkill -f "talon/talon"

# Press L1 + Y (or run toggle script)
~/dectation/scripts/toggle-talon.sh

# Expected: Should auto-start Talon
```

**Verify**:
- [ ] Shows "Starting Talon..." notification
- [ ] Shows "Talon started!" notification after ~2-3 seconds
- [ ] Shows "Dictation Mode 🎤" notification
- [ ] Talon icon appears in system tray
- [ ] Can immediately start dictating

### 6. Dictation Mode Test

Verify that waking enters dictation mode automatically:

```bash
# Make sure Talon is running
~/dectation/scripts/start-talon.sh

# Put to sleep
~/dectation/scripts/toggle-talon.sh

# Wake up
~/dectation/scripts/toggle-talon.sh

# Immediately start speaking (without saying "dictation mode")
```

**Verify**:
- [ ] Notification says "Dictation Mode 🎤" (not just "Listening")
- [ ] Spoken text appears immediately without needing to say "dictation mode"
- [ ] Works consistently every time you wake

## Integration Testing Checklist

Complete integration test on actual Steam Deck:

- [ ] Fresh install completes without errors
- [ ] L1 + Y keyboard shortcut works
- [ ] Toggle between sleep/wake with L1 + Y
- [ ] Auto-starts Talon when not running
- [ ] Wakes in dictation mode automatically
- [ ] Desktop notifications appear
- [ ] System tray icon changes state
- [ ] Voice dictation works after waking
- [ ] Installer is idempotent (can run multiple times)
- [ ] All files in correct locations

## Troubleshooting Tests

### Test REPL Connection

Verify Talon's REPL is accessible:

```bash
# Check REPL socket exists
ls -la ~/.talon/.sys/repl.sock

# Test REPL connection
python3 << 'EOF'
import socket
import os
import json

repl_path = os.path.expanduser("~/.talon/.sys/repl.sock")
sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
sock.connect(repl_path)
writer = sock.makefile('w', buffering=1, encoding='utf8')
reader = sock.makefile('r', buffering=1, encoding='utf8')
greeting = reader.readline()
print(f"REPL connection successful: {greeting}")
sock.close()
EOF
```

### Test Keyboard Shortcut Registration

Verify shortcut is registered:

```bash
# Check shortcut file
grep "toggle-dictation" ~/.config/kglobalshortcutsrc

# Check service is running
systemctl --user status plasma-kglobalaccel.service

# Restart service
systemctl --user restart plasma-kglobalaccel.service
```

### Enable Debug Logging

For detailed troubleshooting:

```bash
# Edit toggle-talon.sh and uncomment debug lines
cd ~/dectation/scripts
# Uncomment all lines starting with "# echo" in toggle-talon.sh

# Run toggle
~/dectation/scripts/toggle-talon.sh

# Check logs
cat ~/.talon/toggle-debug.log
cat ~/.talon/toggle.log
tail -50 ~/.talon/talon.log
```

## Expected Log Entries

### Successful Toggle (from toggle_sleep.py logs):

```
2025-10-18 11:38:33 - toggle_sleep called
2025-10-18 11:38:33 - is_sleeping: True
2025-10-18 11:38:33 - current modes: {'all', 'sleep', 'hotkey', 'noise', 'gamepad', 'deck', 'face'}
2025-10-18 11:38:33 - Waking up (calling speech.enable())
2025-10-18 11:38:33 - Switching to dictation mode
2025-10-18 11:38:33 - Sent dictation mode notification
```

## Test Coverage Summary

| Component | Unit Test | Manual Test | Integration Test |
|-----------|-----------|-------------|------------------|
| Installer | ✅ | ✅ | ✅ |
| Toggle Script | ❌ | ✅ | ✅ |
| Keyboard Shortcut | ❌ | ✅ | ✅ |
| REPL Communication | ❌ | ✅ | ✅ |
| Dictation Mode | ❌ | ✅ | ✅ |
| Auto-Start | ❌ | ✅ | ✅ |
| Idempotency | ✅ | ✅ | ✅ |

## Continuous Testing

For ongoing development:

1. **Before commits**: Run `./test-install.sh`
2. **After script changes**: Test toggle manually
3. **After Python changes**: Copy to `~/.talon/user/` and test
4. **After installer changes**: Test fresh install in VM or isolated environment
5. **Before releases**: Complete integration testing checklist

## Known Limitations

- Automated tests don't cover:
  - Actual Talon installation (too large to download in tests)
  - KDE keyboard shortcut registration (requires running KDE)
  - System tray icon changes (requires GUI)
  - Actual voice dictation (requires Talon running)

These require manual testing on actual Steam Deck hardware.
