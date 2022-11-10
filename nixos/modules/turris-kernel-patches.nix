{
  config,
  lib,
  pkgs,
  ...
}:
with lib; {
  boot.kernelPatches = [
    {
      name = "PCI-aadvark";
      patch = ./PCI-aardvark-controller-changes-BATCH-6.patch;
    }
  ];
}
