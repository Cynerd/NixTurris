{
  config,
  lib,
  pkgs,
  ...
}:
with lib; {
  config = mkIf (config.turris.board == "mox") {
    # Use early print to the serial console
    boot.kernelParams = [
      "earlycon=ar3700_uart,0xd0012000"
      "console=ttyMV0,115200"
    ];
    # Insert these modules early. The watchdog should be handled as soon as
    # possible and moxtet is for some reason ignored otherwise.
    boot.initrd.kernelModules = [
      "armada_37xx_wdt"
      "moxtet"
      "gpio-moxtet"
      "turris-mox-rwtm"
      "aspm" # Required to prevent SError kernel panic
    ];
    # Explicitly set device tree to ensure we load the correct one.
    # This fixes boot with some U-Boot versions.
    hardware.deviceTree.name = "marvell/armada-3720-turris-mox.dtb";

    # Systemd seems to not handling hardware watchdog for some reason
    systemd.services."nowatchdog" = {
      script = "echo V >/dev/watchdog0";
      wantedBy = ["multi-user.target"];
    };

    # The additional administration packages
    environment.systemPackages = with pkgs; [
      mox-otp
    ];
  };
}
