#!/bin/bash

export PATH=/usr/bin:/bin:/usr/local/bin

CONFIG_DIR="$HOME/.config"
DOTFILES_DIR="$HOME/dotfiles"
WATCH_FOLDERS=("hypr" "waybar" "matugen" "gtk-3.0" "kitty")

notify-send "Dotfiles Watcher" "Started watching ~/.config"

inotifywait -m -r -e modify,create,delete "$CONFIG_DIR" --format '%w%f' |
while read FILE
do
    for folder in "${WATCH_FOLDERS[@]}"; do
        if [[ "$FILE" == *"/$folder/"* ]]; then

            cp -r "$CONFIG_DIR/$folder" "$DOTFILES_DIR/"

            cd "$DOTFILES_DIR" || exit

            git add .

            if ! git diff --cached --quiet; then
                COMMIT_MSG="Auto backup: $(date '+%Y-%m-%d %H:%M:%S')"
                git commit -m "$COMMIT_MSG"

                if git push; then
                    notify-send "Dotfiles Backed Up ✅" "$folder pushed successfully"
                else
                    notify-send "Dotfiles Push Failed ❌" "Check SSH or remote"
                fi
            fi

            break
        fi
    done
done
