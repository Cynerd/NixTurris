{ config, lib, pkgs, ... }:

with lib;

{

  config = mkIf (config.turris.board == "omnia") {
    # Use early print to the serial console
    boot.kernelParams = [
      "earlyprintk" "console=ttyS0,115200"
    ];

    # The additional administration packages
    environment.systemPackages =  with pkgs; [
      libatsha204
    ];

  };
}
