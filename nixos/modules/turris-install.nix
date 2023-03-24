{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cnf = config.turris.install-settings;
in {
  options.turris.install-settings = mkEnableOption "Install configuration for NixTurris.";

  config = mkIf cnf {
    boot.consoleLogLevel = lib.mkDefault 7;

    # Allow access to the root account right after installation
    users = {
      mutableUsers = false;
      users.root.password = mkDefault "nixturris";
    };

    # Allow root access over SSH
    services.openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = true;
        PermitRootLogin = "yes";
      };
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
  };
}
