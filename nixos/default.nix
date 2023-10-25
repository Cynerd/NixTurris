self: let
  modules = {
    turris-board = import ./modules/turris-board.nix;
    turris-defaults = import ./modules/turris-defaults.nix;
    turris-install = import ./modules/turris-install.nix;
    turris-mox-led = import ./modules/turris-mox-led.nix;
    turris-mox-support = import ./modules/turris-mox-support.nix;
    turris-omnia-leds = import ./modules/turris-omnia-leds.nix;
    turris-omnia-support = import ./modules/turris-omnia-support.nix;
    turris-tarball = import ./modules/turris-tarball.nix;

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
