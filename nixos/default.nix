self: let
  modules = {
    turris-board = import ./modules/turris-board.nix;
    turris-crossbuild = import ./modules/turris-crossbuild.nix;
    turris-defaults = import ./modules/turris-defaults.nix;
    turris-mox-support = import ./modules/turris-mox-support.nix;
    turris-moxled = import ./modules/turris-moxled.nix;
    turris-omnia-support = import ./modules/turris-omnia-support.nix;
    turris-omnialeds = import ./modules/turris-omnialeds.nix;
    turris-tarball = import ./modules/turris-tarball.nix;

    armv7l-overlay = import ./modules/armv7l-overlay.nix;

    hostapd = import ./modules/hostapd.nix;
    fwenv = import ./modules/fwenv.nix;
  };
in
  modules
  // {
    default = {
      imports = builtins.attrValues modules;
      nixpkgs.overlays = [self.overlays.default];
    };
  }
