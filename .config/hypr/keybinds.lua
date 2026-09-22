-- ~/.config/hypr/keybinds.lua
-- Migrated from keybinds.conf
-- Docs: https://wiki.hypr.land/Configuring/Basics/Binds/
--       https://wiki.hypr.land/Configuring/Basics/Dispatchers/

local home = os.getenv("HOME")
local menu = "rofi -show drun"

-- Launchers
hl.bind(mainMod .. " + T", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + Space", hl.dsp.exec_cmd("pgrep -x rofi >/dev/null && pkill -x rofi || " .. menu))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd(browser))

hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind("SUPER + Tab", hl.dsp.exec_cmd("hyprlock"))
hl.bind("SUPER + SHIFT + Tab", hl.dsp.exec_cmd("qs ipc -p " .. home .. "/.config/quickshell/overview call overview toggle"))
hl.bind(mainMod .. " + GRAVE", hl.dsp.exec_cmd("pgrep -x wlogout >/dev/null || wlogout -b 1 -c 20 -r 20 -L 1700 -R 1700 -T 325 -B 325"))
hl.bind(mainMod .. " + W", hl.dsp.exec_cmd("quickshell -n -p " .. home .. "/.config/quickshell/hyprquickpaper"))

hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ mode = 0 }))
hl.bind(mainMod .. " + D", hl.dsp.window.fullscreen({ mode = 1 }))

hl.bind(mainMod .. " + O", hl.dsp.exec_cmd(home .. "/.config/hypr/scripts/opacity.sh"))

-- Super + A: remove transparency on the focused window (make it fully opaque).
-- Everything is 0.9 by default (see rules.lua); this forces the current window
-- to 1.0. Press again to hand it back to the default 0.9.
local OPAQUE_OPACITY = "1.0"
local DEFAULT_OPACITY = "0.9"
local opaque_state = {}
hl.bind(mainMod .. " + A", function()
    local w = hl.get_active_window()
    if w == nil then return end
    local addr = w.address
    if opaque_state[addr] then
        hl.dispatch(hl.dsp.window.set_prop({ prop = "opacity", value = DEFAULT_OPACITY }))
        opaque_state[addr] = nil
    else
        hl.dispatch(hl.dsp.window.set_prop({ prop = "opacity", value = OPAQUE_OPACITY }))
        opaque_state[addr] = true
    end
end)

-- Mouse move/resize window
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
-- mouse:273 (right-click) resize bind removed: suspected of firing on a stuck/desynced
-- SUPER modifier while gaming (fullscreen game grabs input, swallowing the key-up),
-- causing plain right-clicks to trigger an interactive resize/exit-fullscreen.
-- resize_on_border (hyprland.lua) already covers border-drag resizing.

-- Toggle waybar
hl.bind(mainMod .. " + SHIFT + W", hl.dsp.exec_cmd("sh -c 'pgrep -x waybar >/dev/null && pkill waybar || nohup waybar >/dev/null 2>&1 &'"))

-- Clipboard
hl.bind(mainMod .. " + V", hl.dsp.exec_cmd("pgrep -x rofi >/dev/null && pkill -x rofi || cliphist list | rofi -dmenu -p '' | cliphist decode | wl-copy"))

-- Screenshots (saved to ~/Pictures AND copied to clipboard)
hl.bind(mainMod .. " + Delete", hl.dsp.exec_cmd("grim - | tee " .. home .. "/Pictures/$(date +%s).png | wl-copy"))
hl.bind("Delete", hl.dsp.exec_cmd('grim -g "$(slurp)" - | tee ' .. home .. '/Pictures/$(date +%s).png | wl-copy'))

-- Screenshot key -> Flameshot, capturing the screen the mouse is currently
-- over and going straight into edit mode. `flameshot screen` grabs that one
-- monitor directly (defaults to "screen containing the cursor"), unlike
-- `flameshot gui` which goes through the Wayland screen-share portal and
-- pops up a "choose a screen" picker first on this dual-monitor setup.
hl.bind("Print", hl.dsp.exec_cmd("flameshot screen --edit"))

-- Brightness
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl set 5%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 5%-"), { locked = true, repeating = true })

-- Keyboard layout
hl.bind(mainMod .. " + X", hl.dsp.exec_cmd("hyprctl switchxkblayout current next"))

-- Toggle float window, center and rezise
hl.bind(mainMod .. " + G", function()
    hl.dispatch(hl.dsp.window.float({ action = "toggle" }))

    local w = hl.get_active_window()
    if w ~= nil and w.floating then
        local mon = hl.get_active_monitor()
        if mon ~= nil then
            local target_w = math.floor(mon.width * 0.7) 
            local target_h = math.floor(mon.height * 0.7)

            -- absolute resize (relative = false), not a delta
            hl.dispatch(hl.dsp.window.resize({ x = target_w, y = target_h, relative = false }))

            local mon_x = mon.x or 0
            local mon_y = mon.y or 0
            local target_x = mon_x + math.floor((mon.width - target_w) / 2)
            local target_y = mon_y + math.floor((mon.height - target_h) / 2)

            -- absolute move to the centered position
            hl.dispatch(hl.dsp.window.move({ x = target_x, y = target_y, relative = false }))
        end
    end
end)

