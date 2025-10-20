#!/bin/bash
# Dectation Uninstaller
# Removes all Dectation and Talon Voice components from Steam Deck

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
print_header() {
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}!${NC} $1"
}

print_info() {
    echo -e "${BLUE}→${NC} $1"
}

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

print_header "Dectation Uninstaller for Steam Deck"
echo ""
echo "This will remove:"
echo "  • Talon Voice installation (~/talon/)"
echo "  • Talon community commands (~/.talon/user/community/)"
echo "  • Dectation scripts (toggle_sleep.py)"
echo "  • Keyboard shortcuts configuration"
echo "  • Desktop file integration"
echo "  • Claude Code hooks (audio feedback)"
echo "  • PATH modifications from .bashrc"
echo ""
print_warning "This will NOT remove:"
echo "  • The dectation repository directory ($SCRIPT_DIR)"
echo "  • Talon user configuration (~/.talon/, except Dectation scripts and community)"
echo ""
read -p "Continue with uninstallation? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Uninstallation cancelled."
    exit 0
fi

echo ""
print_header "Step 1: Stopping Talon Voice"

# Stop Talon if running
if pgrep -f "talon/talon" > /dev/null; then
    print_info "Stopping Talon process..."
    pkill -f "talon/talon" || true
    sleep 2

    if pgrep -f "talon/talon" > /dev/null; then
        print_warning "Talon still running, forcing stop..."
        pkill -9 -f "talon/talon" || true
        sleep 1
    fi

    if pgrep -f "talon/talon" > /dev/null; then
        print_error "Could not stop Talon (still running)"
    else
        print_success "Talon stopped"
    fi
else
    print_info "Talon is not running"
fi

echo ""
print_header "Step 2: Removing Keyboard Shortcut"

# Remove from kglobalshortcutsrc
SHORTCUT_FILE="$HOME/.config/kglobalshortcutsrc"
if [ -f "$SHORTCUT_FILE" ]; then
    if grep -q "\[services\]\[net.local.toggle-dictation.sh.desktop\]" "$SHORTCUT_FILE"; then
        print_info "Removing keyboard shortcut configuration..."

        # Create backup
        cp "$SHORTCUT_FILE" "${SHORTCUT_FILE}.dectation-backup"

        # Remove the section (including the _launch line after it)
        sed -i '/\[services\]\[net.local.toggle-dictation.sh.desktop\]/,/^_launch=/d' "$SHORTCUT_FILE"
        print_success "Keyboard shortcut removed (backup saved)"
    else
        print_info "Keyboard shortcut not found in config"
    fi
else
    print_info "Shortcuts config file not found"
fi

# Restart shortcuts service
print_info "Restarting keyboard shortcuts service..."
if systemctl --user restart plasma-kglobalaccel.service 2>/dev/null; then
    print_success "Shortcuts service restarted"
else
    print_warning "Could not restart shortcuts service (may require logout)"
fi

echo ""
print_header "Step 3: Removing Desktop File"

DESKTOP_FILE="$HOME/.local/share/applications/net.local.toggle-dictation.sh.desktop"
if [ -f "$DESKTOP_FILE" ]; then
    print_info "Removing desktop file..."
    rm -f "$DESKTOP_FILE"
    print_success "Desktop file removed"

    # Update desktop database
    if command -v update-desktop-database &> /dev/null; then
        update-desktop-database "$HOME/.local/share/applications" 2>/dev/null || true
    fi
else
    print_info "Desktop file not found"
fi

echo ""
print_header "Step 4: Removing Dectation Scripts"

# Remove toggle_sleep.py from Talon user directory
if [ -f "$HOME/.talon/user/toggle_sleep.py" ]; then
    print_info "Removing toggle_sleep.py..."
    rm -f "$HOME/.talon/user/toggle_sleep.py"
    print_success "Removed toggle_sleep.py"
else
    print_info "toggle_sleep.py not found"
fi

# Remove toggle_sleep.talon if it exists
if [ -f "$HOME/.talon/user/toggle_sleep.talon" ]; then
    print_info "Removing toggle_sleep.talon..."
    rm -f "$HOME/.talon/user/toggle_sleep.talon"
    print_success "Removed toggle_sleep.talon"
fi

echo ""
print_header "Step 5: Removing PATH Configuration"

