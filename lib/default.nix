{
  self,
  lib ? self.inputs.nixpkgs.lib,
} @ args:
import ./system.nix args
// {
  wifiAP = import ./wifiAP.nix args;
}
