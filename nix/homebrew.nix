{
  homebrew = {
    enable = true;
    enableZshIntegration = true;

    taps = [
      "felixkratz/formulae"
      "laishulu/homebrew"
    ];

    brews = [
      "cargo-nextest"
      "glew"
      "herdr"
      "pkgconf"
      "plotutils"
      "sdl2-compat"
      "stow"
      "swiftformat"
      "swiftlint"
      "terminal-notifier"
      "xcode-build-server"
    ];

    casks = [
      "claude-code"
      "codex"
      "font-blex-mono-nerd-font"
      "font-fira-code-nerd-font"
      "font-jetbrains-mono-nerd-font"
      "ghostty"
      "google-japanese-ime"
      "mos"
      "raycast"
      "stats"
      "zed"
    ];

    onActivation = {
      autoUpdate = false;
      upgrade = false;
      cleanup = "none";
    };

    # nix-darwin 26.05 does not expose Homebrew 6's `trusted` field yet.
    extraConfig = ''
      brew "laishulu/homebrew/macism", trusted: true
    '';
  };
}
