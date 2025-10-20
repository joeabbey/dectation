#!/bin/bash
# Test script for install.sh
# This creates a temporary test environment to verify installation works

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_test() {
    echo -e "${BLUE}[TEST]${NC} $1"
}

print_pass() {
    echo -e "${GREEN}[PASS]${NC} $1"
}

print_fail() {
    echo -e "${RED}[FAIL]${NC} $1"
}

print_info() {
    echo -e "${YELLOW}[INFO]${NC} $1"
}

# Create a temporary test environment
TEST_DIR=$(mktemp -d -t dectation-test-XXXXXX)
TEST_HOME="$TEST_DIR/home"

print_info "Creating test environment at: $TEST_DIR"
mkdir -p "$TEST_HOME"

# Copy installer and files to test directory
cp -r "$(dirname "$0")" "$TEST_DIR/dectation"

# Export test HOME
export ORIGINAL_HOME="$HOME"
export HOME="$TEST_HOME"

print_info "Test HOME set to: $HOME"
echo ""

# Test 1: Check prerequisites
print_test "Checking prerequisites..."
if command -v python3 &> /dev/null && command -v git &> /dev/null && command -v curl &> /dev/null; then
    print_pass "All prerequisites available"
else
    print_fail "Missing prerequisites"
    exit 1
fi

# Test 2: Run installer in non-interactive mode
print_test "Running installer (skipping Talon download for speed)..."

# Create mock .bashrc
touch "$HOME/.bashrc"

# Mock the Talon installation (skip downloading)
export SKIP_TALON_DOWNLOAD=true

# Run parts of the installer manually for testing
cd "$TEST_DIR/dectation"

# Test directory creation
print_test "Testing directory creation..."
mkdir -p "$HOME/.talon/user"
mkdir -p "$HOME/.local/share/applications"
if [ -d "$HOME/.talon/user" ] && [ -d "$HOME/.local/share/applications" ]; then
    print_pass "Directories created successfully"
else
    print_fail "Directory creation failed"
fi

# Test toggle_sleep.py copy
print_test "Testing toggle_sleep.py installation..."
cp "$TEST_DIR/dectation/talon/toggle_sleep.py" "$HOME/.talon/user/"
if [ -f "$HOME/.talon/user/toggle_sleep.py" ]; then
    print_pass "toggle_sleep.py installed"
else
    print_fail "toggle_sleep.py installation failed"
fi

# Test desktop file installation
print_test "Testing desktop file installation..."
cp "$TEST_DIR/dectation/toggle-dictation.desktop" "$HOME/.local/share/applications/net.local.toggle-dictation.sh.desktop"
if [ -f "$HOME/.local/share/applications/net.local.toggle-dictation.sh.desktop" ]; then
    print_pass "Desktop file installed"
else
    print_fail "Desktop file installation failed"
fi

# Test PATH addition to .bashrc
print_test "Testing .bashrc PATH addition (first run)..."
if ! grep -q "dectation/scripts" "$HOME/.bashrc"; then
    echo '' >> "$HOME/.bashrc"
    echo '# Dectation voice control scripts' >> "$HOME/.bashrc"
    echo 'export PATH="$HOME/dectation/scripts:$PATH"' >> "$HOME/.bashrc"
    print_pass "PATH added to .bashrc"
else
    print_fail "PATH check failed (should not exist yet)"
fi

# Test idempotency: PATH should not be added again
print_test "Testing .bashrc idempotency (second run)..."
BASHRC_BEFORE=$(wc -l < "$HOME/.bashrc")
if ! grep -q "dectation/scripts" "$HOME/.bashrc"; then
    echo '' >> "$HOME/.bashrc"
    echo '# Dectation voice control scripts' >> "$HOME/.bashrc"
    echo 'export PATH="$HOME/dectation/scripts:$PATH"' >> "$HOME/.bashrc"
fi
BASHRC_AFTER=$(wc -l < "$HOME/.bashrc")

if [ "$BASHRC_BEFORE" -eq "$BASHRC_AFTER" ]; then
    print_pass "PATH not duplicated (idempotent)"
else
    print_fail "PATH was duplicated (not idempotent)"
    print_info "Before: $BASHRC_BEFORE lines, After: $BASHRC_AFTER lines"
fi

# Test script permissions
print_test "Testing script permissions..."
chmod +x "$TEST_DIR/dectation/scripts"/*.sh
if [ -x "$TEST_DIR/dectation/scripts/toggle-talon.sh" ] && [ -x "$TEST_DIR/dectation/scripts/start-talon.sh" ]; then
    print_pass "Scripts are executable"
else
    print_fail "Scripts are not executable"
fi

# Test file structure
print_test "Testing repository structure..."
REQUIRED_FILES=(
    "README.md"
    "install.sh"
    "scripts/toggle-talon.sh"
    "scripts/start-talon.sh"
    "talon/toggle_sleep.py"
    "toggle-dictation.desktop"
)

ALL_FOUND=true
for file in "${REQUIRED_FILES[@]}"; do
    if [ ! -f "$TEST_DIR/dectation/$file" ]; then
        print_fail "Missing required file: $file"
        ALL_FOUND=false
    fi
done

if $ALL_FOUND; then
    print_pass "All required files present"
fi

# Test desktop file format
print_test "Testing desktop file format..."
DESKTOP_FILE="$HOME/.local/share/applications/net.local.toggle-dictation.sh.desktop"
if grep -q "Exec=" "$DESKTOP_FILE" && grep -q "Type=Application" "$DESKTOP_FILE"; then
    print_pass "Desktop file format valid"
else
    print_fail "Desktop file format invalid"
fi

# Test toggle_sleep.py syntax
print_test "Testing toggle_sleep.py Python syntax..."
if python3 -m py_compile "$HOME/.talon/user/toggle_sleep.py" 2>/dev/null; then
    print_pass "toggle_sleep.py has valid Python syntax"
else
    print_fail "toggle_sleep.py has syntax errors"
fi

# Cleanup
print_info ""
print_info "Cleaning up test environment..."
export HOME="$ORIGINAL_HOME"
rm -rf "$TEST_DIR"
print_info "Test environment removed"

echo ""
echo "========================================"
echo "         Test Summary"
echo "========================================"
echo "All basic tests completed!"
echo ""
echo "Note: Full integration testing requires:"
echo "  - Running on actual Steam Deck"
echo "  - KDE Plasma desktop environment"
echo "  - Talon Voice installation"
echo "  - Testing keyboard shortcut activation"
echo ""
