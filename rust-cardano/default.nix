{ pkgs ? import (import ../pins/nixpkgs) {}
}:

let
  inherit (pkgs)  stdenv;
  version = "binary";
in
stdenv.mkDerivation {
  name = "rust-cardano-${version}";
  src = ./.;
  installPhase = ''
    echo you need to manually install libcardano_c.so in this directory
    mkdir -p $out/cardano-c
    cp libcardano_c.so $out
    cp cardano-c/cardano.h $out/cardano-c
  '';
}
