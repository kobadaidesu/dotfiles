{
  inputs,
  ...
}:

{
  imports = [ ./nix/darwin ];

  nixpkgs.hostPlatform = "aarch64-darwin";

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  users.users.kobadai = {
    name = "kobadai";
    home = "/Users/kobadai";
  };
  system.primaryUser = "kobadai";

  # macOS 26 protects /etc/pam.d from this activation context.
  # Sudo continues to use the system password configuration.
  security.pam.services.sudo_local.enable = false;

  system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;

  # Set once for this initial nix-darwin 26.05 installation.
  system.stateVersion = 7;
}
