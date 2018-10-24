{ pkgs ? import (import ../pins/nixpkgs) {}
, rust-cardano ? pkgs.callPackage ../rust-cardano {}
, racket2nix ? import (import ../pins/racket2nix) {}
}:

let
  inherit (pkgs) libtool stdenv swig;
  inherit (racket2nix) buildRacketPackage;
in

let src = stdenv.mkDerivation {
  name = "rust-cardano-bindings";
  nativeBuildInputs = [ libtool swig rust-cardano ];
  src = ./.;
  buildPhase = ''
    for i in $(cd ${rust-cardano.out}/; find cardano-c -name '*.h'); do
      mkdir -p ''${i%/*}
      i_base=''${i##*/}
      i_base_under=''${i_base//-/_}
      cat > ''${i%.h}.i <<EOF
    %module ''${i_base_under%.h}
    %{
    #include <$i>
    %}

    %include <$i>
    EOF
    swig -I${rust-cardano.out} -mzscheme -declaremodule ''${i%.h}.i
    done
  '';

  installPhase = ''
    extensions=$(find cardano-c -name '*_wrap.c')
    for i in $extensions; do
      mkdir -p $out/''${i%/*}
      cp $i $out/''$i
    done
    cat > $out/install.rkt <<EOF
    #lang racket

    (require make/setup-extension)
    (require dynext)

    (provide pre-installer)

    (define extensions (string-split "$extensions"))

    (define (pre-installer collections-top-path collection-path)
      (for [(extension extensions)]
        (eprintf "extension '~a'~n" extension)
        (pre-install collection-path
                     (build-path collection-path "private")
                     extension
                     "."
                     '() '() '() '() '() '()
                     (lambda (thunk) (thunk)))))
    EOF
    cp info.rkt $out
  '';
}; in

buildRacketPackage src
