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
    bootstrapHook = callPackage (
      { makeSetupHook, autoconf, autoconf-archive, automake, gettext, libtool }:
      makeSetupHook
        { deps = [ autoconf autoconf-archive automake gettext libtool ]; }
        ./build-support/bootstrap.sh
    ) { };

    logc = callPackage ./libraries/logc { };
    logc-0_1 = logc.overrideAttrs (oldAttrs: rec {
      version = "0.1.0";
      src = fetchgit {
        url = "https://gitlab.nic.cz/turris/logc.git";
        rev = "v" + version;
        sha256 = "1swjzs2249wvnqx2zvxwd7d1z22kd3512xxfvq002cvgbq78ka9a";
      };
      patches = [];
    });
    logc-libs = callPackage ./libraries/logc-libs { };
    base64c = callPackage ./libraries/base64c { };
    paho-mqtt-c = callPackage ./libraries/paho-mqtt-c { };

    sentinel-certgen = python3Packages.callPackage ./sentinel/certgen { };
    #sentinel-dynfw-client = python3Packages.callPackage ./sentinel/dynfw-client { };
    sentinel-proxy = callPackage ./sentinel/proxy { };
    sentinel-minipot = callPackage ./sentinel/minipot { };
    sentinel-fwlogs = callPackage ./sentinel/fwlogs { };
    sentinel-faillogs = callPackage ./sentinel/faillogs { };

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
