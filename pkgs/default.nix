final: prev: let
  inherit (prev.lib) optional versionOlder versionAtLeast;
  inherit (final) kernelPatchesTurris;

  overrideMox = kernel:
    kernel.override (oldAttrs: {
      kernelPatches =
        oldAttrs.kernelPatches
        ++ (optional (versionAtLeast kernel.version "6.12") kernelPatchesTurris.builtin_mmc)
        ++ (optional (versionOlder kernel.version "6.2") kernelPatchesTurris.mvebu_pci_aadvark);
    });
  overrideOmnia = kernel:
    kernel.override (oldAttrs: {
      kernelPatches =
        oldAttrs.kernelPatches
        ++ [
          kernelPatchesTurris.mvebu_pci_omnia_fix
          kernelPatchesTurris.extra_led_triggers
          (
            if (versionOlder kernel.version "6.5")
            then kernelPatchesTurris.omnia_separate_dtb_6_1
            else kernelPatchesTurris.omnia_separate_dtb
          )
        ]
        ++ (optional (versionAtLeast kernel.version "6.12") kernelPatchesTurris.builtin_mmc);
      features.turrisOmniaSplitDTB = true;
    });
in {
  # Crypto and certificates
  libatsha204 = final.callPackage ./libatsha204 {};
  mox-otp = final.python3Packages.callPackage ./mox-otp {};
  crypto-wrapper = final.callPackage ./crypto-wrapper {};

  # Kernel patches and board specific kernels
  kernelPatchesTurris = import ./kernel-patches final.lib;
  # Mox kernels
  linux_turris_mox = overrideMox prev.linux;
  linux_latest_turris_mox = overrideMox prev.linux_latest;
  linux_6_1_turris_mox = overrideMox prev.linux_6_1;
  linux_6_6_turris_mox = overrideMox prev.linux_6_6;
  linux_6_12_turris_mox = overrideMox prev.linux_6_12;
  # Omnia kernels
  linux_turris_omnia = overrideOmnia prev.linux;
  linux_latest_turris_omnia = overrideOmnia prev.linux_latest;
  linux_6_1_turris_omnia = overrideOmnia prev.linux_6_1;
  linux_6_6_turris_omnia = overrideOmnia prev.linux_6_6;
  linux_6_12_turris_omnia = overrideOmnia prev.linux_6_12;

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
    extraPatches = [./uboot-patches/include-configs-turris_mox-increase-space-for-the-ke.patch];
    BL31 = "${final.armTrustedFirmwareTurrisMox}/bl31.bin";
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
}
