{
  description = "Turris flake";

  outputs = { self, flake-utils, nixpkgs }: {

      overlays.default = final: prev: import ./pkgs { nixpkgs = prev; };
      overlay = self.overlays.default; # Backward compatibility

      nixosModules = import ./nixos;
      nixosModule = {
        imports = builtins.attrValues self.nixosModules;
        nixpkgs.overlays = [ self.overlay ];
      };

      lib = import ./lib self;

      nixosConfigurations = {
        tarballMox = self.lib.nixturrisTarballSystem { board = "mox"; nixpkgs = nixpkgs; };
        tarballOmnia = self.lib.nixturrisTarballSystem { board = "omnia"; nixpkgs = nixpkgs; };
      };

    } // flake-utils.lib.eachSystem (flake-utils.lib.defaultSystems ++ ["armv7l-linux"]) (
      system: {
        packages = let
          tarball = nixos: nixos.config.system.build.tarball;
        in {

          tarballMox = tarball self.nixosConfigurations.tarballMox;
          tarballOmnia = tarball self.nixosConfigurations.tarballOmnia;

          crossTarballMox = tarball (self.lib.nixturrisTarballSystem { board = "mox"; nixpkgs = nixpkgs; system = system; });
          crossTarballOmnia = tarball (self.lib.nixturrisTarballSystem { board = "omnia"; nixpkgs = nixpkgs; system = system; });

        } // flake-utils.lib.filterPackages system (flake-utils.lib.flattenTree (
          import ./pkgs { nixpkgs = nixpkgs.legacyPackages."${system}"; }
        ));

        # The legacyPackages imported as overlay allows us to use pkgsCross to
        # cross-compile those packages.
        legacyPackages = import nixpkgs {
          inherit system;
          overlays = [ self.overlay ];
          crossOverlays = [ self.overlay ];
        };
      }
    );
}
