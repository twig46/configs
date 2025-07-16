#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# 1. Connect to Wi‑Fi
nmcli device wifi connect 'Mice' --ask

# 2. Install essential packages
sudo pacman -Sy --noconfirm \
  fuzzel waybar git kitty fish hyprland hyprpaper sddm yazi feh fastfetch \
  vim rclone 7zip

# 3. Clone your personal configs


# 4. Move configurations into place
mv "$HOME/configs/.config/"* "$HOME/.config/" || true
sudo mv "$HOME/configs/silent" /usr/share/sddm/themes/ || true

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

# 6. Enable multilib (Steam support disabled)
sudo sed -i '/\#\[multilib\]/,+1s/^#//' /etc/pacman.conf || true
echo "Note: multilib repo enabled, but Steam installation skipped."

# 7. Install yay (AUR helper)
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si --noconfirm
cd ..

# 8. Install your AUR packages
yay -S --noconfirm ttf-jetbrains-mono-nerd zen-browser-bin papirus-icon-theme-git

echo "✅ Setup complete! Reboot or relogin to apply changes."

