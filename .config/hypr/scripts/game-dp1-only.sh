#!/bin/bash
# Runs a game through gamescope, pinned to the 2K monitor's native
# 2560x1440 resolution, so games that mis-detect the "first" monitor
# (HDMI-A-1 is Hyprland monitor ID 0, DP-1 is ID 1) don't pick the 1080p
# screen and crash/open windowed at the wrong size.
#
# Previous version of this script disabled HDMI-A-1 entirely to force
# single-monitor detection, which fixed the same bug but blanked the
# second screen for the whole play session. gamescope fixes it without
# touching the second monitor: it's a nested Wayland client, so the game
# only ever sees the 2560x1440 surface gamescope hands it, and Hyprland
# places/fullscreens that surface on DP-1 as normal (workspace 1-5 rule).
set -u
LOG="/tmp/game-dp1-only.log"
exec 3>>"$LOG"
echo "=== $(date) : PID $$ launched with: $* ===" >&3

[ "${1:-}" = "--" ] && shift

if [ "$#" -eq 0 ]; then
  echo "Usage: game-dp1-only.sh -- <command...>" >&2
  exit 1
fi

# --force-grab-cursor forces relative/raw-input mouse capture. GW1's
# right-click-drag camera turn needs this to register at all - without it,
# gamescope's auto (cursor-visibility-based) switching never engages
# relative mode for it and right-click does nothing. The real/host cursor
# visibly drifting off the gamescope surface while captured is a cosmetic
# side effect of relative mode, not a functional bug, so this stays on by
# default. Set GAME_FORCE_GRAB_CURSOR=0 in a game's Steam launch options to
# disable it for titles where it causes problems instead (e.g. a
# click-to-interact game where forced relative capture breaks clicking).
grab_cursor_flag=()
[ "${GAME_FORCE_GRAB_CURSOR:-1}" = "1" ] && grab_cursor_flag=(--force-grab-cursor)

exec gamescope \
  --backend wayland \
  -W 2560 -H 1440 \
  -w 2560 -h 1440 \
  -r 180 \
  --adaptive-sync \
  "${grab_cursor_flag[@]}" \
  -f \
  -- "$@" 2>&3
