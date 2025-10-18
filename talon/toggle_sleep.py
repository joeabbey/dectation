"""
Toggle Talon sleep mode script
Place in ~/.talon/user/ directory
"""

from talon import Module, actions, app, scope
import os
from datetime import datetime

mod = Module()

def log_to_file(message):
    """Log messages to a file for debugging"""
    log_file = os.path.expanduser("~/speech-to-text/talon-toggle-debug.log")
    with open(log_file, "a") as f:
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        f.write(f"{timestamp} - {message}\n")

@mod.action_class
class Actions:
    def toggle_sleep():
        """Toggle Talon sleep mode"""
        try:
            log_to_file("toggle_sleep called")

            # Check if currently in sleep mode
            is_sleeping = "sleep" in scope.get("mode", [])
            log_to_file(f"is_sleeping: {is_sleeping}")
            log_to_file(f"current modes: {scope.get('mode', [])}")

            if is_sleeping:
                # Currently sleeping, wake up in silent mode (truly silent listening)
                log_to_file("Waking up (calling speech.enable())")
                actions.speech.enable()

                # Switch to silent mode after waking up (only responds to "hey claude")
                log_to_file("Switching to silent mode")
                actions.mode.disable("sleep")
                actions.mode.disable("dictation")
                actions.mode.disable("command")
                actions.mode.enable("user.silent")

                app.notify("Listening 🎧", body="Say 'hey claude' to speak")
                log_to_file("Sent silent mode notification")
            else:
                # Currently awake, go to sleep
                log_to_file("Going to sleep (calling speech.disable())")
                actions.speech.disable()
                app.notify("Sleeping 😴")
                log_to_file("Sent sleeping notification")

        except Exception as e:
            error_msg = f"Error: {str(e)}"
            log_to_file(f"EXCEPTION: {error_msg}")
            import traceback
            log_to_file(traceback.format_exc())
            app.notify(error_msg[:40])
