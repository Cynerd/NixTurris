{ nixpkgs ? <nixpkgs>, nixlib ? nixpkgs.lib }:

let
  pkgs = nixpkgs // turrispkgs;
  callPackage = nixlib.callPackageWith pkgs;

  disableCheck = pkg: pkg.overrideAttrs (oldAttrs: {
    doCheck = false;
    doInstallCheck = false;
  });
  armv7lDisableCheck = pkg: if nixpkgs.system != "armv7l-linux" then pkg else disableCheck pkg;
  aarch64DisableCheck = pkg: if nixpkgs.system != "aarch64-linux" then pkg else disableCheck pkg;

  turrispkgs = with pkgs; {

    # Crypto and certificates
    libatsha204 = callPackage ./libatsha204 { };
    mox-otp = python3Packages.callPackage ./mox-otp { };
    #crypto-wrapper = callPackage ./crypto-wrapper { };
    #certgen = python3Packages.callPackage ./certgen { };

    # NOR Firmwares
    ubootTurrisMox = buildUBoot {
      defconfig = "turris_mox_defconfig";
      extraMeta.platforms = ["aarch64-linux"];
      filesToInstall = ["u-boot.bin"];
      extraPatches = [ ./patches/include-configs-turris_mox-increase-space-for-the-ke.patch ];
    };
    armTrustedFirmwareTurrisMox = buildArmTrustedFirmware rec {
      platform = "a3700";
      extraMeta.platforms = ["aarch64-linux"];
      extraMakeFlags = ["USE_COHERENT_MEM=0" "CM3_SYSTEM_RESET=1" "FIP_ALIGN=0x100"];
      filesToInstall = ["build/${platform}/release/bl31.bin"];
    };
    ubootTurrisOmnia = buildUBoot {
      defconfig = "turris_omnia_defconfig";
      extraMeta.platforms = ["armv7l-linux"];
      filesToInstall = ["u-boot-spl.kwb"];
    };

  };

in turrispkgs
