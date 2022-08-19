{ config, lib, pkgs, ... }:

with lib;

{

  config = mkIf (config.turris.board == "omnia") {
    # Use early print to the serial console
    boot.kernelParams = [
      "earlyprintk" "console=ttyS0,115200"
    ];
    # Custom kernel config
    boot.kernelPatches = [{
      name = "omnia";
      patch = null;
      extraConfig = ''
        LEDS_CLASS_MULTICOLOR y
        LEDS_TURRIS_OMNIA y
        '';
    }];

    # The additional administration packages
    environment.systemPackages =  with pkgs; [
      libatsha204
    ];

  };
}
