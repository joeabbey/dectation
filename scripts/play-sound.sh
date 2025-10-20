#!/bin/bash
# Simple sound player for dectation notifications
# Plays a soft, pleasant tone for audio feedback

SOUND_TYPE="${1:-prompt}"

# Sound file paths
PROMPT_SOUND="/usr/share/sounds/oxygen/stereo/bell.ogg"
SUCCESS_SOUND="/usr/share/sounds/oxygen/stereo/completion-success.ogg"
ERROR_SOUND="/usr/share/sounds/oxygen/stereo/completion-fail.ogg"

# Select sound based on type
case "$SOUND_TYPE" in
    prompt|claude)
        SOUND_FILE="$PROMPT_SOUND"
        ;;
    success)
        SOUND_FILE="$SUCCESS_SOUND"
        ;;
    error)
        SOUND_FILE="$ERROR_SOUND"
        ;;
    *)
        SOUND_FILE="$PROMPT_SOUND"
        ;;
esac

# Play the sound if file exists and paplay is available
if [ -f "$SOUND_FILE" ] && command -v paplay >/dev/null 2>&1; then
    paplay "$SOUND_FILE" 2>/dev/null &
fi

exit 0
