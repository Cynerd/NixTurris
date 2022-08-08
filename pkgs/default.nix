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

  };

in turrispkgs
