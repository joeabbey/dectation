#!/bin/bash
# Start Talon Voice without sudo requirement (skips eye tracker setup)

cd ~/talon

# Run Talon directly, skipping the udev rule setup
unset QT_AUTO_SCREEN_SCALE_FACTOR QT_SCALE_FACTOR
export LC_NUMERIC=C
export QT_PLUGIN_PATH="$HOME/talon/lib/plugins"
export LD_LIBRARY_PATH="$HOME/talon/lib:$HOME/talon/resources/python/lib:$HOME/talon/resources/pypy/lib"

"$HOME/talon/talon" "$@"
