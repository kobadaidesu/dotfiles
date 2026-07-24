{ pkgs, ... }:

let
  toml = pkgs.formats.toml { };
in
{
  xdg.configFile."herdr/config.toml".source = toml.generate "herdr-config.toml" {
    onboarding = false;

    keys = {
      prefix = "ctrl+r";
      focus_pane_left = "prefix+h";
      focus_pane_down = "prefix+j";
      focus_pane_up = "prefix+k";
      focus_pane_right = "prefix+l";

      command = [
        {
          key = "prefix+alt+g";
          type = "pane";
          command = "git status && echo && git log --oneline --graph --all -20 | less -R";
        }
      ];
    };

    ui = {
      agent_panel_sort = "spaces";
      toast = {
        delivery = "system";
        delay_seconds = 1;
      };
    };

    theme = {
      name = "tokyo-night";
      auto_switch = false;
    };

    experimental = {
      reveal_hidden_cursor_for_cjk_ime = true;
      cjk_ime_agents = [
        "claude"
        "codex"
      ];
      switch_ascii_input_source_in_prefix = true;
      pane_history = true;
    };
  };
}
