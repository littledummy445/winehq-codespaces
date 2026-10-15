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

echo "=== 6. Configuring OpenBox Auto-launch (WineGUI & Terminal) ==="
mkdir -p ~/.config/openbox
cat << 'EMU' > ~/.config/openbox/autostart
# Auto-launch WineGUI and a terminal inside the desktop session
winegui &
xfce4-terminal &
EMU
chmod +x ~/.config/openbox/autostart

echo "=== 7. Launching VNC Server with OpenBox on Display :0 ==="
vncserver -kill :0 2>/dev/null || true

tigervncserver :0 \
    --I-KNOW-THIS-IS-INSECURE \
    -SecurityTypes None \
    -xstartup /usr/bin/openbox \
    -geometry 1280x800 \
    -localhost no

echo "=== 8. Starting noVNC / websockify bridge on port 6080 ==="
pkill -f websockify || true
websockify --web=/usr/share/novnc/ 6080 localhost:5900 &

echo "====================================================="
echo " SUCCESS! OpenBox + Chrome + XFCE Terminal + WineGUI running."
echo " Go to the 'Ports' tab in Codespaces, find port 6080,"
echo " change visibility to Public, and click 'Open in Browser'."
echo "====================================================="
