#!/bin/bash

# Ensure proper PATH for systemd
export PATH=/usr/bin:/bin

# Force git to use your SSH key directly (no ssh-agent needed)
export GIT_SSH_COMMAND="ssh -i $HOME/.ssh/githubkey -o IdentitiesOnly=yes"

CONFIG_DIR="$HOME/.config"
DOTFILES_DIR="$HOME/dotfiles"

WATCH_FOLDERS=("hypr" "waybar" "matugen" "gtk-3.0" "kitty")

notify-send -t 2000 "Dotfiles Watcher" "Started watching ~/.config"

sleep 1

inotifywait -m -r -e modify,create,delete --format '%w%f' "$CONFIG_DIR" |

while read FILE
do
    for folder in "${WATCH_FOLDERS[@]}"; do
        if [[ "$FILE" == *"/$folder/"* ]]; then

            echo "Change detected in $folder"

            # Copy updated config
            rm -rf "$DOTFILES_DIR/$folder"
            cp -r "$CONFIG_DIR/$folder" "$DOTFILES_DIR/"

            cd "$DOTFILES_DIR" || exit

            git add .

            # Only commit if something actually changed
            if ! git diff --cached --quiet; then
                COMMIT_MSG="Auto backup: $(date '+%Y-%m-%d %H:%M:%S')"
                git commit -m "$COMMIT_MSG"

                if git push; then
                    notify-send -t 3000 "Dotfiles Backed Up ✅" "$folder pushed to GitHub"
                else
                    notify-send -t 4000 "Dotfiles Push Failed ❌" "Check SSH setup"
                fi
            fi

            break
        fi
    done
done
