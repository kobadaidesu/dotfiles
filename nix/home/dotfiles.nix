{
  xdg.configFile = {
    "borders/bordersrc".source = ../../borders/.config/borders/bordersrc;
    "ghostty/config".source = ../../ghostty/.config/ghostty/config;
    "herdr/config.toml".source = ../../herdr/.config/herdr/config.toml;

    nvim = {
      source = ../../nvim/.config/nvim;
      recursive = true;
    };

    zed = {
      source = ../../zed/.config/zed;
      recursive = true;
    };
  };
}
