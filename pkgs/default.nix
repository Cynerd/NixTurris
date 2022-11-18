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
  };
in
  turrispkgs
