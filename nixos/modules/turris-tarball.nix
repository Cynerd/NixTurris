{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:
with lib; let
  inherit (config.system.build) toplevel;
in {
  system.build.tarball = pkgs.callPackage "${modulesPath}/../lib/make-system-tarball.nix" {
    contents = [
      {
        source = pkgs.writeText "tarball-extlinux" ''
          DEFAULT nixturris-tarball
          TIMEOUT 0
          LABEL nixturris-tarball
            MENU LABEL NixOS Turris - Tarball
            LINUX ${toplevel}/kernel
            FDTDIR ${toplevel}/dtbs
            INITRD ${toplevel}/initrd
            APPEND init=${toplevel}/init ${builtins.toString config.boot.kernelParams}
        '';
        target = "./boot/extlinux/extlinux.conf";
      }
    ];

    storeContents =
      map (x: {
        object = x;
        symlink = "none";
      }) [
        toplevel
        pkgs.stdenv
      ];
  };
}
