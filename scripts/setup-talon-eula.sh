#!/bin/bash
# Setup Talon EULA acceptance and trigger initial model downloads
# This ensures Talon is ready to use on first run

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_info() {
    echo -e "${BLUE}→${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}!${NC} $1"
}

TALON_DIR="$HOME/.talon"
APP_INI="$TALON_DIR/.sys/app.ini"

# Create .talon/.sys directory if it doesn't exist
mkdir -p "$TALON_DIR/.sys"

# Check if EULA is already accepted
if [ -f "$APP_INI" ]; then
    if grep -q "IAgreeToEulaVersion" "$APP_INI"; then
        print_success "Talon EULA already accepted"
        exit 0
    fi
fi

print_info "Setting up Talon EULA acceptance..."

# Create or update app.ini with EULA acceptance
# Version 5 is the current EULA version as of 2023
cat > "$APP_INI" << 'EOF'
[Talon]
IAgreeToEulaVersion=5
EOF

print_success "Talon EULA accepted (version 5)"
print_info "Note: By using this installer, you agree to Talon's EULA at https://talonvoice.com/EULA.txt"

# If startOnLoginPath doesn't exist, add it
if [ -f "$HOME/talon/talon" ]; then
    if ! grep -q "startOnLoginPath" "$APP_INI"; then
        echo "startOnLoginPath=$HOME/talon/talon" >> "$APP_INI"
        print_info "Configured Talon startup path"
    fi
fi

print_success "Talon configuration complete"
echo ""
print_info "When Talon starts for the first time, it will:"
echo "  • Download speech recognition models (~100-200MB)"
echo "  • This happens automatically in the background"
echo "  • You'll see a notification when models are ready"
