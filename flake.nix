{
  description = "Turris flake";

  inputs.nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-21.11";

  outputs = { self, flake-utils, nixpkgs-stable }: {

      overlays.default = final: prev: import ./pkgs { nixpkgs = prev; };
      overlay = self.overlays.default; # Backward compatibility

      nixosModules = import ./nixos;
      nixosModule = {
        imports = builtins.attrValues self.nixosModules;
        nixpkgs.overlays = [ self.overlay ];
      };

      lib = import ./lib { self = self; nixpkgs-stable = nixpkgs-stable; };

      nixosConfigurations = {
        tarballMox = self.lib.nixturrisTarballSystem { board = "mox"; };
        tarballOmnia = self.lib.nixturrisTarballSystem { board = "omnia"; };
      };

    } // flake-utils.lib.eachSystem (flake-utils.lib.defaultSystems ++ ["armv7l-linux"]) (
      system: {
        packages = {
          tarballMox = self.nixosConfigurations.tarballMox.config.system.build.tarball;
          tarballOmnia = self.nixosConfigurations.tarballOmnia.config.system.build.tarball;
          crossTarballMox = (self.lib.nixturrisTarballSystem { board = "mox"; system = system; }).config.system.build.tarball;
          crossTarballOmnia = (self.lib.nixturrisTarballSystem { board = "omnia"; system = system; }).config.system.build.tarball;
        } // flake-utils.lib.filterPackages system (flake-utils.lib.flattenTree (
          import ./pkgs { nixpkgs = nixpkgs-stable.legacyPackages."${system}"; }
        ));

        # The legacyPackages imported as overlay allows us to use pkgsCross to
        # cross-compile those packages.
        legacyPackages = import nixpkgs-stable {
          inherit system;
          overlays = [ self.overlay ];
          crossOverlays = [ self.overlay ];
        };
      }
    );
}
