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
      "herdr"
      "laishulu/homebrew/macism"
    ];

    casks = [
      "claude-code"
      "codex"
      "font-blex-mono-nerd-font"
      "font-fira-code-nerd-font"
      "font-jetbrains-mono-nerd-font"
      "google-japanese-ime"
      "mos"
      "raycast"
      "stats"
    ];

    onActivation = {
      autoUpdate = false;
      upgrade = false;
      cleanup = "none";
    };
  };
}
