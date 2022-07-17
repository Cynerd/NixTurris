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
    system = boardSystem.${board}.system;
    modules = [
      self.nixosModules.default
      { turris.board = board; }
    ] ++ modules;
  } // override);

  # The minimalized system to decrease amount of ram needed for rebuild
  # TODO this does not work right now as it requires just load of work to do
  nixturrisMinSystem = {
    nixpkgs,
    modules ? [],
    ...
  } @args: self.lib.nixturrisSystem (args // {
    nixpkgs = nixpkgs;
    modules = modules ++ [ ../nixos/nixos-modules-minfake.nix ];
    override = {
      baseModules = import ../nixos/nixos-modules.nix nixpkgs;
    };
  });

}
