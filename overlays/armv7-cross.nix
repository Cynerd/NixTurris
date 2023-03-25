final: prev: {
  btrfs-progs = prev.btrfs-progs.overrideAttrs (oldAttrs: {
    configureFlags = ["--disable-python"];
    installFlags = [];
  });
  pixz = prev.pixz.overrideAttrs (oldAttrs: {
    configureFlags = ["--without-manpage"];
    patches = [../pkgs/patches/0001-configure.ac-replace-AC_CHECK_FILE.patch];
  });

  python310 = prev.python310.override {
    packageOverrides = pyfinal: pyprev: {
      sphinx-rtd-theme = pyprev.sphinx-rtd-theme.overrideAttrs (oldAttrs: {
        nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [pyfinal.pythonRelaxDepsHook];
      });
      sphinxcontrib-jquery = pyprev.sphinxcontrib-jquery.overrideAttrs (oldAttrs: {
        nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [pyfinal.setuptools];
      });
    };
  };
  python310Packages = final.python310.pkgs;
  python = final.python310;
  pythonPackages = final.python.pkgs;
}
