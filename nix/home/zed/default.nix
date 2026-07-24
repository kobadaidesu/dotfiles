{ pkgs, ... }:

let
  json = pkgs.formats.json { };
in
{
  xdg.configFile = {
    "zed/settings.json".source = json.generate "zed-settings.json" (import ./settings.nix);
    "zed/keymap.json".source = json.generate "zed-keymap.json" (import ./keymap.nix);
    "zed/tasks.json".source = json.generate "zed-tasks.json" (import ./tasks.nix);

    "zed/themes" = {
      source = ../../../assets/zed/themes;
      recursive = true;
    };
  };
}