# Remove dectation PATH entry from .bashrc
if [ -f "$HOME/.bashrc" ]; then
    if grep -q "dectation/scripts" "$HOME/.bashrc"; then
        print_info "Removing PATH configuration from .bashrc..."

        # Create backup
        cp "$HOME/.bashrc" "$HOME/.bashrc.dectation-backup"

        # Remove the dectation lines
        sed -i '/# Dectation voice control scripts/d' "$HOME/.bashrc"
        sed -i '\|export PATH="$HOME/dectation/scripts:$PATH"|d' "$HOME/.bashrc"

        # Remove empty lines that might have been left
        sed -i '/^$/N;/^\n$/D' "$HOME/.bashrc"

        print_success "PATH configuration removed (backup saved)"
    else
        print_info "No PATH configuration found in .bashrc"
    fi
fi

echo ""
print_header "Step 6: Removing Talon Components"

# Ask about removing Talon community
if [ -d "$HOME/.talon/user/community" ]; then
    echo ""
    read -p "Remove Talon community commands? (Y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
        print_info "Removing Talon community..."
        rm -rf "$HOME/.talon/user/community"
        print_success "Talon community removed"
    else
        print_info "Keeping Talon community"
    fi
else
    print_info "Talon community not found"
fi

# Ask about removing Talon installation
if [ -d "$HOME/talon" ]; then
    echo ""
    read -p "Remove Talon Voice installation? (Y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
        print_info "Removing Talon installation..."
        rm -rf "$HOME/talon"
        print_success "Talon installation removed (~talon/)"
    else
        print_info "Keeping Talon installation"
    fi
else
    print_info "Talon installation not found"
fi

# Ask about removing speech models (can take time to re-download)
if [ -d "$HOME/.talon/.sys/blob" ]; then
    BLOB_SIZE=$(du -sh "$HOME/.talon/.sys/blob" 2>/dev/null | cut -f1)
    echo ""
    print_warning "Speech recognition models directory exists: ~/.talon/.sys/blob/ ($BLOB_SIZE)"
    echo "These models will be automatically re-downloaded (~100-200MB) on next Talon start."
    read -p "Remove speech models? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_info "Removing speech models..."
        rm -rf "$HOME/.talon/.sys/blob"
        print_success "Speech models removed (will re-download on next start)"
    else
        print_info "Keeping speech models"
    fi
fi

# Ask about removing entire .talon directory
if [ -d "$HOME/.talon" ]; then
    echo ""
    print_warning "Talon configuration directory still exists: ~/.talon/"
    echo "This may contain your personal Talon settings and customizations."
    read -p "Remove entire Talon configuration directory? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_info "Removing Talon configuration directory..."
        rm -rf "$HOME/.talon"
        print_success "Talon configuration removed (~/.talon/)"
    else
        print_info "Keeping Talon configuration directory"
    fi
fi

echo ""
print_header "Step 7: Removing Claude Code Hooks"

# Remove Claude Code hooks if they exist
if [ -d "$HOME/.claude/hooks" ]; then
    if [ -f "$HOME/.claude/hooks/play-stop-sound.sh" ] || [ -f "$HOME/.claude/hooks/play-prompt-sound.sh" ]; then
        print_info "Removing Dectation Claude hooks..."
        rm -f "$HOME/.claude/hooks/play-stop-sound.sh"
        rm -f "$HOME/.claude/hooks/play-prompt-sound.sh"
        print_success "Claude hooks removed"

        print_warning "Note: Hook configuration in ~/.claude/settings.json needs manual cleanup"
        print_info "Edit ~/.claude/settings.json to remove 'Stop' and 'PreToolUse' hook entries"
    else
        print_info "No Dectation Claude hooks found"
    fi
else
    print_info "Claude hooks directory not found"
fi

echo ""
print_header "Step 8: Cleanup"

# Remove log files
if [ -f "$HOME/.talon/toggle-debug.log" ]; then
    rm -f "$HOME/.talon/toggle-debug.log"
    print_success "Removed debug logs"
fi

# Remove downloaded Talon archive if it still exists
if [ -f "$HOME/talon-linux.tar.xz" ]; then
    print_info "Removing Talon download archive..."
    rm -f "$HOME/talon-linux.tar.xz"
    print_success "Removed talon-linux.tar.xz"
fi

echo ""
print_header "Uninstallation Complete!"
echo ""
print_success "Dectation has been uninstalled from your system."
echo ""
echo "Remaining items:"
echo "  • Dectation repository: $SCRIPT_DIR"
echo "    (You can manually delete this directory if desired)"
echo ""
if [ -f "$HOME/.bashrc.dectation-backup" ]; then
    echo "Backups created:"
    echo "  • ~/.bashrc.dectation-backup"
fi
if [ -f "$HOME/.config/kglobalshortcutsrc.dectation-backup" ]; then
    echo "  • ~/.config/kglobalshortcutsrc.dectation-backup"
fi
echo ""
print_info "You may need to log out and log back in for all changes to take effect."
echo ""
