# Arch Linux + Hyprland Dotfiles

This repository contains my complete Arch Linux configuration with Hyprland window manager and all associated dotfiles.

## System Overview

- **Distribution**: Arch Linux
- **Window Manager**: Hyprland
- **Status Bar**: Waybar
- **Terminal**: Kitty, Alacritty, Ghostty
- **Shell**: Bash with Starship prompt
- **Application Launcher**: Rofi, Walker
- **Notification Daemon**: Mako, Dunst
- **Lock Screen**: Hyprlock
- **Idle Manager**: Hypridle
- **Editor**: Neovim
- **Theme Manager**: pywal
- **Display Manager**: SDDM
- **GPU**: NVIDIA (open-dkms)

## Repository Structure

```
dotfiles/
├── .config/           # Application configurations
│   ├── hypr/         # Hyprland configuration
│   ├── waybar/       # Waybar status bar
│   ├── kitty/        # Kitty terminal
│   ├── alacritty/    # Alacritty terminal
│   ├── ghostty/      # Ghostty terminal
│   ├── nvim/         # Neovim configuration
│   ├── rofi/         # Rofi launcher
│   ├── mako/         # Mako notifications
│   ├── dunst/        # Dunst notifications
│   ├── walker/       # Walker launcher
│   ├── wal/          # pywal theming
│   ├── btop/         # System monitor
│   ├── fastfetch/    # System info
│   ├── lazygit/      # Git TUI
│   ├── mise/         # Runtime manager
│   ├── swayosd/      # OSD daemon
│   ├── uwsm/         # Window manager session
│   └── starship.toml # Starship prompt
├── packages/         # Package lists
│   ├── pkglist.txt      # All explicitly installed packages
│   ├── officiallist.txt # Official repository packages
│   └── aurlist.txt      # AUR packages
├── .bashrc           # Bash configuration
├── .bash_profile     # Bash profile
├── install.sh        # Installation script
└── README.md         # This file
```

## Installation

### Prerequisites

- A fresh or existing Arch Linux installation
- Internet connection
- `git` installed (`sudo pacman -S git`)

### Quick Install

1. Clone this repository:
```bash
git clone https://github.com/DanielCoffey1/arch-dots ~/dotfiles
cd ~/dotfiles
```

2. Run the installation script:
```bash
./install.sh
```

3. Follow the prompts to:
   - Install packages (choose official, AUR, or all)
   - Deploy dotfiles (automatically backs up existing configs)
   - Enable systemd services

### Manual Installation

If you prefer to install manually:

#### Install Packages

```bash
# Install official repository packages
sudo pacman -S --needed - < packages/officiallist.txt

# Install AUR packages (requires yay)
yay -S --needed - < packages/aurlist.txt
```

#### Deploy Dotfiles

```bash
# Backup your existing configs first!
cp -r ~/.config ~/.config.backup

# Copy configurations
cp -r .config/* ~/.config/
cp .bashrc ~/
cp .bash_profile ~/
```

## Post-Installation

### Essential Steps

1. **Reboot** or re-login to apply all changes
2. **Configure NVIDIA** if you're using NVIDIA GPU
3. **Enable services**:
   ```bash
   sudo systemctl enable --now bluetooth
   sudo systemctl enable sddm
   ```

### Hyprland First Launch

- Press `Super + Return` to open a terminal
- Press `Super + D` or `Super + R` to open application launcher
- Press `Super + Q` to close windows
- Press `Super + M` to exit Hyprland

### Customization

- **Hyprland**: Edit `~/.config/hypr/hyprland.conf`
- **Waybar**: Edit `~/.config/waybar/config`
- **Theme**: Run `wal -i /path/to/wallpaper` to generate color scheme
- **Keybindings**: Check `~/.config/hypr/hyprland.conf`

## Key Features

- **pywal integration**: Automatic color scheme generation from wallpapers
- **Multiple terminal options**: Kitty, Alacritty, Ghostty
- **GPU screen recording**: gpu-screen-recorder configured
- **Development tools**: Neovim, mise, lazygit, docker
- **System monitoring**: btop, plasma-systemmonitor
- **File management**: Dolphin, Nautilus

## Package Management

### Update All Packages

```bash
yay -Syu
```

### Add New Package to List

After installing a new package, update the lists:
```bash
pacman -Qe | awk '{print $1}' > packages/pkglist.txt
pacman -Qm | awk '{print $1}' > packages/aurlist.txt
pacman -Qen | awk '{print $1}' > packages/officiallist.txt
```

## Troubleshooting

### NVIDIA Issues

If you experience issues with NVIDIA:
- Check kernel modules: `lsmod | grep nvidia`
- Rebuild initramfs: `sudo mkinitcpio -P`
- Check Hyprland env vars in `~/.config/hypr/hyprland.conf`

### Display Manager Not Starting

```bash
sudo systemctl status sddm
sudo journalctl -u sddm
```

### Hyprland Won't Start

Check logs:
```bash
cat /tmp/hypr/$HYPRLAND_INSTANCE_SIGNATURE/hyprland.log
```

## Backup

This repository IS your backup. Keep it updated:

```bash
cd ~/dotfiles
# Copy any changed configs
cp ~/.bashrc .
cp -r ~/.config/hypr .config/
# Update package lists
pacman -Qe | awk '{print $1}' > packages/pkglist.txt
# Commit and push
git add .
git commit -m "Update dotfiles"
git push
```

## Credits

Configuration inspired by the Arch and Hyprland communities.

## License

Feel free to use and modify these configurations for your own setup.
