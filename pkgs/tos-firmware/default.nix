{
  lib,
  stdenvNoCC,
  fetchgit,
  board,
  mtdutils,
  makeWrapper,
}:
stdenvNoCC.mkDerivation rec {
  pname = "tos-firmware-" + board;
  version = "6.0";
  src = fetchgit {
    url = "https://gitlab.nic.cz/turris/os/packages.git";
    rev = "v" + version;
    sha256 = "087gxdvkrykm2ghn23zscq5nw86am4jqf4nj5hzf6bmc6zxgdnhg";
  };

  nativeBuildInputs = [makeWrapper];
  installPhase = ''
    mkdir -p $out/firmware
    cp hardware/${board}/${board}-firmware/files/* $out/firmware
    rm $out/firmware/config.sh

    mkdir -p $out/bin
    install -m 555 ${./turris-firmware-update.sh} $out/bin/turris-firmware-update
    wrapProgram $out/bin/turris-firmware-update \
      --prefix PATH : ${lib.makeBinPath [mtdutils]} \
      --set TURRIS_BOARD "${board}"  \
      --set TURRIS_FIRMWARE "$out/firmware"
  '';

  meta = with lib; {
    homepage = "https://gitlab.nic.cz/turris/os/packages";
    description = "Turris stable firmware for Turris ${board}";
    platforms = platforms.linux;
    license = licenses.gpl3;
  };
}
