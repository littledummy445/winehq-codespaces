#!/usr/bin/env bash
set -e

echo "=== 1. Updating system and adding i386 architecture for Wine ==="
sudo dpkg --add-architecture i386
sudo apt-get update -y

echo "=== 2. Installing X11, OpenBox, TigerVNC, and noVNC ==="
sudo apt-get install -y \
    tigervnc-standalone-server \
    openbox \
    novnc \
    websockify \
    wget \
    curl \
    software-properties-common \
    gnupg \
    lsb-release

echo "=== 3. Installing WineHQ (Stable) ==="
sudo mkdir -pm755 /etc/apt/keyrings
sudo wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key
sudo wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/ubuntu/dists/$(lsb_release -sc)/winehq-$(lsb_release -sc).sources || true

sudo apt-get update -y
sudo apt-get install -y --install-recommends winehq-stable || sudo apt-get install -y wine-stable

echo "=== 4. Launching VNC Server with OpenBox on Display :0 ==="
# Kill any existing Xvfb/VNC locks
vncserver -kill :0 2>/dev/null || true

# Start TigerVNC server running OpenBox window manager
tigervncserver :0 \
    -SecurityTypes none \
    -xstartup /usr/bin/openbox \
    -geometry 1280x800 \
    -localhost no

echo "=== 5. Starting noVNC / websockify bridge on port 6080 ==="
# Kill existing websockify instances if any
pkill -f websockify || true

# Launch websockify to wrap VNC into a web socket stream
websockify --web=/usr/share/novnc/ 6080 localhost:5900 &

echo "====================================================="
echo " SUCCESS! OpenBox + WineHQ environment is running."
echo " Go to the 'Ports' tab in Codespaces, find port 6080,"
echo " change visibility to Public, and click 'Open in Browser'."
echo " Appended to URL, use: vnc.html?host=localhost&port=6080"
echo "====================================================="
