# Dectation

Voice control for Steam Deck using Talon Voice - the perfect blend of "deck" and "dictation"!

Control your Steam Deck hands-free with voice commands using [Talon Voice](https://talonvoice.com/). Toggle between listening and sleeping mode with a simple keyboard shortcut.

## Features

- 🎤 **Voice Commands**: Full Talon Voice integration for hands-free control
- ⌨️ **Keyboard Shortcut**: Toggle voice control on/off with `Ctrl+Space`
- 🔄 **Auto-Start**: Automatically starts Talon if not running when triggered
- 🔔 **Visual Feedback**: Desktop notifications show current state (Sleeping 😴 / Listening 🎤)
- 🎮 **Steam Deck Optimized**: Configured specifically for Steam Deck in desktop mode

## Prerequisites

- Steam Deck in Desktop Mode (KDE Plasma)
- Talon Voice installed at `~/talon/`
- Talon community config at `~/.talon/user/community/`
- Python 3 (pre-installed on Steam Deck)

## Installation

### 1. Install Talon Voice

Download and extract Talon for Linux:

```bash
cd ~
curl -L -o talon-linux.tar.xz https://talonvoice.com/dl/latest/talon-linux.tar.xz
tar -xf talon-linux.tar.xz
```

### 2. Install Talon Community Commands

```bash
cd ~/.talon/user
git clone https://github.com/talonhub/community.git
```

### 3. Clone This Repository

```bash
cd ~
git clone https://github.com/joeabbey/dectation.git
```

### 4. Install Scripts

Copy the Talon toggle action:

```bash
cp ~/dectation/talon/toggle_sleep.py ~/.talon/user/
```

Make scripts executable:

```bash
chmod +x ~/dectation/scripts/*.sh
```

### 5. Set Up Keyboard Shortcut

Copy the desktop file:

```bash
cp ~/dectation/toggle-dictation.desktop ~/.local/share/applications/
update-desktop-database ~/.local/share/applications
```

Configure the keyboard shortcut in KDE:

1. Open **System Settings** → **Shortcuts** → **Custom Shortcuts**
2. The shortcut for "toggle-dictation" should appear
3. Set it to `Ctrl+Space` (or your preferred key combination)
4. Click **Apply**

Alternatively, you can manually configure via command line:

```bash
# Add shortcut entry to KDE config
kwriteconfig5 --file kglobalshortcutsrc --group "services" --group "net.local.toggle-dictation.sh.desktop" --key "_launch" "Ctrl+Space"

# Restart the shortcuts service
systemctl --user restart plasma-kglobalaccel.service
```

## Usage

### Toggle Voice Control

Press `Ctrl+Space` to toggle between:
- **Listening 🎤** - Talon is active and listening for voice commands
- **Sleeping 😴** - Talon is inactive and ignoring voice input

### Running Scripts Manually

Start Talon:
```bash
~/dectation/scripts/start-talon.sh
```

Toggle sleep mode:
```bash
~/dectation/scripts/toggle-talon.sh
```

## How It Works

1. **Keyboard Shortcut**: `Ctrl+Space` triggers the desktop file via KDE's global shortcuts
2. **Toggle Script**: Checks if Talon is running, starts it if needed
3. **REPL Communication**: Connects to Talon's REPL socket to send commands
4. **Toggle Action**: Calls the custom `toggle_sleep` action in Talon
5. **State Detection**: Checks current mode and toggles between sleep/awake
6. **Feedback**: Shows desktop notifications for state changes

## File Structure

```
dectation/
├── README.md                    # This file
├── scripts/
│   ├── start-talon.sh          # Starts Talon in background
│   └── toggle-talon.sh         # Toggles Talon sleep/wake mode
├── talon/
│   └── toggle_sleep.py         # Talon action for toggling sleep
└── toggle-dictation.desktop    # Desktop file for keyboard shortcut
```

## Troubleshooting

### Keyboard shortcut doesn't work

1. Check if the desktop file is installed:
   ```bash
   ls -la ~/.local/share/applications/net.local.toggle-dictation.sh.desktop
   ```

2. Verify the shortcut is registered:
   ```bash
   grep "toggle-dictation" ~/.config/kglobalshortcutsrc
   ```

3. Restart the shortcuts service:
   ```bash
   systemctl --user restart plasma-kglobalaccel.service
   ```

### Talon doesn't start

1. Check if Talon is installed:
   ```bash
   ls -la ~/talon/talon
   ```

2. Try starting Talon manually:
   ```bash
   ~/dectation/scripts/start-talon.sh
   ```

3. Check Talon logs:
   ```bash
   tail -f ~/.talon/talon.log
   ```

### Toggle doesn't work but Talon is running

1. Check if `toggle_sleep.py` is installed:
   ```bash
   ls -la ~/.talon/user/toggle_sleep.py
   ```

2. Check Talon's REPL socket:
   ```bash
   ls -la ~/.talon/.sys/repl.sock
   ```

3. Test the toggle manually:
   ```bash
   ~/dectation/scripts/toggle-talon.sh
   ```

### Enable Debug Logging

Uncomment debug lines in `scripts/toggle-talon.sh` to enable detailed logging:

```bash
# Change this line:
# echo "=== $(date '+%Y-%m-%d %H:%M:%S') ===" >> "$DEBUG_LOG"

# To this:
echo "=== $(date '+%Y-%m-%d %H:%M:%S') ===" >> "$DEBUG_LOG"
```

Then check logs at:
- `~/.talon/toggle-debug.log` - Script debug output
- `~/.talon/toggle.log` - Toggle events
- `~/.talon/talon.log` - Talon application log

## Credits

- [Talon Voice](https://talonvoice.com/) by Ryan Hileman
- [Talon Community](https://github.com/talonhub/community) for community commands
- Developed for Steam Deck enthusiasts wanting hands-free control

## License

MIT License - Feel free to use and modify!

## Contributing

Contributions welcome! Please open an issue or pull request.

## Support

Having issues? Please check the Troubleshooting section above or open an issue on GitHub.