-- Gpu screen recorder
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(
    "bash -c 'PIDFILE=/tmp/osu-gsr.pid; if [ -f \"$PIDFILE\" ] && kill -0 \"$(cat \"$PIDFILE\")\" 2>/dev/null; then kill -INT \"$(cat \"$PIDFILE\")\"; rm -f \"$PIDFILE\"; else mkdir -p ~/Videos; gpu-screen-recorder -w HDMI-A-1 -f 60 -a default_output -o ~/Videos/$(date +%Y-%m-%d_%H-%M-%S).mp4 & echo $! > \"$PIDFILE\"; fi'"
))

-- Zoom
local function zoomfunction(value)
    local zoomvalue = hl.get_config("cursor:zoom_factor")
    if (zoomvalue + value) > 1.5 then
        hl.config({ cursor = { zoom_factor = 1.5 } })
    elseif (zoomvalue + value) < 1.0 then
        hl.config({ cursor = { zoom_factor = 1.0 } })
    else
        hl.config({ cursor = { zoom_factor = zoomvalue + value } })
    end
end
hl.bind(mainMod .. " + mouse_down", function() zoomfunction(-0.5) end, { repeating = true })
hl.bind(mainMod .. " + mouse_up", function() zoomfunction(0.5) end, { repeating = true })

--# Zoom with keypad
hl.bind(mainMod .. " + code:82", function() zoomfunction(-0.3) end, { repeating = true })
hl.bind(mainMod .. " + code:86", function() zoomfunction(0.3) end, { repeating = true })

-- VERIFY: exit dispatcher. Docs explicitly say to double check the exit
-- dispatcher call when moving to Lua.
hl.bind(mainMod .. " + SHIFT + E", hl.dsp.exit())

-- Focus (arrow keys)
hl.bind(mainMod .. " + Left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + Down",  hl.dsp.focus({ direction = "down" }))
hl.bind(mainMod .. " + Up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + Right", hl.dsp.focus({ direction = "right" }))

-- VERIFY: move active window within layout (old `movewindow` dispatcher).
-- Confirmed pattern is hl.dsp.window.move({ workspace = N }) for sending to a
-- workspace (used below) - the direction-swap variant isn't shown in the
-- official example, so double check this fires like the old movewindow did.
hl.bind(mainMod .. " + SHIFT + H", hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + J", hl.dsp.window.move({ direction = "down" }))
hl.bind(mainMod .. " + SHIFT + K", hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.window.move({ direction = "right" }))

-- VERIFY: resize active window by pixel delta (old `resizeactive`, repeating
-- while held via `binde`). Param names guessed as x/y - confirm with hyprctl eval.
hl.bind(mainMod .. " + CTRL + H", hl.dsp.window.resize({ x = -40, y = 0 }), { repeating = true })
hl.bind(mainMod .. " + CTRL + L", hl.dsp.window.resize({ x = 40, y = 0 }), { repeating = true })
hl.bind(mainMod .. " + CTRL + K", hl.dsp.window.resize({ x = 0, y = -40 }), { repeating = true })
hl.bind(mainMod .. " + CTRL + J", hl.dsp.window.resize({ x = 0, y = 40 }), { repeating = true })

-- Workspaces 1-5, and move-to-workspace with SHIFT.
-- Bound by physical keycode (not keysym) so this keeps working regardless of
-- keyboard layout - on AZERTY the number row needs Shift for digits, which
-- broke plain "1".."5" keysym binds.
--
-- Per-monitor workspaces: DP-1 owns real workspace ids 1-5, HDMI-A-1 owns
-- 6-10 (pinned via hl.workspace_rule in hyprland.lua), so the SAME physical
-- keys 1-5 always mean "this screen's own 5 desks" - pressing "2" on either
-- monitor goes to that monitor's own second desk, not a shared global one.
local workspace_codes = { 10, 11, 12, 13, 14 } -- 1..5

local function monitor_ws_offset()
    local mon = hl.get_active_monitor()
    if mon ~= nil and mon.name == "HDMI-A-1" then
        return 5
    end
    return 0
end

for i = 1, 5 do
    local code = workspace_codes[i]
    hl.bind(mainMod .. " + code:" .. code, function()
        hl.dispatch(hl.dsp.focus({ workspace = i + monitor_ws_offset() }))
    end)
    hl.bind(mainMod .. " + SHIFT + code:" .. code, function()
        hl.dispatch(hl.dsp.window.move({ workspace = i + monitor_ws_offset() }))
    end)
end

-- Media keys
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })

hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

