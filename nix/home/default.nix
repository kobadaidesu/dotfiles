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
    ];
  };

  xdg.enable = true;

  programs = {
    home-manager.enable = true;
    neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
    };
  };
}
