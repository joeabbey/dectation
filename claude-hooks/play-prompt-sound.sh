#!/bin/bash
# Claude Code UserPromptSubmit hook
# Plays a soft bell sound when you're about to submit a prompt to Claude

# Use the dectation sound player
SOUND_SCRIPT="$HOME/dectation/scripts/play-sound.sh"

# Play the prompt sound
if [ -x "$SOUND_SCRIPT" ]; then
    "$SOUND_SCRIPT" prompt &
fi

# Exit 0 to allow the prompt to continue to Claude
exit 0
