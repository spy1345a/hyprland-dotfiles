#!/bin/bash

WALL_DIR="$HOME/Pictures/wallpapers"

while true; do
    IMG=$(find "$WALL_DIR" -type f | shuf -n 1)

    echo "Changing to $IMG"

    pkill -x swaybg
    swaybg -i "$IMG" -m fill &

    echo "Running matugen"
    matugen image "$IMG"

    echo "Restarting waybar"
    killall waybar
    waybar &

    sleep 300
done
