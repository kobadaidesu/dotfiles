{ config, ... }:

let
  starshipSettings = builtins.fromTOML (builtins.readFile ../../starship/.config/starship.toml);
in
{
  programs.zsh = {
    enable = true;
    dotDir = config.home.homeDirectory;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    oh-my-zsh = {
      enable = true;
      theme = "agnoster";
      plugins = [
        "git"
        "z"
        "sudo"
        "colored-man-pages"
        "command-not-found"
      ];
    };

    shellAliases = {
      gs = "git status";
      rebuild = "sudo darwin-rebuild switch --flake $HOME/dotfiles#macbook";
    };

    initContent = ''
      # maka: 雀魂の牌譜取り込みセッション (mjsoul-maka-why)。
      # ゲームタブが無いときだけ専用 Chrome を開く（毎回開くとタブが増えて
      # 記録が別タブに付いてしまうため）。
      maka() {
        if ! curl -s --max-time 2 http://127.0.0.1:9222/json/list 2>/dev/null | grep -q mahjongsoul; then
          "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
            --remote-debugging-address=127.0.0.1 \
            --remote-debugging-port=9222 \
            --user-data-dir="$HOME/.local/share/mjcap/chrome-profile" \
            "https://game.mahjongsoul.com/" >/dev/null 2>&1 &!
          sleep 2
        fi
        ( cd "$HOME/Documents/janntama" && ./bin/mjcap ingest "$@" )
      }
    '';
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = starshipSettings;
  };
}
