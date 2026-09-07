{
  imports = [
    ../packages.nix
    ./dotfiles.nix
    ./git.nix
    ./zsh.nix
  ];

  home = {
    username = "kobadai";
    homeDirectory = "/Users/kobadai";
    stateVersion = "26.05";
    sessionPath = [
      "$HOME/.local/bin"
      "$HOME/go/bin"
      "$HOME/development/flutter/bin"
    ];
  };

  xdg.enable = true;

  programs = {
    home-manager.enable = true;
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };
}
