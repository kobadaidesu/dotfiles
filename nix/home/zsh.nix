{ config, ... }:

let
  starshipSettings = builtins.fromTOML (
    builtins.readFile ../../starship/.config/starship.toml
  );
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
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = starshipSettings;
  };
}
