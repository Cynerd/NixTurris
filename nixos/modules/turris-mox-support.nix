{ config, lib, pkgs, ... }:

with lib;

{

  config = mkIf (config.turris.board == "mox") {
    # Use early print to the serial console
    boot.kernelParams = [
      "earlycon=ar3700_uart,0xd0012000" "console=ttyMV0,115200"
      "pcie_aspm=off" # Fix for crashes due to SError Interrupt on ath10k load
    ];
    # Custom kernel config
    boot.kernelPatches = [{
      name = "rwtm";
      patch = null;
      extraConfig = ''
        TURRIS_MOX_RWTM y
        ARMADA_37XX_RWTM_MBOX y
        '';
    }];

    # The additional administration packages
    environment.systemPackages =  with pkgs; [
      #mox-otp
    ];

  };
}
