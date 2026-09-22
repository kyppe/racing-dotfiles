#!/bin/bash
# Hides waybar while any game window is open (same class match as the
# "games" rule in rules.lua: steam_app_* or gamescope), and restores it once
# no game windows remain - so the bar doesn't sit on top of fullscreen game
# content.

sock="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"
game_class='^(steam_app_.*|gamescope)$'

has_game() {
  hyprctl clients -j | jq -e --arg re "$game_class" \
    '[.[] | select(.class | test($re))] | length > 0' >/dev/null
}

socat -U - "UNIX-CONNECT:$sock" | while read -r line; do
  case "$line" in
    openwindow*|closewindow*)
      if has_game; then
        pkill -x waybar
      else
        pgrep -x waybar >/dev/null || { nohup waybar >/dev/null 2>&1 & disown; }
      fi
      ;;
  esac
done
