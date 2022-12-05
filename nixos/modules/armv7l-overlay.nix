{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  is_native = config.nixpkgs.crossSystem == null && config.nixpkgs.system == "armv7l-linux";
  is_cross = config.nixpkgs.crossSystem != null && config.nixpkgs.crossSystem.system == "armv7l-linux";
in {
  nixpkgs.overlays =
    (optionals is_native [
      (self: super: let
        disableCheck = pkg:
          pkg.overrideAttrs (oldAttrs: {
            doCheck = false;
            doInstallCheck = false;
          });
      in {
        # Overrides to get build to work
        boehmgc = disableCheck super.boehmgc;
        libuv = disableCheck super.libuv;
        dav1d = disableCheck super.dav1d;
        elfutils = disableCheck super.elfutils;
        nlohmann_json = disableCheck super.nlohmann_json;
        gobject-introspection = disableCheck super.gobject-introspection;
        mdbook = disableCheck super.mdbook;
        libseccomp = disableCheck super.libseccomp;
        nix = disableCheck super.nix;

        python310 = super.python310.override {
          packageOverrides = python-self: python-super: let
            noTest = pkg:
              pkg.overrideAttrs (oldAttrs: {
                dontUsePytestCheck = true;
                dontUseSetuptoolsCheck = true;
              });
          in {
            pytest-xdist = noTest python-super.pytest-xdist;
            requests = noTest python-super.requests;
          };
        };
        python310Packages = self.python310.pkgs;
        python = self.python310;
        pythonPackages = self.python.pkgs;
      })
    ])
    ++ (optionals is_cross [
      (self: super: {
        btrfs-progs = super.btrfs-progs.overrideAttrs (oldAttrs: {
          configureFlags = ["--disable-python"];
          installFlags = [];
        });
        pixz = super.pixz.overrideAttrs (oldAttrs: {
          configureFlags = ["--without-manpage"];
          patches = [../../pkgs/patches/0001-configure.ac-replace-AC_CHECK_FILE.patch];
        });
      })
    ]);
}
