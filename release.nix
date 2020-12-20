{ pkgs ? (import <nixpkgs> {}) }:

with pkgs;

let
  zipDeriv = name: deriv: pkgs.stdenv.mkDerivation {
    name = "${name}.zip";
    version = deriv.version;

    builder = pkgs.writeScript "build_${name}.zip.sh" ''
      #! ${pkgs.bash}/bin/bash

      if [ ! -d "${deriv}" ]; then
        echo "Derivation ${deriv} is not a directory"
        exit 1
      fi

      cd "${deriv}"
      ${pkgs.zip}/bin/zip -r "$out" .
    '';
  };

  socs = {
    "arty_a7-35t" = (import ./arty.nix) { inherit pkgs; };
  };


in
  linkFarm "tock-litex" (
    lib.mapAttrsToList (name: deriv: { name = "${name}.zip"; path = zipDeriv name deriv; }) socs
  )
