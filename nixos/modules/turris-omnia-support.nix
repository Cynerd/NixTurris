{ config, lib, pkgs, ... }:

with lib;

{

  config = mkIf (config.turris.board == "omnia") {
    # Use early print to the serial console
    boot.kernelParams = [
      "earlyprintk" "console=ttyS0,115200"
    ];
    # Force load of Turris Omnia leds (not loadded automatically for some
    # reason).
    boot.kernelModules = [
      "leds_turris_omnia"
    ];

    # The additional administration packages
    environment.systemPackages =  with pkgs; [
      libatsha204
    ];

  };
}
