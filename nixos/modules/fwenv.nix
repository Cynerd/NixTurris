{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cnf = config.firmware.environment;
in {
  # TODO we could also allow just building environment tools as part of uboot
  # for specific board and use that here instead of configuration. The advantage
  # would be that configuration would be provided by build and not by nixos.
  options = {
    firmware.environment = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "If U-Boot environment access should be configured";
      };
      device = mkOption {
        type = types.str;
        description = "Device with U-Boot environment";
      };
      offset = mkOption {
        type = types.ints.unsigned;
        default = 0;
        description = "Offset in device to the environment";
      };
      size = mkOption {
        type = types.ints.positive;
        description = "Environemnt size";
      };
      secsize = mkOption {
        type = with types; nullOr ints.positive;
        default = null;
        description = "Flash sector size.";
      };
      numsec = mkOption {
        type = with types; nullOr ints.positive;
        default = null;
        description = "Number of sectors";
      };
    };
  };

  config = mkIf cnf.enable {
    environment.etc."fw_env.config".text = ''
      ${cnf.device} 0x${toHexString cnf.offset} 0x${toHexString cnf.size}${
        optionalString (cnf.secsize != null) " 0x${toHexString cnf.secsize}${
          optionalString (cnf.numsec != null) " ${cnf.numsec}"
        }"
      }
    '';
    environment.systemPackages = with pkgs; [
      ubootEnvTools
    ];
  };
}
