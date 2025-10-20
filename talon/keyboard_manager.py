"""
Keyboard Manager for Dectation V2
Manages onscreen keyboard visibility during dictation mode
Place in ~/.talon/user/ directory
"""

from talon import Module, actions, app, cron
import subprocess
import os

mod = Module()

# Settings
mod.setting(
    "dectation_auto_hide_keyboard",
    type=bool,
    default=True,
    desc="Automatically hide onscreen keyboard when entering dictation mode",
)

mod.setting(
    "dectation_keyboard_restore",
    type=bool,
    default=True,
    desc="Restore keyboard visibility when exiting dictation mode",
)

mod.setting(
    "dectation_keyboard_delay_ms",
    type=int,
    default=200,
    desc="Delay in milliseconds before showing/hiding keyboard",
)

# State tracking
class KeyboardState:
    def __init__(self):
        self.was_visible_before_dictation = False
        self.auto_manage_enabled = True
        self.script_path = os.path.expanduser("~/dectation/scripts/steam-keyboard-control.sh")

    def is_keyboard_visible(self):
        """Check if keyboard is currently visible"""
        try:
            result = subprocess.run(
                [self.script_path, "status"],
                capture_output=True,
                text=True,
                timeout=2
            )
            return result.stdout.strip() == "visible"
        except Exception as e:
            # If we can't determine status, assume hidden
            return False

    def show_keyboard(self):
        """Show the onscreen keyboard"""
        try:
            subprocess.Popen(
                [self.script_path, "show"],
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL
            )
        except Exception as e:
            app.notify(f"Keyboard show failed: {str(e)[:30]}")

    def hide_keyboard(self):
        """Hide the onscreen keyboard"""
        try:
            subprocess.Popen(
                [self.script_path, "hide"],
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL
            )
        except Exception as e:
            app.notify(f"Keyboard hide failed: {str(e)[:30]}")

keyboard_state = KeyboardState()


@mod.action_class
class Actions:
    def keyboard_show():
        """Show the onscreen keyboard"""
        keyboard_state.show_keyboard()
        app.notify("Keyboard shown")

    def keyboard_hide():
        """Hide the onscreen keyboard"""
        keyboard_state.hide_keyboard()
        app.notify("Keyboard hidden")

    def keyboard_toggle():
        """Toggle onscreen keyboard visibility"""
        if keyboard_state.is_keyboard_visible():
            keyboard_state.hide_keyboard()
            app.notify("Keyboard hidden")
        else:
            keyboard_state.show_keyboard()
            app.notify("Keyboard shown")

    def keyboard_auto_manage_enable():
        """Enable automatic keyboard management"""
        keyboard_state.auto_manage_enabled = True
        app.notify("Keyboard auto-manage enabled")

    def keyboard_auto_manage_disable():
        """Disable automatic keyboard management"""
        keyboard_state.auto_manage_enabled = False
        app.notify("Keyboard auto-manage disabled")

    def keyboard_on_dictation_start():
        """Called when entering dictation mode - hides keyboard if auto-manage enabled"""
        # Only proceed if auto-manage is enabled
        if not keyboard_state.auto_manage_enabled:
            return

        # Check settings
        auto_hide = actions.user.settings.get("user.dectation_auto_hide_keyboard", True)
        if not auto_hide:
            return

        # Remember current state
        keyboard_state.was_visible_before_dictation = keyboard_state.is_keyboard_visible()

        # Hide keyboard if it's visible
        if keyboard_state.was_visible_before_dictation:
            # Add small delay
            delay_ms = actions.user.settings.get("user.dectation_keyboard_delay_ms", 200)
            cron.after(f"{delay_ms}ms", keyboard_state.hide_keyboard)

    def keyboard_on_dictation_stop():
        """Called when exiting dictation mode - restores keyboard if it was visible before"""
        # Only proceed if auto-manage is enabled
        if not keyboard_state.auto_manage_enabled:
            return

        # Check settings
        restore = actions.user.settings.get("user.dectation_keyboard_restore", True)
        if not restore:
            return

        # Restore keyboard if it was visible before dictation
        if keyboard_state.was_visible_before_dictation:
            # Add small delay
            delay_ms = actions.user.settings.get("user.dectation_keyboard_delay_ms", 200)
            cron.after(f"{delay_ms}ms", keyboard_state.show_keyboard)
            keyboard_state.was_visible_before_dictation = False
