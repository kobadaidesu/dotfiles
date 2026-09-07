{ inputs, ... }:

{
  imports = [
    ./homebrew.nix
    ./macos-defaults.nix
    ./nix-settings.nix
    ./services.nix
  ];

  nixpkgs.hostPlatform = "aarch64-darwin";
  nixpkgs.config.allowUnfree = true;

  system.primaryUser = "kobadai";
  users.users.kobadai.home = "/Users/kobadai";

  # Touch ID で sudo を通す + darwin-rebuild だけはパスワード無しで実行可に
  # (エージェントが dotfiles 変更を自動デプロイできるようにするため)
  security.pam.services.sudo_local.touchIdAuth = true;
  security.sudo.extraConfig = ''
    kobadai ALL=(ALL) NOPASSWD: /run/current-system/sw/bin/darwin-rebuild
  '';

  programs.zsh.enable = true;
  environment.pathsToLink = [ "/share/zsh" ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "hm-backup";
    extraSpecialArgs = { inherit inputs; };
    users.kobadai = import ./home;
  };

  nix-homebrew = {
    enable = true;
    enableRosetta = false;
    user = "kobadai";
    autoMigrate = true;
    mutableTaps = true;
  };

  system.stateVersion = 6;
}
