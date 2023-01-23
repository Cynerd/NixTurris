{
  self,
  lib ? self.inputs.nixpkgs.lib,
}:
with builtins;
with lib; let
  libOverlay = prev: final:
    import ./. {
      inherit self;
      lib = prev;
    };
in rec {
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
    nixpkgs ? self.inputs.nixpkgs,
    modules ? [],
    specialArgs ? {},
    ...
  } @ args:
    nixpkgs.lib.nixosSystem ((filterAttrs (n: v: ! (elem n ["board" "nixpkgs"])) args)
      // {
        modules =
          [
            self.nixosModules.default
            {
              nixpkgs.system = boardSystem.${board}.system;
              turris.board = board;
            }
          ]
          ++ modules;
        specialArgs =
          specialArgs
          // {
            lib = (attrByPath ["lib"] nixpkgs.lib specialArgs).extend libOverlay;
          };
      });

  # The minimalized system to decrease amount of ram needed for rebuild
  # TODO this does not work right now as it requires just load of work to do.
  # The nix-daemon pulls in xserver and the result is that pretty much
  # everything has to be included in such case.
  nixturrisMinSystem = {
    board,
    nixpkgs ? self.inputs.nixpkgs,
    modules ? [],
    ...
  } @ args:
    nixpkgs.lib.nixos.evalModules ({
        modules =
          (map (v: nixpkgs.outPath + "/nixos/modules" + v) (import ./nixos-min-modules.nix))
          ++ [
            self.nixosModules.default
            {
              nixpkgs.system = boardSystem.${board}.system;
              turris.board = board;
            }
          ]
          ++ modules;
      }
      // (filterAttrs (n: v: ! (elem n ["board" "nixpkgs" "modules"])) args));
}
