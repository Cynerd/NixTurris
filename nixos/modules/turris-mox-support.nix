{ config, lib, pkgs, ... }:

with lib;

{

  config = mkIf (config.turris.board == "mox") {
    # Use early print to the serial console
    boot.kernelParams = [
      "earlycon=ar3700_uart,0xd0012000" "console=ttyMV0,115200"
      "pcie_aspm=off" # Fix for crashes due to SError Interrupt on ath10k load
    ];

    # The additional administration packages
    environment.systemPackages =  with pkgs; [
      #mox-otp
    ];

  };
}
