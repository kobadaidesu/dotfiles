{ ... }:

{
  xdg.configFile."borders/bordersrc" = {
    executable = true;
    text = ''
      #!/bin/bash

      # Match AlvaroParker/config's Hyprland palette with a subtle Catppuccin glow.
      options=(
        style=round
        width=2.5
        hidpi=on
        "active_color=glow(0xffcba6f7)"
        inactive_color=0x9945475a
      )

      borders "''${options[@]}"
    '';
  };
}
