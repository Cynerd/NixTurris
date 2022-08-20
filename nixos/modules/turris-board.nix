{ config, lib, pkgs, ... }:

with lib;

{

  options = {
    turris.board = mkOption {
      type = types.enum [ "omnia" "mox" ];
      description = "The unique Turris board identifier.";
    };
  };

  config = {
    assertions = [{
      assertion = config.turris.board != null;
      message = "Turris board has to be specified";
    }];

    environment.systemPackages =  with pkgs; [
      # As we override the nix package we have to override nixos-rebuild as well
      (pkgs.nixos-rebuild.override { nix = config.nix.package.out; })
      # The Git is required to access this repository
      git
    ];
  };
}
