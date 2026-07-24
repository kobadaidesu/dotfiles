{
  description = "kobadai's macOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-26.05-darwin";

    nix-darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      nix-darwin,
      home-manager,
      nix-homebrew,
      ...
    }:
    {
      darwinConfigurations."KobayashinoMacBook-Pro" = nix-darwin.lib.darwinSystem {
        specialArgs = { inherit inputs; };

        modules = [
          ./darwin-configuration.nix
          home-manager.darwinModules.home-manager
          nix-homebrew.darwinModules.nix-homebrew
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;

              # Preserve unmanaged files during the first migration.
              backupFileExtension = "hm-backup-20260724";

              users.kobadai = import ./home.nix;
            };

            nix-homebrew = {
              enable = true;
              user = "kobadai";
              autoMigrate = true;

              trust.formulae = [
                "felixkratz/formulae/borders"
                "laishulu/homebrew/macism"
              ];
            };
          }
        ];
      };

      formatter.aarch64-darwin = nixpkgs.legacyPackages.aarch64-darwin.nixfmt-tree;
    };
}
