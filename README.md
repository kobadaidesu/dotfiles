# dotfiles
<img width="3024" height="1964" alt="スクリーンショット 2026-07-16 20 56 37" src="https://github.com/user-attachments/assets/dec61e49-91a1-4200-a1ff-b81863630757" />



Personal macOS configuration managed with
[nix-darwin](https://github.com/nix-darwin/nix-darwin) and
[Home Manager](https://github.com/nix-community/home-manager).

## Included configurations

- Zsh and Oh My Zsh
- Git
- Ghostty
- Starship
- JankyBorders
- herdr
- Zed
- Neovim / LazyVim

## Architecture

- nix-darwin manages Nix settings, CLI packages, and the remaining Homebrew formulae.
- Home Manager links user configuration files into the home directory.
- Existing files are preserved once with the `.hm-backup-20260724` suffix during migration.
- Ghostty and Zed applications remain manually installed for now; their configuration is managed by Home Manager.

GNU Stow and the old Homebrew bootstrap are no longer used.

## Setup

Nix and Homebrew must already be installed.

```sh
git clone https://github.com/kobadaidesu/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

After the first installation, apply changes with:

```sh
sudo darwin-rebuild switch \
  --flake "path:$HOME/dotfiles#KobayashinoMacBook-Pro"
```

Update pinned inputs explicitly:

```sh
nix flake update --flake ~/dotfiles
```

## Local-only data

Authentication credentials, API keys, application logs, session history, and generated databases are intentionally not tracked.
