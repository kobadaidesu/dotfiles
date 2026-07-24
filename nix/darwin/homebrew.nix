{ ... }:

{
  # Keep fast-moving vendor CLIs and macOS applications on Homebrew.
  homebrew = {
    enable = true;

    taps = [
      "felixkratz/formulae"
      "laishulu/homebrew"
    ];

    brews = [
      "felixkratz/formulae/borders"
      "glew"
      "herdr"
      "laishulu/homebrew/macism"
      "sdl2-compat"
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
  };
}
