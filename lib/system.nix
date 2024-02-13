self: prev: final: let
  inherit (self.nixpkgs.lib) filterAttrs elem;
in {
  boardPlatform = {
    omnia = {
      config = "armv7l-unknown-linux-gnueabihf";
      system = "armv7l-linux";
    };
    mox = {
      config = "aarch64-unknown-linux-gnu";
      system = "aarch64-linux";
    };
  };
  # Backward compatibility but boardPlatform is more exact name.
  boardSystem = prev.warn "boardSystem is deprecard. Please use boardPlatform instead." final.boardPlatform;

  # Adds buildPlatform attribute to the NixOS system attribute set.
  addBuildPlatform = nixos:
    nixos
    // {
      buildPlatform = prev.genAttrs prev.systems.flakeExposed (
        system: let
          nixos' = nixos.extendModules {
            modules = [
              {
                nixpkgs.buildPlatform.system = system;
              }
            ];
          };
          nixos'' = nixos' // {inherit (nixos'._module.args) pkgs;};
        in
          if system == nixos.config.nixpkgs.hostPlatform.system
          then nixos
          else nixos''
      );
    };

  # NixOS system for specific Turris board
  nixturrisSystem = {
    board ? "mox",
    nixpkgs ? self.inputs.nixpkgs,
    modules ? [],
    specialArgs ? {},
    ...
  } @ args: let
    nixosArgs = prev.filterAttrs (n: v: ! (prev.elem n ["board" "nixpkgs"])) args;
    nixosLib = final;
    nixosModules =
      modules
      ++ [
        self.nixosModules.default
        {turris.board = nixpkgs.lib.mkDefault board;}
      ];
    nixos = nixpkgs.lib.nixosSystem (nixosArgs
      // {
        modules = nixosModules;
        specialArgs = specialArgs // {lib = nixpkgs.lib.extend self.overlays.lib;};
      });
  in
    final.addBuildPlatform nixos;

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
    final.addBuildPlatform (nixpkgs.lib.nixos.evalModules ({
        modules =
          (map (v: nixpkgs.outPath + "/nixos/modules" + v) (import ./nixos-min-modules.nix))
          ++ [
            self.nixosModules.default
            {turris.board = board;}
          ]
          ++ modules;
      }
      // (filterAttrs (n: v: ! (elem n ["board" "nixpkgs" "modules"])) args)));
}
