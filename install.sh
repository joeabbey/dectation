#!/bin/bash
# Dectation Easy Installer
# Automatically sets up voice control for Steam Deck

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

print_header "Dectation Installer for Steam Deck"
echo ""
echo "This installer will set up voice control for your Steam Deck."
echo "It will:"
echo "  • Download and install Talon Voice"
echo "  • Accept Talon EULA (https://talonvoice.com/EULA.txt)"
echo "  • Download speech recognition models (~100-200MB)"
echo "  • Install Talon community commands"
echo "  • Configure keyboard shortcuts (Ctrl+Space)"
echo "  • Set up all necessary scripts"
echo ""
echo "By continuing, you agree to the Talon Voice EULA."
echo ""
read -p "Continue with installation? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Installation cancelled."
    exit 0
fi

echo ""
print_header "Step 1: Checking Prerequisites"

# Check if we're on Steam Deck
if [ ! -f /etc/os-release ] || ! grep -q "steamdeck" /etc/os-release 2>/dev/null; then
    print_warning "This doesn't appear to be a Steam Deck, but continuing anyway..."
else
    print_success "Running on Steam Deck"
fi

# Check for required commands
if ! command -v python3 &> /dev/null; then
    print_error "Python 3 is required but not found"
    exit 1
fi
print_success "Python 3 found"

if ! command -v git &> /dev/null; then
    print_error "Git is required but not found"
    exit 1
fi
print_success "Git found"

if ! command -v curl &> /dev/null; then
    print_error "curl is required but not found"
    exit 1
fi
print_success "curl found"

echo ""
print_header "Step 2: Installing Talon Voice"

# Check if Talon is already installed
if [ -d "$HOME/talon" ] && [ -f "$HOME/talon/talon" ]; then
    print_warning "Talon already installed at ~/talon/"
    read -p "Skip Talon installation? (Y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Nn]$ ]]; then
        rm -rf "$HOME/talon"
    else
        print_info "Skipping Talon installation"
        SKIP_TALON=true
    fi
fi

if [ "$SKIP_TALON" != "true" ]; then
    print_info "Downloading Talon Voice..."
    cd "$HOME"

    # Download Talon
    if [ -f "talon-linux.tar.xz" ]; then
        print_info "Talon archive already downloaded, using existing file"
    else
        curl -L -o talon-linux.tar.xz "https://talonvoice.com/dl/latest/talon-linux.tar.xz"
        print_success "Downloaded Talon Voice"
    fi

    # Extract Talon
    print_info "Extracting Talon..."
    tar -xf talon-linux.tar.xz
    print_success "Extracted Talon Voice"

    # Clean up
    rm talon-linux.tar.xz
    print_success "Talon Voice installed to ~/talon/"
fi

echo ""
print_header "Step 3: Installing Talon Community Commands"

# Create .talon/user directory
mkdir -p "$HOME/.talon/user"

# Check if community is already installed
if [ -d "$HOME/.talon/user/community" ]; then
    print_warning "Talon community already installed"
    read -p "Update existing installation? (Y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
        print_info "Updating Talon community..."
        cd "$HOME/.talon/user/community"
        git pull
        print_success "Updated Talon community"
    else
        print_info "Skipping community installation"
    fi
else
    print_info "Cloning Talon community repository..."
    cd "$HOME/.talon/user"
    git clone https://github.com/talonhub/community.git
    print_success "Installed Talon community commands"
fi

echo ""
print_header "Step 4: Accepting Talon EULA"

# Run EULA setup script
print_info "Configuring Talon EULA acceptance..."
"$SCRIPT_DIR/scripts/setup-talon-eula.sh"

echo ""
print_header "Step 5: Installing Dectation Scripts"

# Copy Talon scripts to user directory
print_info "Installing Talon scripts..."
cp "$SCRIPT_DIR/talon/toggle_sleep.py" "$HOME/.talon/user/"
print_success "Installed toggle_sleep.py"

# V2: Install keyboard manager and Claude integration
if [ -f "$SCRIPT_DIR/talon/keyboard_manager.py" ]; then
    cp "$SCRIPT_DIR/talon/keyboard_manager.py" "$HOME/.talon/user/"
    print_success "Installed keyboard_manager.py (V2)"
fi

if [ -f "$SCRIPT_DIR/talon/claude_integration.py" ]; then
    cp "$SCRIPT_DIR/talon/claude_integration.py" "$HOME/.talon/user/"
    print_success "Installed claude_integration.py (V2)"
fi

if [ -f "$SCRIPT_DIR/talon/claude_templates.py" ]; then
    cp "$SCRIPT_DIR/talon/claude_templates.py" "$HOME/.talon/user/"
    print_success "Installed claude_templates.py (V2)"
fi

# V2: Copy Talon command files
if [ -f "$SCRIPT_DIR/talon/keyboard_commands.talon" ]; then
    cp "$SCRIPT_DIR/talon/keyboard_commands.talon" "$HOME/.talon/user/"
    print_success "Installed keyboard_commands.talon (V2)"
fi

if [ -f "$SCRIPT_DIR/talon/claude_commands.talon" ]; then
    cp "$SCRIPT_DIR/talon/claude_commands.talon" "$HOME/.talon/user/"
    print_success "Installed claude_commands.talon (V2)"
fi

