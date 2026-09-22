#!/usr/bin/env bash
# Installs the packages this rice depends on. Arch/CachyOS only.
# Does NOT touch ~/.config — run install.sh separately for that.
set -euo pipefail

if ! command -v pacman >/dev/null; then
    echo "This is an Arch/CachyOS-only bootstrap (needs pacman). Aborting." >&2
    exit 1
fi

# Pulls in hyprland, noctalia (+ noctalia-qs), waybar, matugen, kitty, hyprlock,
# hyprpaper, grim, slurp, wl-clipboard, and other CachyOS Hyprland-edition deps.
PACMAN_PKGS=(
    cachyos-hypr-noctalia
    nvtop
    jq
    cliphist
    hyprpicker
    wf-recorder
    tesseract
)

# From the AUR (quickshell overview widget + pywalfox, used by matugen templates)
AUR_PKGS=(
    quickshell-overview-git
    python-pywalfox
)

echo "About to install with pacman (needs sudo):"
printf '  %s\n' "${PACMAN_PKGS[@]}"
read -rp "Continue? [y/N] " reply
[[ "$reply" =~ ^[Yy]$ ]] || { echo "Aborted."; exit 1; }

sudo pacman -S --needed "${PACMAN_PKGS[@]}"

if command -v yay >/dev/null; then
    AUR_HELPER=yay
elif command -v paru >/dev/null; then
    AUR_HELPER=paru
else
    echo "No AUR helper (yay/paru) found — skipping: ${AUR_PKGS[*]}"
    echo "Install one first, then: <helper> -S --needed ${AUR_PKGS[*]}"
    exit 0
fi

echo "About to install from AUR with $AUR_HELPER:"
printf '  %s\n' "${AUR_PKGS[@]}"
read -rp "Continue? [y/N] " reply
[[ "$reply" =~ ^[Yy]$ ]] || { echo "Skipped AUR packages."; exit 0; }

"$AUR_HELPER" -S --needed "${AUR_PKGS[@]}"

echo "Done. Now run ./install.sh to symlink the configs."
