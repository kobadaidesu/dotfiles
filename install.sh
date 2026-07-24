#!/usr/bin/env bash

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOST_NAME="${DARWIN_HOST:-$(/usr/sbin/scutil --get LocalHostName)}"
FLAKE_REF="path:$DOTFILES_DIR#$HOST_NAME"

if [[ "$EUID" -eq 0 ]]; then
  export HOME="/var/root"
fi

if [[ "$(/usr/bin/uname -s)" != "Darwin" ]]; then
  echo "This setup currently supports macOS only." >&2
  exit 1
fi

NIX_BIN="$(command -v nix 2>/dev/null || true)"
if [[ -z "$NIX_BIN" && -x /run/current-system/sw/bin/nix ]]; then
  NIX_BIN="/run/current-system/sw/bin/nix"
elif [[ -z "$NIX_BIN" && -x /nix/var/nix/profiles/default/bin/nix ]]; then
  NIX_BIN="/nix/var/nix/profiles/default/bin/nix"
fi

if [[ -z "$NIX_BIN" ]]; then
  echo "Nix is required: https://nixos.org/download/" >&2
  exit 1
fi

if [[ "$HOST_NAME" != "KobayashinoMacBook-Pro" ]]; then
  echo "No nix-darwin configuration is defined for host: $HOST_NAME" >&2
  exit 1
fi

DARWIN_REBUILD_BIN="$(command -v darwin-rebuild 2>/dev/null || true)"
if [[ -z "$DARWIN_REBUILD_BIN" && -x /run/current-system/sw/bin/darwin-rebuild ]]; then
  DARWIN_REBUILD_BIN="/run/current-system/sw/bin/darwin-rebuild"
fi

if [[ -n "$DARWIN_REBUILD_BIN" ]]; then
  /usr/bin/sudo "$DARWIN_REBUILD_BIN" switch --flake "$FLAKE_REF"
else
  /usr/bin/sudo "$NIX_BIN" \
    --extra-experimental-features "nix-command flakes" \
    run github:nix-darwin/nix-darwin/nix-darwin-26.05#darwin-rebuild \
    -- switch --flake "$FLAKE_REF"
fi

echo "nix-darwin and Home Manager configuration applied."
