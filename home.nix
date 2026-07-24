{ ... }:

{
  imports = [
    ./nix/home/git.nix
    ./nix/home/starship.nix
    ./nix/home/zsh.nix
  ];

  home = {
    username = "kobadai";
    homeDirectory = "/Users/kobadai";
    stateVersion = "26.05";
  };

  programs.home-manager.enable = true;
  xdg.enable = true;

  xdg.configFile = {
    "ghostty/config".source = ./ghostty/.config/ghostty/config;
    "herdr/config.toml".source = ./herdr/.config/herdr/config.toml;
    "borders/bordersrc".source = ./borders/.config/borders/bordersrc;

    "zed/settings.json".source = ./zed/.config/zed/settings.json;
    "zed/keymap.json".source = ./zed/.config/zed/keymap.json;
    "zed/tasks.json".source = ./zed/.config/zed/tasks.json;
    "zed/themes" = {
      source = ./zed/.config/zed/themes;
      recursive = true;
    };

    "nvim" = {
      source = ./nvim/.config/nvim;
      recursive = true;
    };
  };

}
