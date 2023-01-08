{nixpkgs}:
with builtins;
with nixpkgs.lib; let
  callPackage = nixpkgs.newScope turrispkgs;
  turrispkgs = {
    # Crypto and certificates
    libatsha204 = callPackage ./libatsha204 {};
    mox-otp = nixpkgs.python3Packages.callPackage ./mox-otp {};
    crypto-wrapper = callPackage ./crypto-wrapper {};

    # Kernel patches and board specific kernels
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
        extraStructuredConfig = with nixpkgs.lib.kernel; {PCIEASPM = no;};
      };
      omnia_separate_dtb = {
        # The long term patch that provides two separate device trees for Turris
        # Omnia. The armada-385-turris-omnia-phy.dtb uses metallic Ethernet and
        # armada-385-turris-omnia-spf uses SFP cage.
        name = "omnia-separate-dtb";
        patch = ./patches/linux-omnia-separate-dts.patch;
      };
    };
    linux_6_0_turris_omnia = nixpkgs.linux_6_0.override (oldAttrs: {
      kernelPatches = [
        turrispkgs.kernelPatchesTurris.mvebu_pci_omnia_fix
        turrispkgs.kernelPatchesTurris.omnia_separate_dtb
      ];
      features.turrisOmniaSplitDTB = true;
    });
    linux_6_1_turris_omnia = nixpkgs.linux_6_1.override (oldAttrs: {
      kernelPatches = [
        turrispkgs.kernelPatchesTurris.mvebu_pci_omnia_fix
        turrispkgs.kernelPatchesTurris.omnia_separate_dtb
      ];
      features.turrisOmniaSplitDTB = true;
    });
    linux_6_0_turris_mox = nixpkgs.linux_6_0.override (oldAttrs: {
      kernelPatches = [turrispkgs.kernelPatchesTurris.mvebu_pci_aadvark];
    });
    linux_6_1_turris_mox = nixpkgs.linux_6_1.override (oldAttrs: {
      kernelPatches = [turrispkgs.kernelPatchesTurris.mvebu_pci_aadvark];
    });

    # NOR Firmware as considered stable by Turris and shipped in Turris OS
    tosFirmwareOmnia = callPackage ./tos-firmware {board = "omnia";};
    tosFirmwareMox = callPackage ./tos-firmware {board = "mox";};

    # NOR Firmwares build in Nix
    armTrustedFirmwareTurrisMox = nixpkgs.buildArmTrustedFirmware rec {
      platform = "a3700";
      extraMeta.platforms = ["aarch64-linux"];
      extraMakeFlags = ["USE_COHERENT_MEM=0" "CM3_SYSTEM_RESET=1" "FIP_ALIGN=0x100"];
      filesToInstall = ["build/${platform}/release/bl31.bin"];
    };
    ubootTurrisMox = nixpkgs.buildUBoot {
      defconfig = "turris_mox_defconfig";
      extraMeta.platforms = ["aarch64-linux"];
      filesToInstall = ["u-boot.bin"];
      extraPatches = [./patches/include-configs-turris_mox-increase-space-for-the-ke.patch];
      BL31 = "${armTrustedFirmwareTurrisMox}/bl31.bin";
    };
    ubootTurrisOmnia = nixpkgs.buildUBoot {
      defconfig = "turris_omnia_defconfig";
      extraMeta.platforms = ["armv7l-linux"];
      filesToInstall = ["u-boot-spl.kwb"];
    };

    # Firmware environment tools
    ubootEnvTools = nixpkgs.buildUBoot {
      defconfig = "tools-only_defconfig";
      installDir = "$out/bin";
      hardeningDisable = [];
      dontStrip = false;
      extraMeta.platforms = nixpkgs.lib.platforms.linux;
      extraMakeFlags = ["envtools"];
      filesToInstall = ["tools/env/fw_printenv"];
      postInstall = ''
        ln -sf fw_printenv $out/bin/fw_setenv
      '';
    };
  };
in
  turrispkgs
