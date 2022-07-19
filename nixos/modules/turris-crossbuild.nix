{ config, lib, pkgs, modulesPath, extendModules, ... }:

with lib;

let

  crossVariant = host: extendModules {
    modules = [{
      nixpkgs.system = host;
      nixpkgs.crossSystem = {
        inherit (config.nixpkgs.localSystem) system config;
      };
    }];
  };

in mkIf (config.nixpkgs.crossSystem == null) {

  system.build.cross = genAttrs lib.systems.flakeExposed (system:
    crossVariant system
  );

}
