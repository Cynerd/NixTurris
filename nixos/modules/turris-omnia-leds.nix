{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.turris.omnialeds;

  ledConfig = {
    name,
    trigger ? "none",
    netdevName ? null,
    color,
    brightness ? 255,
  }: {
    enabled = mkOption {
      type = types.bool;
      default = true;
      description = "If LED should be enabled at all";
    };
    brightness = mkOption {
      type = types.ints.u8;
      default = brightness;
      description = "Set brightness intensity";
    };
    color = let
      clr = c:
        mkOption {
          type = types.ints.u8;
          default = color.${c};
          description = "Set intensity for the color ${c}";
        };
    in {
      red = clr "red";
      green = clr "green";
      blue = clr "blue";
    };
    trigger = mkOption {
      type = types.str;
      default = trigger;
      description = "Trigger for the LED";
    };
    # netdev trigger
    netdevName = mkOption {
      type = with types; nullOr str;
      default = netdevName;
      description = ''
        Name of the network device to trigger when trigger is set to `netdev`
      '';
    };
  };
  lanConfig = i:
    ledConfig {
      name = "lan${toString i}";
      trigger = "netdev";
      netdevName = "lan${toString i}";
      color = {
        red = 0;
        green = 0;
        blue = 255;
      };
    };
  wlanConfig = i:
    ledConfig {
      name = "wlan${toString i}";
      trigger = "netdev";
      netdevName = "wlp${toString i}s0";
      color = {
        red = 255;
        green = 255;
        blue = 0;
      };
    };
  indicatorConfig = i:
    ledConfig {
      name = "indicator${toString i}";
      color = {
        red = 255;
        green = 255;
        blue = 255;
      };
      brightness = 0;
    };

  ledSetup = sysname: lcfg: ''
    echo ${toString lcfg.brightness} > /sys/class/leds/rgb:${sysname}/brightness
    echo ${toString lcfg.color.red} ${toString lcfg.color.green} ${toString lcfg.color.blue} > /sys/class/leds/rgb:${sysname}/multi_intensity
    echo ${lcfg.trigger} > /sys/class/leds/rgb:${sysname}/trigger
    ${optionalString (lcfg.trigger == "netdev") ''
      echo '${lcfg.netdevName}' > /sys/class/leds/rgb:${sysname}/device_name
      echo 1 > /sys/class/leds/rgb:${sysname}/link
      echo 1 > /sys/class/leds/rgb:${sysname}/rx
      echo 1 > /sys/class/leds/rgb:${sysname}/tx
    ''}
  '';
in {
  options = {
    turris.omnialeds = {
      enabled = mkOption {
        type = types.bool;
        default = true;
        description = "If Omnia LEDs setup should be enabled or not.";
      };
      brightness = mkOption {
        type = with types; nullOr (ints.between 0 100);
        default = null;
        description = "Global brightness (overrides brightness set by the front button)";
      };
      power = ledConfig {
        name = "power";
        trigger = "heartbeat";
        color = {
          red = 0;
          green = 255;
          blue = 0;
        };
      };
      wan = ledConfig {
        name = "wan";
        trigger = "netdev";
        netdevName = "eth2";
        color = {
          red = 0;
          green = 255;
          blue = 0;
        };
      };
      lan0 = lanConfig 0;
      lan1 = lanConfig 1;
      lan2 = lanConfig 2;
      lan3 = lanConfig 3;
      lan4 = lanConfig 4;
      wlan1 = wlanConfig 1;
      wlan2 = wlanConfig 2;
      wlan3 = wlanConfig 3;
      indicator1 = indicatorConfig 1;
      indicator2 = indicatorConfig 2;
      extraCommands = mkOption {
        type = types.lines;
        default = "";
        description = "Extra commands executed to setup LEDs";
      };
    };
  };

  config = mkIf (config.turris.board == "omnia" && cfg.enabled) {
    # TODO modprobe triggers only if required
    boot.kernelModules = [
      "ledtrig_tty"
      "ledtrig_activity"
      "ledtrig_pattern"
      "ledtrig_netdev"
      "ledtrig_usbport"
    ];

    systemd.services."omnia-leds" = {
      script = ''
        ${optionalString (cfg.brightness != null)
          "echo ${toString cfg.brightness} > /sys/devices/platform/soc/soc:internal-regs/f1011000.i2c/i2c-0/i2c-1/1-002b/brightness"}
        ${ledSetup "power" cfg.power}
        ${ledSetup "wan" cfg.wan}
        ${ledSetup "lan-0" cfg.lan0}
        ${ledSetup "lan-1" cfg.lan1}
        ${ledSetup "lan-2" cfg.lan2}
        ${ledSetup "lan-3" cfg.lan3}
        ${ledSetup "lan-4" cfg.lan4}
        ${ledSetup "wlan-1" cfg.wlan1}
        ${ledSetup "wlan-2" cfg.wlan2}
        ${ledSetup "wlan-3" cfg.wlan3}
        ${ledSetup "indicator-1" cfg.indicator1}
        ${ledSetup "indicator-2" cfg.indicator2}

        # Extra commands
        ${cfg.extraCommands}
      '';
      wantedBy = ["multi-user.target"];
    };
  };
}
