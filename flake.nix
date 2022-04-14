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

    } // flake-utils.lib.eachSystem (flake-utils.lib.defaultSystems ++ ["armv7l-linux"]) (
      system: {
        packages = let

          createTarball = {...} @args: (self.lib.nixturrisSystem ({
              modules = [ (import ./tarball.nix args.board) ];
            } // args)).config.system.build.tarball;

        in {

          tarballMox = createTarball { board = "mox"; };
          tarballOmnia = createTarball { board = "omnia"; };
          crossTarballMox = createTarball { board = "mox"; system = system; };
          crossTarballOmnia = createTarball { board = "omnia"; system = system; };

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
