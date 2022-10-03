{ stdenv, lib, fetchgit
, bash, openssl
, makeWrapper
, libatsha204, mox-otp
}:
let

  bins = [openssl]
    ++ lib.optional (stdenv.system == "aarch64-linux") mox-otp
    ++ lib.optional (stdenv.system == "armv7l-linux") libatsha204;

in stdenv.mkDerivation rec {
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

  nativeBuildInputs = [ makeWrapper ];


  installPhase = ''
    mkdir -p $out/bin
    makeWrapper crypto-wrapper.sh $out/bin/crypto-wrapper  \
      --prefix PATH : ${lib.makeBinPath bins}
    '';
}
