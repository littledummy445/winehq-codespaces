# winehq-codespaces

Set up WineHQ and Wine GUI tooling inside GitHub Codespaces.

## What this repository provides

- A Codespaces-ready install script for WineHQ stable
- GUI support dependencies for Wine apps (`xvfb`, `x11vnc`, `openbox`, `novnc`)
- A helper launcher script to run Wine GUI configuration
- Ubuntu codename support for `jammy`, `noble`, and `resolute` (with a compatibility fallback)

## Quick start

1. Open this repository in GitHub Codespaces.
2. Wait for the `postCreateCommand` to complete. It runs:
   - `.devcontainer/install-winehq.sh`
3. Verify the installation:

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

## Repository structure

- `.devcontainer/devcontainer.json` - Codespaces container definition
- `.devcontainer/install-winehq.sh` - WineHQ + GUI dependency installer
- `scripts/run-winegui.sh` - Wine GUI launcher helper
- `CONTRIBUTING.md` - Contribution guidelines

## License

This project is licensed under the MIT License. See [`LICENSE`](./LICENSE).
