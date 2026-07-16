#!/usr/bin/env bash

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGES=(
  zsh
  git
  ghostty
  starship
  borders
  herdr
  zed
  nvim
)

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "This setup currently supports macOS only." >&2
  exit 1
fi

if ! command -v brew >/dev/null 2>&1; then
  echo "Homebrew is required: https://brew.sh" >&2
  exit 1
fi

brew bundle --file="$DOTFILES_DIR/Brewfile"

OH_MY_ZSH_DIR="${ZSH:-$HOME/.oh-my-zsh}"
if [[ ! -d "$OH_MY_ZSH_DIR" ]]; then
  git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git "$OH_MY_ZSH_DIR"
fi

ZSH_CUSTOM_DIR="${ZSH_CUSTOM:-$OH_MY_ZSH_DIR/custom}"
if [[ ! -d "$ZSH_CUSTOM_DIR/plugins/zsh-autosuggestions" ]]; then
  git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions \
    "$ZSH_CUSTOM_DIR/plugins/zsh-autosuggestions"
fi

if [[ ! -d "$ZSH_CUSTOM_DIR/plugins/zsh-syntax-highlighting" ]]; then
  git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git \
    "$ZSH_CUSTOM_DIR/plugins/zsh-syntax-highlighting"
fi

stow \
  --dir="$DOTFILES_DIR" \
  --target="$HOME" \
  --restow \
  "${PACKAGES[@]}"

echo "Dotfiles linked successfully. Start a new shell to load the Zsh configuration."
