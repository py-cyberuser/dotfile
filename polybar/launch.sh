#!/bin/bash

# Terminate already running bar instances
killall -q polybar
# If all your bars have ipc enabled, you can also use
# polybar-msg cmd quit

# Launch Polybar, using default config location ~/.config/polybar/config.ini
polybar -r -c ~/.config/polybar/themes/nord/config.ini main 2>&1 | tee /tmp/polybar.log &
