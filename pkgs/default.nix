prev: final: let
  inherit (prev.lib) optional versionOlder;

  kernelPatchesTurris = {
    mvebu_pci_aadvark = {
      # This patch is required to fix PCI for Mox
      name = "mvebu-pci-aadvark";
      patch = ./patches/linux-6.0-pci-aadvark-controller-changes.patch;
    };
    mvebu_pci_omnia_fix = {
      # This is special hack for Turris Omnia as PCI doesn't work with
      # PCIEASPM configuration symbol.
      name = "mvebu-pci-fix";
      patch = null;
      extraStructuredConfig = with final.lib.kernel; {PCIEASPM = no;};
    };
    omnia_separate_dtb = {
      # The long term patch that provides two separate device trees for Turris
      # Omnia. The armada-385-turris-omnia-phy.dtb uses metallic Ethernet and
      # armada-385-turris-omnia-spf uses SFP cage.
      name = "omnia-separate-dtb";
      patch = ./patches/linux-omnia-separate-dts.patch;
    };
    omnia_separate_dtb_6_1 = {
      name = "omnia-separate-dtb";
      patch = ./patches/linux-6.1-omnia-separate-dts.patch;
    };
    extra_led_triggers = {
      name = "extra-led-triggers";
      patch = null;
      extraStructuredConfig = with final.lib.kernel; {
        LEDS_TRIGGER_DISK = yes;
        LEDS_TRIGGER_MTD = yes;
        LEDS_TRIGGER_PANIC = yes;
      };
    };
  };
  overrideMox = kernel:
    kernel.override (oldAttrs: {
      kernelPatches = oldAttrs.kernelPatches ++ (optional (versionOlder kernel.version "6.2") kernelPatchesTurris.mvebu_pci_aadvark);
    });
  overrideOmnia = kernel:
    kernel.override (oldAttrs: {
      kernelPatches =
        oldAttrs.kernelPatches
        ++ [
          kernelPatchesTurris.mvebu_pci_omnia_fix
          (
            if (versionOlder kernel.version "6.5")
            then kernelPatchesTurris.omnia_separate_dtb_6_1
            else kernelPatchesTurris.omnia_separate_dtb
          )
          kernelPatchesTurris.extra_led_triggers
        ];
      features.turrisOmniaSplitDTB = true;
    });

  turrispkgs = {
    # Crypto and certificates
    libatsha204 = final.callPackage ./libatsha204 {};
    mox-otp = final.python3Packages.callPackage ./mox-otp {};
    crypto-wrapper = final.callPackage ./crypto-wrapper {};

    # Kernel patches and board specific kernels
    inherit kernelPatchesTurris;
    # Mox kernels
    linux_turris_mox = overrideMox prev.linux;
    linux_latest_turris_mox = overrideMox prev.linux_latest;
    linux_6_1_turris_mox = overrideMox prev.linux_6_1;
    linux_6_5_turris_mox = overrideMox prev.linux_6_5;
    # Omnia kernels
    linux_turris_omnia = overrideOmnia prev.linux;
    linux_latest_turris_omnia = overrideOmnia prev.linux_latest;
    linux_6_1_turris_omnia = overrideOmnia prev.linux_6_1;
    linux_6_5_turris_omnia = overrideOmnia prev.linux_6_5;

    # NOR Firmware as considered stable by Turris and shipped in Turris OS
    tosFirmwareOmnia = final.callPackage ./tos-firmware {board = "omnia";};
    tosFirmwareMox = final.callPackage ./tos-firmware {board = "mox";};

    # NOR Firmwares build in Nix
    armTrustedFirmwareTurrisMox = prev.buildArmTrustedFirmware rec {
      platform = "a3700";
      extraMeta.platforms = ["aarch64-linux"];
      extraMakeFlags = ["USE_COHERENT_MEM=0" "CM3_SYSTEM_RESET=1" "FIP_ALIGN=0x100"];
      filesToInstall = ["build/${platform}/release/bl31.bin"];
    };
    ubootTurrisMox = prev.buildUBoot {
      defconfig = "turris_mox_defconfig";
      extraMeta.platforms = ["aarch64-linux"];
      filesToInstall = ["u-boot.bin"];
      extraPatches = [./patches/include-configs-turris_mox-increase-space-for-the-ke.patch];
      BL31 = "${turrispkgs.armTrustedFirmwareTurrisMox}/bl31.bin";
    };
    ubootTurrisOmnia = prev.buildUBoot {
      defconfig = "turris_omnia_defconfig";
      extraMeta.platforms = ["armv7l-linux"];
      filesToInstall = ["u-boot-spl.kwb"];
    };

    # Firmware environment tools
    ubootEnvTools = prev.buildUBoot {
      defconfig = "tools-only_defconfig";
      installDir = "$out/bin";
      hardeningDisable = [];
      dontStrip = false;
      extraMeta.platforms = prev.lib.platforms.linux;
      extraMakeFlags = ["envtools"];
      filesToInstall = ["tools/env/fw_printenv"];
      postInstall = ''
        ln -sf fw_printenv $out/bin/fw_setenv
      '';
    };
  };
in
  turrispkgs
