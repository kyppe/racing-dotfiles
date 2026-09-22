# racing-dotfiles

Personal Hyprland rice, built on top of an [ML4W](https://github.com/mylinuxforwork/dotfiles) install (CachyOS).

## Contents

| Dir | Purpose |
|---|---|
| `hypr` | Hyprland config, keybinds, monitors, rules, hyprlock |
| `waybar` | Status bar |
| `rofi` | App launcher |
| `walker` | Launcher (alternative) |
| `kitty` | Terminal |
| `fish` | Shell config |
| `quickshell` | Overview / OSD widgets |
| `noctalia` | Shell/panel + plugins |
| `swaync` | Notifications |
| `matugen` | Material You theming/colors |
| `wlogout` | Logout menu |

## Install on a new machine

```sh
git clone git@github.com:kyppe/racing-dotfiles.git ~/racing-dotfiles
~/racing-dotfiles/install.sh
```

This symlinks each `.config/<app>` dir into `~/.config/<app>`, backing up anything already there
to `~/.config-backup-<timestamp>`.

Assumes an Arch/CachyOS + Hyprland base with the matching packages installed
(hyprland, waybar, rofi, walker, kitty, fish, quickshell, swaync, matugen).
