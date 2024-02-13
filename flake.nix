{
  description = "Turris flake";

  outputs = {
    self,
    flake-utils,
    nixpkgs,
  }: let
    inherit (flake-utils.lib) eachDefaultSystem;
    inherit (nixpkgs.lib) fixedPoints;
  in
    {
      overlays = {
        lib = final: prev: import ./lib self final prev;
        default = final: prev: import ./pkgs prev final;
      };
      nixosModules = import ./nixos self;
      lib = fixedPoints.fix (import ./lib self nixpkgs.lib);

      nixosConfigurations = {
        installMox = self.lib.nixturrisSystem {
          board = "mox";
          modules = [{turris.install-settings = true;}];
        };
        installOmnia = self.lib.nixturrisSystem {
          board = "omnia";
          modules = [{turris.install-settings = true;}];
        };
      };

      templates.default = {
        path = ./template;
        description = "NixOS configuration for Turris";
      };
    }
    // eachDefaultSystem (
      system: let
        pkgs = nixpkgs.legacyPackages."${system}";
        tarball = nixos: nixos.buildPlatform.${system}.config.system.build.tarball;
      in {
        packages = {
          tarballMox = tarball self.nixosConfigurations.installMox;
          tarballOmnia = tarball self.nixosConfigurations.installOmnia;
        };

        # The legacyPackages imported as overlay allows us to use pkgsCross to
        # cross-compile those packages.
        legacyPackages = pkgs.extend self.overlays.default;

        formatter = pkgs.alejandra;
      }
    );
}
