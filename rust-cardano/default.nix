{ pkgs ? import (import ../pins/nixpkgs) {}
}:

let
  inherit (pkgs) stdenv lib buildPlatform buildRustCrate buildRustCrateHelpers fetchgit;
  #rust-cardano = builtins.filterSource (path: type: type == "*" || baseNameOf path != "*" ) ../../rust-cardano;
  rust-cardano = fetchgit {
        url = https://github.com/input-output-hk/rust-cardano/;
        rev = "646d161b75b5a405f91aedf79e41e45f87d26275";
        sha256 = "0ss2w28xkh451lsmzcmlkdh2cmchyk63c3x8baaaqhmfz9q83s7v";
      };
  cratesIO = (import "${rust-cardano}/crates-io.nix" { inherit lib buildRustCrate buildRustCrateHelpers; });
  cardano-c = (import "${rust-cardano}/Cargo.nix" {
    inherit lib buildPlatform buildRustCrate buildRustCrateHelpers cratesIO fetchgit;
  }).cardano_c {};

  version = "binary";
in
stdenv.mkDerivation {
  name = "rust-cardano-${version}";
  src = ./.;
  installPhase = ''
    mkdir -p $out/cardano-c
    ln -s ${rust-cardano}/cardano-c/cardano.h $out/cardano-c/cardano.h
    ln -s ${cardano-c}/lib/libcardano_c.so $out/libcardano_c.so
  '';
}
