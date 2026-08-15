#!/bin/bash
# --- Launch xwinwrap wallpaper ---

# Single-monitor solution nicked from
# https://github.com/StefanAngelovski/Linux-Mint-Animated-Wallpapers/tree/master

VIDEO="$HOME/Pictures/wallpapers/animated/frieren-wallpaper.mp4"

sleep 2

xrandr --query | grep " connected" | grep -oP '\d+x\d+\+\d+\+\d+' | while read -r geom; do
xwinwrap -b -s -st -sp -nf -fdt -g "$geom" -- \
mpv -wid WID \
    --loop \
    --no-audio \
    --no-osc \
    --no-input-default-bindings \
    --input-vo-keyboard=no \
    --input-cursor=no \
    --no-border \
    "$VIDEO" &

sleep 0.3
done

# Wait a moment for xwinwrap to initialize
sleep 1

# --- Launch a tiny dummy window to trigger Cinnamon Desktop stacking ---
xterm -geometry 1x1+0+0 -e "sleep 0.1" >/dev/null 2>&1 &

# Optional: force Desktop focus just in case
wmctrl -a "Desktop" >/dev/null 2>&1

