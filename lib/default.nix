{ self, nixpkgsDefault }: rec {

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
    nixpkgs ? nixpkgsDefault,
    modules ? [],
    override ? {}
  }: nixpkgs.lib.nixosSystem ({
    modules = [
      self.nixosModules.default
      {
        nixpkgs.system = boardSystem.${board}.system;
        turris.board = board;
      }
    ] ++ modules;
  } // override);

  # The minimalized system to decrease amount of ram needed for rebuild
  # TODO this does not work right now as it requires just load of work to do.
  # The nix-daemon pulls in xserver and the result is that pretty much
  # everything has to be included in such case.
  nixturrisMinSystem = {
    board,
    nixpkgs ? nixpkgsDefault,
    modules ? [],
    override ? {}
  }:nixpkgs.lib.nixos.evalModules ({
    modules = (map (v: nixpkgs.outPath + "/nixos/modules" + v) (import ./nixos-min-modules.nix)) ++ [
      self.nixosModules.default
      {
        nixpkgs.system = boardSystem.${board}.system;
        turris.board = board;
      }
    ] ++ modules;
  } // override);

}
