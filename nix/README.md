# Nix

This directory contains the macOS configuration managed with nix-darwin, Home
Manager, and nix-homebrew. The flake entry point is [`../flake.nix`](../flake.nix).

## Layout

- `darwin.nix`: host, user, Home Manager, and nix-homebrew integration
- `nix-settings.nix`: Nix CLI and flakes settings
- `homebrew.nix`: Homebrew formulae, casks, and taps
- `packages.nix`: command-line tools installed from Nixpkgs
- `macos-defaults.nix`: declarative macOS preferences
- `services.nix`: services supplied by Homebrew formulae
- `home/`: Home Manager configuration and existing dotfile links

## First activation

Install a Nix implementation using one of the installers supported by
[nix-darwin](https://github.com/nix-darwin/nix-darwin#prerequisites), clone
this repository to `~/dotfiles`, and run:

```sh
cd ~/dotfiles
brew install --cask --adopt ghostty zed
nix flake lock
nix flake check
sudo nix run nix-darwin/nix-darwin-26.05#darwin-rebuild -- \
  switch --flake .#macbook
```

Later changes can be applied with:

```sh
sudo darwin-rebuild switch --flake ~/dotfiles#macbook
```

This configuration lets nix-darwin manage upstream Nix. If Determinate Nix is
installed instead, change `nix.enable` to `false` and move the settings from
`nix-settings.nix` to Determinate's configuration before the first activation.

The existing `/opt/homebrew` installation is migrated by nix-homebrew.
Homebrew cleanup and automatic upgrades are disabled initially, so packages
that have not been declared yet are left installed.

Ghostty and Zed already exist outside Homebrew on this Mac. The `--adopt` step
lets Homebrew take ownership of those app bundles before nix-darwin runs
`brew bundle`. If either app cannot be adopted, move its existing app bundle
aside and rerun that command.

On the first Home Manager activation, conflicting unmanaged dotfiles are moved
aside with the `.hm-backup` suffix before the Nix-managed links are created.

Commit the generated `flake.lock` after reviewing its inputs. Generating it
before the `sudo` bootstrap command keeps the file owned by the normal user.

## Adding software

- Add normal command-line tools to `packages.nix`.
- Add macOS-only formulae and GUI casks to `homebrew.nix`.
- Put formulae that should run as services in `services.nix`.
- Add shell, Git, and dotfile settings under `home/`.

Then run `rebuild` (the Zsh alias) or the full `darwin-rebuild` command above.
Using `brew install` directly is still fine for trying something temporarily;
declare it in the appropriate Nix file when you decide to keep it.
