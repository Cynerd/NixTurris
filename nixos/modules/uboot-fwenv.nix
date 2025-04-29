{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.programs.uboot-fwenv;
in {
  options.programs.uboot-fwenv = {
    enable = mkEnableOption (mdDoc ''
      U-Boot environment access configuration.

      Use this to setup access to the U-Boot's environment variables with
      generic ubootEnvTools package.
    '');
    package = mkOption {
      type = types.package;
      default = pkgs.ubootEnvTools;
      defaultText = literalExpression "pkgs.ubootEnvTools";
      description = mdDoc ''
        Package providing U-Boot's environment tools (`fw_printenv` and
        `fw_setenv`) that is added to `environment.systemPackages`.
      '';
    };
    device = mkOption {
      type = types.str;
      description = mdDoc "Device with U-Boot environment";
    };
    offset = mkOption {
      type = types.strMatching "0x[a-fA-F0-9]+";
      default = "0x0";
      description = mdDoc "Offset in the device to the environment";
    };
    size = mkOption {
      type = types.strMatching "0x[a-fA-F0-9]+";
      description = mdDoc "Environemnt size";
    };
    secsize = mkOption {
      type = with types; nullOr (strMatching "0x[a-fA-F0-9]+");
      default = null;
      description = mdDoc "Flash sector size.";
    };
    numsec = mkOption {
      type = with types; nullOr (strMatching "0x[a-fA-F0-9]+");
      default = null;
      description = mdDoc "Number of sectors";
    };
  };

  config = mkIf cfg.enable {
    environment.etc."fw_env.config".text =
      "${cfg.device} ${cfg.offset} ${cfg.size}"
      + optionalString (cfg.secsize != null) (
        " ${cfg.secsize}" + (optionalString (cfg.numsec != null) " ${cfg.numsec}")
      );

    environment.systemPackages = [cfg.package];
  };

  meta.maintainers = [maintainers.cynerd];
}
