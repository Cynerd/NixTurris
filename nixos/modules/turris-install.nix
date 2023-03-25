{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cnf = config.turris.install-settings;
in {
  options.turris.install-settings = mkEnableOption "Install configuration for NixTurris.";

  config = mkIf cnf {
    boot.consoleLogLevel = lib.mkDefault 7;

    # Allow access to the root account right after installation
    users = {
      mutableUsers = false;
      users.root.password = mkDefault "nixturris";
    };

    # Allow root access over SSH
    services.openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = true;
        PermitRootLogin = "yes";
      };
    };

    boot.postBootCommands = ''
      ${pkgs.bash}/bin/bash ${./turris-initial-config.sh} \
        '${config.turris.board}'
    '';
  };
}
