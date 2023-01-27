{
  self,
  lib ? self.inputs.nixpkgs.lib,
} @ args:
import ./system.nix args
// {
  hostapd = import ./hostapd.nix args;
}
