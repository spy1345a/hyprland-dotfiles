#!/usr/bin/env bash

# -----------------------------
# Dotfiles Auto Backup Watcher
# -----------------------------

export PATH=/usr/bin:/bin
export GIT_SSH_COMMAND="ssh -i $HOME/.ssh/githubkey -o IdentitiesOnly=yes"

CONFIG_DIR="$HOME/.config"
DOTFILES_DIR="$HOME/dotfiles"

WATCH_FOLDERS=(
    hypr
    waybar
    matugen
    gtk-3.0
    gtk-4.0
    kitty
    fish
)

LOCKFILE="/tmp/dotfiles-watcher.lock"

notify-send -t 2000 "Dotfiles Watcher" "Started watching ~/.config"

# -----------------------------
# Ensure base dotfiles dir exists
# -----------------------------
mkdir -p "$DOTFILES_DIR"

# -----------------------------
# Watch Files
# -----------------------------

inotifywait -m -r \
-e close_write,create,delete,move,attrib \
--format '%w%f' "$CONFIG_DIR" |

while read FILE
do
    REL_PATH="${FILE#$CONFIG_DIR/}"

    for folder in "${WATCH_FOLDERS[@]}"; do
        if [[ "$REL_PATH" == "$folder"* ]]; then

            echo "Change detected in $folder"

            TARGET_DIR="$DOTFILES_DIR/$folder"
            SOURCE_DIR="$CONFIG_DIR/$folder"

            # ---- Auto-create directory if missing ----
            if [ ! -d "$TARGET_DIR" ]; then
                mkdir -p "$TARGET_DIR"

                notify-send -t 3000 \
                "Dotfiles Initialized 📁" \
                "Created $folder directory"
            fi

            # ---- Debounce ----
            if [ -f "$LOCKFILE" ]; then
                continue
            fi

            touch "$LOCKFILE"

            (
                sleep 2

                rm -rf "$TARGET_DIR"
                cp -r "$SOURCE_DIR" "$DOTFILES_DIR/"

                cd "$DOTFILES_DIR" || exit

                git add .

                if ! git diff --cached --quiet; then
                    COMMIT_MSG="Auto backup: $(date '+%Y-%m-%d %H:%M:%S')"

                    git commit -m "$COMMIT_MSG"

                    if git push; then
                        notify-send -t 3000 \
                        "Dotfiles Backed Up ✅" \
                        "$folder pushed to GitHub"
                    else
                        notify-send -t 4000 \
                        "Dotfiles Push Failed ❌" \
                        "Check SSH setup"
                    fi
                fi

                rm -f "$LOCKFILE"
            ) &

            break
        fi
    done
done
