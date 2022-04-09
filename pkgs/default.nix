{ nixpkgs ? <nixpkgs>, nixlib ? nixpkgs.lib }:

let
  pkgs = nixpkgs // turrispkgs;
  callPackage = nixlib.callPackageWith pkgs;

  armv7lDisableCheck = pkg: if nixpkgs.system != "armv7l-linux" then pkg
    else pkg.overrideAttrs (oldAttrs: {
      doCheck = false;
      doInstallCheck = false;
    }); 

  turrispkgs = with pkgs; {

    # Crypto
    libatsha204 = callPackage ./libatsha204 { };

    # Overrides to get armv7 to work
    bison = armv7lDisableCheck nixpkgs.bison;
    findutils = armv7lDisableCheck nixpkgs.findutils;
    libuv = armv7lDisableCheck nixpkgs.libuv;
    p11-kit = armv7lDisableCheck nixpkgs.p11-kit;
    elfutils = armv7lDisableCheck nixpkgs.elfutils;
    glib = armv7lDisableCheck nixpkgs.glib;
    rustc = armv7lDisableCheck nixpkgs.rustc;
    mdbook = armv7lDisableCheck nixpkgs.mdbook;
    ell = armv7lDisableCheck nixpkgs.ell;
    polkit = armv7lDisableCheck nixpkgs.polkit;
    udisks2 = armv7lDisableCheck nixpkgs.udisks2;
    udisks = udisks2;

  };

in turrispkgs
