{
  stdenv,
  lib,
  fetchgit,
  pkg-config,
  buildPackages,
  patchelf,
  glibc,
  openssl,
  unbound,
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
  patches = [
    ./0001-Fix-multiple-definitions.patch
    ./0002-Drop-PAGE_SIZE.patch
  ];

  buildInputs = [openssl unbound];
  nativeBuildInputs = [pkg-config patchelf];

  makeFlags = [
    "RELEASE=1"
    "NO_DOC=1"
    "USE_LAYER=USE_LAYER_NI2C"
    "DEFAULT_NI2C_DEV_PATH=NI2C_DEV_PATH_OMNIA"
  ];
  configurePhase = ''
    sed -i 's|/usr/bin/perl|${buildPackages.perl}/bin/perl|' build/embed_gen.pl build/normalize_dep_file.pl
  '';
  installPhase = ''
    mkdir -p $out/usr/include $out/lib $out/bin
    cp src/libatsha204/atsha204.h $out/usr/include/
    cp lib/libatsha204.so* $out/lib
    cp bin/atsha204cmd $out/bin
    patchelf --set-rpath $out/lib:${openssl.out}/lib:${unbound.lib}/lib:${glibc}/lib $out/bin/atsha204cmd
  '';
}
