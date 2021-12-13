{ stdenv, lib, fetchgit
, bootstrapHook, pkg-config
, czmq, msgpack, logc-0_1, logc-libs, libconfig, libnetfilter_log
}:

stdenv.mkDerivation rec {
  pname = "sentinel-proxy";
  version = "0.2.0";
  meta = with lib; {
    homepage = "https://gitlab.nic.cz/turris/sentinel/fwlogs";
    description = "Firewall logs collector";
    platforms = with platforms; linux;
    license = licenses.gpl3;
  };

  src = fetchgit {
    url = "https://gitlab.nic.cz/turris/sentinel/fwlogs.git";
    rev = "v" + version;
    sha256 = "04rlm3mlri2wz33z6jh2yh0p81lnrfpfmmfjrn4sfjwh1g21ins7";
  };

  buildInputs = [czmq msgpack logc-0_1 logc-libs libconfig libnetfilter_log];
  nativeBuildInputs = [bootstrapHook pkg-config];
}
