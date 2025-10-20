#!/bin/bash
# Claude Code Session Manager for Dectation V2
# Manages Claude Code sessions in terminal

set -e

ACTION="${1:-}"
CLAUDE_STATE_FILE="$HOME/.talon/claude-session-state"
DEBUG_LOG="$HOME/.talon/claude-session-debug.log"

# Debug logging (uncomment for troubleshooting)
log_debug() {
    # echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$DEBUG_LOG"
    :
}

# Check if claude is installed
is_claude_installed() {
    command -v claude >/dev/null 2>&1
}

# Check if there's an active Claude session
is_claude_running() {
    if [ -f "$CLAUDE_STATE_FILE" ]; then
        local pid
        pid=$(cat "$CLAUDE_STATE_FILE" 2>/dev/null || echo "")
        if [ -n "$pid" ] && ps -p "$pid" > /dev/null 2>&1; then
            return 0
        else
            # Stale PID file, remove it
            rm -f "$CLAUDE_STATE_FILE"
            return 1
        fi
    fi
    return 1
}

# Get Claude session PID
get_claude_pid() {
    if [ -f "$CLAUDE_STATE_FILE" ]; then
        cat "$CLAUDE_STATE_FILE"
    fi
}

# Start a new Claude session in a terminal
start_claude_session() {
    log_debug "start_claude_session called"

    if ! is_claude_installed; then
        echo "Error: Claude Code is not installed"
        echo "Install it with: npm install -g @anthropic-ai/claude-code"
        notify-send "Claude Not Installed" "Please install Claude Code first"
        return 1
    fi

    if is_claude_running; then
        log_debug "Claude already running"
        echo "Claude session already running (PID: $(get_claude_pid))"
        return 0
    fi

    # Determine which terminal to use
    local terminal=""
    if command -v konsole >/dev/null 2>&1; then
        terminal="konsole"
    elif command -v gnome-terminal >/dev/null 2>&1; then
        terminal="gnome-terminal"
    elif command -v xterm >/dev/null 2>&1; then
        terminal="xterm"
    else
        echo "Error: No terminal emulator found"
        return 1
    fi

    log_debug "Starting Claude in $terminal"

    # Start Claude in a new terminal window
    case "$terminal" in
        konsole)
            konsole --hold -e claude &
            local pid=$!
            echo "$pid" > "$CLAUDE_STATE_FILE"
            log_debug "Started Claude session (PID: $pid)"
            notify-send "Claude Started" "Claude Code session is ready"
            ;;
        gnome-terminal)
            gnome-terminal -- bash -c "claude; exec bash" &
            local pid=$!
            echo "$pid" > "$CLAUDE_STATE_FILE"
            log_debug "Started Claude session (PID: $pid)"
            notify-send "Claude Started" "Claude Code session is ready"
            ;;
        xterm)
            xterm -hold -e claude &
            local pid=$!
            echo "$pid" > "$CLAUDE_STATE_FILE"
            log_debug "Started Claude session (PID: $pid)"
            notify-send "Claude Started" "Claude Code session is ready"
            ;;
    esac

    return 0
}

# Stop Claude session
stop_claude_session() {
    log_debug "stop_claude_session called"

    if ! is_claude_running; then
        log_debug "No Claude session running"
        echo "No Claude session is currently running"
        return 0
    fi

    local pid
    pid=$(get_claude_pid)

    log_debug "Stopping Claude session (PID: $pid)"
    kill "$pid" 2>/dev/null || true
    rm -f "$CLAUDE_STATE_FILE"

    notify-send "Claude Stopped" "Claude Code session closed"
    echo "Claude session stopped"
}

# Get status
get_status() {
    if is_claude_running; then
        echo "running (PID: $(get_claude_pid))"
        return 0
    else
        echo "not running"
        return 1
    fi
}

# Send input to Claude (via clipboard for now)
send_to_claude() {
    local input="$1"

    if [ -z "$input" ]; then
        echo "Error: No input provided"
        return 1
    fi

    # For now, we'll copy to clipboard and notify user
    # In the future, we could use tmux or other IPC mechanisms
    echo -n "$input" | xclip -selection clipboard 2>/dev/null || \
    echo -n "$input" | wl-copy 2>/dev/null || {
        echo "Error: No clipboard tool available (xclip or wl-copy)"
        return 1
    }

    notify-send "Sent to Claude" "Prompt copied to clipboard - paste in Claude terminal"
    echo "Prompt copied to clipboard. Paste into Claude terminal (Ctrl+Shift+V)"
}

# Main logic
case "$ACTION" in
    start)
        start_claude_session
        ;;
    stop)
        stop_claude_session
        ;;
    status)
        get_status
        ;;
    restart)
        stop_claude_session
        sleep 1
        start_claude_session
        ;;
    send)
        shift  # Remove 'send' from arguments
        send_to_claude "$*"
        ;;
    *)
        echo "Usage: $0 {start|stop|status|restart|send <text>}"
        echo ""
        echo "Manages Claude Code sessions"
        echo ""
        echo "Commands:"
        echo "  start    - Start a new Claude Code session in a terminal"
        echo "  stop     - Stop the running Claude Code session"
        echo "  status   - Check if Claude Code is running"
        echo "  restart  - Restart the Claude Code session"
        echo "  send     - Send text to Claude (copies to clipboard)"
        exit 1
        ;;
esac

exit 0
