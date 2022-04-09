board: { config, lib, pkgs, modulesPath, ... }:

with lib;

{
  imports = [
    "${toString modulesPath}/installer/cd-dvd/system-tarball.nix"
  ];

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
  tarball.contents = [
    { source = pkgs.writeText "default-nixturris-flake" ''
        {
          inputs.nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-21.11";
          inputs.nixturris.url = "git+https://git.cynerd.cz/nixturris";
          outputs = { self, nixpkgs-stable, nixturris }: {
            nixosConfigurations.nixturris = nixturris.lib.nixturrisSystem {
              nixpkgs = nixpkgs-stable;
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
          LINUX /run/current-system/kernel
          FDTDIR /run/current-system/dtbs
          INITRD /run/current-system/initrd
          APPEND init=${config.system.build.toplevel}/init ${builtins.toString config.boot.kernelParams}
      '';
      target = "/boot/extlinux/extlinux.conf";
    }
  ];
}
