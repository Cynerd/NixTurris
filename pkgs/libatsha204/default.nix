{ stdenv, lib, fetchgit
, pkg-config, perl, patchelf
,glibc , openssl, unbound
}:

stdenv.mkDerivation rec {
  pname = "libatsha204";
  version = "29.2";
  meta = with lib; {
    homepage = "https://gitlab.nic.cz/turris/libatsha204";
    description = "Turris Atsha204 library and tools";
    platforms = platforms.linux;
    license = licenses.gpl3;
  };

  src = fetchgit {
    url = "https://gitlab.nic.cz/turris/libatsha204.git";
    rev = "v" + version;
    fetchSubmodules = true;
    sha256 = "1lhvqdy2sfbvz9y9lwqhxggpr8rwfd66v73gv9s7b7811r6way20";
  };

  buildInputs = [openssl unbound];
  nativeBuildInputs = [pkg-config perl patchelf];

  makeFlags = [ "RELEASE=1" "NO_DOC=1" ];
  configurePhase = ''
    sed -i 's|/usr/bin/perl|${perl}/bin/perl|' build/embed_gen.pl build/normalize_dep_file.pl
    '';
  installPhase = ''
    mkdir -p $out/usr/include $out/lib $out/bin
    cp src/libatsha204/atsha204.h $out/usr/include/
    cp lib/libatsha204.so* $out/lib
    cp bin/atsha204cmd $out/bin
    patchelf --set-rpath $out/lib:${openssl.out}/lib:${unbound.lib}/lib:${glibc}/lib $out/bin/atsha204cmd
    '';
}
