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

    # Enable flakes for nix as we are using that instead of legacy setup
    nix = {
      package = pkgs.nixFlakes;
      extraOptions = "experimental-features = nix-command flakes";
    };

    environment.systemPackages =  with pkgs; [
      # As we override the nix package we have to override nixos-rebuild as well
      (pkgs.nixos-rebuild.override { nix = config.nix.package.out; })
      # The Git is required to access this repository
      git
    ];
  };
}
