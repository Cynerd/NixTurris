{
  description = "Turris flake";

  outputs = {
    self,
    flake-utils,
    nixpkgs,
  }:
    with nixpkgs.lib;
    with flake-utils.lib; let
      # Note: crossTarball* targets are broken on darwin so it gets disabled here
      isNotDarwin = system: ! hasSuffix "-darwin" system;
      supportedHostSystems =
        filter isNotDarwin defaultSystems ++ [system.armv7l-linux];
    in
      {
        overlays.default = final: prev: import ./pkgs {nixpkgs = prev;};
        nixosModules = import ./nixos self;
        lib = import ./lib {inherit self;};

        nixosConfigurations = {
          mox = self.lib.nixturrisSystem {
            board = "mox";
            nixpkgs = nixpkgs;
          };
          omnia = self.lib.nixturrisSystem {
            board = "omnia";
            nixpkgs = nixpkgs;
          };
        };
      }
      // eachSystem supportedHostSystems (
        system: let
          pkgs = nixpkgs.legacyPackages."${system}";
        in {
          packages = let
            tarball = nixos: nixos.config.system.build.tarball;
          in
            {
              tarballMox = tarball self.nixosConfigurations.mox;
              tarballOmnia = tarball self.nixosConfigurations.omnia;

              crossTarballMox = tarball self.nixosConfigurations.mox.config.system.build.cross.${system};
              crossTarballOmnia = tarball self.nixosConfigurations.omnia.config.system.build.cross.${system};
            }
            // filterPackages system (flattenTree (
              import ./pkgs {nixpkgs = pkgs;}
            ));

          # The legacyPackages imported as overlay allows us to use pkgsCross to
          # cross-compile those packages.
          legacyPackages = pkgs.extend self.overlays.default;

          formatter = pkgs.alejandra;
        }
      );
}
