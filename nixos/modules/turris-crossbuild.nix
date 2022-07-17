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

  # TODO for each common platform
  system.build.cross.x86_64-linux = crossVariant "x86_64-linux";

}
