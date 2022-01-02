board: { config, lib, pkgs, modulesPath, ... }: {
  imports = [
    "${toString modulesPath}/installer/cd-dvd/system-tarball.nix"
  ];

  boot.consoleLogLevel = lib.mkDefault 7;
  turris.device = "/dev/mmcblk1"; # TODO this is for mox and sd card only

  # Allow access to the root account right after installation
  users = {
    mutableUsers = false;
    users.root.password = "nixturris";
  };

  # TODO we have to generate the hardware specific configuration on first boot
  tarball.contents = [
    { source = pkgs.writeText "default-nixturris-flake" ''
        {
          inputs.nixturris.url = "git+git://cynerd.cz/nixturris.git";
          outputs = { self, nixturris }: {
            nixosConfigurations.nixturris = nixturris.lib.nixturrisSystem {
              board = "${board}";
              modules = [({ config, lib, pkgs, ... }: {
                # Optionally place your configuration here
              })];
            };
          };
        }
      '';
      target = "/etc/nixos/flake.nix";
    }
    { source = pkgs.writeText "medkit-extlinux" ''
        DEFAULT nixos-default
        TIMEOUT 0
        LABEL nixos-default
          MENU LABEL NixOS - Default
          FDTDIR /run/current-system/dtbs
          LINUX /run/current-system/kernel
          INITRD /run/current-system/initrd
          APPEND init=${config.system.build.toplevel}/init ${builtins.toString config.boot.kernelParams}
      '';
      target = "/boot/extlinux/extlinux.conf";
    }
  ];
}
