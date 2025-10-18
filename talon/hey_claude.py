# Hey Claude - Wake Word for Silent Listening
#
# This module keeps Talon in command mode (silent - not typing everything)
# and only activates when you say "hey claude [your message]"
#
# Workflow:
# 1. Press L1+Y to wake Talon - it enters COMMAND mode (silent listening)
# 2. Talon listens but doesn't type anything you say
# 3. Say "hey claude [your message]" to trigger dictation
# 4. Your message is typed and Enter is pressed automatically
#
# Usage: "hey claude [your message here]"
# Example: "hey claude create a file called test.py"
#
# This prevents accidental typing while keeping voice control ready.
# See hey_claude.talon for the voice command definition.
