lib: {
  # Turris Omnia specific patches ##############################################
  omnia_arch_only = {
    name = "mvebu-arch-only";
    patch = null;
    structuredExtraConfig = with lib.kernel; {
      ARCH_ACTIONS = no;
      ARCH_AIROHA = no;
      ARCH_ALPINE = no;
      ARCH_ARTPEC = no;
      ARCH_ASPEED = no;
      ARCH_AT91 = no;
      ARCH_BCM = no;
      ARCH_BERLIN = no;
      ARCH_DIGICOLOR = no;
      ARCH_DOVE = no;
      ARCH_EXYNOS = no;
      ARCH_HIGHBANK = no;
      ARCH_HISI = no;
      ARCH_HPE = no;
      ARCH_INTEL_SOCFPGA = no;
      ARCH_KEYSTONE = no;
      ARCH_MEDIATEK = no;
      ARCH_MESON = no;
      ARCH_MILBEAUT = no;
      ARCH_MMP = no;
      ARCH_MXC = no;
      ARCH_NPCM = no;
      ARCH_OMAP3 = no;
      ARCH_OMAP4 = no;
      ARCH_QCOM = no;
      ARCH_REALTEK = no;
      ARCH_RENESAS = no;
      ARCH_ROCKCHIP = no;
      ARCH_S5PV210 = no;
      ARCH_STI = no;
      ARCH_STM32 = no;
      ARCH_SUNPLUS = no;
      ARCH_SUNXI = no;
      ARCH_TEGRA = no;
      ARCH_U8500 = no;
      ARCH_UNIPHIER = no;
      ARCH_VEXPRESS = no;
      ARCH_VIRT = no;
      ARCH_WM8850 = no;
      ARCH_ZYNQ = no;
      PLAT_SPEAR = no;
      SOC_AM33XX = no;
      SOC_AM43XX = no;
      SOC_DRA7XX = no;
      SOC_OMAP5 = no;

      MACH_ARMADA_370 = no;
      MACH_ARMADA_375 = no;
      MACH_ARMADA_39X = no;
      MACH_ARMADA_XP = no;
      MACH_DOVE = no;
    };
  };

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
  mox_arch_only = {
    name = "mvebu-arch-only";
    patch = null;
    structuredExtraConfig = with lib.kernel; {
      # TODO not every platform is disabled as some of the collide with other
      # configuration options.
      ARCH_ACTIONS = no;
      ARCH_ALPINE = no;
      ARCH_APPLE = no;
      ARCH_BCM2835 = no;
      ARCH_BCMBCA = no;
      ARCH_BCM_IPROC = no;
      ARCH_BERLIN = no;
      ARCH_BRCMSTB = no;
      ARCH_EXYNOS = no;
      ARCH_HISI = no;
      ARCH_INTEL_SOCFPGA = no;
      ARCH_K3 = no;
      ARCH_KEEMBAY = no;
      ARCH_LG1K = no;
      ARCH_MESON = no;
      ARCH_MXC = no;
      ARCH_NPCM = no;
      ARCH_QCOM = no;
      ARCH_REALTEK = no;
      ARCH_RENESAS = no;
      ARCH_S32 = no;
      ARCH_SEATTLE = no;
      ARCH_SPARX5 = no;
      ARCH_SPRD = no;
      ARCH_SYNQUACER = no;
      ARCH_THUNDER = no;
      ARCH_THUNDER2 = no;
      ARCH_UNIPHIER = no;
      ARCH_VEXPRESS = no;
      ARCH_VISCONTI = no;
      ARCH_XGENE = no;
      ARCH_ZYNQMP = no;
      #ARCH_MEDIATEK = no;
      #ARCH_NXP = no;
      #ARCH_LAYERSCAPE = no;
      #ARCH_BCM = no;
      #ARCH_ROCKCHIP = no;
      #ARCH_SUNXI = no;
      #ARCH_TEGRA = no;
    };
  };
  mox_arch_only_6_6 = {
    name = "mvebu-arch-only-6.6";
    patch = null;
    structuredExtraConfig = with lib.kernel; {
      ARCH_MA35 = no;
      ARCH_STM32 = no;
    };
  };
  mox_arch_only_6_12 = {
    name = "mvebu-arch-only-6.12";
    patch = null;
    structuredExtraConfig = with lib.kernel; {
      ARCH_AIROHA = no;
    };
  };
  mox_arch_only_6_16 = {
    name = "mvebu-arch-only-6.16";
    patch = null;
    structuredExtraConfig = with lib.kernel; {
      ARCH_BLAIZE = no;
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
