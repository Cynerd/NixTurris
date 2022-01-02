{ stdenv, lib, fetchgit
, bootstrapHook, pkg-config
, logc, czmq, libevent
, check
}:

stdenv.mkDerivation rec {
  pname = "logc-libs";
  version = "0.1.0";
  meta = with lib; {
    homepage = "https://gitlab.nic.cz/turris/logc-libs";
    description = "Logging for C";
    license = licenses.mit;
  };

  src = fetchgit {
    url = "https://gitlab.nic.cz/turris/logc-libs.git";
    rev = "v" + version;
    sha256 = "11b89742k81wbb0mc4r13l2sviz720qgl06v4wnjwlmi9x4pzy1a";
  };

  buildInputs = [logc czmq libevent];
  nativeBuildInputs = [bootstrapHook pkg-config];
  depsBuildBuild = [check];

  doCheck = false; #  TODO the test fails due to errno being set by czmq for some reason
  doInstallCheck = false;
  configureFlags = lib.optional (stdenv.hostPlatform == stdenv.buildPlatform) "--enable-tests";
}
