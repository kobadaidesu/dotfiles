{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    gh
    neovim
    ripgrep
  ];
}
