{ config, lib, pkgs, ... }:

with lib;

{

  options = {

    services.sentinel = {

      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to enable the Turris Sentinel attact prevention system.
        '';
      };
      deviceToken = mkOption {
        type = types.str;
        description = ''
          Turris Sentinel token. You can use `sentinel-device-token -c` to get new one.
        '';
      };

      faillogs = {
        enable = mkOption {
          type = types.bool;
          default = true;
          description = ''
            Whether to enable the Turris Sentinel fail logs collector.
            The services.sentinel.enable has to be enabled as well.
          '';
        };
      };
    };

  };


  config = mkIf config.services.sentinel.enable {
    environment.systemPackages = [ pkgs.sentinel-proxy ];
    #environment.etc.cups.source = "/var/lib/cups";

    #systemd.services.sentinel-proxy = {
    #  description = "Turris Sentinel proxy";
    #  wantedBy = [ "multi-user.target" ];
    #  path = [ sentinel-proxy ];
    #  serviceConfig.ExecStart = "${sentinel-proxy}/bin/sentinel-proxy -f ";
    #};

  };

}
