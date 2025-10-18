# Voice command file for "Hey Claude" wake word
# Only works in silent mode - won't trigger in dictation/command modes
# This ensures ONLY "hey claude" commands are recognized

mode: user.silent
-

# Wake word: "hey claude" followed by your message
hey claude <user.prose>$:
    insert(user.prose)
    key(enter)
