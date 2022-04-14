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
      swapLabel = mkOption {
        type = types.str;
        default = "NixTurrisSwap";
        description = "GPT partition label for available swap parition";
      };
    };
  };

  config = mkIf cnf.enable {
    # We do not need Grub as U-Boot supports boot using extlinux like file
    boot.loader.grub.enable = false;
    boot.loader.generic-extlinux-compatible.enable = true;
    # Use early print to the serial console
    boot.kernelParams = [
      "boot.shell_on_fail"
    ] ++ optionals (config.turris.board == "mox") [
      "earlycon=ar3700_uart,0xd0012000" "console=ttyMV0,115200"
      "pcie_aspm=off" # Fix for crashes due to SError Interrupt on ath10k load
    ] ++ optional (config.turris.board == "omnia") [
      "earlyprintk" "console=ttyS0,115200"
    ];

    # Use the latest kernel
    boot.kernelPackages = pkgs.linuxPackages_latest;

    # The supported deployment is on BTRFS
    boot.supportedFilesystems = [ "btrfs" ];

    # Cover nix memory consumption peaks by compressing the RAM
    zramSwap = {
      enable = true;
      memoryPercent = 80;
    };
    # Nix is really memory hungry so we have to sometimes also use swap device.
    swapDevices = [{
      device = "/dev/disk/by-partlabel/" + cnf.swapLabel;
      priority = 0;
    }];

    fileSystems = {
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
      htop
    ] ++ optionals (config.turris.board == "mox") [
      libatsha204
    ] ++ optionals (config.turris.board == "omnia") [
      libatsha204
    ];

    # No need for installer tools in standard system
    system.disableInstallerTools = true;
  };
}
