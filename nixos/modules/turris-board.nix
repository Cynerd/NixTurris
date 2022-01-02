{ config, lib, pkgs, ... }:

with lib;

{

  options = {
    turris.board = mkOption {
      type = types.enum [ "omnia" "mox" ];
      description = "The unique Turris board identifier.";
    };

    turris.device = mkOption {
      type = types.str;
      example = "/dev/mmcblk0";
      description = "The device used to boot the Turris system.";
    };
  };

  config = {
    assertions = [{
      assertion = config.turris.board != null;
      message = "Turris board has to be specified";
    }];

    # We do not need Grub as U-Boot supports boot using extlinux like file
    boot.loader.grub.enable = false;
    boot.loader.generic-extlinux-compatible.enable = true;
    # Use early print to the serial console
    boot.kernelParams = [
      "earlyprintk" "console=ttyMV0,115200" "earlycon=ar3700_uart,0xd0012000"
      "boot.shell_on_fail"
    ];

    # Use the latest kernel
    boot.kernelPackages = pkgs.linuxPackages_latest;

    # The supported deployment is on BTRFS
    boot.supportedFilesystems = [ "btrfs" ];

    # Cover nix memory consumption peaks by compressing the RAM
    zramSwap = {
      enable = true;
      memoryPercent = 100;
    };
    # Nix is really memory hungry so we have to sometimes also use swap device.
    # We expect that to be the second partition on the root device.
    swapDevices = [{
      device = config.turris.device + "p2";
      priority = 0;
    }];

    fileSystems = {
      # Root filesystem is expected to be on:
      # Mox: SD card
      # Omnia: internam MMC storage
      "/" = {
        device = config.turris.device + "p1";
        fsType = "btrfs";
      };
    };

    # The default hostname
    # TODO set this only if not already set
    networking.hostName = "nixturris";

    # Enable flakes for nix as we are using that instead of legacy setup
    nix = {
      package = pkgs.nixFlakes;
      extraOptions = "experimental-features = nix-command flakes";
    };

    # Allow root access over SSH
    # TODO allow disable as it is nice only for initial setup
    services.openssh = {
      enable = true;
      passwordAuthentication = true;
      permitRootLogin = "yes";
    };

    # Set default editor
    # TODO probably switch to nano later on
    programs.vim.defaultEditor = true;

    # The additional administration packages
    environment.systemPackages =  with pkgs; [
      (pkgs.nixos-rebuild.override { nix = config.nix.package.out; })
      git # This is required to access the repository
      htop
    ];

    # No need for installer tools in standard system
    system.disableInstallerTools = true;
  };
}
