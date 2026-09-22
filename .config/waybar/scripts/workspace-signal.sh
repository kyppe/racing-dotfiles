#!/bin/bash
# Listens to Hyprland's event socket and pokes waybar's custom/wsN modules
# (SIGRTMIN+8) to refresh instantly on workspace/window changes, instead of
# waiting for their polling interval.
#
# Debounced (min 300ms between fires): a burst of window events (e.g. a
# crashing app respawning repeatedly) was previously triggering a pkill -
# and therefore all 10 workspace-info.sh scripts - on every single event
# with no rate limit, which spiked CPU hard. The 5s poll interval in
# waybar's config.jsonc still catches anything a debounced burst misses.

sock="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"
debounce_ms=300
last_fire=0

socat -U - "UNIX-CONNECT:$sock" | while read -r line; do
  case "$line" in
    workspace*|focusedmon*|openwindow*|closewindow*|movewindow*|activewindow*)
      now_ms=$(($(date +%s%N) / 1000000))
      if (( now_ms - last_fire >= debounce_ms )); then
        pkill -RTMIN+8 waybar
        last_fire=$now_ms
      fi
      ;;
  esac
done
