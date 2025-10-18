#!/bin/bash
# Toggle Talon sleep mode - fixed version with detailed logging

# Set up display environment for notifications
export DISPLAY="${DISPLAY:-:0}"
export DBUS_SESSION_BUS_ADDRESS="${DBUS_SESSION_BUS_ADDRESS:-unix:path=/run/user/$(id -u)/bus}"

# Debug log (optional - comment out if you don't need debugging)
DEBUG_LOG=~/.talon/toggle-debug.log
# echo "=== $(date '+%Y-%m-%d %H:%M:%S') ===" >> "$DEBUG_LOG"

# Check if Talon is running, start it if not
if ! pgrep -f "talon/talon" > /dev/null; then
    # echo "Talon not running, starting..." >> "$DEBUG_LOG"
    notify-send "Talon" "Starting Talon..." -t 2000 2>/dev/null || true
    nohup ~/dectation/scripts/start-talon.sh > /dev/null 2>&1 &

    # Wait for Talon to start (max 10 seconds)
    for i in {1..20}; do
        sleep 0.5
        if pgrep -f "talon/talon" > /dev/null; then
            sleep 2
            notify-send "Talon" "Talon started!" -t 2000 2>/dev/null || true
            # echo "Talon started successfully" >> "$DEBUG_LOG"
            break
        fi
    done

    if ! pgrep -f "talon/talon" > /dev/null; then
        # echo "ERROR: Failed to start Talon" >> "$DEBUG_LOG"
        notify-send "Talon" "Failed to start Talon!" -t 3000 2>/dev/null || true
        exit 1
    fi
else
    # echo "Talon already running" >> "$DEBUG_LOG"
    :
fi

# Call the toggle_sleep action via Talon's REPL using correct protocol
python3 - 2>/dev/null << 'PYEOF'
import socket
import os
import sys
import json
import time

repl_path = os.path.expanduser("~/.talon/.sys/repl.sock")
print(f"Connecting to REPL at {repl_path}")

try:
    s = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    s.connect(repl_path)
    print("Connected to REPL")

    # Create text mode file objects for reading/writing JSON
    writer = s.makefile('w', buffering=1, encoding='utf8')
    reader = s.makefile('r', buffering=1, encoding='utf8')

    # Read initial greeting
    greeting = reader.readline()
    print(f"Received greeting: {greeting.strip()}")

    # Send the Python code as input using the correct protocol
    command = {
        "cmd": "input",
        "text": "from talon import actions; actions.user.toggle_sleep()"
    }
    print(f"Sending command: {command}")
    writer.write(json.dumps(command) + '\n')
    writer.flush()
    print("Command sent")

    # Wait a bit for execution
    time.sleep(0.5)

    # Try to read response
    try:
        s.settimeout(1)
        response = reader.readline()
        print(f"Response: {response.strip()}")
    except:
        print("No response or timeout")

    # Close the connection
    s.shutdown(socket.SHUT_RDWR)
    print("SUCCESS")
    sys.exit(0)

except Exception as e:
    print(f"ERROR: {type(e).__name__}: {e}")
    import traceback
    traceback.print_exc()
    sys.exit(1)
PYEOF

exit_code=$?
# echo "Python exit code: $exit_code" >> "$DEBUG_LOG"

# Log file location (optional - comment out if you don't need logging)
LOG_FILE=~/.talon/toggle.log

if [ $exit_code -eq 0 ]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Talon voice toggled" >> "$LOG_FILE"
    echo "Talon toggled"
else
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Talon toggle FAILED" >> "$LOG_FILE"
    notify-send "Talon" "Toggle failed" -t 2000 2>/dev/null || true
    echo "Toggle failed"
    exit 1
fi
