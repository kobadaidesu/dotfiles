{ config, lib, ... }:

{
  home.sessionPath = [
    "/run/current-system/sw/bin"
    "/etc/profiles/per-user/${config.home.username}/bin"
    "${config.home.homeDirectory}/go/bin"
  ];

  programs.zsh = {
    enable = true;
    dotDir = config.home.homeDirectory;
    enableCompletion = true;

    # nix-darwin initializes Homebrew from /etc/zprofile after .zshenv.
    # Restore Nix profiles to the front for interactive shells.
    initContent = lib.mkOrder 1500 ''
      path=(
        /run/current-system/sw/bin
        /etc/profiles/per-user/${config.home.username}/bin
        ${config.home.homeDirectory}/go/bin
        $path
      )
      typeset -U path
    '';

    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      gs = "git status";
    };

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
  };
}
