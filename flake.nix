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
        overlays = {
          default = final: prev: import ./pkgs {nixpkgs = prev;};
          armv7-cross = import ./overlays/armv7-cross.nix;
          armv7-native = import ./overlays/armv7-native.nix;
        };
        nixosModules = import ./nixos self;
        lib = import ./lib {inherit self;};

        nixosConfigurations = {
          installMox = self.lib.nixturrisSystem {
            board = "mox";
            inherit nixpkgs;
            modules = [{turris.install-settings = true;}];
          };
          installOmnia = self.lib.nixturrisSystem {
            board = "omnia";
            inherit nixpkgs;
            modules = [{turris.install-settings = true;}];
          };
        };
      }
      // eachSystem supportedHostSystems (
        system: let
          pkgs = nixpkgs.legacyPackages."${system}";
          tarball = nixos: nixos.buildPlatform.${system}.config.system.build.tarball;
        in {
          packages =
            {
              tarballMox = tarball self.nixosConfigurations.installMox;
              tarballOmnia = tarball self.nixosConfigurations.installOmnia;
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
