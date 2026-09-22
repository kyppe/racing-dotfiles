#!/bin/bash
# Live network throughput for Waybar, with separate download/upload icons
# and a signal-strength-aware wifi icon. Falls back to ethernet when wifi is off.

CACHE="${XDG_RUNTIME_DIR:-/tmp}/waybar-wifi-usage.cache"

status=$(nmcli -t -f DEVICE,TYPE,STATE device status 2>/dev/null)
iface=$(awk -F: '$2=="wifi" && $3=="connected"{print $1; exit}' <<< "$status")
mode="wifi"
if [ -z "$iface" ]; then
    iface=$(awk -F: '$2=="ethernet" && $3=="connected"{print $1; exit}' <<< "$status")
    mode="ethernet"
fi

human() {
    awk -v b="$1" 'BEGIN {
        if (b > 1048576) printf "%.1fMB/s", b/1048576;
        else if (b > 1024) printf "%.0fKB/s", b/1024;
        else printf "%.0fB/s", b;
    }'
}

if [ -z "$iface" ]; then
    echo "{\"text\": \"󰤭  Off\", \"class\": \"disconnected\", \"tooltip\": \"No network connection\"}"
    rm -f "$CACHE"
    exit 0
fi

rx_now=$(cat "/sys/class/net/$iface/statistics/rx_bytes" 2>/dev/null || echo 0)
tx_now=$(cat "/sys/class/net/$iface/statistics/tx_bytes" 2>/dev/null || echo 0)
now=$(date +%s.%N)

if [ -f "$CACHE" ]; then
    read -r prev_time prev_rx prev_tx prev_iface < "$CACHE"
else
    prev_time=$now
    prev_rx=$rx_now
    prev_tx=$tx_now
    prev_iface=$iface
fi

if [ "$prev_iface" != "$iface" ]; then
    prev_time=$now
    prev_rx=$rx_now
    prev_tx=$tx_now
fi

echo "$now $rx_now $tx_now $iface" > "$CACHE"

read -r rx_rate tx_rate <<< "$(awk -v now="$now" -v prev="$prev_time" -v rx="$rx_now" -v prx="$prev_rx" -v tx="$tx_now" -v ptx="$prev_tx" 'BEGIN {
    dt = now - prev;
    if (dt <= 0) dt = 1;
    rr = (rx - prx) / dt;
    tr = (tx - ptx) / dt;
    if (rr < 0) rr = 0;
    if (tr < 0) tr = 0;
    printf "%f %f", rr, tr;
}')"

if [ "$mode" = "wifi" ]; then
    label=$(nmcli -t -f active,ssid,signal dev wifi 2>/dev/null | awk -F: '$1=="yes"{print; exit}')
    ssid=$(cut -d: -f2 <<< "$label")
    signal=$(cut -d: -f3 <<< "$label")
    signal=${signal:-0}
    icon="󰖩"
    label="${ssid:-Wi-Fi} ($signal%)"
else
    icon="󰈀"
    label=$(nmcli -t -f GENERAL.CONNECTION device show "$iface" 2>/dev/null | cut -d: -f2)
    label="${label:-Ethernet}"
fi

text="󰇚$(human "$rx_rate")  󰕒$(human "$tx_rate")  <span size='large'>$icon</span>"
tooltip="$label · ↓ $(human "$rx_rate")  ↑ $(human "$tx_rate")"

echo "{\"text\": \"$text\", \"class\": \"connected\", \"tooltip\": \"$tooltip\"}"
