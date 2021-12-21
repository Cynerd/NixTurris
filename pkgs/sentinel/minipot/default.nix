{ stdenv, lib, fetchgit
, bootstrapHook, pkg-config, gperf
, czmq, msgpack, libevent, base64c, logc-0_1, logc-libs
}:

stdenv.mkDerivation rec {
  pname = "sentinel-minipot";
  version = "2.2";
  meta = with lib; {
    homepage = "https://gitlab.nic.cz/turris/sentinel/minipot";
    description = "Firewall logs collector";
    platforms = with platforms; linux;
    license = licenses.gpl3;
  };

  src = fetchgit {
    url = "https://gitlab.nic.cz/turris/sentinel/minipot.git";
    rev = "v" + version;
    sha256 = "05p2q9mj8bhjapfphlrs45l691dmkpiia6ir1nnpa1pa5jy045p9";
  };

  buildInputs = [czmq msgpack libevent base64c logc-0_1 logc-libs];
  nativeBuildInputs = [bootstrapHook pkg-config gperf];
}
