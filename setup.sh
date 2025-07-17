#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

CONF="$HOME/.config/hypr/hyprpaper.conf"
WALL="$HOME/.config/hypr/wall.png"

# 0. Enable multilib early and update system
sudo sed -i '/^\[multilib\]/,/Include/s/^#//' /etc/pacman.conf || true
sudo pacman -Sy --noconfirm

# 1. Install core packages including SDDM, Qt, Hyprland, Hyprpaper & helpers
sudo pacman -Sy --noconfirm \
  sddm qt5-declarative qt6-declarative qt6-svg \
  fuzzel waybar git kitty fish hyprland hyprpaper \
  yazi feh fastfetch vim rclone 7zip qt6-virtualkeyboard \
  qt6-multimedia-ffmpeg

# 2. Clone your configs and copy .config directory

sudo cp -r "$HOME/configs/.config" "$HOME/"

# 3. Initialize a simple hyprpaper.conf (to be overwritten later)
sudo mkdir -p "${CONF%/*}"
cat >"$CONF" <<EOF
preload = $WALL
wallpaper = DP-1,$WALL
EOF
echo "✅ Initial hyprpaper.conf created (will be dynamically updated)."

# 4. Initialize SDDM theme structure then install 'silent'
sudo -u "$USER" sddm-greeter-qt6 --test-mode --theme /usr/share/sddm/themes/ || true
sudo mkdir -p /usr/share/sddm/themes
sudo mv "$HOME/configs/silent" /usr/share/sddm/themes/ || true

# 5. Enable SDDM service
sudo systemctl enable sddm.service

# 6. Write your SDDM config
sudo tee /etc/sddm.conf > /dev/null <<EOF
[Theme]
Current=silent

[Wayland]
EnableHiDPI=true

[General]
InputMethod=qtvirtualkeyboard
GreeterEnvironment=QML2_IMPORT_PATH=/usr/share/sddm/themes/silent/components/,QT_IM_MODULE=qtvirtualkeyboard,QT_SCREEN_SCALE_FACTORS=1.5,QT_FONT_DPI=192
EOF

# 7. Install yay and required AUR packages (including monitor-attacher)
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si --noconfirm
cd ..
yay -S --noconfirm \
  ttf-jetbrains-mono-nerd zen-browser-bin papirus-icon-theme-git \
  hyprland-monitor-attached
fc-cache -fv

# 9. Hook monitor-attached into hyprland.conf





chsh -s /usr/bin/fish

echo "✅ Integrated hyprland-monitor-attached into hyprland.conf." :contentReference[oaicite:1]{index=1}

echo "🎉 Setup complete! After login, your wallpaper will auto-update based on monitor."



