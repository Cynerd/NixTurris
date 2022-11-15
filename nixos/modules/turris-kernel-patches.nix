{
  config,
  lib,
  pkgs,
  ...
}:
with lib; {
  boot.kernelPatches = [
    {
      name = "PCI: aardvark: Implement workaround for PCIe Completion Timeout";
      patch = ./v2-PCI-aardvark-Implement-workaround-for-PCIe-Completion-Timeout.patch;
    }
    {
      name = "PCI-aadvark";
      patch = ./PCI-aardvark-controller-changes-BATCH-6.patch;
    }
  ];
}
