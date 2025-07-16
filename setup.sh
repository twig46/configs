#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

CONF="$HOME/.config/hypr/hyprpaper.conf"
WALL="$HOME/.config/hypr/wall.png"

# 0. Enable multilib early
sudo sed -i '/^\[multilib\]/,/Include/s/^#//' /etc/pacman.conf || true
sudo pacman -Sy --noconfirm

# 1. Install core packages including SDDM and Qt dependencies
sudo pacman -Sy --noconfirm \
  sddm qt5-declarative qt6-declarative qt6-svg \
  fuzzel waybar git kitty fish hyprland hyprpaper \
  yazi feh fastfetch vim rclone 7zip qt6-svg \
  qt6-virtualkeyboard qt6-multimedia-ffmpeg

sudo cp -r "$HOME/configs/.config" "$HOME"


mkdir -p "${CONF%/*}"

MONITOR=$(hyprctl monitors | awk '/^Monitor/ {print $2; exit}')
if [ -z "$MONITOR" ]; then
  echo "⚠️ No monitor detected via 'hyprctl monitors'."
  exit 1
fi

cat > "$CONF" <<EOF
preload = $WALL
wallpaper = $MONITOR,$WALL
EOF

echo "✅ Written hyprpaper.conf:"
echo "  preload = $WALL"
echo "  wallpaper = $MONITOR,$WALL"

# 4. Initialize SDDM theme structure by running a harmless test
sudo -u "$USER" sddm-greeter-qt6 --test-mode --theme /usr/share/sddm/themes/ || true

# Ensure themes folder exists, then move your 'silent' theme in place
sudo mkdir -p /usr/share/sddm/themes
sudo mv "$HOME/configs/silent" /usr/share/sddm/themes/ || true

# 5. Enable SDDM service
sudo systemctl enable sddm.service

# 6. Write your SDDM configuration
sudo tee /etc/sddm.conf > /dev/null <<EOF
[Theme]
Current=silent

[Wayland]
EnableHiDPI=true

[General]
InputMethod=qtvirtualkeyboard
GreeterEnvironment=QML2_IMPORT_PATH=/usr/share/sddm/themes/silent/components/,QT_IM_MODULE=qtvirtualkeyboard,QT_SCREEN_SCALE_FACTORS=1.5,QT_FONT_DPI=192
EOF

# 7. Install yay (AUR helper)
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si --noconfirm
cd ..

# 8. Install AUR packages (fonts + others)
yay -S --noconfirm ttf-jetbrains-mono-nerd zen-browser-bin papirus-icon-theme-git
fc-cache -fv

echo "✅ Setup complete! SDDM theme directories initialized before move, theme installed, SDDM enabled. Reboot to apply."


