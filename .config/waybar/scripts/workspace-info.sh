#!/bin/bash
# Waybar custom module: one instance per REAL workspace id ($1).
# Workspaces 1-5 are pinned to DP-1, 6-10 to HDMI-A-1 (see hyprland.lua),
# so the displayed number is "local" to that screen (1-5 on both bars)
# while the real id used for querying/dispatch stays global.
#
# Outputs JSON {text, tooltip, class}:
#  - text: local workspace number on top, app count in small text below
#  - tooltip: full list of what's open on hover
#  - class: "active" if THIS monitor currently has this workspace focused
#           (independent of which monitor has keyboard focus overall)

ws="$1"
local_num=$(( (ws - 1) % 5 + 1 ))

clients="$(hyprctl clients -j | jq --argjson ws "$ws" '[.[] | select(.workspace.id == $ws)]')"
count="$(echo "$clients" | jq 'length')"
plural=""
[ "$count" -ne 1 ] && plural="s"

if [ "$count" -eq 0 ]; then
  tooltip="Workspace $local_num — empty"
else
  list="$(echo "$clients" | jq -r '.[] | "  • " + .class + " — " + .title')"
  tooltip="Workspace $local_num ($count app$plural):
$list"
fi

is_active="$(hyprctl monitors -j | jq --argjson ws "$ws" '[.[].activeWorkspace.id] | index($ws) != null')"

if [ "$is_active" = "true" ]; then
  class="active"
elif [ "$count" -gt 0 ]; then
  class="occupied"
else
  class="empty"
fi

text="<span weight='bold'>$local_num</span> <span size='small' alpha='80%'>$count</span>"

jq -nc --arg text "$text" --arg tooltip "$tooltip" --arg class "$class" \
  '{text: $text, tooltip: $tooltip, class: ["ws-pill", $class]}'
