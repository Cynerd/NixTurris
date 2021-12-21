{ nixpkgs ? import <nixpkgs> {}}:

let
  pkgs = nixpkgs // turrispkgs;
  callPackage = pkgs.lib.callPackageWith pkgs;

  turrispkgs = with pkgs; {
    bootstrapHook = callPackage (
      { makeSetupHook, autoconf, autoconf-archive, automake, gettext, libtool }:
      makeSetupHook
        { deps = [ autoconf autoconf-archive automake gettext libtool ]; }
        ./build-support/bootstrap.sh
    ) { };

    logc = callPackage ./libraries/logc { };
    logc-0_1 = callPackage ./libraries/logc {
      pkgversion = "0.1.0";
      pkgsha256 = "1swjzs2249wvnqx2zvxwd7d1z22kd3512xxfvq002cvgbq78ka9a";
    };
    logc-libs = callPackage ./libraries/logc-libs { };
    base64c = callPackage ./libraries/base64c { };
    paho-mqtt-c = callPackage ./libraries/paho-mqtt-c { };

    sentinel-proxy = callPackage ./sentinel/proxy { };
    sentinel-minipot = callPackage ./sentinel/minipot { };
    sentinel-fwlogs = callPackage ./sentinel/fwlogs { };
    sentinel-faillogs = callPackage ./sentinel/faillogs { };

  };

in turrispkgs
