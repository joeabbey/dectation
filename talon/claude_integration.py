"""
Claude Code Integration for Dectation V2
Voice commands for interacting with Claude Code
Place in ~/.talon/user/ directory
"""

from talon import Module, actions, app, clip
import subprocess
import os

mod = Module()

# Settings
mod.setting(
    "dectation_claude_binary",
    type=str,
    default="claude",
    desc="Claude Code binary name or path",
)

mod.setting(
    "dectation_claude_auto_start",
    type=bool,
    default=True,
    desc="Automatically start Claude Code if not running",
)

# Helper functions
def get_script_path(script_name):
    """Get path to a dectation script"""
    return os.path.expanduser(f"~/dectation/scripts/{script_name}")

def run_claude_manager(command):
    """Run the Claude session manager script"""
    script = get_script_path("claude-session-manager.sh")
    try:
        result = subprocess.run(
            [script, command],
            capture_output=True,
            text=True,
            timeout=5
        )
        return result.returncode == 0, result.stdout.strip()
    except Exception as e:
        return False, str(e)

def is_claude_running():
    """Check if Claude session is running"""
    success, output = run_claude_manager("status")
    return success and "running" in output

def ensure_claude_running():
    """Start Claude if not running and auto-start is enabled"""
    auto_start = actions.user.settings.get("user.dectation_claude_auto_start", True)

    if not is_claude_running() and auto_start:
        app.notify("Starting Claude...")
        success, _ = run_claude_manager("start")
        if not success:
            app.notify("Failed to start Claude")
            return False
    return True


@mod.action_class
class Actions:
    def claude_start_session():
        """Start a new Claude Code session"""
        success, output = run_claude_manager("start")
        if success:
            app.notify("Claude started")
        else:
            app.notify("Failed to start Claude")

    def claude_stop_session():
        """Stop the Claude Code session"""
        success, output = run_claude_manager("stop")
        if success:
            app.notify("Claude stopped")

    def claude_send_clipboard():
        """Send clipboard contents to Claude"""
        if not ensure_claude_running():
            return

        # Get clipboard contents
        text = clip.text()
        if not text:
            app.notify("Clipboard is empty")
            return

        # Send to Claude (copies back to clipboard with notification)
        success, _ = run_claude_manager(f"send {text}")
        if success:
            app.notify("Ready to paste in Claude")
        else:
            app.notify("Failed to send to Claude")

    def claude_send_prompt(prompt: str):
        """Send a text prompt to Claude"""
        if not ensure_claude_running():
            return

        if not prompt:
            app.notify("No prompt provided")
            return

        # Send to Claude
        success, _ = run_claude_manager(f"send {prompt}")
        if success:
            app.notify("Prompt ready - paste in Claude")
        else:
            app.notify("Failed to send prompt")

    def claude_quick_prompt(template: str, context: str = ""):
        """Send a quick prompt using a template"""
        if not ensure_claude_running():
            return

        # Build the full prompt
        if context:
            full_prompt = f"{template} {context}"
        else:
            # Try to get context from clipboard
            context = clip.text()
            if context:
                full_prompt = f"{template}\n\n{context}"
            else:
                full_prompt = template

        # Send to Claude
        actions.user.claude_send_prompt(full_prompt)