# Make scripts executable
print_info "Making scripts executable..."
chmod +x "$SCRIPT_DIR/scripts"/*.sh
print_success "Scripts are now executable"

echo ""
print_header "Step 6: Setting Up Keyboard Shortcut"

# Copy desktop file
print_info "Installing desktop file..."
mkdir -p "$HOME/.local/share/applications"
cp "$SCRIPT_DIR/desktop/toggle-dictation.desktop" "$HOME/.local/share/applications/net.local.toggle-dictation.sh.desktop"

# Update desktop database
if command -v update-desktop-database &> /dev/null; then
    update-desktop-database "$HOME/.local/share/applications" 2>/dev/null || true
fi
print_success "Desktop file installed"

# Configure keyboard shortcut
print_info "Configuring Ctrl+Space keyboard shortcut..."

# Add to kglobalshortcutsrc
SHORTCUT_FILE="$HOME/.config/kglobalshortcutsrc"

if [ -f "$SHORTCUT_FILE" ]; then
    # Check if entry already exists
    if grep -q "\[services\]\[net.local.toggle-dictation.sh.desktop\]" "$SHORTCUT_FILE"; then
        print_warning "Keyboard shortcut already configured"
    else
        # Add shortcut entry
        cat >> "$SHORTCUT_FILE" << 'EOF'

[services][net.local.toggle-dictation.sh.desktop]
_launch=Ctrl+Space
EOF
        print_success "Keyboard shortcut configured"
    fi
else
    print_warning "KDE shortcuts config not found, you may need to configure manually"
fi

# Restart shortcuts service
print_info "Restarting keyboard shortcuts service..."
if systemctl --user restart plasma-kglobalaccel.service 2>/dev/null; then
    print_success "Shortcuts service restarted"

    # Verify shortcut was registered
    sleep 1
    if grep -q "Ctrl+Space" "$SHORTCUT_FILE" 2>/dev/null; then
        print_success "Keyboard shortcut Ctrl+Space successfully configured!"
    fi
else
    print_warning "Could not restart shortcuts service (may require logout)"
fi

echo ""
print_header "Step 7: Final Setup"

# Create log directory
mkdir -p "$HOME/.talon"
print_success "Created log directory"

# Add dectation scripts to PATH (optional)
if ! grep -q "dectation/scripts" "$HOME/.bashrc" 2>/dev/null; then
    print_info "Adding dectation scripts to PATH..."
    echo '' >> "$HOME/.bashrc"
    echo '# Dectation voice control scripts' >> "$HOME/.bashrc"
    echo 'export PATH="$HOME/dectation/scripts:$PATH"' >> "$HOME/.bashrc"
    print_success "Added to PATH (will take effect in new terminals)"
else
    print_info "PATH already configured (skipping)"
fi

echo ""
print_header "Installation Complete!"
echo ""
print_success "Dectation has been successfully installed!"
echo ""
print_warning "IMPORTANT: First-time setup required!"
echo ""
echo "After Talon starts, you need to install speech models (one-time setup):"
echo "  1. Look for the Talon microphone icon in your system tray"
echo "  2. Right-click the icon"
echo "  3. Select: Speech Recognition → Install Conformer"
echo "  4. Wait for models to download (~100-200MB)"
echo "  5. You'll see a notification when ready!"
echo ""
echo "Next steps:"
echo "  1. Start Talon (can be done automatically below)"
echo "  2. Install speech models via Talon tray icon (see above)"
echo "  3. Press L1 + Y on Steam Deck (Ctrl+Space) to toggle voice control"
echo ""
print_info "V2 Features Installed:"
echo "  • Automatic keyboard management (hides during dictation)"
echo "  • Voice commands for Claude Code integration"
echo "  • Quick prompt templates (review, refactor, debug, etc.)"
echo ""
echo "V2 Voice Commands:"
echo "  • 'show/hide keyboard' - Manual keyboard control"
echo "  • 'start claude' - Start Claude Code session"
echo "  • 'claude review this' - Send code review prompt"
echo "  • 'send to claude' - Send clipboard to Claude"
echo ""
echo "Tips:"
echo "  • When Talon starts, it will show a microphone icon in your system tray"
echo "  • Press L1 + Y to put Talon to sleep (icon changes)"
echo "  • Press L1 + Y again to wake Talon up"
echo "  • Say 'help alphabet' to learn voice commands"
echo ""
echo "Steam Deck Button Mapping:"
echo "  • L1 + Y = Ctrl+Space (toggle voice control)"
echo ""
echo "Note: If the Ctrl+Space shortcut doesn't work immediately, you may need to:"
echo "  • Log out and log back in, OR"
echo "  • Manually set it in: System Settings → Shortcuts → Custom Shortcuts"
echo ""

# Check if Talon is already running
if pgrep -f "talon/talon" > /dev/null; then
    print_success "Talon is already running!"
    echo ""
    echo "Press L1 + Y to toggle voice control on/off."
else
    read -p "Start Talon now? (Y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
        print_info "Starting Talon..."
        nohup "$SCRIPT_DIR/scripts/start-talon.sh" > /dev/null 2>&1 &
        sleep 2

        if pgrep -f "talon/talon" > /dev/null; then
            print_success "Talon is now running!"
            echo ""
            echo "Look for the microphone icon in your system tray."
            echo "Try saying 'help alphabet' to test voice control!"
        else
            print_warning "Talon may not have started. Try running: $SCRIPT_DIR/scripts/start-talon.sh"
        fi
    else
        echo ""
        echo "You can start Talon later with:"
        echo "  $SCRIPT_DIR/scripts/start-talon.sh"
    fi
fi

echo ""
print_header "Enjoy Dectation!"
echo ""
echo "For help and documentation, see:"
echo "  $SCRIPT_DIR/README.md"
echo "  https://github.com/joeabbey/dectation"
echo ""
