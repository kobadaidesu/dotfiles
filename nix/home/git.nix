{
  programs.git = {
    enable = true;
    settings.user = {
      name = "kobadaidesu";
      email = "daigokobayashi04@gmail.com";
    };
    ignores = [
      "**/.claude/settings.local.json"
    ];
  };
}
