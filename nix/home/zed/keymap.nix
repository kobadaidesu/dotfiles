let
  escapeEnter = builtins.fromJSON ''"\u001b\r"'';

  withAsciiIme = action: [
    "action::Sequence"
    [
      [
        "task::Spawn"
        { task_name = "IME: ABC"; }
      ]
      action
    ]
  ];

  paneBindings = {
    "ctrl-t h" = "workspace::ActivatePaneLeft";
    "ctrl-t j" = "workspace::ActivatePaneDown";
    "ctrl-t k" = "workspace::ActivatePaneUp";
    "ctrl-t l" = "workspace::ActivatePaneRight";
  };
in
[
  {
    context = "Terminal";
    bindings."shift-enter" = [
      "terminal::SendText"
      escapeEnter
    ];
  }

  {
    context = "Editor";
    bindings = {
      f12 = "editor::FindAllReferences";
      "cmd-f12" = "editor::GoToDefinition";
    };
  }

  {
    context = "Editor && vim_mode == normal && !menu";
    bindings = {
      i = withAsciiIme "vim::InsertBefore";
      a = withAsciiIme "vim::InsertAfter";
      "shift-i" = withAsciiIme "vim::InsertFirstNonWhitespace";
      "shift-a" = withAsciiIme "vim::InsertEndOfLine";
      o = withAsciiIme "vim::InsertLineBelow";
      "shift-o" = withAsciiIme "vim::InsertLineAbove";
      c = withAsciiIme "vim::PushChange";
      "shift-c" = withAsciiIme "vim::ChangeToEndOfLine";
      s = withAsciiIme "vim::Substitute";
      "shift-s" = withAsciiIme "vim::SubstituteLine";
      r = withAsciiIme "vim::PushReplace";
      "shift-r" = withAsciiIme "vim::ToggleReplace";
      "g i" = withAsciiIme "vim::InsertAtPrevious";
      insert = withAsciiIme "vim::InsertBefore";

      space = null;
      "space g s" = "git_panel::ToggleFocus";
      "g shift-a" = null;
      "g r" = "editor::FindAllReferences";
    };
  }

  {
    context = "Editor && vim_mode == visual && !menu";
    bindings = {
      c = withAsciiIme "vim::Substitute";
      s = withAsciiIme "vim::Substitute";
      "shift-r" = withAsciiIme "vim::SubstituteLine";
      "shift-s" = withAsciiIme "vim::SubstituteLine";
      "shift-i" = withAsciiIme "vim::InsertBefore";
      "shift-a" = withAsciiIme "vim::InsertAfter";
      "g shift-i" = withAsciiIme "vim::VisualInsertFirstNonWhiteSpace";
      "g shift-a" = withAsciiIme "vim::VisualInsertEndOfLine";
    };
  }

  {
    context = "Editor && vim_mode == insert && !menu";
    bindings."j j" = "vim::NormalBefore";
  }

  {
    context = "Editor && VimControl && !VimWaiting && !menu";
    bindings = paneBindings;
  }

  {
    context = "Dock";
    bindings = paneBindings;
  }
]
