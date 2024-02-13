{
  config,
  lib,
  pkgs,
  modulesPath,
  extendModules,
  ...
}:
with lib; let
  variant = extendModules {
    modules = [
      {
        boot.postBootCommands = ''
          # On the first boot do some maintenance tasks
          if [ -f /nix-path-registration ]; then
            set -euo pipefail

            # Register the contents of the initial Nix store
            ${config.nix.package.out}/bin/nix-store --load-db < /nix-path-registration

            # nixos-rebuild also requires a "system" profile and an /etc/NIXOS tag.
            touch /etc/NIXOS
            ${config.nix.package.out}/bin/nix-env -p /nix/var/nix/profiles/system --set /run/current-system

            # Prevents this from running on later boots.
            rm -f /nix-path-registration
          fi
        '';
        # We do not have generations in the initial image
        boot.loader.generic-extlinux-compatible.configurationLimit = 0;
      }
    ];
  };
  inherit (variant.config.system.build) toplevel;
in
  mkIf (config.turris.board != null) {
    system.build.tarball = pkgs.callPackage "${modulesPath}/../lib/make-system-tarball.nix" {
      extraCommands = pkgs.buildPackages.writeShellScript "tarball-extra-commands" ''
        ${variant.config.boot.loader.generic-extlinux-compatible.populateCmd} \
          -c ${toplevel} -d ./boot
      '';
      contents = [];

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
