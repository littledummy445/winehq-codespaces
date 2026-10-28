# winehq-codespaces

Set up WineHQ and Wine GUI tooling inside GitHub Codespaces.

## What this repository provides

- A Codespaces-ready install script for WineHQ stable
- GUI support dependencies for Wine apps (`xvfb`, `x11vnc`, `openbox`, `novnc`)
- A helper launcher script to run Wine GUI configuration
- Ubuntu codename support for `jammy`, `noble`, and `resolute` (with a compatibility fallback)

## Quick start

1. Open this repository in GitHub Codespaces.
2. Link to GitHub Codespaces (Open)[codespaces.new]
3. Wait for the `postCreateCommand` to complete. It runs:
   - `.devcontainer/install-winehq.sh`
4. Verify the installation:

```bash
wine --version
winetricks --version
```

4. Run the Wine GUI config helper:

```bash
bash scripts/run-winegui.sh
```

## Manual install (outside post-create)

```bash
bash .devcontainer/install-winehq.sh
```

## Full terminal install script

Run this full script in an Ubuntu terminal to install WineHQ stable, required Wine components, noVNC, and websockify:

```bash
#!/usr/bin/env bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive
source /etc/os-release
CODENAME="${VERSION_CODENAME:-}"

case "$CODENAME" in
  jammy) REPO_FILE_URL="https://dl.winehq.org/wine-builds/ubuntu/dists/jammy/winehq-jammy.sources" ;;
  noble|resolute) REPO_FILE_URL="https://dl.winehq.org/wine-builds/ubuntu/dists/noble/winehq-noble.sources" ;;
  *)
    echo "Unsupported Ubuntu codename: ${CODENAME:-unknown}. Supported: jammy, noble, resolute." >&2
    exit 1
    ;;
esac

sudo dpkg --add-architecture i386
sudo mkdir -pm755 /etc/apt/keyrings
sudo apt-get update
sudo apt-get install -y ca-certificates wget gnupg
wget -qO- https://dl.winehq.org/wine-builds/winehq.key | sudo gpg --dearmor -o /etc/apt/keyrings/winehq-archive.key
sudo wget -qO /etc/apt/sources.list.d/winehq.sources "$REPO_FILE_URL"

sudo apt-get update
sudo apt-get install -y --install-recommends winehq-stable
sudo apt-get install -y winetricks xvfb x11vnc openbox novnc websockify
```

## Repository structure

- `.devcontainer/devcontainer.json` - Codespaces container definition
- `.devcontainer/install-winehq.sh` - WineHQ + GUI dependency installer
- `scripts/run-winegui.sh` - Wine GUI launcher helper
- `CONTRIBUTING.md` - Contribution guidelines

## License

This project is licensed under the MIT License. See [`LICENSE`](./LICENSE).
