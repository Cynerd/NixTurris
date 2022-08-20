{ config, lib, pkgs, ... }:

with lib;

let

  cnf = config.turris.defaults;

in {

  options = {
    turris.defaults = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Use default Turris configuration";
      };
      rootLabel = mkOption {
        type = types.str;
        default = "NixTurris";
        description = "GPT partition label the root system is stored on";
      };
    };
  };

  config = mkIf cnf.enable {
    system.stateVersion = mkDefault "22.11";

    # We do not need Grub as U-Boot supports boot using extlinux like file
    boot.loader.grub.enable = mkDefault false;
    boot.loader.systemd-boot.enable = mkDefault false;
    boot.loader.generic-extlinux-compatible.enable = mkDefault true;
    # Use early print to the serial console
    boot.kernelParams = [
      "boot.shell_on_fail"
    ];

    # Use the latest kernel
    boot.kernelPackages = mkDefault pkgs.linuxPackages_latest;

    # The supported deployment is on BTRFS
    boot.supportedFilesystems = [ "btrfs" ];
    boot.initrd.supportedFilesystems = [ "btrfs" ];

    # Cover nix memory consumption peaks by compressing the RAM
    zramSwap = mkDefault {
      enable = true;
      memoryPercent = 80;
    };

    fileSystems = mkDefault {
      "/" = {
        device = "/dev/disk/by-partlabel/" + cnf.rootLabel;
        fsType = "btrfs";
      };
    };

    # The default hostname
    networking.hostName = mkDefault "nixturris";

    # Set default editor
    # TODO probably switch to nano later on
    programs.vim.defaultEditor = mkDefault true;

    # The additional administration packages
    environment.systemPackages =  with pkgs; [
      htop iw
    ];

    # No need for installer tools in standard system
    system.disableInstallerTools = true;
  };
}
