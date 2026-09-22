#!/usr/bin/env bash
# Symlinks the config dirs in this repo into ~/.config, backing up anything already there,
# then rewrites any path baked in for the original author's account to yours.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="$HOME/.config"
BACKUP="$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)"
ORIGINAL_HOME="/home/kyppe"

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

if [ "$HOME" != "$ORIGINAL_HOME" ]; then
    echo "Rewriting hardcoded $ORIGINAL_HOME paths to $HOME ..."
    matches=$(grep -rlF "$ORIGINAL_HOME" "$REPO_DIR/.config" 2>/dev/null || true)
    if [ -n "$matches" ]; then
        while IFS= read -r file; do
            sed -i "s#$ORIGINAL_HOME#$HOME#g" "$file"
            echo "  fixed: ${file#"$REPO_DIR"/}"
        done <<< "$matches"
    fi
fi

echo "Done. Old configs (if any) backed up to $BACKUP"
