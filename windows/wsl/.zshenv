# zsh environment for WSL (Ubuntu). install.ps1 links it to ~/.zshenv.

[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

# oh-my-zsh runs compinit itself; skip the second run in /etc/zsh/zshrc.
skip_global_compinit=1
