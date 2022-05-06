{
  description = "Turris flake";

  outputs = { self, flake-utils, nixpkgs }:
  with flake-utils.lib;
  let
    supportedHostSystems = (
      # Note: crossTarball* targets are broken on darwin so it gets disabled here
      with builtins; filter (system: match ".*-darwin" system == null) defaultSystems
    ) ++ [system.armv7l-linux];
  in {

      overlays.default = final: prev: import ./pkgs { nixpkgs = prev; };
      nixosModules = import ./nixos self;
      lib = import ./lib self;

      nixosConfigurations = {
        tarballMox = self.lib.nixturrisTarballSystem { board = "mox"; nixpkgs = nixpkgs; };
        tarballOmnia = self.lib.nixturrisTarballSystem { board = "omnia"; nixpkgs = nixpkgs; };
      };

    } // eachSystem supportedHostSystems (
      system: {

        packages = let
          tarball = nixos: nixos.config.system.build.tarball;
        in {

          tarballMox = tarball self.nixosConfigurations.tarballMox;
          tarballOmnia = tarball self.nixosConfigurations.tarballOmnia;

          crossTarballMox = tarball (self.lib.nixturrisTarballSystem { board = "mox"; nixpkgs = nixpkgs; system = system; });
          crossTarballOmnia = tarball (self.lib.nixturrisTarballSystem { board = "omnia"; nixpkgs = nixpkgs; system = system; });

        } // filterPackages system (flattenTree (
          import ./pkgs { nixpkgs = nixpkgs.legacyPackages."${system}"; }
        ));

        # The legacyPackages imported as overlay allows us to use pkgsCross to
        # cross-compile those packages.
        legacyPackages = import nixpkgs {
          inherit system;
          overlays = [ self.overlays.default ];
          crossOverlays = [ self.overlays.default ];
        };

      }
    );
}
