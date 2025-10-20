#!/bin/bash
# Steam Keyboard Control Script for Steam Deck
# Controls the onscreen keyboard visibility

set -e

ACTION="${1:-}"
DEBUG_LOG="$HOME/.talon/keyboard-control-debug.log"

# Debug logging (uncomment for troubleshooting)
log_debug() {
    # echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$DEBUG_LOG"
    :
}

# Check if we're on Steam Deck with Steam running
is_steam_available() {
    pgrep -x "steam" > /dev/null 2>&1
}

# Check if keyboard is currently visible using xdotool
is_keyboard_visible() {
    if command -v xdotool >/dev/null 2>&1; then
        # Search for Steam keyboard window
        local kb_window
        kb_window=$(xdotool search --name "maliit" 2>/dev/null || echo "")

        if [ -n "$kb_window" ]; then
            # Check if window is mapped (visible)
            for wid in $kb_window; do
                if xdotool getwindowgeometry "$wid" 2>/dev/null | grep -q "Position:"; then
                    log_debug "Keyboard window $wid is visible"
                    return 0
                fi
            done
        fi
    fi

    log_debug "Keyboard not visible"
    return 1
}

# Show the keyboard
show_keyboard() {
    log_debug "show_keyboard called"

    if is_steam_available; then
        log_debug "Using Steam URI to show keyboard"
        steam steam://open/keyboard >/dev/null 2>&1 &

        # Give it a moment to appear
        sleep 0.3

        log_debug "Keyboard show command sent"
        return 0
    else
        log_debug "Steam not available, trying alternative methods"

        # Try DBus to KDE Virtual Keyboard as fallback
        if command -v qdbus >/dev/null 2>&1; then
            qdbus org.kde.kwin /VirtualKeyboard org.kde.kwin.VirtualKeyboard.setEnabled true 2>/dev/null && return 0
        fi

        # Try maliit-server if available
        if command -v maliit-server >/dev/null 2>&1; then
            maliit-server >/dev/null 2>&1 &
            return 0
        fi

        log_debug "No keyboard control method available"
        return 1
    fi
}

# Hide the keyboard
hide_keyboard() {
    log_debug "hide_keyboard called"

    if is_steam_available; then
        log_debug "Using Steam URI to close keyboard"
        steam steam://close/keyboard >/dev/null 2>&1 &

        # Give it a moment to close
        sleep 0.3

        log_debug "Keyboard hide command sent"
        return 0
    else
        log_debug "Steam not available, trying alternative methods"

        # Try DBus to KDE Virtual Keyboard as fallback
        if command -v qdbus >/dev/null 2>&1; then
            qdbus org.kde.kwin /VirtualKeyboard org.kde.kwin.VirtualKeyboard.setEnabled false 2>/dev/null && return 0
        fi

        # Try killing maliit-server
        if pgrep -x "maliit-server" >/dev/null 2>&1; then
            pkill -x "maliit-server"
            return 0
        fi

        log_debug "No keyboard control method available"
        return 1
    fi
}

# Get keyboard status (visible/hidden)
get_status() {
    if is_keyboard_visible; then
        echo "visible"
        return 0
    else
        echo "hidden"
        return 1
    fi
}

# Main logic
case "$ACTION" in
    show)
        show_keyboard
        ;;
    hide)
        hide_keyboard
        ;;
    status)
        get_status
        ;;
    toggle)
        if is_keyboard_visible; then
            hide_keyboard
        else
            show_keyboard
        fi
        ;;
    *)
        echo "Usage: $0 {show|hide|status|toggle}"
        echo ""
        echo "Controls the Steam Deck onscreen keyboard"
        echo ""
        echo "Commands:"
        echo "  show    - Show the onscreen keyboard"
        echo "  hide    - Hide the onscreen keyboard"
        echo "  status  - Check if keyboard is visible or hidden"
        echo "  toggle  - Toggle keyboard visibility"
        exit 1
        ;;
esac

exit 0
