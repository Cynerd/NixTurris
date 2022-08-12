self: let

  modules = {

    turris-board = import ./modules/turris-board.nix;
    turris-crossbuild = import ./modules/turris-crossbuild.nix;
    turris-defaults = import ./modules/turris-defaults.nix;
    turris-moxled = import ./modules/turris-moxled.nix;
    turris-tarball = import ./modules/turris-tarball.nix;

    armv7l-overlay = import ./modules/armv7l-overlay.nix;

    hostapd = import ./modules/hostapd.nix;

  };

in modules // {
  default = {
    imports = builtins.attrValues modules;
    nixpkgs.overlays = [ self.overlays.default ];
  };
}
