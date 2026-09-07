{
  xdg.configFile = {
    "borders/bordersrc".source = ../../borders/.config/borders/bordersrc;
    "ghostty/config".source = ../../ghostty/.config/ghostty/config;
    "herdr/config.toml".source = ../../herdr/.config/herdr/config.toml;

    zed = {
      source = ../../zed/.config/zed;
      recursive = true;
    };
  };
}
