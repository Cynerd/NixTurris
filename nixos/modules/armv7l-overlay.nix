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
        boehmgc = disableCheck super.boehmgc;
        libseccomp = disableCheck super.libseccomp;
        libuv = disableCheck super.libuv;
        elfutils = disableCheck super.elfutils;
        gobject-introspection = disableCheck super.gobject-introspection;
        nlohmann_json = disableCheck super.nlohmann_json;
        openldap = disableCheck super.openldap;

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

        # Overrides to get build to work
        #boehmgc = armv7lDisableCheck nixpkgs.boehmgc;
        #libseccomp = armv7lDisableCheck nixpkgs.libseccomp;
        #libuv = armv7lDisableCheck nixpkgs.libuv;
        #elfutils = armv7lDisableCheck nixpkgs.elfutils;
        #patchelf = armv7lDisableCheck nixpkgs.patchelf;
        #bison = armv7lDisableCheck nixpkgs.bison;
        #findutils = armv7lDisableCheck nixpkgs.findutils;
        #p11-kit = armv7lDisableCheck nixpkgs.p11-kit;
        #glib = armv7lDisableCheck nixpkgs.glib;
        #rustc = armv7lDisableCheck nixpkgs.rustc;
        #mdbook = armv7lDisableCheck nixpkgs.mdbook;
        #ell = armv7lDisableCheck nixpkgs.ell;
        #polkit = armv7lDisableCheck nixpkgs.polkit;
        #udisks2 = disableCheck nixpkgs.udisks2;
        #udisks = udisks2;
        #llvm = armv7lDisableCheck nixpkgs.llvm;
        #llvm_14 = armv7lDisableCheck nixpkgs.llvm_14;
        #jemalloc = armv7lDisableCheck nixpkgs.jemalloc;
        #openssh = armv7lDisableCheck nixpkgs.openssh;
        #nlohmann_json = armv7lDisableCheck nixpkgs.nlohmann_json;
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
