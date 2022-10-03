{ nixpkgs ? <nixpkgs>, nixlib ? nixpkgs.lib }:

let
  pkgs = nixpkgs // turrispkgs;
  callPackage = nixlib.callPackageWith pkgs;

  turrispkgs = with pkgs; {

    # Crypto and certificates
    libatsha204 = callPackage ./libatsha204 { };
    mox-otp = python3Packages.callPackage ./mox-otp { };
    crypto-wrapper = callPackage ./crypto-wrapper { };

    # NOR Firmwares
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
      extraPatches = [ ./patches/include-configs-turris_mox-increase-space-for-the-ke.patch ];
      BL31 = "${armTrustedFirmwareTurrisMox}/bl31.bin";
    };
    ubootTurrisOmnia = buildUBoot {
      defconfig = "turris_omnia_defconfig";
      extraMeta.platforms = ["armv7l-linux"];
      filesToInstall = ["u-boot-spl.kwb"];
    };

  };

in turrispkgs
