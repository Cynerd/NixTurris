{ config, lib, pkgs, ... }:

with lib;

{

  config = mkIf (config.turris.board == "omnia") {
    # Use early print to the serial console
    boot.kernelParams = [
      "earlyprintk" "console=ttyS0,115200"
    ];
    # Force load of Turris Omnia leds
    boot.kernelModules = [
      "leds_turris_omnia"
    ];
    # Explicitly set device tree to ensure we load the correct one.
    hardware.deviceTree.name = "armada-385-turris-omnia.dtb";

    # The additional administration packages
    environment.systemPackages =  with pkgs; [
      libatsha204
    ];

  };
}
