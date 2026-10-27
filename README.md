# dotfiles
<img width="3024" height="1964" alt="スクリーンショット 2026-07-16 20 56 37" src="https://github.com/user-attachments/assets/dec61e49-91a1-4200-a1ff-b81863630757" />



Personal macOS configuration managed with nix-darwin, Home Manager, and
nix-homebrew. The previous [GNU Stow](https://www.gnu.org/software/stow/)
workflow remains available while the migration is completed. The Zed and herdr
configurations can also be set up on Windows; see [Windows setup](#windows-setup).

## Included configurations

- Zsh and Oh My Zsh
- Git
- Ghostty
- Starship
- JankyBorders
- herdr
- Zed

## Declarative setup

The Nix configuration starts at [`flake.nix`](flake.nix), with modules under
[`nix/`](nix/). See [`nix/README.md`](nix/README.md) for the first activation
and rebuild commands.

## Legacy Stow setup

Homebrew must already be installed.

```sh
git clone https://github.com/kobadaidesu/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

The setup script installs the packages in `Brewfile`, installs the two Oh My
Zsh plugins used by `.zshrc`, and links each configuration into the home
directory with Stow.

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

## Windows setup

`install.ps1` links the Zed, herdr, and WSL zsh configurations with symbolic
links. Turn
on Developer Mode (Settings > System > For developers) or run it from an
elevated PowerShell.

```powershell
git clone https://github.com/kobadaidesu/dotfiles.git $HOME\dotfiles
powershell -ExecutionPolicy Bypass -File $HOME\dotfiles\install.ps1
```

The script installs Zed with winget, FiraCode Nerd Font, and
[zenhan](https://github.com/iuchim/zenhan) when they are missing, then links:

| Repository | Windows |
| --- | --- |
| `zed/.config/zed/settings.json`, `keymap.json`, `themes/` | `%APPDATA%\Zed\` |
| `windows/zed/tasks.json` | `%APPDATA%\Zed\tasks.json` |
| `herdr/.config/herdr/config.toml` | `%APPDATA%\herdr\config.toml` and `~/.config/herdr/config.toml` in the default WSL distribution |
| `windows/wsl/notify-send` | `~/.local/bin/notify-send` in the default WSL distribution |
| `windows/wsl/.zshrc`, `.zshenv` | `~/.zshrc`, `~/.zshenv` in the default WSL distribution |

`windows/zed/tasks.json` replaces the macOS task that switches to the ABC
input source with macism: on Windows, zenhan turns the IME off when Vim mode
enters insert mode.

WSL has no notification daemon, so herdr's `ui.toast.delivery = "system"`
would show nothing there. `windows/wsl/notify-send` takes the place of
libnotify's command and shows the notification as a Windows toast through
`powershell.exe`.

The WSL zsh configuration uses Oh My Zsh with the agnoster theme, which must
already be installed in WSL. It is tuned for start-up and prompt speed: on
Windows drives (`/mnt/*`) the prompt shows only the Git branch instead of
running agnoster's full status check, and nvm is loaded on first use.

Existing files are renamed with a `.backup-<timestamp>` suffix before they are
linked. Pass `-SkipWsl` to leave WSL untouched.

herdr itself is not installed by the script. Install it inside WSL or on
Windows by following the [herdr install guide](https://herdr.dev/docs/install/).

## Local-only data

Authentication credentials, API keys, application logs, session history, and generated databases are intentionally not tracked.
