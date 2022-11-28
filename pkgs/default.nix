{
  nixpkgs ? <nixpkgs>,
  nixlib ? nixpkgs.lib,
}:
with builtins;
with nixlib; let
  pkgs = nixpkgs // turrispkgs;
  callPackage = callPackageWith pkgs;

  turrispkgs = with pkgs; {
    # Crypto and certificates
    libatsha204 = callPackage ./libatsha204 {};
    mox-otp = python3Packages.callPackage ./mox-otp {};
    crypto-wrapper = callPackage ./crypto-wrapper {};

    # NOR Firmware as considered stable by Turris and shipped in Turris OS
    tosFirmwareOmnia = callPackage ./tos-firmware {board = "omnia";};
    tosFirmwareMox = callPackage ./tos-firmware {board = "mox";};

    # NOR Firmwares build in Nix
    armTrustedFirmwareTurrisMox = buildArmTrustedFirmware rec {
      platform = "a3700";
      extraMeta.platforms = ["aarch64-linux"];
      extraMakeFlags = ["USE_COHERENT_MEM=0" "CM3_SYSTEM_RESET=1" "FIP_ALIGN=0x100"];
      filesToInstall = ["build/${platform}/release/bl31.bin"];
    };
    ubootTurrisMox = buildUBoot {
      defconfig = "turris_mox_defconfig";
      extraMeta.platforms = ["aarch64-linux"];
      filesToInstall = ["u-boot.bin"];
      extraPatches = [./patches/include-configs-turris_mox-increase-space-for-the-ke.patch];
      BL31 = "${armTrustedFirmwareTurrisMox}/bl31.bin";
    };
    ubootTurrisOmnia = buildUBoot {
      defconfig = "turris_omnia_defconfig";
      extraMeta.platforms = ["armv7l-linux"];
      filesToInstall = ["u-boot-spl.kwb"];
    };

    # Firmware environment tools
    ubootEnvTools = buildUBoot {
      defconfig = "tools-only_defconfig";
      installDir = "$out/bin";
      hardeningDisable = [];
      dontStrip = false;
      extraMeta.platforms = lib.platforms.linux;
      extraMakeFlags = ["envtools"];
      filesToInstall = ["tools/env/fw_printenv"];
      postInstall = ''
        ln -sf fw_printenv $out/bin/fw_setenv
      '';
    };

    kernelPatchesTurris = {
      # Linux 5.15 patches
      mvebu_pci_fixes_5_15 = {
        name = "mvebu-pci-fixes";
        patch = ./patches/linux-5.15-mvebu-pci-improvements.patch;
        # Disable devices that conflict with PCI
        extraStructuredConfig = with lib.kernel; {
          PCIEASPM = no;
        };
      };
      mvebu_pci_aadvark_5_15 = {
        name = "mvebu-pci-aadvark-5-15";
        patch = ./patches/linux-5.15-pci-aadvark.patch;
      };
      omnia_leds_5_15 = {
        name = "omnia-leds-5.15";
        patch = ./patches/linux-5.15-omnia-leds.patch;
      };
      omnia_separate_dts_5_15 = {
        name = "omnia-separate-dts-5.15";
        patch = ./patches/linux-5.15-turris-omnia-separate-dts.patch;
      };
      # Linux 6.0 patches
      mvebu_pci_aadvark = {
        name = "mvebu-pci-aadvark";
        patch = ./patches/linux-6.0-pci-aadvark-controller-changes.patch;
      };
    };
    # Kernel with mvebu PCI patches for Turris Omnia
    linux_5_15_turris_omnia = nixpkgs.linux_5_15.override (oldAttrs: {
      kernelPatches = [
        kernelPatchesTurris.mvebu_pci_fixes_5_15
        kernelPatchesTurris.mvebu_pci_aadvark_5_15
        kernelPatchesTurris.omnia_leds_5_15
        kernelPatchesTurris.omnia_separate_dts_5_15
      ];
      features.turrisOmniaSplitDTB = true;
    });
    ## Kernel with PCI patches fixing SError on Turris Mox
    linux_6_0_turris_mox = nixpkgs.linux_6_0.override (oldAttrs: {
      kernelPatches = [kernelPatchesTurris.mvebu_pci_aadvark];
    });
  };
in
  turrispkgs
