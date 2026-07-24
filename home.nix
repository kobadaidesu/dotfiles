{ ... }:

{
  home = {
    username = "kobadai";
    homeDirectory = "/Users/kobadai";
    stateVersion = "26.05";
  };

  programs.home-manager.enable = true;
  xdg.enable = true;

  home.file = {
    ".zshrc".source = ./zsh/.zshrc;
    ".gitconfig".source = ./git/.gitconfig;
  };

  xdg.configFile = {
    "git/ignore".source = ./git/.config/git/ignore;
    "ghostty/config".source = ./ghostty/.config/ghostty/config;
    "starship.toml".source = ./starship/.config/starship.toml;
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
