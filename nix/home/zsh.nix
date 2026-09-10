{ config, ... }:

let
  starshipSettings = builtins.fromTOML (builtins.readFile ../../starship/.config/starship.toml);
in
{
  programs.zsh = {
    enable = true;
    dotDir = config.home.homeDirectory;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    oh-my-zsh = {
      enable = true;
      theme = "agnoster";
      plugins = [
        "git"
        "z"
        "sudo"
        "colored-man-pages"
        "command-not-found"
      ];
    };

    shellAliases = {
      gs = "git status";
      rebuild = "sudo darwin-rebuild switch --flake $HOME/dotfiles#macbook";
    };

    initContent = ''
      # maka: 雀魂の牌譜取り込みセッション (mjsoul-maka-why)。実体は repo 同梱の scripts/maka。
      maka() { "$HOME/Documents/janntama/scripts/maka" "$@"; }
    '';
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = starshipSettings;
  };
}
