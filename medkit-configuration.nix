{ config, lib, pkgs, ... }: {
  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;
  boot.kernelParams = [
    "earlyprintk" "console=ttyMV0,115200" "earlycon=ar3700_uart,0xd0012000"
    "boot.shell_on_fail"
  ];
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.supportedFilesystems = [ "btrfs" "vfat" "ntfs" ];

  zramSwap = {
    enable = true;
    memoryPercent = 100;
  };
  swapDevices = [{
    device = "/dev/mmcblk1p2";
    priority = 0;
  }];

  fileSystems = {
    "/" = {
      device = "/dev/mmcblk1p1";
      fsType = "btrfs";
    };
  };

  networking.hostName = "nixturris";

  i18n.supportedLocales = ["en_US.UTF-8/UTF-8" "cs_CZ.UTF-8/UTF-8"];
  nix = {
    package = pkgs.nixFlakes;
    extraOptions = "experimental-features = nix-command flakes";
  };

  programs.vim.defaultEditor = true;

  #services.sentinel.enable = true;

  services.openssh = {
    enable = true;
    passwordAuthentication = true;
    permitRootLogin = "yes";
  };

  environment.systemPackages =  with pkgs; [
    nixos-option
    htop
  ];

  users = {
    mutableUsers = false;
    users.root.password = "nixturris";
  };

}
