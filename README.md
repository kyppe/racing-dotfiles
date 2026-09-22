# racing-dotfiles

Personal Hyprland rice, built on CachyOS's `cachyos-hypr-noctalia` edition (with some
ML4W-derived pieces layered in: fish, walker, swaync, matugen).

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

## Install on a new machine (Arch/CachyOS)

```sh
git clone git@github.com:kyppe/racing-dotfiles.git ~/racing-dotfiles
cd ~/racing-dotfiles
./bootstrap.sh   # installs required packages via pacman + AUR (asks before each step)
./install.sh     # symlinks .config/<app> into ~/.config/<app>
```

`install.sh` backs up anything already at `~/.config/<app>` to `~/.config-backup-<timestamp>`
before symlinking.

`bootstrap.sh` installs `cachyos-hypr-noctalia` (pulls in hyprland, noctalia, waybar, matugen,
kitty, hyprlock, hyprpaper, grim, slurp, wl-clipboard, hyprpicker, etc.) plus `nvtop`, `jq`,
`cliphist`, `wf-recorder`, `tesseract` via pacman, and `quickshell-overview-git` +
`python-pywalfox` via an AUR helper (yay/paru). It never runs `sudo` without asking first.

Not covered: your actual wallpaper file(s), SDDM theme, and anything outside `~/.config`
(shell login setup, systemd/uwsm units, etc.).
