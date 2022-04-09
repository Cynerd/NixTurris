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

      lib = {
        # The full NixOS system
        nixturrisSystem = {nixpkgs ? nixpkgs-stable, board, modules ? [], override ? {}}: let
          pkgs = if board == "omnia"
            then nixpkgs.legacyPackages.armv7l-linux
            else nixpkgs.legacyPackages.aarch64-linux;
        in nixpkgs.lib.nixosSystem ({
          system = pkgs.system;
          modules = [
            self.nixosModule
            { turris.board = board; }
          ] ++ modules;
        } // override);
        # The minimalized system to decrease amount of ram needed for rebuild
        # TODO this does not work right now as it requires just load of work to do
        nixturrisMinSystem = {nixpkgs ? nixpkgs-stable, modules, ...} @args: 
        self.lib.nixturrisSystem (args // {
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

          createTarball = board: (self.lib.nixturrisSystem {
              board = board;
              modules = [ (import ./tarball.nix board) ];
            }).config.system.build.tarball;

        in {

          tarball-mox = createTarball "mox";
          tarball-omnia = createTarball "omnia";

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
