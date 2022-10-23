{ config, lib, pkgs, ... }:

with lib;

{

  options = {
    turris.moxled = mkOption {
      type = types.bool;
      default = true;
      description = "Turris Mox CPU modul LED. Set to false to disable it.";
    };
  };

  config = mkIf (config.turris.board == "mox") {

    systemd.services."mox-redled" = {
      script = if config.turris.moxled then
          "echo heartbeat > /sys/class/leds/mox:red:activity/trigger"
        else
          "echo 0 > /sys/class/leds/mox:red:activity/brightness"
          "";
      wantedBy = [ "multi-user.target" ];
    };

  };
}
