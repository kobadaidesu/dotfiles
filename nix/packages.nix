{ pkgs, ... }:

{
  home.packages = with pkgs; [
    fd
    gh
    go
    just
    lazygit
    nodejs
    ripgrep
  ];
}
