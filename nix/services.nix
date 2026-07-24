{
  homebrew.extraConfig = ''
    brew "felixkratz/formulae/borders", trusted: true, restart_service: :changed
  '';
}
