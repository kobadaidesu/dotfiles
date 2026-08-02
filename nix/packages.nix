{ pkgs, ... }:

{
  home.packages = with pkgs; [
    fd
    gh
    go
    gopls
    just
    lazygit
    nodejs
    ripgrep
  ];
}
