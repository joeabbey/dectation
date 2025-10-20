#!/bin/bash
# Claude Code PreToolUse hook (for AskUserQuestion)
# Plays a bell sound when Claude presents options/questions

# Use the dectation sound player
SOUND_SCRIPT="$HOME/dectation/scripts/play-sound.sh"

# Play the prompt sound
if [ -x "$SOUND_SCRIPT" ]; then
    "$SOUND_SCRIPT" prompt &
fi

# Exit 0 to allow the prompt to continue to Claude
exit 0
