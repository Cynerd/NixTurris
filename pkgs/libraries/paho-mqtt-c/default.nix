{ stdenv, lib, fetchurl
, cmake
, openssl
}:

stdenv.mkDerivation rec {
  pname = "paho-mqtt-c";
  version = "1.3.9";
  meta = with lib; {
    homepage = "https://eclipse.org/paho";
    description = "An Eclipse Paho C client library for MQTT";
    license = licenses.epl20;
  };

  src = fetchurl {
    url = "https://github.com/eclipse/paho.mqtt.c/archive/refs/tags/v" + version + ".tar.gz";
    sha256 = "1v9m4mx47bhahzda5sf5zp80shbaizymfbdidm8hsvfgl5grnv1q";
  };

  buildInputs = [openssl];
  nativeBuildInputs = [cmake];

  cmakeFlags = ["-DPAHO_WITH_SSL=TRUE" "-DPAHO_HIGH_PERFORMANCE=TRUE"];
}
