#!/usr/bin/env bash
# Symlinks the config dirs in this repo into ~/.config, backing up anything already there.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="$HOME/.config"
BACKUP="$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)"

mkdir -p "$TARGET"

for dir in "$REPO_DIR"/.config/*/; do
    name="$(basename "$dir")"
    dest="$TARGET/$name"

    if [ -e "$dest" ] || [ -L "$dest" ]; then
        mkdir -p "$BACKUP"
        echo "Backing up existing $dest -> $BACKUP/$name"
        mv "$dest" "$BACKUP/$name"
    fi

    ln -s "$REPO_DIR/.config/$name" "$dest"
    echo "Linked $dest -> $REPO_DIR/.config/$name"
done

echo "Done. Old configs (if any) backed up to $BACKUP"
