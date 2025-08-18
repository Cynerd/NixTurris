lib: {
  # Turris Omnia specific patches ##############################################
  mvebu_pci_omnia_fix = {
    # This is special hack for Turris Omnia as PCI doesn't work with
    # PCIEASPM configuration symbol.
    name = "mvebu-pci-fix";
    patch = null;
    structuredExtraConfig = with lib.kernel; {PCIEASPM = no;};
  };

  omnia_separate_dtb = {
    # The long term patch that provides two separate device trees for Turris
    # Omnia. The armada-385-turris-omnia-phy.dtb uses metallic Ethernet and
    # armada-385-turris-omnia-spf uses SFP cage.
    name = "omnia-separate-dtb";
    patch = ./linux-omnia-separate-dts.patch;
  };

  omnia_separate_dtb_6_1 = {
    name = "omnia-separate-dtb";
    patch = ./linux-6.1-omnia-separate-dts.patch;
  };

  # Turris Mox specific patches ################################################
  mox_arch = {
    name = "mox-arch-specific";
    patch = null;
    structuredExtraConfig = with lib.kernel; {
      ARCH_MVEBU = yes;
    };
  };

  mvebu_pci_aadvark = {
    # This patch is required to fix PCI for Mox
    name = "mvebu-pci-aadvark";
    patch = ./linux-6.0-pci-aadvark-controller-changes.patch;
  };

  # Generic patches ############################################################
  extra_led_triggers = {
    name = "extra-led-triggers";
    patch = null;
    structuredExtraConfig = with lib.kernel; {
      LEDS_TRIGGER_DISK = yes;
      LEDS_TRIGGER_MTD = yes;
      LEDS_TRIGGER_PANIC = yes;
    };
  };

  builtin_mmc = {
    name = "builtin-mmc";
    patch = null;
    structuredExtraConfig = with lib.kernel; {
      RPMB = yes;
      MMC_BLOCK = yes;
    };
  };
}
