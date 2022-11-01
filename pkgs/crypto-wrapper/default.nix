{
  stdenv,
  lib,
  fetchgit,
  bash,
  openssl,
  makeWrapper,
  libatsha204,
  mox-otp,
}: let
  bins =
    [openssl]
    ++ lib.optional (stdenv.system == "aarch64-linux") mox-otp
    ++ lib.optional (stdenv.system == "armv7l-linux") libatsha204;
in
  stdenv.mkDerivation rec {
    pname = "crypto-wrapper";
    version = "0.4.1";
    meta = with lib; {
      homepage = "https://gitlab.nic.cz/turris/crypto-wrapper";
      description = "Simple script abstracting access to the Turris crypto backend.";
      platforms = platforms.linux;
      license = licenses.gpl3;
    };

    src = fetchgit {
      url = "https://gitlab.nic.cz/turris/crypto-wrapper.git";
      rev = "v" + version;
      sha256 = "0p6mj8swj6zzd49aas3b1mb7m6xrvrr534bjw97ggq62vx8r2nci";
    };
    patches = [./0001-Do-not-rely-on-sysinfo-file-that-is-not-available-ou.patch];

    nativeBuildInputs = [makeWrapper];

    installPhase = ''
      mkdir -p $out/bin
      cp crypto-wrapper.sh $out/bin/crypto-wrapper
      wrapProgram $out/bin/crypto-wrapper  \
        --prefix PATH : ${lib.makeBinPath bins} \
        --inherit-argv0
    '';
  }
