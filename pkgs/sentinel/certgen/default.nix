{ buildPythonApplication, lib, fetchgit
, python3
, ipset
}:

buildPythonApplication rec {
  pname = "sentinel-dynfw-client";
  version = "6.2";
  meta = with lib; {
    homepage = "https://gitlab.nic.cz/turris/sentinel/certgen";
    description = "Sentinel automated passwords and certificates retrieval";
    license = licenses.gpl3;
  };

  src = fetchgit {
    url = "https://gitlab.nic.cz/turris/sentinel/certgen.git";
    rev = "v" + version;
    sha256 = "10ii3j3wqdib7m2fc0w599981mv9q3ahj96q4kyrn5sh18v2c7nb";
  };

  # TODO we are missing crypto-wrapper
  buildInputs = with python3.pkgs; [six requests cryptography];
}
