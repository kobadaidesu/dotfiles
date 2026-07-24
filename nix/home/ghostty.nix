{ ... }:

{
  # Ghostty itself remains a native macOS application.
  programs.ghostty = {
    enable = true;
    package = null;

    settings = {
      "font-family" = "FiraCode Nerd Font";
      "font-style" = "SemiBold";
      "font-size" = 10;

      background = "#1E1E2E";
      foreground = "#CDD6F4";
      "background-opacity" = 0.45;
      "background-opacity-cells" = false;

      "selection-foreground" = "#1E1E2E";
      "selection-background" = "#F5E0DC";

      "cursor-style" = "block";
      "cursor-style-blink" = true;
      "cursor-color" = "#F5E0DC";
      "cursor-text" = "#1E1E2E";

      "search-foreground" = "#1E1E2E";
      "search-background" = "#A6ADC8";
      "search-selected-foreground" = "#1E1E2E";
      "search-selected-background" = "#A6E3A1";

      palette = [
        "0=#45475A"
        "1=#F38BA8"
        "2=#A6E3A1"
        "3=#F9E2AF"
        "4=#89B4FA"
        "5=#F5C2E7"
        "6=#94E2D5"
        "7=#BAC2DE"
        "8=#7F849C"
        "9=#F38BA8"
        "10=#A6E3A1"
        "11=#F9E2AF"
        "12=#89B4FA"
        "13=#F5C2E7"
        "14=#94E2D5"
        "15=#A6ADC8"
        "16=#FAB387"
        "17=#F5E0DC"
      ];

      "window-width" = 106;
      "window-height" = 26;
      "window-padding-x" = 10;
      "window-padding-y" = 10;
      "window-inherit-working-directory" = false;

      "gtk-toolbar-style" = "flat";
      "gtk-wide-tabs" = false;

      term = "xterm-256color";

      keybind = [
        "ctrl+backspace=text:\\x17"
        "ctrl+enter=unbind"
      ];
    };
  };
}
