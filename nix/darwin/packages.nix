{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    cargo-nextest
    fd
    gh
    go
    just
    lazygit
    nodejs
    pkg-config
    plotutils
    ripgrep
    tree-sitter
  ];
}
