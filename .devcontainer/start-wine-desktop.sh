#!/usr/bin/env bash
set -e

echo "=== 1. Cleaning up any broken Wine repositories ==="
sudo rm -f /etc/apt/sources.list.d/winehq*.sources
sudo rm -f /etc/apt/keyrings/winehq*
sudo apt-get update -y

echo "=== 2. Enabling 32-bit architecture and updating system ==="
sudo dpkg --add-architecture i386
sudo apt-get update -y

echo "=== 3. Installing dependencies, native Wine, and XFCE Terminal ==="
sudo apt-get install -y \
    tigervnc-standalone-server \
    openbox \
    novnc \
    websockify \
    wget \
    curl \
    ca-certificates \
    wine \
    wine32 \
    wine64 \
    fonts-wine \
    libglib2.0-0 \
    libgtk-4-1 \
    libjson-glib-1.0-0 \
    libadwaita-1-0 \
    xfce4-terminal

echo "=== 4. Installing Google Chrome ==="
wget -O google-chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo apt-get install -y ./google-chrome.deb || sudo apt-get install -f -y
rm -f google-chrome.deb

echo "=== 5. Downloading and Installing WineGUI .deb package ==="
DEB_URL=$(curl -s https://api.github.com/repos/winegui/WineGUI/releases/latest | grep "browser_download_url" | grep ".deb" | cut -d '"' -f 4 | head -n 1)

if [ -z "$DEB_URL" ]; then
    DEB_URL="https://github.com/winegui/WineGUI/releases/download/v4.0.0/WineGUI-v4.0.0-x86_64.deb"
fi

wget -O winegui.deb "$DEB_URL"
sudo apt-get install -y ./winegui.deb || sudo apt-get install -f -y
rm -f winegui.deb

echo "=== 6. Configuring OpenBox Scaling & Auto-launch for Desktop 1 ==="
mkdir -p ~/.config/openbox

cat << 'XRES' > ~/.Xresources
Xft.dpi: 144
Xft.antialias: 1
Xft.hinting: 1
Xft.hintstyle: hintfull
XRES
xrdb -merge ~/.Xresources 2>/dev/null || true

cat << 'EMU' > ~/.config/openbox/autostart
xrdb -merge ~/.Xresources &
winegui &
xfce4-terminal &
EMU
chmod +x ~/.config/openbox/autostart

echo "=== 7. Launching VNC Server 1 (OpenBox / WineGUI) on Display :0 (Port 6080) ==="
vncserver -kill :0 2>/dev/null || true
tigervncserver :0 \
    --I-KNOW-THIS-IS-INSECURE \
    -SecurityTypes None \
    -xstartup /usr/bin/openbox \
    -geometry 1600x900 \
    -localhost no

echo "=== 8. Launching VNC Server 2 (Dedicated Chrome) on Display :1 (Port 6081) ==="
vncserver -kill :1 2>/dev/null || true

# Create custom startup script for the Chrome-only display session
cat << 'CHROMESTART' > ~/.vnc/xstartup-chrome
#!/bin/sh
xrdb -merge ~/.Xresources
# Launch Chrome with sandbox flags required for containerized environments
exec google-chrome --no-sandbox --disable-dev-shm-usage --start-maximized https://www.google.com
CHROMESTART
chmod +x ~/.vnc/xstartup-chrome

tigervncserver :1 \
    --I-KNOW-THIS-IS-INSECURE \
    -SecurityTypes None \
    -xstartup ~/.vnc/xstartup-chrome \
    -geometry 1600x900 \
    -localhost no

echo "=== 9. Starting noVNC / websockify bridges for both ports ==="
pkill -f websockify || true
# Bridge Port 6080 to Display :0 (OpenBox Desktop)
websockify --web=/usr/share/novnc/ 6080 localhost:5900 &
# Bridge Port 6081 to Display :1 (Dedicated Chrome Instance)
websockify --web=/usr/share/novnc/ 6081 localhost:5901 &

echo "====================================================="
echo " SUCCESS! Dual environments running:"
echo " -> Desktop 1 (WineGUI + Terminal): Port 6080"
echo " -> Desktop 2 (Dedicated Chrome):   Port 6081"
echo " Go to the 'Ports' tab in Codespaces, make both Public,"
echo " and open them in your browser!"
echo "====================================================="
