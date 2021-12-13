{ stdenv, lib, fetchgit
, bootstrapHook, pkg-config
, logc, czmq, libevent
}:

stdenv.mkDerivation rec {
  pname = "logc-libs";
  version = "0.1.0";
  meta = with lib; {
    homepage = "https://gitlab.nic.cz/turris/logc-libs";
    description = "Logging for C";
    platforms = with platforms; linux;
    license = licenses.mit;
  };

  src = fetchgit {
    url = "https://gitlab.nic.cz/turris/logc-libs.git";
    rev = "v" + version;
    sha256 = "11b89742k81wbb0mc4r13l2sviz720qgl06v4wnjwlmi9x4pzy1a";
  };

  buildInputs = [logc czmq libevent];
  nativeBuildInputs = [bootstrapHook pkg-config];
}
