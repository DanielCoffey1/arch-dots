#!/bin/bash

# Arch Linux Dotfiles Installation Script
# This script will install packages and deploy dotfiles

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Functions
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running on Arch Linux
if [ ! -f /etc/arch-release ]; then
    print_error "This script is designed for Arch Linux only!"
    exit 1
fi

print_info "Starting Arch Linux dotfiles installation..."

# Install yay if not present
if ! command -v yay &> /dev/null; then
    print_info "Installing yay AUR helper..."
    sudo pacman -S --needed --noconfirm git base-devel
    cd /tmp
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    cd ~
    print_success "yay installed successfully"
else
    print_success "yay is already installed"
fi

# Ask user what to install
echo ""
print_info "What would you like to install?"
echo "1) Only official repository packages"
echo "2) Only AUR packages"
echo "3) All packages (official + AUR)"
echo "4) Skip package installation"
read -p "Enter your choice (1-4): " install_choice

case $install_choice in
    1)
        print_info "Installing official repository packages..."
        sudo pacman -S --needed - < packages/officiallist.txt
        print_success "Official packages installed"
        ;;
    2)
        print_info "Installing AUR packages..."
        yay -S --needed - < packages/aurlist.txt
        print_success "AUR packages installed"
        ;;
    3)
        print_info "Installing all packages (this may take a while)..."
        sudo pacman -S --needed - < packages/officiallist.txt
        yay -S --needed - < packages/aurlist.txt
        print_success "All packages installed"
        ;;
    4)
        print_warning "Skipping package installation"
        ;;
    *)
        print_error "Invalid choice. Exiting."
        exit 1
        ;;
esac

# Deploy dotfiles
echo ""
print_info "Deploying dotfiles..."

# Backup existing configs
BACKUP_DIR=~/dotfiles_backup_$(date +%Y%m%d_%H%M%S)
print_info "Creating backup of existing configs at $BACKUP_DIR"
mkdir -p "$BACKUP_DIR/.config"

# List of config directories to deploy
config_dirs=(
    "hypr"
    "waybar"
    "kitty"
    "alacritty"
    "ghostty"
    "nvim"
    "rofi"
    "mako"
    "dunst"
    "walker"
    "wal"
    "btop"
    "fastfetch"
    "lazygit"
    "mise"
    "swayosd"
    "uwsm"
)

# Backup and copy config directories
for dir in "${config_dirs[@]}"; do
    if [ -d "$HOME/.config/$dir" ]; then
        print_info "Backing up existing ~/.config/$dir"
        cp -r "$HOME/.config/$dir" "$BACKUP_DIR/.config/"
    fi

    if [ -d ".config/$dir" ]; then
        print_info "Deploying $dir config"
        cp -r ".config/$dir" "$HOME/.config/"
    fi
done

# Handle individual config files
if [ -f ".config/starship.toml" ]; then
    [ -f "$HOME/.config/starship.toml" ] && cp "$HOME/.config/starship.toml" "$BACKUP_DIR/.config/"
    cp ".config/starship.toml" "$HOME/.config/"
    print_info "Deployed starship.toml"
fi

# Deploy shell configs
shell_files=(".bashrc" ".bash_profile")
for file in "${shell_files[@]}"; do
    if [ -f "$file" ]; then
        [ -f "$HOME/$file" ] && cp "$HOME/$file" "$BACKUP_DIR/"
        cp "$file" "$HOME/"
        print_info "Deployed $file"
    fi
done

print_success "Dotfiles deployed successfully!"
print_info "Backup of old configs saved to: $BACKUP_DIR"

# Enable systemd services (if needed)
echo ""
read -p "Would you like to enable common systemd services? (y/n): " enable_services
if [[ $enable_services == "y" || $enable_services == "Y" ]]; then
    print_info "Enabling systemd services..."

    # Enable Bluetooth
    sudo systemctl enable --now bluetooth.service

    # Enable SDDM (if installed)
    if command -v sddm &> /dev/null; then
        sudo systemctl enable sddm.service
    fi

    print_success "Services enabled"
fi

echo ""
print_success "Installation complete!"
print_info "You may need to:"
echo "  - Reboot your system"
echo "  - Re-login to apply shell changes"
echo "  - Configure NVIDIA drivers if applicable"
echo "  - Set up your user-specific configurations"
echo ""
print_info "Enjoy your Arch + Hyprland setup!"
