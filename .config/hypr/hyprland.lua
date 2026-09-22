-- ~/.config/hypr/hyprland.lua
-- Docs: https://wiki.hypr.land/Configuring/Start/

---- MY PROGRAMS ----

mainMod    = "SUPER"
terminal   = "kitty"
menu       = "rofi -show drun"
fileManager = "thunar"
browser    = "brave"


---- AUTOSTART ----

hl.on("hyprland.start", function()
    hl.exec_cmd("waybar")
    hl.exec_cmd("qs -d -c noctalia-shell")
    hl.exec_cmd(os.getenv("HOME") .. "/.config/waybar/scripts/workspace-signal.sh")
    hl.exec_cmd(os.getenv("HOME") .. "/.config/hypr/scripts/game-waybar-autohide.sh")
    hl.exec_cmd("dunst")
    hl.exec_cmd("nm-applet")
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")
    hl.exec_cmd("/usr/lib/polkit-kde-authentication-agent-1")

    hl.exec_cmd("awww-daemon")
    hl.exec_cmd("qs -d -c volume-osd")
    hl.exec_cmd("qs -d -p " .. os.getenv("HOME") .. "/.config/quickshell/overview")
end)

---- ENVIRONMENT VARIABLES ----

hl.env("XCURSOR_SIZE", "14")
hl.env("QT_QPA_PLATFORM", "wayland")
hl.env("MOZ_ENABLE_WAYLAND", "1")

---- INPUT ----

hl.config({
    input = {
        kb_layout = "fr",
        follow_mouse = 1,  -- default: focus follows cursor. was 0 (click-only), suspected
                           -- cause of newly-mapped fullscreen Xwayland surfaces (games)
                           -- not getting pointer focus until an explicit focus-cycle click.
        sensitivity = 0.5,
        touchpad = {
            natural_scroll = false,
            tap_to_click = true,
        },
    },
    cursor = {
        no_warps = true, -- don't jump the mouse on workspace/focus changes (e.g. bar clicks)
    },
})

---- WORKSPACES PER MONITOR ----
-- Pin workspaces 1-5 to DP-1 and 6-10 to HDMI-A-1, "persistent" so they
-- stay bound to that monitor even when empty. Confirmed unrelated to the
-- Guild Wars crash (disabling this didn't fix it - the real cause was the
-- Xwayland dual-monitor layout bug, fixed via the game-dp1-only.sh /
-- gamescope approaches instead).
for i = 1, 5 do
    hl.workspace_rule({ workspace = i, monitor = "DP-1", persistent = true, default = (i == 1) })
end
for i = 6, 10 do
    hl.workspace_rule({ workspace = i, monitor = "HDMI-A-1", persistent = true, default = (i == 6) })
end

---- LOOK AND FEEL ----

hl.config({ render = { expand_undersized_textures = false}})
hl.config({
    general = {
        gaps_in = 3,
        gaps_out = 3,
        border_size = 0,
        resize_on_border = true,
        allow_tearing = false,
        layout = "dwindle",
    },
    decoration = {
        rounding = 8,
        blur = {
            enabled = true,
            size = 5,
            passes = 1,
            vibrancy = 0.2,
        },
        shadow = {
            enabled = true,
            range = 8,
            render_power = 3,
        },
    },
    animations = {
        enabled = true,
    },
})

hl.curve("easeOut", { type = "bezier", points = { {0.05, 0.9}, {0.1, 1.0} } })

hl.animation({ leaf = "windows",    enabled = true, speed = 5, bezier = "easeOut" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 5, bezier = "easeOut" })
hl.animation({ leaf = "border",     enabled = true, speed = 5, bezier = "default" })
hl.animation({ leaf = "fade",       enabled = true, speed = 4, bezier = "default" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 7, bezier = "default", style = "slidefade" })

-- LAYOUT
hl.config({
    dwindle = { preserve_split = true },
})
hl.config({
    master = { new_status = "master" },
})

-- MISC
hl.config({
    misc = {
        disable_hyprland_logo = true,
        disable_splash_rendering = true,
    },
})

---- SPLIT-OUT FILES ----

require("monitors")
require("keybinds")
require("rules")

local ok, err = pcall(require, "hyprland-gui")
if not ok then
    print("hyprland-gui not found, skipping (install HyprMod to enable it)")
end

-- HyprMod managed settings
require("hyprland-gui")
