{
  config,
  lib,
  pkgs,
  ...
}:
with lib; {
  config = mkIf (config.turris.board == "mox") {
    boot = {
      # Use Turris Mox specific kernel. It fixes SError with patch.
      kernelPackages = mkDefault (pkgs.linuxPackagesFor pkgs.linux_turris_mox);
      # This includes modules to support common PC manufacturers but is not
      # something required on Turris.
      initrd.includeDefaultModules = false;
      # Use early print to the serial console
      kernelParams = [
        "earlycon=ar3700_uart,0xd0012000"
        "console=ttyMV0,115200"
        "pcie_aspm=off" # Fix for crashes due to SError Interrupt on ath10k load
      ];
      # Insert these modules early. The watchdog should be handled as soon as
      # possible and moxtet is for some reason ignored otherwise.
      initrd.kernelModules = [
        "armada_37xx_wdt"
        "moxtet"
        "gpio-moxtet"
        "turris-mox-rwtm"
      ];
    };
    # Explicitly set device tree to ensure we load the correct one.
    # This fixes boot with some U-Boot versions.
    hardware.deviceTree.name = mkDefault "marvell/armada-3720-turris-mox.dtb";

    # Systemd seems to not handling hardware watchdog for some reason
    systemd.services."nowatchdog" = {
      script = "echo V >/dev/watchdog0";
      wantedBy = ["multi-user.target"];
    };

    # The additional administration packages
    environment.systemPackages = with pkgs; [
      mox-otp
    ];

    # U-Boot environment access
    firmware.environment = mkDefault {
      enable = true;
      device = "/dev/mtd2";
      size = 65536; # 0x10000
    };
  };
}
