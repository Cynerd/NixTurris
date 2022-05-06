self: let

  modules = {

    turris-board = import ./modules/turris-board.nix;
    turris-defaults = import ./modules/turris-defaults.nix;

    hostapd = import ./modules/hostapd.nix;

  };

in modules // {
  default = {
    imports = builtins.attrValues modules;
    nixpkgs.overlays = [ self.overlays.default ];
  };
}
