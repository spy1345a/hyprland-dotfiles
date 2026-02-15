#!/bin/bash

WALL_DIR="$HOME/Pictures/wallpapers"
SIGNAL_FILE="/tmp/wallpaper_reload"

change_wallpaper() {
    IMG=$(find "$WALL_DIR" -type f | shuf -n 1)

    echo "Changing to $IMG"

    pkill -x swaybg
    swaybg -i "$IMG" -m fill &

    echo "Running matugen"
    matugen image "$IMG"

    echo "Restarting waybar"
    killall waybar
    sleep 0.5
    waybar &
}

while true; do
    change_wallpaper

    for i in {1..300}; do
        if [ -f "$SIGNAL_FILE" ]; then
            echo "Manual reload triggered"
            rm "$SIGNAL_FILE"
            break
        fi
        sleep 1
    done
done
