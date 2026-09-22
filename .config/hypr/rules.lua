-- ~/.config/hypr/rules.lua
-- Migrated from rules.conf
-- Docs: https://wiki.hypr.land/Configuring/Basics/Window-Rules/

hl.layer_rule({
    match = { namespace = "rofi" },
    blur = true,
    ignore_alpha = 0.15,
})

-- Opacity rules: 90% for all windows, except browsers (when fullscreen) and
-- games (always) stay fully opaque - so video/game content isn't see-through.
hl.window_rule({
    match = { class = ".*" },
    opacity = "0.9 override",
})

-- Any fullscreen window is fully opaque, regardless of class - covers every
-- game generically (native Linux binaries have arbitrary class names like
-- "darkest.bin.x86_64" that can't be predicted/matched individually; Proton
-- games are "steam_app_<appid>"; both just fullscreen normally) plus
-- fullscreen browser video.
hl.window_rule({
    match = { fullscreen = true },
    opacity = "1.0 override",
})

hl.window_rule({
    match = { class = "^(steam_app_.*|gamescope)$" },
    opacity = "1.0 override", -- also cover windowed-mode Proton games, not just fullscreen ones
    workspace = "empty", -- always open games on an empty workspace, never on top of existing windows
})

hl.window_rule({
    name = "float-pavucontrol",
    match = { class = "^(pavucontrol)$" },
    float = true,
})

hl.window_rule({
    name = "float-nm-connection-editor",
    match = { class = "^(nm-connection-editor)$" },
    float = true,
})

hl.window_rule({
    name = "float-blueman-manager",
    match = { class = "^(blueman-manager)$" },
    float = true,
})

hl.window_rule({
    name = "float-open-file",
    match = { title = "^(Open File)$" },
    float = true,
})

hl.window_rule({
    name = "float-save-file",
    match = { title = "^(Save File)$" },
    float = true,
})

hl.window_rule({
    name = "float-noctalia-settings",
    match = { title = "^(Noctalia)$" },
    float = true,
    center = true,
})
