{ config, lib, pkgs, ... }:

with lib;

{
  config = {
    # Kernel patches from Turris OS
    boot.kernelPatches = [{
      name = "ARM-dts-turris-omnia-enable-LED-controller-node";
      patch = ./kernel-patches/0001-ARM-dts-turris-omnia-enable-LED-controller-node.patch;
    }{
      name = "leds-turris-omnia-support-HW-controlled-mode-via-pri";
      patch = ./kernel-patches/0002-leds-turris-omnia-support-HW-controlled-mode-via-pri.patch;
    }{
      name = "leds-turris-omnia-initialize-multi-intensity-to-full";
      patch = ./kernel-patches/0003-leds-turris-omnia-initialize-multi-intensity-to-full.patch;
    }{
      name = "leds-turris-omnia-change-max-brightness-from-255-to-";
      patch = ./kernel-patches/0004-leds-turris-omnia-change-max-brightness-from-255-to-.patch;
    }{
      name = "generic-Mangle-bootloader-s-kernel-arguments";
      patch = ./kernel-patches/0005-generic-Mangle-bootloader-s-kernel-arguments.patch;
    }{
      name = "cpuidle-mvebu-indicate-failure-to-enter-deeper-sleep";
      patch = ./kernel-patches/0006-cpuidle-mvebu-indicate-failure-to-enter-deeper-sleep.patch;
    }{
      name = "pci-mvebu-time-out-reset-on-link-up";
      patch = ./kernel-patches/0007-pci-mvebu-time-out-reset-on-link-up.patch;
    }{
      name = "ARM-dts-mvebu-armada-385-turris-omnia-separate-dts-f";
      patch = ./kernel-patches/0008-ARM-dts-mvebu-armada-385-turris-omnia-separate-dts-f.patch;
    }{
      name = "phy-marvell-phy-mvebu-a3700-comphy-Change-2500base-x";
      patch = ./kernel-patches/0009-phy-marvell-phy-mvebu-a3700-comphy-Change-2500base-x.patch;
    }{
      name = "Rename-device-tree-for-Omnia-back-as-that-is-what-is";
      patch = ./kernel-patches/0010-Rename-device-tree-for-Omnia-back-as-that-is-what-is.patch;
    }];
  };
}
