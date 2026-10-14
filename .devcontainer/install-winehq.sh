#!/usr/bin/env bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

if ! command -v sudo >/dev/null 2>&1; then
  echo "sudo is required to run this script." >&2
  exit 1
fi

source /etc/os-release
CODENAME="${VERSION_CODENAME:-}"

case "$CODENAME" in
  jammy)
    REPO_FILE_URL="https://dl.winehq.org/wine-builds/ubuntu/dists/jammy/winehq-jammy.sources"
    ;;
  noble)
    REPO_FILE_URL="https://dl.winehq.org/wine-builds/ubuntu/dists/noble/winehq-noble.sources"
    ;;
  resolute)
    REPO_FILE_URL="https://dl.winehq.org/wine-builds/ubuntu/dists/noble/winehq-noble.sources"
    echo "Ubuntu codename '$CODENAME' is using the WineHQ noble repository for compatibility."
    ;;
  *)
    echo "Unsupported Ubuntu codename: ${CODENAME:-unknown}." >&2
    echo "This script currently supports jammy, noble, and resolute based Codespaces images." >&2
    exit 1
    ;;
esac

sudo dpkg --add-architecture i386
sudo mkdir -pm755 /etc/apt/keyrings

if [ ! -f /etc/apt/keyrings/winehq-archive.key ]; then
  wget -qO- https://dl.winehq.org/wine-builds/winehq.key | sudo gpg --dearmor -o /etc/apt/keyrings/winehq-archive.key
fi

sudo wget -qO /etc/apt/sources.list.d/winehq.sources "$REPO_FILE_URL"

sudo apt-get update
sudo apt-get install -y --install-recommends winehq-stable
sudo apt-get install -y winetricks xvfb x11vnc openbox novnc websockify

echo "WineHQ and GUI dependencies were installed successfully."
