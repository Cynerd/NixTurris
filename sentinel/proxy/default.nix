{ stdenv, lib, fetchgit
, autoconf, autoconf-archive, automake, libtool, pkgconfig, gperf
, openssl, zlib, czmq, libconfig, msgpack, paho-mqtt-c
}:

stdenv.mkDerivation rec {
  pname = "sentinel-proxy";
  version = "1.4";
  meta = with lib; {
    homepage = "https://gitlab.nic.cz/turris/sentinel/proxy";
    description = "Main MQTT Sentinel client. Proxy that lives on the router and relays messages received from ZMQ to uplink server over MQTT channel.";
    platforms = with platforms; linux;
    license = licenses.gpl3;
  };

  src = fetchgit {
    url = "https://gitlab.nic.cz/turris/sentinel/proxy.git";
    rev = "v" + version;
    sha256 = "11s538yf4ydlzlx1vs9fc6hh9igf40s3v853mlcki8a28bni6xwb";
  };

  buildInputs = [openssl zlib czmq libconfig msgpack paho-mqtt-c];
  nativeBuildInputs = [
    autoconf autoconf-archive automake libtool pkgconfig gperf
  ];

  preConfigure = "./bootstrap";
}
