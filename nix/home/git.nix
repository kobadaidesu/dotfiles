{ ... }:

{
  programs.git = {
    enable = true;

    settings.user = {
      email = "daigokobayashi04@gmail.com";
      name = "kobadaidesu";
    };

    ignores = [
      "**/.claude/settings.local.json"
    ];
  };
}
