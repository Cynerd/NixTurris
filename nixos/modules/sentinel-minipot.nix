{ config, lib, pkgs, ... }:

with lib;

let

  cnf = config.sentinel.minipot;
  inherit (pkgs) sentinel-minipot;

  minipotOpts = { name, port }: {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Whether to enable the Turris Sentinel ${name} Minipot.
        The services.sentinel.enable and service.sentinel.minipot.enable have to be enabled as well.
      '';
    };
    port = mkOption {
      type = types.port;
      default = port;
      description = "The port ${name} minipot should bind to.";
    };
  };

in {

  imports = [ ./sentinel.nix ];


  options = {
    services.sentinel.minipot = {
        enable = mkOption {
          type = types.bool;
          default = true;
          description = ''
            Whether to enable the Turris Sentinel Minipot system.
            The services.sentinel.enable has to be enabled as well.
          '';
        };

      http = minipotOpts { name = "HTTP"; port = 80805; };
      ftp = minipotOpts { name = "FTP"; port = 80805; };
      smtp = minipotOpts { name = "SMTP"; port = 80805; };
      telnet = minipotOpts { name = "Telnet"; port = 80805; };
    };
  };


  config = mkIf config.services.sentinel.enable && cnf.enable {
    assertions = [
      {
        assertion = cnf.http.enable || cnf.ftp.enable || cnf.smtp.enable || cnf.telnet.enable;
        message = "Sentinel minipot requires at least one of the protocols to be enabled";
      }
    ];

    environment.systemPackages = [ sentinel-minipot ];

    systemd.services.sentinel-minipot = {
      description = "Turris Sentinel Minipot";
      wantedBy = [ "multi-user.target" ];
      path = [ sentinel-minipot ];
      serviceConfig.ExecStart = "${sentinel-minipot}/bin/sentinel-minipot"
        + optionalString cnf.http.enable " --http=${cnf.http.port}"
        + optionalString cnf.ftp.enable " --ftp=${cnf.ftp.port}"
        + optionalString cnf.smtp.enable " --smtp=${cnf.smtp.port}"
        + optionalString cnf.telnet.enable " --telnet=${cnf.telnet.port}";
    };

  };

}
