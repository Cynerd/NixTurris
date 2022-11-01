{
  config,
  lib,
  pkgs,
  modulesPath,
  extendModules,
  ...
}:
with lib; let
  tarballVariant = extendModules {
    modules = [
      {
        boot.consoleLogLevel = lib.mkDefault 7;

        # Allow access to the root account right after installation
        users = {
          mutableUsers = false;
          users.root.password = mkDefault "nixturris";
        };

        # Allow root access over SSH
        services.openssh = {
          enable = true;
          passwordAuthentication = true;
          permitRootLogin = "yes";
        };

        # TODO we have to generate the hardware specific configuration on first boot
        boot.postBootCommands = ''
        '';

        environment.etc."nixos/flake.nix" = {
          mode = "0600";
          text = ''
            {
              inputs.nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-21.11";
              inputs.nixturris.url = "git+https://git.cynerd.cz/nixturris";
              outputs = { self, nixpkgs-stable, nixturris }: {
                nixosConfigurations.nixturris = nixturris.lib.nixturrisSystem {
                  nixpkgs = nixpkgs-stable;
                  board = "${config.turris.board}";
                  modules = [({ config, lib, pkgs, ... }: {
                    # Optionally place your configuration here
                  })];
                };
              };
            }
          '';
        };
      }
    ];
  };
  tarballBuild = tarballVariant.config.system.build.toplevel;
in {
  system.build.tarball = pkgs.callPackage "${modulesPath}/../lib/make-system-tarball.nix" {
    contents = [
      {
        source = pkgs.writeText "tarball-extlinux" ''
          DEFAULT nixturris-tarball
          TIMEOUT 0
          LABEL nixturris-tarball
            MENU LABEL NixOS Turris - Tarball
            LINUX ${tarballBuild}/kernel
            FDTDIR ${tarballBuild}/dtbs
            INITRD ${tarballBuild}/initrd
            APPEND init=${tarballBuild}/init ${builtins.toString tarballVariant.config.boot.kernelParams}
        '';
        target = "./boot/extlinux/extlinux.conf";
      }
    ];

    storeContents =
      map (x: {
        object = x;
        symlink = "none";
      }) [
        tarballBuild
        pkgs.stdenv
      ];
  };
}
