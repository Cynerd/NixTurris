{
  config,
  lib,
  pkgs,
  ...
}:
with lib; {
  config = mkIf (config.turris.board == "mox") {
    # Use Turris Mox specific kernel. It fixes SError with patch.
    boot.kernelPackages = mkDefault (pkgs.linuxPackagesFor pkgs.linux_6_0_turris_mox);
    # Explicitly set device tree to ensure we load the correct one.
    # This fixes boot with some U-Boot versions.
    hardware.deviceTree.name = mkDefault "marvell/armada-3720-turris-mox.dtb";
    # This includes modules to support common PC manufacturers but is not
    # something required on Turris.
    boot.initrd.includeDefaultModules = false;
    # Use early print to the serial console
    boot.kernelParams = [
      "earlycon=ar3700_uart,0xd0012000"
      "console=ttyMV0,115200"
      "pcie_aspm=off" # Fix for crashes due to SError Interrupt on ath10k load
    ];
    # Insert these modules early. The watchdog should be handled as soon as
    # possible and moxtet is for some reason ignored otherwise.
    boot.initrd.kernelModules = [
      "armada_37xx_wdt"
      "moxtet"
      "gpio-moxtet"
      "turris-mox-rwtm"
    ];

    # Systemd seems to not handling hardware watchdog for some reason
    systemd.services."nowatchdog" = {
      script = "echo V >/dev/watchdog0";
      wantedBy = ["multi-user.target"];
    };

    # The additional administration packages
    environment.systemPackages = with pkgs; [
      mox-otp
      tosFirmwareMox
    ];

    # U-Boot environment access
    firmware.environment = {
      enable = true;
      device = "/dev/mtd2";
      size = 65536; # 0x10000
    };
  };
}
