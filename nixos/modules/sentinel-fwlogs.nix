{ config, lib, pkgs, ... }:

with lib;

{

  imports = [ ./sentinel.nix ];


  options = {

    services.sentinel.fwlogs = {
        enable = mkOption {
          type = types.bool;
          default = true;
          description = ''
            Whether to enable the Turris Sentinel Firewall logs collector.
            The services.sentinel.enable has to be enabled as well.
          '';
        };
      };
  };


  config = mkIf config.services.sentinel.enable && config.services.sentinel.fwlogs.enable {
    environment.systemPackages = [ pkgs.sentinel-fwlogs ];

    systemd.services.sentinel-fwlogs = {
      description = "Turris Sentinel Firewall Logs";
      wantedBy = [ "multi-user.target" ];
      path = [ pkgs.sentinel-fwlogs ];
      serviceConfig.ExecStart = "${pkgs.sentinel-fwlogs}/bin/sentinel-fwlogs";
    };

  };

}
