{ stdenv, lib, fetchgit
, bootstrapHook, pkg-config, gperf
, logc, logc-libs, libevent, czmq, msgpack, libconfig
, check
}:

stdenv.mkDerivation rec {
  pname = "sentinel-faillogs";
  version = "0.1.0";
  meta = with lib; {
    homepage = "https://gitlab.nic.cz/turris/sentinel/faillogs";
    description = "Failed login attempt logs collector";
    license = licenses.gpl3;
  };

  src = fetchgit {
    url = "https://gitlab.nic.cz/turris/sentinel/faillogs.git";
    rev = "99ec41baed19cc1ca70490b2b8cd81784e7748d2";
    sha256 = "1pp93z78qwg7arca5z70gdp5ja2jldk1rzig8r29a2fhjakd0hb2";
  };

  buildInputs = [logc logc-libs libevent czmq msgpack libconfig];
  nativeBuildInputs = [bootstrapHook pkg-config gperf];
  depsBuildBuild = [check];

  doCheck = true;
  doInstallCheck = true;
  configureFlags = lib.optional (stdenv.hostPlatform == stdenv.buildPlatform) "--enable-tests";
}
