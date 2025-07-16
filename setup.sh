#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# 0. Enable multilib repo before installing any packages
sudo sed -i '/^\[multilib\]/,/Include/s/^#//' /etc/pacman.conf || true
sudo pacman -Sy --noconfirm  # Refresh after enabling multilib

# 1. Connect to Wi‑Fi
#nmcli device wifi connect 'Mice' --ask

# 2. Install essential packages
sudo pacman -Sy --noconfirm \
  fuzzel waybar git kitty fish hyprland hyprpaper sddm yazi feh fastfetch \
  vim rclone 7zip

# 3. Clone your personal configs
#git clone https://github.com/twig46/configs.git "$HOME/configs"

# 4. Move configurations into place
mv "$HOME/configs/.config/"* "$HOME/.config/" || true
sudo mv "$HOME/configs/silent" /usr/share/sddm/themes/ || true

# 🟢 Enable SDDM display manager on boot
sudo systemctl enable sddm.service

# 5. Configure SDDM with your preferences
sudo bash -c 'cat > /etc/sddm.conf <<EOF
[Theme]
Current=silent

[Wayland]
EnableHiDPI=true

[General]
InputMethod=qtvirtualkeyboard
GreeterEnvironment=QML2_IMPORT_PATH=/usr/share/sddm/themes/silent/components/,QT_IM_MODULE=qtvirtualkeyboard,QT_SCREEN_SCALE_FACTORS=1.5,QT_FONT_DPI=192
EOF'

# 6. Install yay (AUR helper)
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si --noconfirm
cd ..

# 7. Install your AUR packages
yay -S --noconfirm ttf-jetbrains-mono-nerd zen-browser-bin papirus-icon-theme-git

echo "✅ Setup complete! Reboot or relogin to apply changes."

