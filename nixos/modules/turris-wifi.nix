{ config, lib, pkgs, ... }:

with lib;

let

  cnf = config.turris.wifi;

in {

  options = {
    turris.wifi = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable Turris WiFi configuration";
      };
    };
  };

  config = mkIf cnf.enable {
    # Needed for Ath10k firmware
    hardware.firmware = with pkgs; [ firmwareLinuxNonfree ];

    # The additional administration packages
    environment.systemPackages =  with pkgs; [
      iw
    ] ++ optionals (config.turris.board == "mox") [
    ] ++ optionals (config.turris.board == "omnia") [
    ];

  };
}
