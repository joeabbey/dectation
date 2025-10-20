#!/bin/bash
# Claude Code Stop hook
# Plays a success sound when Claude finishes responding and is ready for input

# Use the dectation sound player
SOUND_SCRIPT="$HOME/dectation/scripts/play-sound.sh"

# Play the success sound (different from prompt bell)
if [ -x "$SOUND_SCRIPT" ]; then
    "$SOUND_SCRIPT" success &
fi

# Exit 0 to indicate success
exit 0
