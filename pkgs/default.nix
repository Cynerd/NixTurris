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

    # Crypto
    libatsha204 = callPackage ./libatsha204 { };
    mox-otp = python3Packages.callPackage ./mox-otp { };

    # Overrides to get build to work
    patchelf = armv7lDisableCheck nixpkgs.patchelf;
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
    llvm = armv7lDisableCheck nixpkgs.llvm;
    llvm_14 = armv7lDisableCheck nixpkgs.llvm_14;
    jemalloc = armv7lDisableCheck nixpkgs.jemalloc;

  };

in turrispkgs
