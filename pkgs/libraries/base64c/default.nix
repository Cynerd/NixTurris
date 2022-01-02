{ stdenv, lib, fetchgit
, bootstrapHook, pkg-config
, check
}:

stdenv.mkDerivation rec {
  pname = "base64c";
  version = "0.2.1";
  meta = with lib; {
    homepage = "https://gitlab.nic.cz/turris/base64c";
    description = "Base64 encoding/decoding library for C";
    license = licenses.mit;
  };

  src = fetchgit {
    url = "https://gitlab.nic.cz/turris/base64c.git";
    rev = "v" + version;
    sha256 = "09qgx2qcni6cmk9mwiis843wgp3f85mh2c3sm0w37ib0bcxdvq7x";
  };

  nativeBuildInputs = [bootstrapHook pkg-config];
  depsBuildBuild = [check];

  doCheck = true;
  doInstallCheck = true;
  configureFlags = lib.optional (stdenv.hostPlatform == stdenv.buildPlatform) "--enable-tests";
}
