{
  description = "NixOS configuration for Turris system";

  inputs.nixturris = {
    url = "gitlab:cynerd/nixturris";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    self,
    flake-utils,
    nixpkgs,
    nixturris,
  }: let
    inherit (flake-utils.lib) eachDefaultSystem;
    inherit (nixturris.lib) nixturrisSystem;
  in
    {
      nixosConfigurations."nixturris" = nixturrisSystem {
        modules = [./configuration.nix];
      };
    }
    // eachDefaultSystem (system: {
      packages = {
        inherit
          (self.nixosConfigurations."nixturris".buildPlatform.${system}.config.system.build)
          toplevel
          tarball
          ;
        default = self.packages.${system}.toplevel;
      };

      formatter = nixpkgs.legacyPackages.${system}.alejandra;
    });
}
