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
