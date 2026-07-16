# dotfiles
<img width="3024" height="1964" alt="スクリーンショット 2026-07-16 20 56 37" src="https://github.com/user-attachments/assets/dec61e49-91a1-4200-a1ff-b81863630757" />



Personal macOS configuration files, managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Included configurations

- Zsh and Oh My Zsh
- Git
- Ghostty
- Starship
- JankyBorders
- herdr
- Zed
- Neovim / LazyVim

## Setup

Homebrew must already be installed.

```sh
git clone https://github.com/kobadaidesu/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

The setup script installs the packages in `Brewfile`, installs the two Oh My Zsh plugins used by `.zshrc`, and links each configuration into the home directory with Stow.

Stow stops instead of overwriting an existing regular file. On a machine that already has configuration files, compare or back them up before running the script again.

## Manual linking

To link only selected configurations:

```sh
stow --dir="$HOME/dotfiles" --target="$HOME" zsh git ghostty starship
```

To remove those links:

```sh
stow --dir="$HOME/dotfiles" --target="$HOME" --delete zsh git ghostty starship
```

## Local-only data

Authentication credentials, API keys, application logs, session history, and generated databases are intentionally not tracked.
