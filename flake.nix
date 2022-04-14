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

      lib = rec {
        # Mapping of board name to the appropriate system
        boardSystem = {
          omnia = {
            config = "armv7l-unknown-linux-gnueabihf";
            system = "armv7l-linux";
          };
          mox = {
            config = "aarch64-unknown-linux-gnu";
            system = "aarch64-linux";
          };
        };

        # NixOS system for specific Turris board
        nixturrisSystem = {
          board,
          system ? boardSystem.${board}.system,
          nixpkgs ? nixpkgs-stable,
          modules ? [],
          override ? {}
        }: nixpkgs.lib.nixosSystem ({
          system = system;
          modules = [
            self.nixosModule
            ({
              turris.board = board;
            } // nixpkgs.lib.optionalAttrs (system != boardSystem.${board}.system) {
              nixpkgs.crossSystem = boardSystem.${board};
            })
          ] ++ modules;
        } // override);

        # The minimalized system to decrease amount of ram needed for rebuild
        # TODO this does not work right now as it requires just load of work to do
        nixturrisMinSystem = {
          nixpkgs ? nixpkgs-stable,
          modules,
          ...
        } @args: self.lib.nixturrisSystem (args // {
          nixpkgs = nixpkgs;
          modules = modules ++ [ ./nixos/nixos-modules-minfake.nix ];
          override = {
            baseModules = import ./nixos/nixos-modules.nix nixpkgs;
          };
        });
      };

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
