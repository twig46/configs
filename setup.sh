#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 1. Connect to Wi-Fi (prompting for password)
nmcli device wifi connect 'Mice' --ask

# 2. Install essential packages
sudo pacman -Sy --noconfirm \
  fuzzel waybar git kitty fish hyprland hyprpaper sddm yazi feh fastfetch \
  vim rclone p7zip

# 3. Move your configurations
mv "$HOME/configs/.config/"* "$HOME/.config/"
sudo mv "$HOME/configs/silent" /usr/share/sddm/themes/

# 4. Configure SDDM: adjust QT scale and set default theme
sudo bash -c 'cat >> /etc/sddm.conf <<EOF
[Theme]
Current=silent

[General]
DisplayCommand=
EOF'

sudo sed -i 's|#?QtScaling=.*|QtScaling=1.5|' /etc/sddm.conf || \
  sudo bash -c 'echo "QtScaling=1.5" >> /etc/sddm.conf'

# 5. Enable multilib and install Steam
sudo sed -i '/\#\[multilib\]/,+1s/^#//' /etc/pacman.conf
sudo pacman -Sy --noconfirm steam

# 6. Install SilentSDDM from GitHub
git clone -b main --depth=1 https://github.com/uiriansan/SilentSDDM.git
cd SilentSDDM
./install.sh
cd ..

# 7. Install yay helper
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si --noconfirm
cd ..

# 8. Install AUR packages
yay -S --noconfirm ttf-jetbrains-mono-nerd zen-browser-bin papirus-icon-theme-git

echo "✅ Setup complete! Reboot or relogin to apply changes."

