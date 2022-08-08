{ stdenv, lib, fetchgit
, bash
, makeWrapper
}:

stdenv.mkDerivation rec {
  pname = "crypto-wrapper";
  version = "0.4";
  meta = with lib; {
    homepage = "https://gitlab.nic.cz/turris/crypto-wrapper";
    description = "Simple script abstracting access to the Turris crypto backend.";
    platforms = platforms.linux;
    license = licenses.gpl3;
  };

  src = fetchgit {
    url = "https://gitlab.nic.cz/turris/crypto-wrapper.git";
    rev = "v" + version;
    sha256 = "1ly37cajkmgqmlj230h5az9m2m1rgvf4r0bf94yipp80wl0z215s";
  };

  installPhase = ''
    mkdir -p $out/bin
    cp crypto-wrapper.sh $out/bin/crypto-wrapper
    wrapProgram $out/bin/crypto-wrapper  \
      --prefix PATH : ${lib.makeBinPath [ bash openssl coreutils ]}
    '';
}
