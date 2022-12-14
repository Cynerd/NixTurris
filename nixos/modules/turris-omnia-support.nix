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
    # Use Omnia specific kernel. It is required as otherwise PCI won't work.
    boot.kernelPackages = mkDefault (pkgs.linuxPackagesFor pkgs.linux_6_1_turris_omnia);
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
    # This includes modules to support common PC manufacturers but is not
    # something required on Turris.
    boot.initrd.includeDefaultModules = false;
    # Use early print to the serial console
    boot.kernelParams = [
      "earlyprintk"
      "console=ttyS0,115200"
    ];
    # Force load of Turris Omnia leds
    boot.kernelModules = [
      "leds_turris_omnia"
    ];

    # The additional administration packages
    environment.systemPackages = with pkgs; [
      libatsha204
      tosFirmwareOmnia
    ];

    # U-Boot environment access
    firmware.environment = {
      enable = true;
      device = "/dev/mtd0";
      offset = 786432; # 0xC0000
      size = 65536; # 0x10000
      secsize = 262144; # 0x40000
    };
  };
}
