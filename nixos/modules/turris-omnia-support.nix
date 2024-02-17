{
  config,
  lib,
  pkgs,
  ...
}:
with lib; {
  options = {
    turris.omnia-sfp = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Use SFP instead of PHY on Turris Omnia.
        This works only with Turris Omnia specific Linux kernel.
      '';
    };
  };

  config = mkIf (config.turris.board == "omnia") {
    nixpkgs.hostPlatform = lib.boardPlatform.omnia;

    boot = {
      # Use Omnia specific kernel. It is required as otherwise PCI won't work.
      kernelPackages = mkDefault (pkgs.linuxPackagesFor pkgs.linux_turris_omnia);
      # This includes modules to support common PC manufacturers but is not
      # something required on Turris.
      initrd.includeDefaultModules = false;
      # Use early print to the serial console
      kernelParams = [
        "earlyprintk"
        "console=ttyS0,115200"
      ];
      # Force load of Turris Omnia leds
      kernelModules = ["leds_turris_omnia"];
      initrd.availableKernelModules = ["ahci_mvebu" "rtc_armada38x"];
    };
    # Explicitly set device tree to ensure we load the correct one.
    # This also allows switch between SFP and PHY.
    hardware.deviceTree.name = mkDefault "armada-385-turris-omnia${
      optionalString (
        attrByPath ["turrisOmniaSplitDTB"] false
        config.boot.kernelPackages.kernel.features
      ) (
        if config.turris.omnia-sfp
        then "-sfp"
        else "-phy"
      )
    }.dtb";

    # The additional administration packages
    environment.systemPackages = with pkgs; [
      libatsha204
    ];

    # U-Boot environment access
    firmware.environment = mkDefault {
      enable = true;
      device = "/dev/mtd2";
      size = 65536; # 0x10000
      secsize = 65536; # 0x10000
    };
  };
}
