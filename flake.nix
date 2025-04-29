{
  description = "Turris flake";

  outputs = {
    self,
    nixpkgs,
  }: let
    inherit (nixpkgs.lib) genAttrs fixedPoints systems;
    forSystems = genAttrs systems.flakeExposed;
  in {
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

    packages = forSystems (system: let
      tarball = nixos: nixos.buildPlatform.${system}.config.system.build.tarball;
    in {
      tarballMox = tarball self.nixosConfigurations.installMox;
      tarballOmnia = tarball self.nixosConfigurations.installOmnia;
    });
    legacyPackages =
      forSystems (system:
        nixpkgs.legacyPackages.${system}.extend self.overlays.default);

    formatter = forSystems (system: nixpkgs.legacyPackages.${system}.alejandra);
  };
}
