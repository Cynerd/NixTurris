final: prev: let
  disableCheck = pkg:
    pkg.overrideAttrs (oldAttrs: {
      doCheck = false;
      doInstallCheck = false;
    });
in {
  # Overrides to get build to work
  boehmgc = disableCheck prev.boehmgc;
  libuv = disableCheck prev.libuv;
  dav1d = disableCheck prev.dav1d;
  elfutils = disableCheck prev.elfutils;
  nlohmann_json = disableCheck prev.nlohmann_json;
  gobject-introspection = disableCheck prev.gobject-introspection;
  mdbook = disableCheck prev.mdbook;
  libseccomp = disableCheck prev.libseccomp;
  nix = disableCheck prev.nix;

  python310 = prev.python310.override {
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
  python310Packages = final.python310.pkgs;
  python = final.python310;
  pythonPackages = final.python.pkgs;
}
