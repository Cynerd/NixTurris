{ stdenvNoCC, fetchgit
, board
}:

stdenvNoCC.mkDerivation rec {
  pname = "tos-firmware-" + board;
  version = "6.0";
  src = fetchgit {
    url = "https://gitlab.nic.cz/turris/os/packages.git";
    rev = "v" + version;
    sha256 = "087gxdvkrykm2ghn23zscq5nw86am4jqf4nj5hzf6bmc6zxgdnhg";
  };

  installPhase = ''
    mkdir -p $out
    cp hardware/${board}/${board}-firmware/files/* $out/
    rm $out/config.sh
  '';
}
