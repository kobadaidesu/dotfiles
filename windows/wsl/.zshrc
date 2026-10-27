# zsh configuration for WSL (Ubuntu). install.ps1 links it to ~/.zshrc.

export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="agnoster"
plugins=(git)

# Skip the completion directory security audit (compaudit, ~0.1s per shell).
ZSH_DISABLE_COMPFIX=true

source $ZSH/oh-my-zsh.sh

# agnoster runs about ten git commands per prompt. On Windows drives (/mnt/*)
# each one goes through the 9P file share, which adds up to ~1s per Enter,
# so show only the branch there (white: clean/dirty is not checked).
functions[agnoster_prompt_git]=$functions[prompt_git]
prompt_git() {
  if [[ $PWD != /mnt/* ]]; then
    agnoster_prompt_git
    return
  fi
  local ref
  if ref=$(command git symbolic-ref --short -q HEAD 2>/dev/null); then
    ref=$''" $ref"
  else
    ref=$(command git rev-parse --short -q HEAD 2>/dev/null) || return
    ref="➦ $ref"
  fi
  prompt_segment white black "${ref//\%/%%}"
}

# 42 tester
alias francinette=$HOME/francinette/tester.sh
alias paco=$HOME/francinette/tester.sh

export PATH="$HOME/.local/bin:$PATH"

export NVM_DIR="$HOME/.nvm"
# Loading nvm takes ~0.5s per shell. Put the default Node (alias/default, or
# the newest installed one) on PATH directly and load nvm on its first use.
() {
  local default=${$(<$NVM_DIR/alias/default 2>/dev/null)#v}
  local bins=($NVM_DIR/versions/node/v${default}*/bin(Nn))
  (( $#bins )) || bins=($NVM_DIR/versions/node/*/bin(Nn))
  (( $#bins )) && path=($bins[-1] $path)
}
nvm() {
  unfunction nvm
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
  nvm "$@"
}

export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin
