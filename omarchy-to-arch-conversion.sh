#!/bin/bash
# Omarchy to Arch Linux Conversion Script
# This script removes all Omarchy packages and repositories

set -e

echo "======================================"
echo "Omarchy to Arch Linux Conversion"
echo "======================================"
echo ""
echo "This will:"
echo "1. Build and install yay from AUR source"
echo "2. Remove all 42 Omarchy packages"
echo "3. Remove Omarchy repository from pacman.conf"
echo "4. Clean up Omarchy configurations"
echo ""
read -p "Press Enter to continue or Ctrl+C to cancel..."

# Step 1: Install dependencies for building yay
echo ""
echo "[1/5] Installing build dependencies..."
sudo pacman -S --needed --noconfirm git go base-devel

# Step 2: Build and install yay from AUR
echo ""
echo "[2/5] Building yay from AUR..."
cd /tmp
rm -rf yay
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si --noconfirm
cd /tmp
rm -rf yay

# Step 3: Remove all Omarchy packages
echo ""
echo "[3/5] Removing Omarchy packages..."

# First, handle fcitx5 which has dependencies from official repos
echo "  -> Handling fcitx5 dependencies..."
if pacman -Qi fcitx5-qt &>/dev/null; then
    echo "     Found fcitx5-qt, will reinstall from official repos after removal"
    REINSTALL_FCITX5_QT=1
fi

# Remove packages without fcitx5 first
echo "  -> Removing Omarchy packages (except fcitx5)..."
sudo pacman -Rns --noconfirm \
    1password-beta \
    1password-cli \
    aether \
    asdcontrol \
    claude-code \
    cursor-bin \
    cursor-cli \
    elephant \
    elephant-bluetooth \
    elephant-calc \
    elephant-clipboard \
    elephant-desktopapplications \
    elephant-files \
    elephant-menus \
    elephant-providerlist \
    elephant-runner \
    elephant-symbols \
    elephant-todo \
    elephant-unicode \
    elephant-websearch \
    gpu-screen-recorder \
    hyprshade \
    limine-mkinitcpio-hook \
    limine-snapper-sync \
    localsend \
    omarchy-chromium \
    omarchy-keyring \
    omarchy-nvim \
    omarchy-walker \
    pinta \
    python-terminaltexteffects \
    spotify \
    tobi-try \
    ttf-ia-writer \
    typora \
    tzupdate \
    ufw-docker \
    walker \
    wayfreeze \
    xdg-terminal-exec \
    yaru-icon-theme

# Now remove fcitx5 and fcitx5-qt together (to avoid dependency issues)
echo "  -> Removing fcitx5 and its dependencies..."
if [ ! -z "$REINSTALL_FCITX5_QT" ]; then
    sudo pacman -Rns --noconfirm fcitx5 fcitx5-qt
else
    sudo pacman -Rns --noconfirm fcitx5
fi

# Step 4: Remove Omarchy repository from pacman.conf
echo ""
echo "[4/5] Removing Omarchy repository..."
sudo cp /etc/pacman.conf /etc/pacman.conf.backup
sudo sed -i '/\[omarchy\]/,+2d' /etc/pacman.conf

# Update package database
echo ""
echo "Updating package database..."
sudo pacman -Syy

# Step 4b: Reinstall fcitx5 from official repos if needed
if [ ! -z "$REINSTALL_FCITX5_QT" ]; then
    echo ""
    echo "[4b/5] Reinstalling fcitx5 from official Arch repos..."
    sudo pacman -S --noconfirm fcitx5 fcitx5-qt
fi

# Step 5: Clean up Omarchy configurations
echo ""
echo "[5/5] Cleaning up configurations..."
sudo rm -rf /usr/share/omarchy-nvim
rm -rf ~/.config/omarchy
rm -f ~/.config/omarchy.ttf

echo ""
echo "======================================"
echo "Conversion Complete!"
echo "======================================"
echo ""
echo "Your system is now pure Arch Linux."
echo ""
if [ ! -z "$REINSTALL_FCITX5_QT" ]; then
    echo "✓ fcitx5 and fcitx5-qt were reinstalled from official Arch repos"
    echo ""
fi
echo "To reinstall applications from AUR, use yay:"
echo ""
echo "  # Development tools"
echo "  yay -S claude-code-bin        # Claude Code (me!)"
echo "  yay -S cursor-bin             # Cursor IDE"
echo "  yay -S neovim                 # Or configure your own nvim"
echo ""
echo "  # Applications"
echo "  yay -S spotify                # Music streaming"
echo "  yay -S typora                 # Markdown editor"
echo "  yay -S pinta                  # Image editor"
echo "  yay -S 1password              # Password manager"
echo "  yay -S localsend-bin          # Local file sharing"
echo ""
echo "  # Browsers"
echo "  sudo pacman -S chromium       # Chromium (official repo)"
echo "  sudo pacman -S firefox        # Firefox (official repo)"
echo ""
echo "  # System utilities"
echo "  yay -S walker-git             # Application launcher"
echo "  yay -S gpu-screen-recorder-git # Screen recorder"
echo "  yay -S hyprshade              # Shader manager"
echo "  yay -S wayfreeze-bin          # Screen freezer"
echo ""
echo "  # Other"
echo "  yay -S yaru-icon-theme        # Icon theme"
echo "  yay -S ufw-docker             # Docker firewall"
echo "  yay -S ttf-ia-writer          # Font"
echo ""
echo "A backup of your pacman.conf was saved to /etc/pacman.conf.backup"
echo "See ~/aur-package-alternatives.md for complete package list"
echo ""
