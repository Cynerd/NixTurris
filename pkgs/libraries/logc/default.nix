{ stdenv, lib, fetchgit
, bootstrapHook, pkg-config, gperf
, libconfig
, check
}:

stdenv.mkDerivation rec {
  pname = "logc";
  version = "0.4.0";
  meta = with lib; {
    homepage = "https://gitlab.nic.cz/turris/logc";
    description = "Logging for C";
    license = licenses.mit;
  };

  src = fetchgit {
    url = "https://gitlab.nic.cz/turris/logc.git";
    rev = "v" + version;
    sha256 = "15nplgjgg6dxryy4yzbj4524y77ci0syi970rmbr955m9vxvhrib";
  };
  patches = [
    ./0001-configure.ac-fix-cross-compilation.patch
  ];

  buildInputs = [libconfig];
  nativeBuildInputs = [bootstrapHook pkg-config gperf];
  depsBuildBuild = [check];

  doCheck = true;
  doInstallCheck = true;
  configureFlags = lib.optional (stdenv.hostPlatform == stdenv.buildPlatform) "--enable-tests";
}
