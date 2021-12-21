{ stdenv, lib, fetchgit
, bootstrapHook, pkg-config, gperf
, libconfig
, pkgversion ? "0.4.0", pkgsha256 ? "15nplgjgg6dxryy4yzbj4524y77ci0syi970rmbr955m9vxvhrib"
}:

stdenv.mkDerivation rec {
  pname = "logc";
  version = pkgversion;
  meta = with lib; {
    homepage = "https://gitlab.nic.cz/turris/logc";
    description = "Logging for C";
    platforms = with platforms; linux;
    license = licenses.mit;
  };

  src = fetchgit {
    url = "https://gitlab.nic.cz/turris/logc.git";
    rev = "v" + version;
    sha256 = pkgsha256;
  };

  buildInputs = [libconfig];
  nativeBuildInputs = [bootstrapHook pkg-config gperf];
}
