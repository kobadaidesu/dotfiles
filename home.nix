{ ... }:

{
  imports = [ ./nix/home ];

  home = {
    username = "kobadai";
    homeDirectory = "/Users/kobadai";
    stateVersion = "26.05";
  };

  programs.home-manager.enable = true;
  xdg.enable = true;
}
