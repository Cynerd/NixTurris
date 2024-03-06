self: let
  modules = {
    turris-board = ./modules/turris-board.nix;
    turris-defaults = ./modules/turris-defaults.nix;
    turris-install = ./modules/turris-install.nix;
    turris-mox-led = ./modules/turris-mox-led.nix;
    turris-mox-support = ./modules/turris-mox-support.nix;
    turris-omnia-leds = ./modules/turris-omnia-leds.nix;
    turris-omnia-support = ./modules/turris-omnia-support.nix;
    turris-tarball = ./modules/turris-tarball.nix;

    fwenv = ./modules/fwenv.nix;
  };
in
  modules
  // {
    default = {
      imports = builtins.attrValues modules;
      nixpkgs.overlays = [self.overlays.default];
    };
  }
